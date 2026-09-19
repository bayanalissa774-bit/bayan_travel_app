// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../models/profile_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/profile_avatar_picker.dart';

import 'activities_selection_page.dart';
import 'gender_selection_page.dart';
import 'profile_setup_page.dart';
import 'settings_page.dart';
import 'schedule_page.dart';
import 'saved_page.dart';
import 'wallet_page.dart';

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../pages/my_bookings_page.dart';

bool _isDark(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

Color _pageBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF101418) : AppColors.softGrey;
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
  return _isDark(context) ? const Color(0xFF2B343C) : const Color(0xFFF0F1F3);
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const String databaseUrl =
      'https://bayan-travel-app-2026-default-rtdb.europe-west1.firebasedatabase.app';

  String username = '';
  String location = '';
  int tripsCount = 0;
  int savedCount = 0;

  StreamSubscription<DatabaseEvent>? userSubscription;

  @override
  void initState() {
    super.initState();
    listenToUserData();
  }

  @override
  void dispose() {
    userSubscription?.cancel();
    super.dispose();
  }

  void listenToUserData() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final FirebaseDatabase database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    );

    final DatabaseReference userReference = database.ref('users/${user.uid}');

    userSubscription = userReference.onValue.listen((event) {
      final Object? value = event.snapshot.value;

      if (value is! Map) return;

      final Map<dynamic, dynamic> userData = Map<dynamic, dynamic>.from(value);

      String loadedUsername = '';
      String loadedLocation = '';
      String loadedFullName = '';

      final Object? profileValue = userData['profile'];

      if (profileValue is Map) {
        final Map<dynamic, dynamic> profile = Map<dynamic, dynamic>.from(
          profileValue,
        );

        loadedUsername = profile['username']?.toString() ?? '';

        loadedLocation = profile['location']?.toString() ?? '';

        loadedFullName = profile['fullName']?.toString() ?? '';
      }

      int loadedTripsCount = 0;
      int loadedSavedCount = 0;

      final Object? bookings = userData['bookings'];

      if (bookings is Map) {
        loadedTripsCount = bookings.length;
      }

      final Object? saved = userData['saved'];

      if (saved is Map) {
        loadedSavedCount = saved.length;
      }

      if (loadedFullName.trim().isNotEmpty) {
        ProfileStore.userName.value = loadedFullName.trim();
      } else if ((user.displayName ?? '').trim().isNotEmpty) {
        ProfileStore.userName.value = user.displayName!.trim();
      }

      if (!mounted) return;

      setState(() {
        username = loadedUsername;
        location = loadedLocation;
        tripsCount = loadedTripsCount;
        savedCount = loadedSavedCount;
      });
    });
  }

  void openEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileSetupPage(),
      ),
    );
  }

  void openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  Future<void> openActivities(
    BuildContext context,
  ) async {
    final List<String>? result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => const ActivitiesSelectionPage(),
      ),
    );

    if (!context.mounted || result == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${result.length} activities selected',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> openGender(
    BuildContext context,
  ) async {
    final String? result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const GenderSelectionPage(),
      ),
    );

    if (!context.mounted || result == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Gender updated to $result',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color pageColor = _pageBackground(context);

    return Scaffold(
      backgroundColor: pageColor,
      body: PhonePage(
        backgroundColor: pageColor,
        child: SafeArea(
          child: Column(
            children: [
              _ProfileAppBar(
                onBack: () {
                  Navigator.pop(context);
                },
                onSettings: () {
                  openSettings(context);
                },
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    10,
                    18,
                    30,
                  ),
                  children: [
                    _ProfileHeroCard(
                      onEditProfile: () {
                        openEditProfile(context);
                      },
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(
                      title: 'My Account',
                      subtitle: 'Manage your travel experience',
                    ),
                    const SizedBox(height: 11),
                    _ProfileMenuCard(
                      children: [
                        _ProfileMenuTile(
                          icon: Icons.luggage_outlined,
                          iconBackground: const Color(0xFFEAF4FF),
                          iconColor: AppColors.primaryBlue,
                          title: 'My Bookings',
                          subtitle: 'View upcoming and previous trips',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyBookingsPage(),
                              ),
                            );
                          },
                        ),
                        const _ProfileDivider(),
                        _ProfileMenuTile(
                          icon: Icons.favorite_border_rounded,
                          iconBackground: const Color(0xFFFFF0F3),
                          iconColor: const Color(0xFFE85A75),
                          title: 'Saved Places',
                          subtitle: 'Destinations you want to visit',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SavedPage(),
                              ),
                            );
                          },
                        ),
                        const _ProfileDivider(),
                        _ProfileMenuTile(
                          icon: Icons.tune_rounded,
                          iconBackground: const Color(0xFFF0EDFF),
                          iconColor: const Color(0xFF7259D9),
                          title: 'Travel Preferences',
                          subtitle: 'Choose your favorite activities',
                          onPressed: () {
                            openActivities(context);
                          },
                        ),
                        const _ProfileDivider(),
                        _ProfileMenuTile(
                          icon: Icons.person_search_outlined,
                          iconBackground: const Color(0xFFFFF1F4),
                          iconColor: const Color(0xFFE85A75),
                          title: 'Gender',
                          subtitle: 'Choose how your profile is displayed',
                          onPressed: () {
                            openGender(context);
                          },
                        ),
                        const _ProfileDivider(),
                        _ProfileMenuTile(
                          icon: Icons.account_balance_wallet_rounded,
                          iconBackground: const Color(0xFFE9F9F1),
                          iconColor: const Color(0xFF1FA66A),
                          title: 'My Wallet',
                          subtitle: 'Balance, cards and transactions',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WalletPage(),
                              ),
                            );
                          },
                        ),
                        const _ProfileDivider(),
                        _ProfileMenuTile(
                          icon: Icons.settings_outlined,
                          iconBackground: const Color(0xFFFFF2E5),
                          iconColor: AppColors.orange,
                          title: 'Settings',
                          subtitle: 'Notifications, language and privacy',
                          onPressed: () {
                            openSettings(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(
                      title: 'Trips',
                      subtitle: 'Your bookings are saved securely',
                    ),
                    const SizedBox(height: 11),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SchedulePage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                          backgroundColor: _cardBackground(
                            context,
                          ),
                          side: const BorderSide(
                            color: AppColors.primaryBlue,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              17,
                            ),
                          ),
                        ),
                        child: const Text(
                          'View My Trips',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar({
    required this.onBack,
    required this.onSettings,
  });

  final VoidCallback onBack;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      color: _pageBackground(context),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              'My Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _CircleIconButton(
            icon: Icons.settings_outlined,
            onPressed: onSettings,
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _cardBackground(context),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: _primaryText(context),
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _ProfileHeroCard extends StatefulWidget {
  const _ProfileHeroCard({
    required this.onEditProfile,
  });

  final VoidCallback onEditProfile;

  @override
  State<_ProfileHeroCard> createState() => _ProfileHeroCardState();
}

class _ProfileHeroCardState extends State<_ProfileHeroCard> {
  static const String databaseUrl =
      'https://bayan-travel-app-2026-default-rtdb.europe-west1.firebasedatabase.app';

  String email = '';
  String location = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    email = user.email ?? '';

    try {
      final FirebaseDatabase database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: databaseUrl,
      );

      final DataSnapshot snapshot =
          await database.ref('users/${user.uid}/profile').get();

      if (snapshot.exists && snapshot.value is Map) {
        final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
          snapshot.value as Map,
        );

        final String fullName = data['fullName']?.toString() ?? '';

        location = data['location']?.toString() ?? '';

        if (fullName.trim().isNotEmpty) {
          ProfileStore.userName.value = fullName.trim();
        }
      }
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String displayedLocation =
        location.trim().isEmpty ? 'Location not set' : location.trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        21,
        18,
        19,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue,
            Color(0xFF3B9FEB),
            Color(0xFF71C4F7),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33006EDC),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileAvatarPicker(
            name: ProfileStore.userName.value,
            radius: 46,
            initialImage: ProfileStore.profileImage.value,
            onImageChanged: (imageBytes) {
              ProfileStore.profileImage.value = imageBytes;
            },
          ),
          const SizedBox(height: 13),
          ValueListenableBuilder<String>(
            valueListenable: ProfileStore.userName,
            builder: (context, userName, child) {
              return Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.fredoka(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
          const SizedBox(height: 5),
          Text(
            email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xDFFFFFFF),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0x2BFFFFFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  isLoading ? 'Loading...' : displayedLocation,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 43,
            width: 165,
            child: FilledButton.icon(
              onPressed: widget.onEditProfile,
              icon: const Icon(
                Icons.edit_outlined,
                size: 17,
              ),
              label: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatsCard extends StatelessWidget {
  const _ProfileStatsCard({
    required this.tripsCount,
    required this.savedCount,
  });

  final int tripsCount;
  final int savedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              value: '$tripsCount',
              label: 'Trips',
              icon: Icons.flight_takeoff_rounded,
              color: AppColors.primaryBlue,
            ),
          ),
          const _StatsDivider(),
          const Expanded(
            child: _StatItem(
              value: '0',
              label: 'Reviews',
              icon: Icons.star_rounded,
              color: AppColors.orange,
            ),
          ),
          const _StatsDivider(),
          Expanded(
            child: _StatItem(
              value: '$savedCount',
              label: 'Saved',
              icon: Icons.favorite_rounded,
              color: Color(0xFFE85A75),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsDivider extends StatelessWidget {
  const _StatsDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 43,
      color: _borderColor(context),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: _secondaryText(context),
            fontSize: 8.5,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  const _ProfileMenuCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _ProfileDivider extends StatelessWidget {
  const _ProfileDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 54,
      color: _borderColor(context),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _isDark(context)
                    ? iconColor.withOpacity(
                        0.16,
                      )
                    : iconBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _primaryText(context),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _secondaryText(context),
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: _secondaryText(context),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTripCard extends StatelessWidget {
  const _RecentTripCard({
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.date,
    required this.rating,
  });

  final String imageUrl;
  final String title;
  final String location;
  final String date;
  final String rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            height: double.infinity,
            child: TravelImage(
              imageUrl: imageUrl,
              borderRadius: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primaryBlue,
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        location,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _secondaryText(context),
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: _secondaryText(context),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        color: _secondaryText(context),
                        fontSize: 8,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.orange,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      rating,
                      style: TextStyle(
                        color: _primaryText(context),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
