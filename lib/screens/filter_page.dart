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
  return _isDark(context) ? const Color(0xFF2B343C) : const Color(0xFFE5E8ED);
}

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  static const double minimumPrice = 0;
  static const double maximumPrice = 150;

  RangeValues priceRange = const RangeValues(50, 100);

  String? selectedLanguage;
  String? selectedActivity;
  String? selectedLocation;

  final List<String> languages = const [
    'English',
    'Arabic',
    'French',
    'Spanish',
  ];

  final List<String> activities = const [
    'Beach',
    'Mountain',
    'Camping',
    'City Tour',
  ];

  final List<String> locations = const [
    'Maldives',
    'New York',
    'London',
    'Sydney',
    'Toronto',
  ];

  void clearFilters() {
    setState(() {
      priceRange = const RangeValues(50, 100);
      selectedLanguage = null;
      selectedActivity = null;
      selectedLocation = null;
    });
  }

  void applyFilters() {
    Navigator.pop(
      context,
      <String, dynamic>{
        'minimumPrice': priceRange.start.round(),
        'maximumPrice': priceRange.end.round(),
        'language': selectedLanguage,
        'activity': selectedActivity,
        'location': selectedLocation,
      },
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
              _FilterAppBar(
                onBack: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    14,
                    18,
                    28,
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      14,
                      18,
                      24,
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
                        Row(
                          children: [
                            _SmallIconButton(
                              icon: Icons.close_rounded,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: clearFilters,
                              child: const Text(
                                'Clear All Filters',
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Price range',
                                style: TextStyle(
                                  color: _primaryText(context),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _isDark(context)
                                    ? const Color(0xFF173653)
                                    : AppColors.lightBlue,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                '\$${priceRange.start.round()} - \$${priceRange.end.round()}',
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 11),
                        _PriceWaveSlider(
                          values: priceRange,
                          minimum: minimumPrice,
                          maximum: maximumPrice,
                          onChanged: (values) {
                            setState(() {
                              priceRange = values;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        _FilterDropdown(
                          label: 'Languages',
                          hint: 'Select language',
                          value: selectedLanguage,
                          icon: Icons.language_rounded,
                          items: languages,
                          onChanged: (value) {
                            setState(() {
                              selectedLanguage = value;
                            });
                          },
                        ),
                        const SizedBox(height: 15),
                        _FilterDropdown(
                          label: 'Activities',
                          hint: 'Select activity',
                          value: selectedActivity,
                          icon: Icons.hiking_rounded,
                          items: activities,
                          onChanged: (value) {
                            setState(() {
                              selectedActivity = value;
                            });
                          },
                        ),
                        const SizedBox(height: 15),
                        _FilterDropdown(
                          label: 'Location',
                          hint: 'Select location',
                          value: selectedLocation,
                          icon: Icons.location_on_outlined,
                          items: locations,
                          onChanged: (value) {
                            setState(() {
                              selectedLocation = value;
                            });
                          },
                        ),
                        const SizedBox(height: 44),
                        Center(
                          child: SizedBox(
                            width: 175,
                            child: PrimaryButton(
                              text: 'Apply Filters',
                              onPressed: applyFilters,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: clearFilters,
                            child: Text(
                              'Reset selections',
                              style: TextStyle(
                                color: _secondaryText(context),
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _FilterAppBar extends StatelessWidget {
  const _FilterAppBar({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      color: _pageBackground(context),
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
              'Filters',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  const _SmallIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          _isDark(context) ? const Color(0xFF252D34) : const Color(0xFFF5F7FA),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            color: _primaryText(context),
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _PriceWaveSlider extends StatelessWidget {
  const _PriceWaveSlider({
    required this.values,
    required this.minimum,
    required this.maximum,
    required this.onChanged,
  });

  final RangeValues values;
  final double minimum;
  final double maximum;
  final ValueChanged<RangeValues> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: Stack(
        children: [
          Positioned(
            left: 8,
            right: 8,
            top: 1,
            bottom: 12,
            child: CustomPaint(
              painter: _PriceWavePainter(
                values: values,
                minimum: minimum,
                maximum: maximum,
                inactiveColor: _isDark(context)
                    ? const Color(0xFF39434C)
                    : const Color(0xFFE7EAF0),
              ),
            ),
          ),
          Positioned(
            left: -8,
            right: -8,
            bottom: -2,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                thumbColor: AppColors.primaryBlue,
                overlayColor: AppColors.primaryBlue.withOpacity(0.12),
                trackHeight: 3,
                rangeThumbShape: const RoundRangeSliderThumbShape(
                  enabledThumbRadius: 7,
                  elevation: 2,
                ),
              ),
              child: RangeSlider(
                values: values,
                min: minimum,
                max: maximum,
                divisions: 30,
                labels: RangeLabels(
                  '\$${values.start.round()}',
                  '\$${values.end.round()}',
                ),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceWavePainter extends CustomPainter {
  const _PriceWavePainter({
    required this.values,
    required this.minimum,
    required this.maximum,
    required this.inactiveColor,
  });

  final RangeValues values;
  final double minimum;
  final double maximum;
  final Color inactiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double range = maximum - minimum;

    final double startPercent =
        ((values.start - minimum) / range).clamp(0.0, 1.0);

    final double endPercent = ((values.end - minimum) / range).clamp(0.0, 1.0);

    final double startX = size.width * startPercent;

    final double endX = size.width * endPercent;

    final double trackY = size.height * 0.78;

    final double span = (endX - startX).clamp(1.0, size.width);

    final Paint inactiveTrackPaint = Paint()
      ..color = inactiveColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, trackY),
      Offset(size.width, trackY),
      inactiveTrackPaint,
    );

    final Path wavePath = Path()
      ..moveTo(startX, trackY)
      ..cubicTo(
        startX + span * 0.08,
        trackY - 35,
        startX + span * 0.20,
        trackY - 43,
        startX + span * 0.33,
        trackY - 24,
      )
      ..cubicTo(
        startX + span * 0.45,
        trackY - 7,
        startX + span * 0.53,
        trackY - 37,
        startX + span * 0.66,
        trackY - 39,
      )
      ..cubicTo(
        startX + span * 0.80,
        trackY - 41,
        startX + span * 0.86,
        trackY - 15,
        endX,
        trackY - 21,
      )
      ..lineTo(endX, trackY)
      ..close();

    final Paint wavePaint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      wavePath,
      wavePaint,
    );

    final Paint activeLinePaint = Paint()
      ..color = AppColors.primaryBlue
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(startX, trackY),
      Offset(endX, trackY),
      activeLinePaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _PriceWavePainter oldDelegate,
  ) {
    return oldDelegate.values != values ||
        oldDelegate.minimum != minimum ||
        oldDelegate.maximum != maximum ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String? value;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          menuMaxHeight: 250,
          dropdownColor: _cardBackground(context),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _secondaryText(context),
            size: 18,
          ),
          hint: Text(
            hint,
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 9,
            ),
          ),
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 18,
            ),
            filled: true,
            fillColor: _isDark(context)
                ? const Color(0xFF252D34)
                : const Color(0xFFFBFCFD),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: _borderColor(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 1.2,
              ),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
