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

Color _borderColor(BuildContext context) {
  return _isDark(context) ? const Color(0xFF2B343C) : const Color(0xFFF0F1F3);
}

class ActivitiesSelectionPage extends StatefulWidget {
  const ActivitiesSelectionPage({super.key});

  @override
  State<ActivitiesSelectionPage> createState() =>
      _ActivitiesSelectionPageState();
}

class _ActivitiesSelectionPageState extends State<ActivitiesSelectionPage> {
  final Set<String> selectedActivities = <String>{
    'Music',
    'Fast food',
    'Outdoor activities',
    'Bicycle',
    'Basketball',
    'Video games',
    'Kids activities',
    'Nightlife',
    'Football',
  };

  final List<_ActivityOption> activities = const [
    _ActivityOption(
      name: 'Tennis',
      icon: Icons.sports_tennis_rounded,
      backgroundColor: Color(0xFFF1F8D8),
      iconColor: Color(0xFF8BAE16),
    ),
    _ActivityOption(
      name: 'Music',
      icon: Icons.music_note_rounded,
      backgroundColor: Color(0xFFFFE9EE),
      iconColor: Color(0xFFE64E68),
    ),
    _ActivityOption(
      name: 'Fast food',
      icon: Icons.fastfood_rounded,
      backgroundColor: Color(0xFFFFF2E5),
      iconColor: AppColors.orange,
    ),
    _ActivityOption(
      name: 'Outdoor activities',
      icon: Icons.hiking_rounded,
      backgroundColor: Color(0xFFFFEDE5),
      iconColor: Color(0xFFE86A2A),
    ),
    _ActivityOption(
      name: 'Bicycle',
      icon: Icons.directions_bike_rounded,
      backgroundColor: Color(0xFFEAF4FF),
      iconColor: AppColors.primaryBlue,
    ),
    _ActivityOption(
      name: 'Basketball',
      icon: Icons.sports_basketball_rounded,
      backgroundColor: Color(0xFFFFF0E5),
      iconColor: Color(0xFFE27625),
    ),
    _ActivityOption(
      name: 'Video games',
      icon: Icons.sports_esports_rounded,
      backgroundColor: Color(0xFFF0EDFF),
      iconColor: Color(0xFF7259D9),
    ),
    _ActivityOption(
      name: 'Kids activities',
      icon: Icons.child_care_rounded,
      backgroundColor: Color(0xFFEAF4FF),
      iconColor: Color(0xFF4D8ECC),
    ),
    _ActivityOption(
      name: 'Skiing',
      icon: Icons.downhill_skiing_rounded,
      backgroundColor: Color(0xFFEAF7FF),
      iconColor: Color(0xFF2994C8),
    ),
    _ActivityOption(
      name: 'Swimming',
      icon: Icons.pool_rounded,
      backgroundColor: Color(0xFFE7F8FC),
      iconColor: Color(0xFF138AB2),
    ),
    _ActivityOption(
      name: 'Camping',
      icon: Icons.cabin_rounded,
      backgroundColor: Color(0xFFFFF2E5),
      iconColor: AppColors.orange,
    ),
    _ActivityOption(
      name: 'Nightlife',
      icon: Icons.nightlife_rounded,
      backgroundColor: Color(0xFFF0EDFF),
      iconColor: Color(0xFF7259D9),
    ),
    _ActivityOption(
      name: 'Football',
      icon: Icons.sports_soccer_rounded,
      backgroundColor: Color(0xFFE9F9F1),
      iconColor: Color(0xFF1FA66A),
    ),
  ];

  void saveActivities() {
    Navigator.pop(
      context,
      selectedActivities.toList(),
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
              _ActivitiesHeader(
                onBack: () {
                  Navigator.pop(context);
                },
                onDone: saveActivities,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(18, 8, 18, 22),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
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
                          itemCount: activities.length,
                          separatorBuilder: (context, index) {
                            return Divider(
                              height: 1,
                              indent: 46,
                              color: _borderColor(context),
                            );
                          },
                          itemBuilder: (context, index) {
                            final activity = activities[index];

                            final bool selected = selectedActivities.contains(
                              activity.name,
                            );

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (selected) {
                                    selectedActivities.remove(
                                      activity.name,
                                    );
                                  } else {
                                    selectedActivities.add(
                                      activity.name,
                                    );
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(15),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: _isDark(context)
                                            ? activity.iconColor
                                                .withOpacity(0.16)
                                            : activity.backgroundColor,
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      child: Icon(
                                        activity.icon,
                                        color: activity.iconColor,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        activity.name,
                                        style: TextStyle(
                                          color: _primaryText(context),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    _ActivitySelectionCircle(
                                      selected: selected,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 165,
                        child: PrimaryButton(
                          text: 'Continue',
                          onPressed: saveActivities,
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

class _ActivityOption {
  const _ActivityOption({
    required this.name,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final String name;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
}

class _ActivitiesHeader extends StatelessWidget {
  const _ActivitiesHeader({
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
                'Select Activities',
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

class _ActivitySelectionCircle extends StatelessWidget {
  const _ActivitySelectionCircle({
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
