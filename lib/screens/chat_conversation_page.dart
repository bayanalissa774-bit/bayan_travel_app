import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';

bool _isDark(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

Color _pageBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF101418) : const Color(0xFFF6F8FB);
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
  return _isDark(context) ? const Color(0xFF2B343C) : const Color(0xFFE6EBF0);
}

class ChatConversationPage extends StatefulWidget {
  const ChatConversationPage({
    super.key,
    required this.name,
    required this.imageUrl,
    this.otherUserId,
  });

  final String name;
  final String imageUrl;

  // Nullable حتى ما نخرب أي استدعاء قديم للصفحة.
  final String? otherUserId;

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  static const String databaseUrl =
      'https://bayan-travel-app-2026-default-rtdb.europe-west1.firebasedatabase.app';

  final TextEditingController messageController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  StreamSubscription<DatabaseEvent>? messagesSubscription;

  DatabaseReference? conversationReference;

  final List<_Message> messages = [];

  bool isLoading = true;
  bool isSending = false;

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

    setupConversation();
  }

  @override
  void dispose() {
    messagesSubscription?.cancel();
    messageController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  String get conversationId {
    final String? myUid = currentUser?.uid;

    final String? otherUid = widget.otherUserId;

    if (myUid == null || otherUid == null || otherUid.isEmpty) {
      return '';
    }

    final List<String> ids = [
      myUid,
      otherUid,
    ]..sort();

    return '${ids[0]}_${ids[1]}';
  }

  Future<void> setupConversation() async {
    final User? me = currentUser;
    final String? otherUid = widget.otherUserId;

    if (me == null || otherUid == null || otherUid.isEmpty) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        showMessage(
          'This contact is not linked to a Bayan user.',
          error: true,
        );
      }

      return;
    }

    final List<String> ids = [
      me.uid,
      otherUid,
    ]..sort();

    conversationReference = database.ref(
      'conversations/$conversationId',
    );

    try {
      await conversationReference!.update({
        'participant1': ids[0],
        'participant2': ids[1],
      });

      messagesSubscription =
          conversationReference!.child('messages').onValue.listen(
        (DatabaseEvent event) {
          final Object? value = event.snapshot.value;

          final List<_Message> loaded = [];

          if (value is Map) {
            final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
              value,
            );

            data.forEach(
              (key, value) {
                if (value is! Map) {
                  return;
                }

                final Map<dynamic, dynamic> item = Map<dynamic, dynamic>.from(
                  value,
                );

                loaded.add(
                  _Message(
                    id: key.toString(),
                    text: item['text']?.toString() ?? '',
                    senderId: item['senderId']?.toString() ?? '',
                    senderName: item['senderName']?.toString() ?? '',
                    createdAt: item['createdAt'] is num
                        ? (item['createdAt'] as num).toInt()
                        : 0,
                  ),
                );
              },
            );
          }

          loaded.sort(
            (a, b) => a.createdAt.compareTo(
              b.createdAt,
            ),
          );

          if (!mounted) return;

          setState(() {
            messages
              ..clear()
              ..addAll(loaded);

            isLoading = false;
          });

          scrollToBottom();
        },
        onError: (error) {
          if (!mounted) return;

          setState(() {
            isLoading = false;
          });

          showMessage(
            'Could not load messages.',
            error: true,
          );
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage(
        'Could not open conversation.',
        error: true,
      );

      debugPrint(
        'Conversation setup error: $error',
      );
    }
  }

  Future<void> sendMessage() async {
    if (isSending) {
      return;
    }

    final String text = messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    final User? me = currentUser;

    if (me == null || conversationReference == null) {
      showMessage(
        'Please log in again.',
        error: true,
      );
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      final DatabaseReference messageRef =
          conversationReference!.child('messages').push();

      final String? messageId = messageRef.key;

      if (messageId == null) {
        throw Exception(
          'Could not create message.',
        );
      }

      final int now = DateTime.now().millisecondsSinceEpoch;

      await conversationReference!.update({
        'messages/$messageId': {
          'id': messageId,
          'text': text,
          'senderId': me.uid,
          'senderName': me.displayName ?? me.email ?? 'Traveler',
          'createdAt': now,
        },
        'lastMessage': text,
        'lastSenderId': me.uid,
        'updatedAt': now,
      });

      messageController.clear();

      scrollToBottom();
    } on FirebaseException catch (error) {
      if (!mounted) return;

      showMessage(
        'Firebase error: ${error.message ?? error.code}',
        error: true,
      );
    } catch (error) {
      if (!mounted) return;

      showMessage(
        'Could not send message.',
        error: true,
      );

      debugPrint(
        'Send message error: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!scrollController.hasClients) {
          return;
        }

        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(
            milliseconds: 250,
          ),
          curve: Curves.easeOut,
        );
      },
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
      ),
    );
  }

  String formatTime(int milliseconds) {
    if (milliseconds == 0) {
      return '';
    }

    final DateTime date = DateTime.fromMillisecondsSinceEpoch(
      milliseconds,
    );

    final int hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
            ? 12
            : date.hour;

    final String minute = date.minute.toString().padLeft(2, '0');

    final String period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final Color pageColor = _pageBackground(context);

    final String? myUid = currentUser?.uid;

    return Scaffold(
      backgroundColor: pageColor,
      body: PhonePage(
        backgroundColor: pageColor,
        child: SafeArea(
          child: Column(
            children: [
              _ConversationHeader(
                name: widget.name,
                imageUrl: widget.imageUrl,
                onBack: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : messages.isEmpty
                        ? _EmptyConversation(
                            name: widget.name,
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(
                              18,
                              18,
                              18,
                              20,
                            ),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final _Message message = messages[index];

                              return _MessageBubble(
                                text: message.text,
                                time: formatTime(
                                  message.createdAt,
                                ),
                                isMine: message.senderId == myUid,
                              );
                            },
                          ),
              ),
              _MessageComposer(
                controller: messageController,
                isSending: isSending,
                onSend: sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader({
    required this.name,
    required this.imageUrl,
    required this.onBack,
  });

  final String name;
  final String imageUrl;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        8,
        9,
        15,
        11,
      ),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        border: Border(
          bottom: BorderSide(
            color: _borderColor(context),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            style: IconButton.styleFrom(
              backgroundColor: _pageBackground(
                context,
              ),
              shape: const CircleBorder(),
            ),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _primaryText(context),
              size: 17,
            ),
          ),
          const SizedBox(width: 4),
          _ConversationAvatar(
            name: name,
            imageUrl: imageUrl,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(
                    color: _primaryText(
                      context,
                    ),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                const Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 7,
                      color: Color(0xFF28B779),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Bayan private chat',
                      style: TextStyle(
                        color: Color(0xFF28B779),
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _isDark(context)
                  ? const Color(0xFF173653)
                  : const Color(0xFFEAF4FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.primaryBlue,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationAvatar extends StatelessWidget {
  const _ConversationAvatar({
    required this.name,
    required this.imageUrl,
  });

  final String name;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final String firstLetter =
        name.trim().isEmpty ? 'B' : name.trim().substring(0, 1).toUpperCase();

    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            Color(0xFF7259D9),
            AppColors.orange,
          ],
        ),
        shape: BoxShape.circle,
      ),
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
                  return _ConversationLetter(
                    letter: firstLetter,
                  );
                },
              )
            : _ConversationLetter(
                letter: firstLetter,
              ),
      ),
    );
  }
}

class _ConversationLetter extends StatelessWidget {
  const _ConversationLetter({
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
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.text,
    required this.time,
    required this.isMine,
  });

  final String text;
  final String time;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 275,
        ),
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        padding: const EdgeInsets.fromLTRB(
          14,
          11,
          14,
          8,
        ),
        decoration: BoxDecoration(
          gradient: isMine
              ? const LinearGradient(
                  colors: [
                    AppColors.primaryBlue,
                    Color(0xFF48A9F4),
                  ],
                )
              : null,
          color: isMine
              ? null
              : _cardBackground(
                  context,
                ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(
              isMine ? 20 : 5,
            ),
            bottomRight: Radius.circular(
              isMine ? 5 : 20,
            ),
          ),
          border: isMine
              ? null
              : Border.all(
                  color: _borderColor(
                    context,
                  ),
                ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 9,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: TextStyle(
                  color: isMine
                      ? Colors.white
                      : _primaryText(
                          context,
                        ),
                  fontSize: 10.5,
                  height: 1.45,
                ),
              ),
            ),
            if (time.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                time,
                style: TextStyle(
                  color: isMine
                      ? const Color(0xD6FFFFFF)
                      : _secondaryText(
                          context,
                        ),
                  fontSize: 7,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation({
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: _isDark(context)
                    ? const Color(0xFF173653)
                    : const Color(0xFFEAF4FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.waving_hand_outlined,
                color: AppColors.primaryBlue,
                size: 40,
              ),
            ),
            const SizedBox(height: 17),
            Text(
              'Say hello!',
              style: GoogleFonts.fredoka(
                color: _primaryText(context),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Start your conversation with $name.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText(
                  context,
                ),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          15,
          9,
          15,
          13,
        ),
        decoration: BoxDecoration(
          color: _cardBackground(context),
          border: Border(
            top: BorderSide(
              color: _borderColor(context),
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            15,
            2,
            5,
            2,
          ),
          decoration: BoxDecoration(
            color: _pageBackground(context),
            borderRadius: BorderRadius.circular(
              25,
            ),
            border: Border.all(
              color: _borderColor(context),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    onSend();
                  },
                  style: TextStyle(
                    color: _primaryText(
                      context,
                    ),
                    fontSize: 10.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write a message...',
                    hintStyle: TextStyle(
                      color: _secondaryText(
                        context,
                      ),
                      fontSize: 10,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(
                width: 42,
                height: 42,
                child: FilledButton(
                  onPressed: isSending ? null : onSend,
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                  ),
                  child: isSending
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          size: 19,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message {
  const _Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
  });

  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final int createdAt;
}
