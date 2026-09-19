import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../models/profile_store.dart';
import '../widgets/common_widgets.dart';
import 'dashboard_page.dart';
import 'forgot_password_page.dart';
import 'sign_up_page.dart';
import 'email_verification_page.dart';

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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool rememberMe = true;
  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void openDashboardPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const DashboardPage(),
      ),
      (route) => false,
    );
  }

  void openSignUpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpPage(),
      ),
    );
  }

  String? validateEmail(String? value) {
    final String email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email';
    }

    if (!email.contains('@') || !email.contains('.')) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Please enter your password';
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
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'user-not-found':
        return 'No account was found with this email.';

      case 'wrong-password':
        return 'The password you entered is incorrect.';

      case 'invalid-credential':
        return 'The email or password is incorrect.';

      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      default:
        return error.message ?? 'Unable to sign in. Please try again.';
    }
  }

  Future<void> login() async {
    FocusScope.of(context).unfocus();

    final bool valid = formKey.currentState?.validate() ?? false;

    if (!valid || isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (kIsWeb) {
        await FirebaseAuth.instance.setPersistence(
          Persistence.LOCAL,
        );
      }

      final UserCredential credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final String? firebaseName = credential.user?.displayName;

      if (firebaseName != null && firebaseName.trim().isNotEmpty) {
        ProfileStore.userName.value = firebaseName.trim();
      }

      await credential.user?.reload();

      final User? currentUser = FirebaseAuth.instance.currentUser;
      debugPrint(
        'EMAIL VERIFIED = ${currentUser?.emailVerified}',
      );

      if (!mounted) {
        return;
      }

      if (currentUser == null) {
        showMessage(
          'Unable to load your account.',
        );
        return;
      }

      if (!currentUser.emailVerified) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const EmailVerificationPage(),
          ),
          (route) => false,
        );

        return;
      }

      showMessage(
        'Welcome back!',
        error: false,
      );

      openDashboardPage();
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
        'Unable to sign in. Please try again.',
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
                7,
                24,
                28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  IconButton(
                    onPressed: () {
                      Navigator.maybePop(context);
                    },
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: _primaryText(context),
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const LoginLogo(),
                  const SizedBox(height: 35),
                  Text(
                    'Welcome Back!',
                    style: GoogleFonts.fredoka(
                      color: _primaryText(context),
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in and continue your next adventure.',
                    style: GoogleFonts.poppins(
                      color: _secondaryText(context),
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 29),
                  _FieldLabel(
                    text: 'Email',
                  ),
                  const SizedBox(height: 4),
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
                  _FieldLabel(
                    text: 'Password',
                  ),
                  const SizedBox(height: 4),
                  AppTextField(
                    controller: passwordController,
                    label: '',
                    hint: 'Enter your password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: hidePassword,
                    textInputAction: TextInputAction.done,
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
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        activeColor: AppColors.primaryBlue,
                        visualDensity: VisualDensity.compact,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                      ),
                      Text(
                        'Remember Me',
                        style: TextStyle(
                          color: _secondaryText(context),
                          fontSize: 9,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: isLoading ? null : login,
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
                              'Log in',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      'or continue with',
                      style: TextStyle(
                        color: _primaryText(context),
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
                  const SizedBox(height: 25),
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Don’t have an account? ',
                          style: TextStyle(
                            color: _primaryText(context),
                            fontSize: 11,
                          ),
                        ),
                        TextButton(
                          onPressed: openSignUpPage,
                          child: const Text(
                            'Sign Up.',
                            style: TextStyle(
                              fontSize: 11,
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
      style: TextStyle(
        color: _secondaryText(context),
        fontSize: 10,
      ),
    );
  }
}

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

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
