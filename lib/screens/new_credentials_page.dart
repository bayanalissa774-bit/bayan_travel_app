import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'password_updated_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

bool _isDark(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

Color _pageBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF101418) : AppColors.softGrey;
}

Color _cardBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF1B2229) : Colors.white;
}

Color _fieldBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF252D34) : Colors.white;
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

class NewCredentialsPage extends StatefulWidget {
  const NewCredentialsPage({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<NewCredentialsPage> createState() => _NewCredentialsPageState();
}

class _NewCredentialsPageState extends State<NewCredentialsPage> {
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;

  bool obscureConfirmPassword = true;

  bool submitted = false;

  bool get hasMinimumLength {
    return passwordController.text.length >= 8;
  }

  bool get hasUppercaseLetter {
    return RegExp(r'[A-Z]').hasMatch(passwordController.text);
  }

  bool get hasNumberOrSpecialCharacter {
    return RegExp(
      r'[0-9!@#$%^&*(),.?":{}|<>_\-+=/\\]',
    ).hasMatch(passwordController.text);
  }

  bool get passwordsMatch {
    return confirmPasswordController.text.isNotEmpty &&
        passwordController.text == confirmPasswordController.text;
  }

  bool get passwordIsValid {
    return hasMinimumLength &&
        hasUppercaseLetter &&
        hasNumberOrSpecialCharacter;
  }

  bool get showPasswordError {
    return submitted && passwordController.text.trim().isEmpty;
  }

  bool get showConfirmPasswordError {
    return submitted && confirmPasswordController.text.trim().isEmpty;
  }

  bool get showPasswordMismatch {
    return confirmPasswordController.text.isNotEmpty &&
        passwordController.text != confirmPasswordController.text;
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> submitPassword() async {
    setState(() {
      submitted = true;
    });

    if (!passwordIsValid ||
        !passwordsMatch ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      return;
    }

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      await user.updatePassword(
        passwordController.text,
      );

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordUpdatedPage(
            email: widget.email,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Could not update password.';

      if (e.code == 'requires-recent-login') {
        message =
            'For security, log out and log in again, then try changing your password.';
      } else if (e.code == 'weak-password') {
        message = 'Please choose a stronger password.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
              _CredentialsHeader(
                onBack: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    30,
                  ),
                  child: Column(
                    children: [
                      const _BayanBrand(),
                      const SizedBox(height: 34),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          23,
                          20,
                          25,
                        ),
                        decoration: BoxDecoration(
                          color: _cardBackground(context),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: _borderColor(context),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: _isDark(context)
                                    ? const Color(0xFF173653)
                                    : AppColors.lightBlue,
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: const Icon(
                                Icons.password_rounded,
                                color: AppColors.primaryBlue,
                                size: 27,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'New Credentials',
                              style: TextStyle(
                                color: _primaryText(context),
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 13),
                            _PasswordRequirement(
                              text:
                                  'Password must be at least 8 characters long.',
                              isValid: hasMinimumLength,
                              hasInput: passwordController.text.isNotEmpty,
                            ),
                            const SizedBox(height: 5),
                            _PasswordRequirement(
                              text:
                                  'Password must contain at least one uppercase letter.',
                              isValid: hasUppercaseLetter,
                              hasInput: passwordController.text.isNotEmpty,
                            ),
                            const SizedBox(height: 5),
                            _PasswordRequirement(
                              text:
                                  'Password must contain at least one number or special character.',
                              isValid: hasNumberOrSpecialCharacter,
                              hasInput: passwordController.text.isNotEmpty,
                            ),
                            const SizedBox(height: 22),
                            _PasswordField(
                              label: 'New Password',
                              hintText: 'Enter new password',
                              controller: passwordController,
                              obscureText: obscurePassword,
                              hasError: showPasswordError ||
                                  (passwordController.text.isNotEmpty &&
                                      !passwordIsValid),
                              errorText: showPasswordError
                                  ? 'This is a required field.'
                                  : null,
                              onChanged: (_) {
                                setState(() {});
                              },
                              onVisibilityPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                            const SizedBox(height: 15),
                            _PasswordField(
                              label: 'Confirm Password',
                              hintText: 'Confirm new password',
                              controller: confirmPasswordController,
                              obscureText: obscureConfirmPassword,
                              hasError: showConfirmPasswordError ||
                                  showPasswordMismatch,
                              errorText: showConfirmPasswordError
                                  ? 'This is a required field.'
                                  : showPasswordMismatch
                                      ? 'Password does not match.'
                                      : null,
                              onChanged: (_) {
                                setState(() {});
                              },
                              onVisibilityPressed: () {
                                setState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 49,
                              child: FilledButton(
                                onPressed: submitPassword,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryBlue,
                                  backgroundColor: _cardBackground(context),
                                  side: const BorderSide(
                                    color: AppColors.primaryBlue,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordRequirement extends StatelessWidget {
  const _PasswordRequirement({
    required this.text,
    required this.isValid,
    required this.hasInput,
  });

  final String text;
  final bool isValid;
  final bool hasInput;

  @override
  Widget build(BuildContext context) {
    final Color displayColor;

    if (!hasInput) {
      displayColor = _secondaryText(context);
    } else if (isValid) {
      displayColor = const Color(0xFF1FA66A);
    } else {
      displayColor = const Color(0xFFE34A4A);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isValid ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
          color: displayColor,
          size: 13,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: displayColor,
              fontSize: 8,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.obscureText,
    required this.hasError,
    required this.errorText,
    required this.onChanged,
    required this.onVisibilityPressed,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final bool hasError;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final VoidCallback onVisibilityPressed;

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        hasError ? const Color(0xFFE34A4A) : AppColors.primaryBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _secondaryText(context),
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 11,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: _secondaryText(context),
              fontSize: 9,
            ),
            filled: true,
            fillColor: _fieldBackground(context),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onVisibilityPressed,
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: _secondaryText(context),
                    size: 18,
                  ),
                ),
                if (hasError)
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.error_rounded,
                      color: Color(0xFFE34A4A),
                      size: 17,
                    ),
                  ),
              ],
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: borderColor,
                width: 1.4,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 5),
          Text(
            errorText!,
            style: const TextStyle(
              color: Color(0xFFE34A4A),
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _CredentialsHeader extends StatelessWidget {
  const _CredentialsHeader({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          const SizedBox(width: 10),
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
        ],
      ),
    );
  }
}

class _BayanBrand extends StatelessWidget {
  const _BayanBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Bayan Travel',
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 7),
        const _BrandIcon(),
      ],
    );
  }
}

class _BrandIcon extends StatelessWidget {
  const _BrandIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 31,
      height: 31,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.orange,
              Color(0xFF8057E8),
            ],
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.flight_takeoff_rounded,
          color: Colors.white,
          size: 17,
        ),
      ),
    );
  }
}
