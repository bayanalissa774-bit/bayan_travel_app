import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../models/profile_store.dart';
import '../widgets/common_widgets.dart';
import 'profile_setup_page.dart';

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

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool acceptTerms = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? validateName(String? value) {
    final String name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Please enter your full name';
    }

    if (name.length < 3) {
      return 'Name must contain at least 3 characters';
    }

    return null;
  }

  String? validateEmail(String? value) {
    final String email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email';
    }

    final RegExp emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? validatePassword(String? value) {
    final String password = value ?? '';

    if (password.isEmpty) {
      return 'Please enter a password';
    }

    if (password.length < 6) {
      return 'Password must contain at least 6 characters';
    }

    return null;
  }

  String? validateConfirmPassword(
    String? value,
  ) {
    final String confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (confirmPassword != passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  void showMessage(
    String message, {
    bool error = true,
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

  String firebaseErrorMessage(
    FirebaseAuthException error,
  ) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in instead.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'weak-password':
        return 'Your password is too weak. Please choose a stronger password.';

      case 'operation-not-allowed':
        return 'Email and password sign up is not enabled.';

      case 'network-request-failed':
        return 'Please check your internet connection and try again.';

      default:
        return error.message ?? 'Something went wrong. Please try again.';
    }
  }

  Future<void> createAccount() async {
    FocusScope.of(context).unfocus();

    final bool formIsValid = formKey.currentState?.validate() ?? false;

    if (!formIsValid) {
      return;
    }

    if (!acceptTerms) {
      showMessage(
        'Please accept the Terms and Privacy Policy.',
      );
      return;
    }

    if (isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final String fullName = fullNameController.text.trim();

      final String email = emailController.text.trim();

      final String password = passwordController.text;

      final UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(fullName);

      ProfileStore.userName.value = fullName;

      try {
        await credential.user?.sendEmailVerification();
      } catch (_) {
        // الحساب تم إنشاؤه حتى لو تعذر إرسال رسالة التحقق.
      }

      if (!mounted) {
        return;
      }

      showMessage(
        'Account created successfully.',
        error: false,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileSetupPage(),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      showMessage(
        firebaseErrorMessage(error),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showSocialMessage(String provider) {
    showMessage(
      '$provider login will be connected next.',
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
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                24,
                10,
                24,
                28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: _primaryText(context),
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const _SignUpLogo(),
                  const SizedBox(height: 30),
                  Text(
                    'Create Your Account',
                    style: GoogleFonts.fredoka(
                      color: _primaryText(context),
                      fontSize: 29,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Join Bayan Travel and start your next adventure.',
                    style: GoogleFonts.poppins(
                      color: _secondaryText(context),
                      fontSize: 12,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _FieldLabel(
                    text: 'Full Name',
                  ),
                  const SizedBox(height: 6),
                  AppTextField(
                    controller: fullNameController,
                    label: '',
                    hint: 'Enter your full name',
                    icon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    validator: validateName,
                  ),
                  const SizedBox(height: 15),
                  const _FieldLabel(
                    text: 'Email',
                  ),
                  const SizedBox(height: 6),
                  AppTextField(
                    controller: emailController,
                    label: '',
                    hint: 'Enter your email',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 15),
                  const _FieldLabel(
                    text: 'Password',
                  ),
                  const SizedBox(height: 6),
                  AppTextField(
                    controller: passwordController,
                    label: '',
                    hint: 'Enter your password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: hidePassword,
                    textInputAction: TextInputAction.next,
                    validator: validatePassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _secondaryText(context),
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const _FieldLabel(
                    text: 'Confirm Password',
                  ),
                  const SizedBox(height: 6),
                  AppTextField(
                    controller: confirmPasswordController,
                    label: '',
                    hint: 'Confirm your password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: hideConfirmPassword,
                    textInputAction: TextInputAction.done,
                    validator: validateConfirmPassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hideConfirmPassword = !hideConfirmPassword;
                        });
                      },
                      icon: Icon(
                        hideConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _secondaryText(context),
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: acceptTerms,
                        activeColor: AppColors.primaryBlue,
                        visualDensity: VisualDensity.compact,
                        onChanged: (value) {
                          setState(() {
                            acceptTerms = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text.rich(
                            TextSpan(
                              text:
                                  'I confirm I am 18 or older and accept the ',
                              children: const [
                                TextSpan(
                                  text: 'Terms of Service and Privacy Policy.',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            style: TextStyle(
                              color: _secondaryText(context),
                              fontSize: 9.5,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: isLoading ? null : createAccount,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primaryBlue.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 21,
                              height: 21,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 19),
                  Center(
                    child: Text(
                      'or register with',
                      style: TextStyle(
                        color: _secondaryText(context),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SocialLoginRow(
                    onGooglePressed: () {
                      showSocialMessage(
                        'Google',
                      );
                    },
                    onFacebookPressed: () {
                      showSocialMessage(
                        'Facebook',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: _secondaryText(context),
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _SignUpLogo extends StatelessWidget {
  const _SignUpLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue,
                Color(0xFF45A5F5),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33006EDC),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.flight_takeoff_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bayan Travel',
              style: GoogleFonts.fredoka(
                color: _primaryText(context),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Explore your world',
              style: GoogleFonts.poppins(
                color: _secondaryText(context),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
