import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'login_page.dart';

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

class PasswordUpdatedPage extends StatelessWidget {
  const PasswordUpdatedPage({
    super.key,
    required this.email,
  });

  final String email;

  void openLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
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
              _SuccessHeader(
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
                      const _SuccessBrand(),
                      const SizedBox(height: 36),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          22,
                          29,
                          22,
                          28,
                        ),
                        decoration: BoxDecoration(
                          color: _cardBackground(context),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: _borderColor(context),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: _isDark(context)
                                    ? const Color(0xFF17372B)
                                    : const Color(0xFFE9F9F1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Color(
                                  0xFF1FA66A,
                                ),
                                size: 43,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              'Password Updated',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _primaryText(context),
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your password for $email has been '
                              'successfully updated.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _secondaryText(context),
                                fontSize: 10,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 27),
                            SizedBox(
                              width: double.infinity,
                              height: 49,
                              child: FilledButton(
                                onPressed: () {
                                  openLogin(context);
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
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
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader({
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

class _SuccessBrand extends StatelessWidget {
  const _SuccessBrand();

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
        const _SuccessBrandIcon(),
      ],
    );
  }
}

class _SuccessBrandIcon extends StatelessWidget {
  const _SuccessBrandIcon();

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
