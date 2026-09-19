import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'new_credentials_page.dart';

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
  return _isDark(context) ? const Color(0xFF252D34) : const Color(0xFFF9FAFC);
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

class VerificationCodePage extends StatefulWidget {
  const VerificationCodePage({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final List<TextEditingController> codeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  Timer? timer;

  int remainingSeconds = 120;

  bool isVerifying = false;

  String get formattedTime {
    final int minutes = remainingSeconds ~/ 60;

    final int seconds = remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String get enteredCode {
    return codeControllers
        .map(
          (controller) => controller.text,
        )
        .join();
  }

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();

    for (final controller in codeControllers) {
      controller.dispose();
    }

    for (final focusNode in focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  void startTimer() {
    timer?.cancel();

    remainingSeconds = 120;

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (currentTimer) {
        if (!mounted) {
          currentTimer.cancel();
          return;
        }

        if (remainingSeconds <= 1) {
          currentTimer.cancel();

          setState(() {
            remainingSeconds = 0;
          });

          return;
        }

        setState(() {
          remainingSeconds--;
        });
      },
    );
  }

  void handleCodeChanged(
    String value,
    int index,
  ) {
    if (value.isNotEmpty && index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> verifyCode() async {
    if (enteredCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please enter the complete 6-digit code.',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

      return;
    }

    setState(() {
      isVerifying = true;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isVerifying = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewCredentialsPage(
          email: widget.email,
        ),
      ),
    );
  }

  void resendCode() {
    for (final controller in codeControllers) {
      controller.clear();
    }

    focusNodes.first.requestFocus();

    setState(() {
      remainingSeconds = 120;
    });

    startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'A new verification code was sent to ${widget.email}.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
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
              _VerificationHeader(
                onBack: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    30,
                  ),
                  child: Column(
                    children: [
                      const _VerificationBrand(),
                      const SizedBox(height: 36),
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
                                Icons.verified_user_outlined,
                                color: AppColors.primaryBlue,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Code Verification',
                              style: TextStyle(
                                color: _primaryText(context),
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter the six-digit verification code '
                              'sent to ${widget.email}.',
                              style: TextStyle(
                                color: _secondaryText(context),
                                fontSize: 10,
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                6,
                                (index) {
                                  return SizedBox(
                                    width: 42,
                                    height: 51,
                                    child: TextField(
                                      controller: codeControllers[index],
                                      focusNode: focusNodes[index],
                                      autofocus: index == 0,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      textInputAction: index == 5
                                          ? TextInputAction.done
                                          : TextInputAction.next,
                                      maxLength: 1,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onChanged: (value) {
                                        handleCodeChanged(
                                          value,
                                          index,
                                        );
                                      },
                                      onSubmitted: (_) {
                                        if (index == 5) {
                                          verifyCode();
                                        }
                                      },
                                      style: TextStyle(
                                        color: _primaryText(context),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      decoration: InputDecoration(
                                        counterText: '',
                                        filled: true,
                                        fillColor: _fieldBackground(context),
                                        contentPadding: EdgeInsets.zero,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: AppColors.primaryBlue,
                                            width: 1.7,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                remainingSeconds > 0
                                    ? '$formattedTime mins'
                                    : 'Code expired',
                                style: TextStyle(
                                  color: remainingSeconds > 0
                                      ? _secondaryText(context)
                                      : const Color(0xFFE34A4A),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 23),
                            SizedBox(
                              width: double.infinity,
                              height: 49,
                              child: FilledButton(
                                onPressed: isVerifying ? null : verifyCode,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isVerifying
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Verify Code',
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
                                onPressed:
                                    remainingSeconds == 0 ? resendCode : null,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryBlue,
                                  backgroundColor: _cardBackground(context),
                                  side: BorderSide(
                                    color: remainingSeconds == 0
                                        ? AppColors.primaryBlue
                                        : _borderColor(context),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Resend Code',
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

class _VerificationHeader extends StatelessWidget {
  const _VerificationHeader({
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

class _VerificationBrand extends StatelessWidget {
  const _VerificationBrand();

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
        const _VerificationBrandIcon(),
      ],
    );
  }
}

class _VerificationBrandIcon extends StatelessWidget {
  const _VerificationBrandIcon();

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
