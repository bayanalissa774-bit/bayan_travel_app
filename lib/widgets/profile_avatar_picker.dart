import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';

class ProfileAvatarPicker extends StatefulWidget {
  const ProfileAvatarPicker({
    super.key,
    required this.name,
    this.radius = 40,
    this.initialImage,
    this.onImageChanged,
  });

  final String name;
  final double radius;
  final Uint8List? initialImage;
  final ValueChanged<Uint8List?>? onImageChanged;

  @override
  State<ProfileAvatarPicker> createState() => _ProfileAvatarPickerState();
}

class _ProfileAvatarPickerState extends State<ProfileAvatarPicker> {
  final ImagePicker imagePicker = ImagePicker();

  Uint8List? selectedImageBytes;
  bool isPickingImage = false;

  String get firstLetter {
    final String trimmedName = widget.name.trim();

    if (trimmedName.isEmpty) {
      return 'B';
    }

    return trimmedName.substring(0, 1).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    selectedImageBytes = widget.initialImage;
  }

  Future<void> pickImageFromGallery() async {
    if (isPickingImage) {
      return;
    }

    setState(() {
      isPickingImage = true;
    });

    try {
      final XFile? selectedImage = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (selectedImage == null) {
        return;
      }

      final Uint8List bytes = await selectedImage.readAsBytes();

      if (!mounted) {
        return;
      }

      setState(() {
        selectedImageBytes = bytes;
      });

      widget.onImageChanged?.call(bytes);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Could not open the photo gallery.',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isPickingImage = false;
        });
      }
    }
  }

  void removeSelectedImage() {
    setState(() {
      selectedImageBytes = null;
    });

    widget.onImageChanged?.call(null);
  }

  void showImageOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9DDE3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 17),
                Text(
                  'Profile Photo',
                  style: GoogleFonts.poppins(
                    color: AppColors.blackText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    pickImageFromGallery();
                  },
                  leading: Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: GoogleFonts.poppins(
                      color: AppColors.blackText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Select a photo from your device',
                    style: GoogleFonts.poppins(
                      color: AppColors.greyText,
                      fontSize: 9,
                    ),
                  ),
                ),
                if (selectedImageBytes != null)
                  ListTile(
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      removeSelectedImage();
                    },
                    leading: Container(
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEEEE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFE34A4A),
                      ),
                    ),
                    title: Text(
                      'Remove Photo',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFE34A4A),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double avatarSize = widget.radius * 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 15,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: selectedImageBytes != null
                ? Image.memory(
                    selectedImageBytes!,
                    width: avatarSize,
                    height: avatarSize,
                    fit: BoxFit.cover,
                  )
                : Container(
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
                    alignment: Alignment.center,
                    child: Text(
                      firstLetter,
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: widget.radius * 0.95,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: 2,
          child: Material(
            color: AppColors.primaryBlue,
            shape: const CircleBorder(),
            elevation: 3,
            child: InkWell(
              onTap: isPickingImage ? null : showImageOptions,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 31,
                height: 31,
                child: isPickingImage
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
