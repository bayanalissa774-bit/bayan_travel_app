import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../models/profile_store.dart';
import '../models/theme_store.dart';
import '../widgets/common_widgets.dart';

import 'account_page.dart';
import 'currency_selection_page.dart';
import 'language_selection_page.dart';
import 'login_page.dart';
import 'profile_setup_page.dart';

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

Color _dividerColor(BuildContext context) {
  return _isDark(context) ? const Color(0xFF2B343C) : const Color(0xFFF0F1F3);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String databaseUrl =
      'https://bayan-travel-app-2026-default-rtdb.europe-west1.firebasedatabase.app';

  bool locationEnabled = false;
  bool isLocating = false;

  bool darkModeEnabled = ThemeStore.isDarkMode;
  bool pushNotificationsEnabled = true;
  bool emailNotificationsEnabled = true;

  String selectedLanguage = 'English / United States';

  String selectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();

    loadLocationSetting();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  DatabaseReference? getLocationReference() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    final FirebaseDatabase database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    );

    return database.ref(
      'users/${user.uid}/locationServices',
    );
  }

  Future<void> loadLocationSetting() async {
    final DatabaseReference? reference = getLocationReference();

    if (reference == null) {
      return;
    }

    try {
      final DataSnapshot snapshot = await reference.child('enabled').get();

      if (!mounted) return;

      setState(() {
        locationEnabled = snapshot.value == true;
      });
    } catch (error) {
      debugPrint(
        'Could not load location setting: $error',
      );
    }
  }

  Future<void> updateLocationServices(
    bool value,
  ) async {
    if (isLocating) {
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage(
        'Please log in again.',
      );
      return;
    }

    final DatabaseReference? reference = getLocationReference();

    if (reference == null) {
      showMessage(
        'Location service is unavailable.',
      );
      return;
    }

    // المستخدم يريد إطفاء الموقع
    if (!value) {
      setState(() {
        isLocating = true;
      });

      try {
        await reference.update({
          'enabled': false,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });

        if (!mounted) return;

        setState(() {
          locationEnabled = false;
        });

        showMessage(
          'Location services disabled.',
        );
      } catch (error) {
        if (!mounted) return;

        showMessage(
          'Could not disable location services.',
        );
      } finally {
        if (mounted) {
          setState(() {
            isLocating = false;
          });
        }
      }

      return;
    }

    // المستخدم يريد تشغيل الموقع
    setState(() {
      isLocating = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;

        setState(() {
          locationEnabled = false;
        });

        showMessage(
          'Location permission was denied.',
        );

        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          locationEnabled = false;
        });

        showMessage(
          'Location permission is blocked. Enable it from browser settings.',
        );

        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      await reference.set({
        'enabled': true,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      if (!mounted) return;

      setState(() {
        locationEnabled = true;
      });

      showMessage(
        'Location updated successfully.',
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        locationEnabled = false;
      });

      showMessage(
        'Could not get your current location.',
      );

      debugPrint(
        'Location error: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLocating = false;
        });
      }
    }
  }

  Future<void> openLanguageSelection() async {
    final String? result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const LanguageSelectionPage(),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      selectedLanguage = result;
    });
  }

  Future<void> openCurrencySelection() async {
    final String? result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CurrencySelectionPage(
          selectedCurrency: selectedCurrency,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      selectedCurrency = result;
    });
  }

  void openEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileSetupPage(),
      ),
    );
  }

  void showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final bool dark = _isDark(context);

        return AlertDialog(
          backgroundColor: _cardBackground(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          icon: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF382326) : const Color(0xFFFFEEEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: Color(0xFFE85A5A),
              size: 28,
            ),
          ),
          title: Text(
            'Log Out?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Are you sure you want to log out of your account?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryText(context),
                side: BorderSide(
                  color: _dividerColor(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    18,
                  ),
                ),
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(
                  dialogContext,
                );

                try {
                  await FirebaseAuth.instance.signOut();

                  if (!mounted) {
                    return;
                  }

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                    (route) => false,
                  );
                } catch (error) {
                  if (!mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Could not log out. Please try again.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE34A4A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    18,
                  ),
                ),
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color pageColor = _pageBackground(context);

    final bool dark = _isDark(context);

    return Scaffold(
      backgroundColor: pageColor,
      body: PhonePage(
        backgroundColor: pageColor,
        child: SafeArea(
          child: Column(
            children: [
              _SettingsAppBar(
                onBack: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    12,
                    18,
                    30,
                  ),
                  children: [
                    _ProfileHeaderCard(
                      onEdit: openEditProfile,
                    ),
                    const SizedBox(height: 22),
                    const _SectionLabel(
                      title: 'Preferences',
                    ),
                    const SizedBox(height: 9),
                    _SettingsCard(
                      children: [
                        _SettingsActionTile(
                          icon: Icons.person_outline_rounded,
                          iconBackground: dark
                              ? const Color(0xFF193148)
                              : const Color(0xFFEAF4FF),
                          iconColor: AppColors.primaryBlue,
                          title: 'Account',
                          subtitle: 'Personal information and security',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AccountPage(),
                              ),
                            );
                          },
                        ),
                        const _CardDivider(),
                        _SettingsActionTile(
                          icon: Icons.edit_outlined,
                          iconBackground: dark
                              ? const Color(0xFF3B2B1D)
                              : const Color(0xFFFFF2E5),
                          iconColor: AppColors.orange,
                          title: 'Edit Profile',
                          subtitle: 'Update your name, bio and photo',
                          onPressed: openEditProfile,
                        ),
                        const _CardDivider(),
                        _SettingsSwitchTile(
                          icon: Icons.location_on_outlined,
                          iconBackground: dark
                              ? const Color(0xFF18352B)
                              : const Color(0xFFE9F9F1),
                          iconColor: const Color(0xFF1FA66A),
                          title: 'Location Services',
                          subtitle: isLocating
                              ? 'Getting your current location...'
                              : locationEnabled
                                  ? 'Current location is enabled'
                                  : 'Use location for nearby places',
                          value: locationEnabled,
                          onChanged: (value) {
                            updateLocationServices(
                              value,
                            );
                          },
                        ),
                        const _CardDivider(),
                        _SettingsSwitchTile(
                          icon: Icons.dark_mode_outlined,
                          iconBackground: dark
                              ? const Color(0xFF2A2540)
                              : const Color(0xFFF0EDFF),
                          iconColor: const Color(0xFF8C78EB),
                          title: 'Dark Mode',
                          subtitle: 'Switch to a darker appearance',
                          value: darkModeEnabled,
                          onChanged: (value) {
                            setState(() {
                              darkModeEnabled = value;
                            });

                            ThemeStore.setDarkMode(
                              value,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const _SectionLabel(
                      title: 'Notifications',
                    ),
                    const SizedBox(height: 9),
                    _SettingsCard(
                      children: [
                        _SettingsSwitchTile(
                          icon: Icons.notifications_none_rounded,
                          iconBackground: dark
                              ? const Color(0xFF40242C)
                              : const Color(0xFFFFF1F4),
                          iconColor: const Color(0xFFE85A75),
                          title: 'Push Notifications',
                          subtitle: 'Booking updates and travel alerts',
                          value: pushNotificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              pushNotificationsEnabled = value;
                            });
                          },
                        ),
                        const _CardDivider(),
                        _SettingsSwitchTile(
                          icon: Icons.mail_outline_rounded,
                          iconBackground: dark
                              ? const Color(0xFF193148)
                              : const Color(0xFFEAF4FF),
                          iconColor: AppColors.primaryBlue,
                          title: 'Email Notifications',
                          subtitle: 'Receive offers and confirmations',
                          value: emailNotificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              emailNotificationsEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const _SectionLabel(
                      title: 'Language & Currency',
                    ),
                    const SizedBox(height: 9),
                    _SettingsCard(
                      children: [
                        _SettingsValueTile(
                          icon: Icons.language_rounded,
                          iconBackground: dark
                              ? const Color(0xFF193148)
                              : const Color(0xFFEAF4FF),
                          iconColor: AppColors.primaryBlue,
                          title: 'Language',
                          subtitle: 'App display language',
                          value: _LanguagePill(
                            language: selectedLanguage,
                          ),
                          onPressed: openLanguageSelection,
                        ),
                        const _CardDivider(),
                        _SettingsValueTile(
                          icon: Icons.payments_outlined,
                          iconBackground: dark
                              ? const Color(0xFF18352B)
                              : const Color(0xFFE9F9F1),
                          iconColor: const Color(0xFF1FA66A),
                          title: 'Currency',
                          subtitle: 'Prices will appear in this currency',
                          value: _CurrencyPill(
                            currency: selectedCurrency,
                          ),
                          onPressed: openCurrencySelection,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const _SectionLabel(
                      title: 'Help & Support',
                    ),
                    const SizedBox(height: 9),
                    _SettingsCard(
                      children: [
                        _SettingsActionTile(
                          icon: Icons.support_agent_rounded,
                          iconBackground: dark
                              ? const Color(0xFF193148)
                              : const Color(0xFFEAF4FF),
                          iconColor: AppColors.primaryBlue,
                          title: 'Contact Support',
                          subtitle: 'We are here to help you',
                          onPressed: () {
                            showMessage(
                              'Opening support',
                            );
                          },
                        ),
                        const _CardDivider(),
                        _SettingsActionTile(
                          icon: Icons.star_outline_rounded,
                          iconBackground: dark
                              ? const Color(0xFF3B2B1D)
                              : const Color(0xFFFFF2E5),
                          iconColor: AppColors.orange,
                          title: 'Rate the App',
                          subtitle: 'Tell us about your experience',
                          onPressed: () {
                            showMessage(
                              'Thank you for your feedback',
                            );
                          },
                        ),
                        const _CardDivider(),
                        _SettingsActionTile(
                          icon: Icons.description_outlined,
                          iconBackground: dark
                              ? const Color(0xFF2A2540)
                              : const Color(0xFFF0EDFF),
                          iconColor: const Color(0xFF8C78EB),
                          title: 'Terms & Privacy',
                          subtitle: 'Read our legal information',
                          onPressed: () {
                            showMessage(
                              'Terms and privacy',
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: showLogoutDialog,
                        icon: const Icon(
                          Icons.logout_rounded,
                          size: 20,
                        ),
                        label: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE85A5A),
                          backgroundColor: dark
                              ? const Color(0xFF291D20)
                              : const Color(0xFFFFF8F8),
                          side: BorderSide(
                            color: dark
                                ? const Color(0xFF563036)
                                : const Color(0xFFFFD1D1),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Bayan Travel  •  Version 1.0.0',
                        style: TextStyle(
                          color: _secondaryText(
                            context,
                          ),
                          fontSize: 9,
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

class _SettingsAppBar extends StatelessWidget {
  const _SettingsAppBar({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      color: _pageBackground(context),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            style: IconButton.styleFrom(
              backgroundColor: _cardBackground(context),
              shape: const CircleBorder(),
            ),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _primaryText(context),
              size: 17,
            ),
          ),
          Expanded(
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatefulWidget {
  const _ProfileHeaderCard({
    required this.onEdit,
  });

  final VoidCallback onEdit;

  @override
  State<_ProfileHeaderCard> createState() => _ProfileHeaderCardState();
}

class _ProfileHeaderCardState extends State<_ProfileHeaderCard> {
  static const String databaseUrl =
      'https://bayan-travel-app-2026-default-rtdb.europe-west1.firebasedatabase.app';

  String location = '';

  @override
  void initState() {
    super.initState();

    loadLocation();
  }

  Future<void> loadLocation() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final FirebaseDatabase database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: databaseUrl,
      );

      final DataSnapshot snapshot = await database
          .ref(
            'users/${user.uid}/profile/location',
          )
          .get();

      if (!mounted) return;

      setState(() {
        location = snapshot.value?.toString() ?? '';
      });
    } catch (error) {
      debugPrint(
        'Could not load profile location: $error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    final String email = user?.email ?? '';

    final String displayedLocation =
        location.trim().isEmpty ? 'Location not set' : location.trim();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue,
            Color(0xFF45A5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33006EDC),
            blurRadius: 18,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          ValueListenableBuilder(
            valueListenable: ProfileStore.profileImage,
            builder: (context, imageBytes, child) {
              final String name = ProfileStore.userName.value.trim();

              final String firstLetter =
                  name.isEmpty ? 'B' : name.substring(0, 1).toUpperCase();

              return Container(
                width: 68,
                height: 68,
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: imageBytes != null
                      ? Image.memory(
                          imageBytes,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryBlue,
                                Color(0xFF7259D9),
                                AppColors.orange,
                              ],
                            ),
                          ),
                          child: Text(
                            firstLetter,
                            style: GoogleFonts.fredoka(
                              color: Colors.white,
                              fontSize: 31,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              );
            },
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<String>(
                  valueListenable: ProfileStore.userName,
                  builder: (
                    context,
                    name,
                    child,
                  ) {
                    return Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 18,
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
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        displayedLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onEdit,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0x33FFFFFF),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 3,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: _primaryText(context),
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bool dark = _isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _dividerColor(context),
        ),
        boxShadow: [
          BoxShadow(
            color: dark ? const Color(0x33000000) : const Color(0x0D000000),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 55,
      color: _dividerColor(context),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
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
            _TileIcon(
              icon: icon,
              backgroundColor: iconBackground,
              iconColor: iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TileTexts(
                title: title,
                subtitle: subtitle,
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

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        children: [
          _TileIcon(
            icon: icon,
            backgroundColor: iconBackground,
            iconColor: iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TileTexts(
              title: title,
              subtitle: subtitle,
            ),
          ),
          Transform.scale(
            scale: 0.82,
            child: Switch(
              value: value,
              activeColor: Colors.white,
              activeTrackColor: AppColors.primaryBlue,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: _isDark(context)
                  ? const Color(0xFF48515A)
                  : const Color(0xFFD1D5DB),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsValueTile extends StatelessWidget {
  const _SettingsValueTile({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onPressed,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 11,
        ),
        child: Row(
          children: [
            _TileIcon(
              icon: icon,
              backgroundColor: iconBackground,
              iconColor: iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TileTexts(
                title: title,
                subtitle: subtitle,
              ),
            ),
            value,
          ],
        ),
      ),
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 21,
      ),
    );
  }
}

class _TileTexts extends StatelessWidget {
  const _TileTexts({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 4),
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
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({
    required this.language,
  });

  final String language;

  String get flagCode {
    if (language.contains('السعودية')) {
      return 'sa';
    }

    if (language.contains(
      'United Kingdom',
    )) {
      return 'gb';
    }

    if (language.contains(
      'United States',
    )) {
      return 'us';
    }

    if (language.contains('France')) {
      return 'fr';
    }

    if (language.contains(
      'Deutschland',
    )) {
      return 'de';
    }

    if (language.contains('España')) {
      return 'es';
    }

    if (language.contains('Italia')) {
      return 'it';
    }

    if (language.contains('Portugal')) {
      return 'pt';
    }

    if (language.contains('Brasil')) {
      return 'br';
    }

    if (language.contains('Türkiye')) {
      return 'tr';
    }

    if (language.contains('Россия')) {
      return 'ru';
    }

    if (language.contains('Україна')) {
      return 'ua';
    }

    if (language.contains('China')) {
      return 'cn';
    }

    if (language.contains('Japan')) {
      return 'jp';
    }

    if (language.contains(
      'South Korea',
    )) {
      return 'kr';
    }

    if (language.contains('India')) {
      return 'in';
    }

    if (language.contains('Pakistan')) {
      return 'pk';
    }

    if (language.contains(
      'Bangladesh',
    )) {
      return 'bd';
    }

    if (language.contains(
      'Indonesia',
    )) {
      return 'id';
    }

    if (language.contains('Malaysia')) {
      return 'my';
    }

    if (language.contains('Thailand')) {
      return 'th';
    }

    if (language.contains('Vietnam')) {
      return 'vn';
    }

    if (language.contains(
      'Nederland',
    )) {
      return 'nl';
    }

    if (language.contains('Sverige')) {
      return 'se';
    }

    if (language.contains('Norge')) {
      return 'no';
    }

    if (language.contains('Danmark')) {
      return 'dk';
    }

    if (language.contains('Polska')) {
      return 'pl';
    }

    if (language.contains('Ελλάδα')) {
      return 'gr';
    }

    if (language.contains('Israel')) {
      return 'il';
    }

    if (language.contains('Iran')) {
      return 'ir';
    }

    if (language.contains('Kenya')) {
      return 'ke';
    }

    if (language.contains(
      'Philippines',
    )) {
      return 'ph';
    }

    return 'us';
  }

  String get shortLanguageName {
    return language.split('/').first.trim();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = _isDark(context);

    return Container(
      height: 35,
      padding: const EdgeInsets.fromLTRB(
        5,
        4,
        9,
        4,
      ),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF252D34) : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dark ? const Color(0xFF39444D) : const Color(0xFFE3E7EC),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 27,
            height: 27,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF303940) : Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.network(
                'https://flagcdn.com/w80/$flagCode.png',
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Icon(
                    Icons.language_rounded,
                    color: AppColors.primaryBlue,
                    size: 16,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 80,
            ),
            child: Text(
              shortLanguageName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 3),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _secondaryText(context),
            size: 15,
          ),
        ],
      ),
    );
  }
}

class _CurrencyPill extends StatelessWidget {
  const _CurrencyPill({
    required this.currency,
  });

  final String currency;

  String get symbol {
    switch (currency) {
      case 'EUR':
        return '€';

      case 'GBP':
        return '£';

      case 'SAR':
        return '﷼';

      case 'AED':
        return 'د.إ';

      case 'TRY':
        return '₺';

      default:
        return '\$';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = _isDark(context);

    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
      ),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF17372B) : const Color(0xFFE9F9F1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dark ? const Color(0xFF275440) : const Color(0xFFD5F1E3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            symbol,
            style: const TextStyle(
              color: Color(0xFF38C98A),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            currency,
            style: TextStyle(
              color: dark ? const Color(0xFF7EE2B4) : const Color(0xFF137D4F),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: dark ? const Color(0xFF7EE2B4) : const Color(0xFF137D4F),
            size: 15,
          ),
        ],
      ),
    );
  }
}
