import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/profile_store.dart';
import '../widgets/common_widgets.dart';
import 'profile_picture_page.dart';

bool _isDark(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

Color _pageBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF101418) : Colors.white;
}

Color _primaryText(BuildContext context) {
  return _isDark(context) ? const Color(0xFFF4F7F9) : AppColors.blackText;
}

Color _secondaryText(BuildContext context) {
  return _isDark(context) ? const Color(0xFF9EA9B2) : AppColors.greyText;
}

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  static const String databaseUrl =
      'https://bayan-travel-app-2026-default-rtdb.europe-west1.firebasedatabase.app';

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController bioController = TextEditingController();

  final TextEditingController locationController = TextEditingController();

  final TextEditingController birthdayController = TextEditingController();

  final TextEditingController genderController = TextEditingController();

  final TextEditingController jobTitleController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  DatabaseReference? profileReference;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    usernameController.dispose();
    bioController.dispose();
    locationController.dispose();
    birthdayController.dispose();
    genderController.dispose();
    jobTitleController.dispose();
    super.dispose();
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

    try {
      final FirebaseDatabase database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: databaseUrl,
      );

      profileReference = database.ref(
        'users/${user.uid}/profile',
      );

      final DataSnapshot snapshot = await profileReference!.get();

      if (snapshot.exists && snapshot.value is Map) {
        final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
          snapshot.value as Map,
        );

        usernameController.text = data['username']?.toString() ?? '';

        bioController.text = data['bio']?.toString() ?? '';

        locationController.text = data['location']?.toString() ?? '';

        birthdayController.text = data['birthday']?.toString() ?? '';

        genderController.text = data['gender']?.toString() ?? '';

        jobTitleController.text = data['jobTitle']?.toString() ?? '';
      }

      if (usernameController.text.trim().isEmpty) {
        usernameController.text = user.displayName?.trim() ?? '';
      }
    } catch (error) {
      if (mounted) {
        showMessage(
          'Could not load profile data.',
          error: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> saveProfile() async {
    if (isSaving) return;

    final String username = usernameController.text.trim();

    if (username.isEmpty) {
      showMessage(
        'Please enter your username.',
        error: true,
      );
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage(
        'Please log in again.',
        error: true,
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final FirebaseDatabase database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: databaseUrl,
      );

      final DatabaseReference reference = database.ref(
        'users/${user.uid}/profile',
      );

      await reference.set({
        'fullName': user.displayName?.trim() ?? '',
        'email': user.email?.trim() ?? '',
        'username': username,
        'bio': bioController.text.trim(),
        'location': locationController.text.trim(),
        'birthday': birthdayController.text.trim(),
        'gender': genderController.text.trim(),
        'jobTitle': jobTitleController.text.trim(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      if ((user.displayName ?? '').trim().isEmpty) {
        await user.updateDisplayName(username);
        ProfileStore.userName.value = username;
      } else {
        ProfileStore.userName.value = user.displayName!.trim();
      }

      if (!mounted) return;

      showMessage(
        'Profile saved successfully.',
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilePicturePage(),
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      showMessage(
        'Firebase error: ${error.message ?? error.code}',
        error: true,
      );
    } catch (error) {
      if (!mounted) return;

      showMessage(
        'Could not save profile.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
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
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  6,
                  12,
                  0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: _isDark(context)
                            ? const Color(
                                0xFF1B2229,
                              )
                            : const Color(
                                0xFFF5F7FA,
                              ),
                        shape: const CircleBorder(),
                      ),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _primaryText(context),
                        size: 18,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Complete Your Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _primaryText(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          26,
                          14,
                          26,
                          28,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tell us about yourself to personalize your\nexperience.',
                              style: TextStyle(
                                color: _secondaryText(
                                  context,
                                ),
                                fontSize: 9.5,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const _FieldTitle(
                              title: 'Username',
                            ),
                            const SizedBox(height: 5),
                            AppTextField(
                              controller: usernameController,
                              label: '',
                              hint: 'Enter username',
                              icon: Icons.alternate_email_rounded,
                            ),
                            const SizedBox(height: 13),
                            const _FieldTitle(
                              title: 'Bio',
                            ),
                            const SizedBox(height: 5),
                            AppTextField(
                              controller: bioController,
                              label: '',
                              hint:
                                  'Tell us about yourself and your travel style',
                              icon: Icons.edit_note_rounded,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 13),
                            const _FieldTitle(
                              title: 'Location',
                            ),
                            const SizedBox(height: 5),
                            AppTextField(
                              controller: locationController,
                              label: '',
                              hint: 'City, Country',
                              icon: Icons.location_on_outlined,
                            ),
                            const SizedBox(height: 13),
                            const _FieldTitle(
                              title: 'Birthday',
                            ),
                            const SizedBox(height: 5),
                            AppTextField(
                              controller: birthdayController,
                              label: '',
                              hint: 'mm/dd/yyyy',
                              icon: Icons.calendar_month_outlined,
                            ),
                            const SizedBox(height: 13),
                            const _FieldTitle(
                              title: 'Gender',
                            ),
                            const SizedBox(height: 5),
                            AppTextField(
                              controller: genderController,
                              label: '',
                              hint: 'Select gender',
                              icon: Icons.people_outline_rounded,
                            ),
                            const SizedBox(height: 13),
                            const _FieldTitle(
                              title: 'Job Title',
                            ),
                            const SizedBox(height: 5),
                            AppTextField(
                              controller: jobTitleController,
                              label: '',
                              hint: 'Enter job title',
                              icon: Icons.work_outline_rounded,
                            ),
                            const SizedBox(height: 25),
                            Center(
                              child: SizedBox(
                                width: 190,
                                child: PrimaryButton(
                                  text: isSaving
                                      ? 'Saving...'
                                      : 'Save & Continue',
                                  onPressed: saveProfile,
                                ),
                              ),
                            ),
                            const SizedBox(height: 35),
                            Center(
                              child: Container(
                                width: 105,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: _isDark(context)
                                      ? const Color(0xFF5B6570)
                                      : AppColors.blackText,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
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

class _FieldTitle extends StatelessWidget {
  const _FieldTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: _secondaryText(context),
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
