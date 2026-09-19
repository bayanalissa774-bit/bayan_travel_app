import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  return _isDark(context) ? const Color(0xFF2B343C) : const Color(0xFFE8EDF2);
}

class CurrencySelectionPage extends StatefulWidget {
  const CurrencySelectionPage({
    super.key,
    required this.selectedCurrency,
  });

  final String selectedCurrency;

  @override
  State<CurrencySelectionPage> createState() => _CurrencySelectionPageState();
}

class _CurrencySelectionPageState extends State<CurrencySelectionPage> {
  late String selectedCurrency;

  final List<Map<String, String>> currencies = const [
    {
      'code': 'USD',
      'name': 'US Dollar',
      'symbol': '\$',
      'country': 'United States',
    },
    {
      'code': 'EUR',
      'name': 'Euro',
      'symbol': '€',
      'country': 'Europe',
    },
    {
      'code': 'GBP',
      'name': 'British Pound',
      'symbol': '£',
      'country': 'United Kingdom',
    },
    {
      'code': 'SAR',
      'name': 'Saudi Riyal',
      'symbol': '﷼',
      'country': 'Saudi Arabia',
    },
    {
      'code': 'AED',
      'name': 'UAE Dirham',
      'symbol': 'د.إ',
      'country': 'United Arab Emirates',
    },
    {
      'code': 'TRY',
      'name': 'Turkish Lira',
      'symbol': '₺',
      'country': 'Türkiye',
    },
  ];

  @override
  void initState() {
    super.initState();

    selectedCurrency = widget.selectedCurrency;
  }

  Map<String, String> get currentCurrency {
    return currencies.firstWhere(
      (currency) => currency['code'] == selectedCurrency,
      orElse: () => currencies.first,
    );
  }

  void selectCurrency(String currency) {
    setState(() {
      selectedCurrency = currency;
    });

    Future.delayed(
      const Duration(milliseconds: 180),
      () {
        if (!mounted) {
          return;
        }

        Navigator.pop(
          context,
          currency,
        );
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
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  12,
                  18,
                  12,
                ),
                child: Row(
                  children: [
                    _CircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Select Currency',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          color: _primaryText(context),
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  4,
                  18,
                  18,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryBlue,
                        Color(0xFF45A5F5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33006EDC),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(
                            0x33FFFFFF,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(
                              0x55FFFFFF,
                            ),
                          ),
                        ),
                        child: Text(
                          currentCurrency['symbol']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current currency',
                              style: TextStyle(
                                color: Color(
                                  0xCCFFFFFF,
                                ),
                                fontSize: 9,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              currentCurrency['code']!,
                              style: GoogleFonts.fredoka(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentCurrency['name']!,
                              style: const TextStyle(
                                color: Color(
                                  0xDDFFFFFF,
                                ),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.currency_exchange_rounded,
                        color: Colors.white,
                        size: 27,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  21,
                  0,
                  21,
                  10,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Available currencies',
                    style: GoogleFonts.poppins(
                      color: _primaryText(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    0,
                    18,
                    28,
                  ),
                  itemCount: currencies.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: 11,
                    );
                  },
                  itemBuilder: (context, index) {
                    final currency = currencies[index];

                    final bool selected = selectedCurrency == currency['code'];

                    return _CurrencyCard(
                      currency: currency,
                      selected: selected,
                      onPressed: () {
                        selectCurrency(
                          currency['code']!,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencyCard extends StatelessWidget {
  const _CurrencyCard({
    required this.currency,
    required this.selected,
    required this.onPressed,
  });

  final Map<String, String> currency;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool dark = _isDark(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(21),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? dark
                    ? const Color(0xFF172B3D)
                    : const Color(0xFFF0F7FF)
                : _cardBackground(context),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: selected ? AppColors.primaryBlue : _borderColor(context),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 220,
                ),
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryBlue,
                            Color(0xFF45A5F5),
                          ],
                        )
                      : null,
                  color: selected
                      ? null
                      : dark
                          ? const Color(
                              0xFF252D34,
                            )
                          : const Color(
                              0xFFF4F7FA,
                            ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  currency['symbol']!,
                  style: TextStyle(
                    color: selected ? Colors.white : _primaryText(context),
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          currency['code']!,
                          style: TextStyle(
                            color: selected
                                ? AppColors.primaryBlue
                                : _primaryText(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: dark
                                  ? const Color(
                                      0xFF173653,
                                    )
                                  : AppColors.lightBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Selected',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 7,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currency['name']!,
                      style: TextStyle(
                        color: _secondaryText(context),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currency['country']!,
                      style: TextStyle(
                        color: _secondaryText(context),
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 220,
                ),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryBlue
                      : dark
                          ? const Color(
                              0xFF252D34,
                            )
                          : const Color(
                              0xFFF5F7FA,
                            ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  selected
                      ? Icons.check_rounded
                      : Icons.arrow_forward_ios_rounded,
                  color: selected ? Colors.white : _secondaryText(context),
                  size: selected ? 17 : 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _cardBackground(context),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
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
