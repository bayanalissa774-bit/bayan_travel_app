// ignore_for_file: unused_element

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';

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

class GenderSelectionPage extends StatefulWidget {
  const GenderSelectionPage({super.key});

  @override
  State<GenderSelectionPage> createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage> {
  String selectedGender = 'Male';

  final List<String> genderOptions = const [
    'Male',
    'Female',
    'Non-binary',
    'Self-describe',
    'Prefer not to say',
  ];

  void saveGender() {
    Navigator.pop(context, selectedGender);
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
              _GenderHeader(
                onBack: () {
                  Navigator.pop(context);
                },
                onDone: saveGender,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(
                    18,
                    8,
                    18,
                    22,
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    17,
                    15,
                    17,
                    22,
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
                      Expanded(
                        child: ListView.separated(
                          itemCount: genderOptions.length,
                          separatorBuilder: (context, index) {
                            return Divider(
                              height: 1,
                              color: _borderColor(context),
                            );
                          },
                          itemBuilder: (context, index) {
                            final String option = genderOptions[index];

                            final bool selected = option == selectedGender;

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedGender = option;
                                });
                              },
                              borderRadius: BorderRadius.circular(15),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          color: _primaryText(context),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    _GenderSelectionCircle(
                                      selected: selected,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 165,
                        child: PrimaryButton(
                          text: 'Continue',
                          onPressed: saveGender,
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

class _GenderHeader extends StatelessWidget {
  const _GenderHeader({
    required this.onBack,
    required this.onDone,
  });

  final VoidCallback onBack;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
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
            Expanded(
              child: Text(
                'Select Gender',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _primaryText(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: onDone,
              child: const Text(
                'Done',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderSelectionCircle extends StatelessWidget {
  const _GenderSelectionCircle({
    required this.selected,
  });

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 23,
      height: 23,
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryBlue : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? AppColors.primaryBlue
              : _isDark(context)
                  ? const Color(0xFF52606B)
                  : const Color(0xFFD8DCE2),
        ),
      ),
      child: selected
          ? const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 15,
            )
          : null,
    );
  }
}
