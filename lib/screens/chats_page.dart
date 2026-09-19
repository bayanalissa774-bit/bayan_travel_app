import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';

import 'chat_conversation_page.dart';
import 'dashboard_page.dart';
import 'profile_page.dart';
import 'saved_page.dart';
import 'schedule_page.dart';

bool _isDark(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

Color _pageBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF101418) : const Color(0xFFF7F9FC);
}

Color _cardBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF1B2229) : Colors.white;
}

Color _primaryText(BuildContext context) {
  return _isDark(context) ? const Color(0xFFF4F7F9) : AppColors.blackText;
}

Color _secondaryText(BuildContext context) {
  return _isDark(context) ? const Color(0xFF9EA9B2) : AppColors.greyText;
}

Color _borderColor(BuildContext context) {
  return _isDark(context) ? const Color(0xFF2B343C) : const Color(0xFFE7ECF1);
}

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  static const String databaseUrl =
      'https://bayan-travel-app-2026-default-rtdb.europe-west1.firebasedatabase.app';

  final TextEditingController searchController = TextEditingController();

  StreamSubscription<DatabaseEvent>? usersSubscription;

  final Map<String, StreamSubscription<DatabaseEvent>>
      conversationSubscriptions = {};

  List<_ChatUser> users = [];

  bool isLoading = true;
  String searchText = '';

  User? get currentUser => FirebaseAuth.instance.currentUser;

  FirebaseDatabase get database {
    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    );
  }

  @override
  void initState() {
    super.initState();
    startChatSystem();
  }

  @override
  void dispose() {
    searchController.dispose();
    usersSubscription?.cancel();

    for (final subscription in conversationSubscriptions.values) {
      subscription.cancel();
    }

    super.dispose();
  }

  Future<void> startChatSystem() async {
    final User? user = currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    try {
      await createPublicProfile(user);
      listenToUsers();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage(
        'Could not start chat.',
        error: true,
      );

      debugPrint(
        'Chat startup error: $error',
      );
    }
  }

  Future<void> createPublicProfile(
    User user,
  ) async {
    final String displayName = (user.displayName ?? '').trim();

    final String name = displayName.isNotEmpty
        ? displayName
        : (user.email ?? 'Traveler').split('@').first;

    await database.ref('publicUsers/${user.uid}').update({
      'uid': user.uid,
      'name': name,
      'email': user.email ?? '',
      'imageUrl': '',
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void listenToUsers() {
    final User? user = currentUser;

    if (user == null) {
      return;
    }

    final DatabaseReference reference = database.ref('publicUsers');

    usersSubscription = reference.onValue.listen(
      (DatabaseEvent event) async {
        final Object? value = event.snapshot.value;

        final List<_ChatUser> loadedUsers = [];

        if (value is Map) {
          final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
            value,
          );

          data.forEach(
            (key, value) {
              final String uid = key.toString();

              if (uid == user.uid) {
                return;
              }

              if (value is! Map) {
                return;
              }

              final Map<dynamic, dynamic> item = Map<dynamic, dynamic>.from(
                value,
              );

              loadedUsers.add(
                _ChatUser(
                  uid: uid,
                  name: item['name']?.toString() ?? 'Traveler',
                  email: item['email']?.toString() ?? '',
                  imageUrl: item['imageUrl']?.toString() ?? '',
                ),
              );
            },
          );
        }

        for (final subscription in conversationSubscriptions.values) {
          await subscription.cancel();
        }

        conversationSubscriptions.clear();

        if (!mounted) return;

        setState(() {
          users = loadedUsers;
          isLoading = false;
        });

        for (final chatUser in loadedUsers) {
          listenToConversation(chatUser);
        }
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        showMessage(
          'Could not load travelers.',
          error: true,
        );
      },
    );
  }

  String conversationIdFor(
    String otherUid,
  ) {
    final String? myUid = currentUser?.uid;

    if (myUid == null) {
      return '';
    }

    final List<String> ids = [
      myUid,
      otherUid,
    ]..sort();

    return '${ids[0]}_${ids[1]}';
  }

  Future<void> listenToConversation(
    _ChatUser chatUser,
  ) async {
    final User? me = currentUser;

    if (me == null) {
      return;
    }

    final String conversationId = conversationIdFor(chatUser.uid);

    if (conversationId.isEmpty) {
      return;
    }

    final List<String> participantIds = [
      me.uid,
      chatUser.uid,
    ]..sort();

    final DatabaseReference reference = database.ref(
      'conversations/$conversationId',
    );

    try {
      await reference.update({
        'participant1': participantIds[0],
        'participant2': participantIds[1],
      });

      conversationSubscriptions[chatUser.uid] = reference.onValue.listen(
        (DatabaseEvent event) {
          final Object? value = event.snapshot.value;

          if (value is! Map) {
            return;
          }

          final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
            value,
          );

          final String lastMessage = data['lastMessage']?.toString() ?? '';

          final int updatedAt =
              data['updatedAt'] is num ? (data['updatedAt'] as num).toInt() : 0;

          if (!mounted) return;

          final int index = users.indexWhere(
            (item) => item.uid == chatUser.uid,
          );

          if (index < 0) {
            return;
          }

          final List<_ChatUser> updated = List<_ChatUser>.from(users);

          updated[index] = updated[index].copyWith(
            lastMessage: lastMessage,
            updatedAt: updatedAt,
          );

          updated.sort(
            (a, b) => b.updatedAt.compareTo(
              a.updatedAt,
            ),
          );

          setState(() {
            users = updated;
          });
        },
      );
    } catch (error) {
      debugPrint(
        'Conversation listen error: $error',
      );
    }
  }

  void openConversation(
    _ChatUser user,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatConversationPage(
          otherUserId: user.uid,
          name: user.name,
          imageUrl: user.imageUrl,
        ),
      ),
    );
  }

  void openHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const DashboardPage(),
      ),
    );
  }

  void openSchedule() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SchedulePage(),
      ),
    );
  }

  void openSaved() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedPage(),
      ),
    );
  }

  void openProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  void showMessage(
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            error ? const Color(0xFFE34A4A) : const Color(0xFF1FA66A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  String formatTime(
    int milliseconds,
  ) {
    if (milliseconds == 0) {
      return '';
    }

    final DateTime date = DateTime.fromMillisecondsSinceEpoch(
      milliseconds,
    );

    final DateTime now = DateTime.now();

    final DateTime today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final DateTime messageDay = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final int difference = today.difference(messageDay).inDays;

    if (difference == 0) {
      final int hour = date.hour > 12
          ? date.hour - 12
          : date.hour == 0
              ? 12
              : date.hour;

      final String minute = date.minute.toString().padLeft(2, '0');

      final String period = date.hour >= 12 ? 'PM' : 'AM';

      return '$hour:$minute $period';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    return '${date.day}/${date.month}';
  }

  List<_ChatUser> get filteredUsers {
    final String query = searchText.trim().toLowerCase();

    if (query.isEmpty) {
      return users;
    }

    return users.where(
      (user) {
        return user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query);
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Color pageColor = _pageBackground(context);

    final List<_ChatUser> shownUsers = filteredUsers;

    return Scaffold(
      backgroundColor: pageColor,
      body: PhonePage(
        backgroundColor: pageColor,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  16,
                  18,
                  12,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    17,
                    18,
                    17,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF087BEA),
                        Color(0xFF55B5F5),
                        Color(0xFF8B7CF6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      28,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x260078DC),
                        blurRadius: 22,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: Color(0x30FFFFFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.forum_rounded,
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bayan Chat',
                              style: GoogleFonts.fredoka(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Meet travelers and share your journey',
                              style: TextStyle(
                                color: Color(0xE6FFFFFF),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x26FFFFFF),
                          borderRadius: BorderRadius.circular(
                            18,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Private',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  4,
                  18,
                  14,
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 10.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search travelers...',
                    hintStyle: TextStyle(
                      color: _secondaryText(
                        context,
                      ),
                      fontSize: 10,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primaryBlue,
                      size: 19,
                    ),
                    suffixIcon: searchText.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();

                              setState(
                                () {
                                  searchText = '';
                                },
                              );
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              color: _secondaryText(
                                context,
                              ),
                              size: 17,
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: _cardBackground(
                      context,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        22,
                      ),
                      borderSide: BorderSide(
                        color: _borderColor(
                          context,
                        ),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        22,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.primaryBlue,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  21,
                  1,
                  21,
                  11,
                ),
                child: Row(
                  children: [
                    Text(
                      'Travelers',
                      style: GoogleFonts.fredoka(
                        color: _primaryText(
                          context,
                        ),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (!isLoading)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _isDark(context)
                              ? const Color(0xFF173653)
                              : const Color(0xFFEAF4FF),
                          borderRadius: BorderRadius.circular(
                            15,
                          ),
                        ),
                        child: Text(
                          '${shownUsers.length} people',
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : shownUsers.isEmpty
                        ? const _NoUsers()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              18,
                              0,
                              18,
                              18,
                            ),
                            itemCount: shownUsers.length,
                            separatorBuilder: (
                              context,
                              index,
                            ) =>
                                const SizedBox(
                              height: 10,
                            ),
                            itemBuilder: (
                              context,
                              index,
                            ) {
                              final _ChatUser user = shownUsers[index];

                              return _UserChatCard(
                                user: user,
                                time: formatTime(
                                  user.updatedAt,
                                ),
                                onPressed: () {
                                  openConversation(
                                    user,
                                  );
                                },
                              );
                            },
                          ),
              ),
              _ChatBottomNavigation(
                onHome: openHome,
                onSchedule: openSchedule,
                onSaved: openSaved,
                onProfile: openProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserChatCard extends StatelessWidget {
  const _UserChatCard({
    required this.user,
    required this.time,
    required this.onPressed,
  });

  final _ChatUser user;
  final String time;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool hasMessage = user.lastMessage.trim().isNotEmpty;

    final String subtitle = hasMessage
        ? user.lastMessage
        : user.email.isNotEmpty
            ? user.email
            : 'Start a conversation';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cardBackground(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _borderColor(context),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 13,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _ChatAvatar(
                    name: user.name,
                    imageUrl: user.imageUrl,
                    radius: 27,
                  ),
                  Positioned(
                    right: -1,
                    bottom: 1,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF25B779),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _cardBackground(
                            context,
                          ),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.fredoka(
                              color: _primaryText(
                                context,
                              ),
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (time.isNotEmpty)
                          Text(
                            time,
                            style: TextStyle(
                              color: _secondaryText(
                                context,
                              ),
                              fontSize: 7.5,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _secondaryText(
                                context,
                              ),
                              fontSize: 9,
                            ),
                          ),
                        ),
                        if (hasMessage) ...[
                          const SizedBox(width: 7),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _isDark(context)
                      ? const Color(0xFF173653)
                      : const Color(0xFFEAF4FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.primaryBlue,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoUsers extends StatelessWidget {
  const _NoUsers();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: _isDark(context)
                    ? const Color(0xFF173653)
                    : const Color(0xFFEAF4FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group_outlined,
                color: AppColors.primaryBlue,
                size: 42,
              ),
            ),
            const SizedBox(height: 17),
            Text(
              'No travelers yet',
              style: GoogleFonts.fredoka(
                color: _primaryText(context),
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'When another Bayan user opens Messages,\nthey will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText(
                  context,
                ),
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({
    required this.name,
    required this.imageUrl,
    required this.radius,
  });

  final String name;
  final String imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final String letter =
        name.trim().isEmpty ? 'B' : name.trim().substring(0, 1).toUpperCase();

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF087BEA),
            Color(0xFF8B7CF6),
            Color(0xFFFFA35B),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: ClipOval(
          child: imageUrl.trim().isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return _AvatarLetter(
                      letter: letter,
                    );
                  },
                )
              : _AvatarLetter(
                  letter: letter,
                ),
        ),
      ),
    );
  }
}

class _AvatarLetter extends StatelessWidget {
  const _AvatarLetter({
    required this.letter,
  });

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: _cardBackground(context),
      child: Text(
        letter,
        style: GoogleFonts.fredoka(
          color: AppColors.primaryBlue,
          fontSize: 21,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ChatBottomNavigation extends StatelessWidget {
  const _ChatBottomNavigation({
    required this.onHome,
    required this.onSchedule,
    required this.onSaved,
    required this.onProfile,
  });

  final VoidCallback onHome;
  final VoidCallback onSchedule;
  final VoidCallback onSaved;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.fromLTRB(
        11,
        6,
        11,
        7,
      ),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        border: Border(
          top: BorderSide(
            color: _borderColor(context),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ChatNavItem(
              icon: Icons.home_outlined,
              label: 'Home',
              onPressed: onHome,
            ),
          ),
          const Expanded(
            child: _ChatNavItem(
              icon: Icons.chat_bubble_rounded,
              label: 'Chat',
              selected: true,
            ),
          ),
          Expanded(
            child: _ChatNavItem(
              icon: Icons.calendar_month_outlined,
              label: 'Schedule',
              onPressed: onSchedule,
            ),
          ),
          Expanded(
            child: _ChatNavItem(
              icon: Icons.favorite_border_rounded,
              label: 'Saved',
              onPressed: onSaved,
            ),
          ),
          Expanded(
            child: _ChatNavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              onPressed: onProfile,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatNavItem extends StatelessWidget {
  const _ChatNavItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: selected ? null : onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: selected
                ? _isDark(context)
                    ? const Color(0xFF173653)
                    : const Color(0xFFEAF4FF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(
              18,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected
                    ? AppColors.primaryBlue
                    : _secondaryText(
                        context,
                      ),
                size: 20,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? AppColors.primaryBlue
                      : _secondaryText(
                          context,
                        ),
                  fontSize: 7.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatUser {
  const _ChatUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.imageUrl,
    this.lastMessage = '',
    this.updatedAt = 0,
  });

  final String uid;
  final String name;
  final String email;
  final String imageUrl;
  final String lastMessage;
  final int updatedAt;

  _ChatUser copyWith({
    String? lastMessage,
    int? updatedAt,
  }) {
    return _ChatUser(
      uid: uid,
      name: name,
      email: email,
      imageUrl: imageUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
