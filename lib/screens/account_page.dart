import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../models/profile_store.dart';
import '../widgets/common_widgets.dart';
import 'profile_setup_page.dart';
import 'new_credentials_page.dart';
import 'devices_page.dart';

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
  return _isDark(context) ? const Color(0xFF2B343C) : const Color(0xFFE8EDF2);
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

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
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
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
                        'Account',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          color: _primaryText(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 5, 18, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _cardBackground(context),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _borderColor(context),
                        ),
                      ),
                      child: Column(
                        children: [
                          ValueListenableBuilder(
                            valueListenable: ProfileStore.profileImage,
                            builder: (context, imageBytes, child) {
                              final String name =
                                  ProfileStore.userName.value.trim();

                              final String firstLetter =
                                  name.isEmpty ? 'B' : name[0].toUpperCase();

                              return Container(
                                width: 78,
                                height: 78,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: _cardBackground(context),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primaryBlue,
                                    width: 2,
                                  ),
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
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
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
                                              fontSize: 32,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          ValueListenableBuilder<String>(
                            valueListenable: ProfileStore.userName,
                            builder: (context, userName, child) {
                              return Text(
                                userName,
                                style: GoogleFonts.fredoka(
                                  color: _primaryText(context),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'bayan.traveler@gmail.com',
                            style: TextStyle(
                              color: _secondaryText(context),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _AccountTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Information',
                      subtitle: 'Name, email and profile information',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileSetupPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _AccountTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Password & Security',
                      subtitle: 'Update your password and security',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NewCredentialsPage(
                              email: 'bayan.traveler@gmail.com',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _AccountTile(
                      icon: Icons.devices_outlined,
                      title: 'Devices',
                      subtitle: 'Manage devices signed into your account',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DevicesPage(),
                          ),
                        );
                      },
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

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _cardBackground(context),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _borderColor(context),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isDark(context)
                      ? const Color(0xFF173653)
                      : AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryBlue,
                  size: 21,
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
      ),
    );
  }
}
