import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';
import '../models/profile_store.dart';
import '../widgets/common_widgets.dart';
import 'email_verification_page.dart';

bool _isDark(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

Color _pageBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF101418) : Colors.white;
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

class ProfilePicturePage extends StatefulWidget {
  const ProfilePicturePage({super.key});

  @override
  State<ProfilePicturePage> createState() => _ProfilePicturePageState();
}

class _ProfilePicturePageState extends State<ProfilePicturePage> {
  final ImagePicker imagePicker = ImagePicker();

  Uint8List? selectedImage;

  @override
  void initState() {
    super.initState();

    selectedImage = ProfileStore.profileImage.value;
  }

  Future<void> pickProfileImage() async {
    final XFile? pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedImage == null) {
      return;
    }

    final Uint8List imageBytes = await pickedImage.readAsBytes();

    if (!mounted) {
      return;
    }

    setState(() {
      selectedImage = imageBytes;
    });

    ProfileStore.profileImage.value = imageBytes;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Profile photo selected successfully.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void openEmailVerificationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmailVerificationPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color pageColor = _pageBackground(context);

    final bool hasImage = selectedImage != null;

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
                        backgroundColor: _cardBackground(context),
                        shape: const CircleBorder(),
                      ),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _primaryText(context),
                        size: 19,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Choose Your Profile Photo',
                        style: TextStyle(
                          color: _primaryText(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: openEmailVerificationPage,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    26,
                    20,
                    26,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: pickProfileImage,
                          child: AnimatedContainer(
                            duration: const Duration(
                              milliseconds: 250,
                            ),
                            width: 140,
                            height: 140,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _cardBackground(context),
                              border: Border.all(
                                color: hasImage
                                    ? AppColors.primaryBlue
                                    : _isDark(context)
                                        ? const Color(0xFF46515B)
                                        : const Color(0xFFD9D9D9),
                                width: hasImage ? 3 : 1,
                              ),
                            ),
                            child: ClipOval(
                              child: hasImage
                                  ? Image.memory(
                                      selectedImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: _isDark(context)
                                          ? const Color(0xFF252D34)
                                          : const Color(0xFFD9D9D9),
                                      child: Icon(
                                        Icons.person_rounded,
                                        size: 88,
                                        color: _isDark(context)
                                            ? const Color(0xFF7D8994)
                                            : const Color(0xFF737373),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: pickProfileImage,
                          icon: const Icon(
                            Icons.photo_library_outlined,
                            size: 18,
                          ),
                          label: Text(
                            hasImage ? 'Change Photo' : 'Upload Photo',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                            backgroundColor: _cardBackground(context),
                            side: const BorderSide(
                              color: AppColors.primaryBlue,
                            ),
                            minimumSize: const Size(
                              double.infinity,
                              48,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 42),
                      Text(
                        'Photo Guidelines',
                        style: TextStyle(
                          color: _primaryText(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _GuidelineText(
                        text: 'Show your face clearly',
                      ),
                      const SizedBox(height: 12),
                      _GuidelineText(
                        text: 'Use a close-up face photo',
                      ),
                      const SizedBox(height: 12),
                      _GuidelineText(
                        text: 'Use a clear and sharp image',
                      ),
                      const SizedBox(height: 80),
                      Center(
                        child: SizedBox(
                          width: 175,
                          child: PrimaryButton(
                            text: hasImage ? 'Save Photo' : 'Continue',
                            onPressed: openEmailVerificationPage,
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

class _GuidelineText extends StatelessWidget {
  const _GuidelineText({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          color: AppColors.primaryBlue,
          size: 17,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
