import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'dashboard_page.dart';

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

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({
    super.key,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool isChecking = false;
  bool isSending = false;

  void showMessage(
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            error ? const Color(0xFFE94B4B) : const Color(0xFF1FA66A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  void openDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const DashboardPage(),
      ),
      (route) => false,
    );
  }

  Future<void> resendVerification() async {
    if (isSending) return;

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage(
        'Please log in again.',
        error: true,
      );
      return;
    }

    await user.reload();

    final User? refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser?.emailVerified == true) {
      showMessage(
        'Your email is already verified.',
      );
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      await refreshedUser?.sendEmailVerification();

      if (!mounted) return;

      showMessage(
        'Verification email sent. Check Inbox or Spam.',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'too-many-requests') {
        showMessage(
          'Too many requests. Wait a little and try again.',
          error: true,
        );
      } else {
        showMessage(
          'Could not send verification email.',
          error: true,
        );
      }
    } catch (_) {
      if (!mounted) return;

      showMessage(
        'Something went wrong. Please try again.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  Future<void> checkVerification() async {
    if (isChecking) return;

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage(
        'Please log in again.',
        error: true,
      );
      return;
    }

    setState(() {
      isChecking = true;
    });

    try {
      await user.reload();

      final User? refreshedUser = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      debugPrint(
        'EMAIL VERIFIED = ${refreshedUser?.emailVerified}',
      );

      if (refreshedUser?.emailVerified == true) {
        showMessage(
          'Email verified successfully!',
        );

        openDashboard();
      } else {
        showMessage(
          'Your email is not verified yet. Check your email and open the verification link.',
          error: true,
        );
      }
    } on FirebaseAuthException {
      if (!mounted) return;

      showMessage(
        'Could not check verification status.',
        error: true,
      );
    } catch (_) {
      if (!mounted) return;

      showMessage(
        'Something went wrong. Please try again.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isChecking = false;
        });
      }
    }
  }

  void continueForTesting() {
    if (!kDebugMode) {
      return;
    }

    showMessage(
      'Debug mode: verification skipped for testing.',
    );

    openDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final Color pageColor = _pageBackground(context);

    final String email =
        FirebaseAuth.instance.currentUser?.email ?? 'your email';

    return Scaffold(
      backgroundColor: pageColor,
      body: PhonePage(
        backgroundColor: pageColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              28,
              7,
              28,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 42),

                const _EmailBrandLogo(),

                const SizedBox(height: 37),

                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _isDark(context)
                        ? const Color(0xFF173653)
                        : AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    color: AppColors.primaryBlue,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  'Verify Your Email',
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  'We sent a verification link to:',
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 7),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _isDark(context)
                        ? const Color(0xFF173653)
                        : const Color(0xFFEAF4FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    email,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  'Open your email and click the verification link. Then come back here and press Continue.',
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 10,
                    height: 1.55,
                  ),
                ),

                const SizedBox(height: 19),

                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Didn’t receive a link? ',
                      style: TextStyle(
                        color: _primaryText(context),
                        fontSize: 10.5,
                      ),
                    ),
                    InkWell(
                      onTap: isSending ? null : resendVerification,
                      child: Text(
                        isSending ? 'Sending...' : 'Re-send',
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Center(
                  child: SizedBox(
                    width: 200,
                    child: PrimaryButton(
                      text: isChecking ? 'Checking...' : 'Continue',
                      onPressed: checkVerification,
                    ),
                  ),
                ),

                // يظهر فقط أثناء تشغيل المشروع بوضع Debug.
                if (kDebugMode) ...[
                  const SizedBox(height: 13),
                  Center(
                    child: TextButton.icon(
                      onPressed: continueForTesting,
                      icon: const Icon(
                        Icons.science_outlined,
                        size: 16,
                      ),
                      label: const Text(
                        'Skip for testing',
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        textStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Debug only — hidden in release build',
                      style: TextStyle(
                        color: _secondaryText(context),
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailBrandLogo extends StatelessWidget {
  const _EmailBrandLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Bayan Travel',
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 7),
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [
                Color(0xFFFFA62B),
                Color(0xFFEF3F9D),
                Color(0xFF7928CA),
              ],
            ).createShader(bounds);
          },
          child: const Icon(
            Icons.location_on_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ],
    );
  }
}
