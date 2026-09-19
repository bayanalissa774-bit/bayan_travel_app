import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

bool _isDark(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

Color _pageBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF101418) : Colors.white;
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
  return _isDark(context) ? const Color(0xFF2B343C) : AppColors.borderGrey;
}

class PhonePage extends StatelessWidget {
  const PhonePage({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final Color pageColor = backgroundColor ?? _pageBackground(context);

    return ColoredBox(
      color:
          _isDark(context) ? const Color(0xFF080B0E) : const Color(0xFFE7E7E7),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 430,
          ),
          child: ColoredBox(
            color: pageColor,
            child: child,
          ),
        ),
      ),
    );
  }
}

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.light = false,
    this.large = false,
  });

  final bool light;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Bayan Travel',
          style: TextStyle(
            color: light ? Colors.white : _primaryText(context),
            fontSize: large ? 27 : 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          '🧳',
          style: TextStyle(
            fontSize: large ? 28 : 23,
          ),
        ),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryText(context),
          backgroundColor: _cardBackground(context),
          side: const BorderSide(
            color: AppColors.primaryBlue,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.controller,
    this.keyboardType,
    bool obscureText = false,
    bool? obscure,
    Widget? suffixIcon,
    Widget? suffix,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.textInputAction,
  })  : obscureText = obscure ?? obscureText,
        suffixIcon = suffixIcon ?? suffix;

  final String label;
  final String hint;
  final IconData icon;

  final TextEditingController? controller;

  final TextInputType? keyboardType;

  final bool obscureText;

  final Widget? suffixIcon;

  final int maxLines;

  final String? Function(String?)? validator;

  final ValueChanged<String>? onChanged;

  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      validator: validator,
      onChanged: onChanged,
      textInputAction: textInputAction,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(
        color: _primaryText(context),
      ),
      decoration: InputDecoration(
        labelText: label.isEmpty ? null : label,
        hintText: hint,
        hintStyle: TextStyle(
          color: _secondaryText(context),
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.primaryBlue,
          size: 19,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _fieldBackground(context),
      ),
    );
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.showBack = true,
  });

  final Widget child;
  final String? title;
  final Widget? trailing;
  final bool showBack;

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
              if (showBack || title != null || trailing != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    6,
                    12,
                    0,
                  ),
                  child: Row(
                    children: [
                      if (showBack)
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).maybePop();
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
                        )
                      else
                        const SizedBox(
                          width: 48,
                        ),
                      Expanded(
                        child: Text(
                          title ?? '',
                          style: TextStyle(
                            color: _primaryText(context),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      trailing ??
                          const SizedBox(
                            width: 48,
                          ),
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    26,
                    16,
                    26,
                    30,
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TravelImage extends StatelessWidget {
  const TravelImage({
    super.key,
    String? imageUrl,
    String? url,
    double borderRadius = 0,
    double? radius,
  })  : imageUrl = imageUrl ?? url ?? '',
        borderRadius = radius ?? borderRadius;

  final String imageUrl;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final Color fallbackColor =
        _isDark(context) ? const Color(0xFF173653) : AppColors.lightBlue;

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        borderRadius,
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }

          return Container(
            color: fallbackColor,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryBlue,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: fallbackColor,
            alignment: Alignment.center,
            child: const Icon(
              Icons.landscape_rounded,
              color: AppColors.primaryBlue,
              size: 45,
            ),
          );
        },
      ),
    );
  }
}

class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({
    super.key,
    this.onGooglePressed,
    this.onFacebookPressed,
  });

  final VoidCallback? onGooglePressed;
  final VoidCallback? onFacebookPressed;

  void showProviderMessage(
    BuildContext context,
    String provider,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$provider sign in will be connected with Firebase.',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget socialButton({
    required BuildContext context,
    required Widget icon,
    required String provider,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed ??
            () {
              showProviderMessage(
                context,
                provider,
              );
            },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: _cardBackground(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderColor(context),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: icon,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        socialButton(
          context: context,
          provider: 'Google',
          onPressed: onGooglePressed,
          icon: Image.asset(
            'assets/images/google_g_logo.png',
            width: 27,
            height: 27,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 14),
        socialButton(
          context: context,
          provider: 'Facebook',
          onPressed: onFacebookPressed,
          icon: const Icon(
            Icons.facebook_rounded,
            color: Color(0xFF1877F2),
            size: 32,
          ),
        ),
      ],
    );
  }
}

// اسم قديم مستخدم ببعض الصفحات
class SocialRow extends StatelessWidget {
  const SocialRow({
    super.key,
    this.onGooglePressed,
    this.onFacebookPressed,
  });

  final VoidCallback? onGooglePressed;
  final VoidCallback? onFacebookPressed;

  @override
  Widget build(BuildContext context) {
    return SocialLoginRow(
      onGooglePressed: onGooglePressed,
      onFacebookPressed: onFacebookPressed,
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.large = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final double size = large ? 48 : 42;

    return Material(
      color: _cardBackground(context),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _cardBackground(context),
            shape: BoxShape.circle,
            border: Border.all(
              color: _borderColor(context),
            ),
          ),
          child: Icon(
            icon,
            color: _primaryText(context),
            size: 20,
          ),
        ),
      ),
    );
  }
}
