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

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final List<Map<String, dynamic>> devices = [
    {
      'name': 'Chrome on Windows',
      'location': 'Current device',
      'lastActive': 'Active now',
      'icon': Icons.laptop_windows_rounded,
      'current': true,
    },
    {
      'name': 'Android Phone',
      'location': 'Mobile device',
      'lastActive': '2 days ago',
      'icon': Icons.smartphone_rounded,
      'current': false,
    },
  ];

  void removeDevice(int index) {
    final String deviceName = devices[index]['name'].toString();

    setState(() {
      devices.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$deviceName signed out.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color pageColor = _pageBackground(context);
    final bool dark = _isDark(context);

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
                  14,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
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
                        'Your Devices',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          color: _primaryText(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  2,
                  18,
                  18,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF173653) : AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: dark
                          ? const Color(0xFF244763)
                          : const Color(0xFFD6EBFF),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.security_rounded,
                        color: AppColors.primaryBlue,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'These devices are currently signed in to your Bayan Travel account.',
                          style: TextStyle(
                            color: dark
                                ? const Color(0xFFD8E4EE)
                                : AppColors.greyText,
                            fontSize: 10,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
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
                  itemCount: devices.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 12);
                  },
                  itemBuilder: (context, index) {
                    final device = devices[index];

                    final bool current = device['current'] == true;

                    return Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _cardBackground(context),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: _borderColor(context),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: dark
                                  ? const Color(0xFF173653)
                                  : AppColors.lightBlue,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              device['icon'] as IconData,
                              color: AppColors.primaryBlue,
                              size: 23,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        device['name'].toString(),
                                        style: TextStyle(
                                          color: _primaryText(context),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (current) ...[
                                      const SizedBox(
                                        width: 7,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: dark
                                              ? const Color(
                                                  0xFF17372B,
                                                )
                                              : const Color(
                                                  0xFFE9F9F1,
                                                ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'Current',
                                          style: TextStyle(
                                            color: Color(
                                              0xFF1FA66A,
                                            ),
                                            fontSize: 7.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  device['location'].toString(),
                                  style: TextStyle(
                                    color: _secondaryText(context),
                                    fontSize: 8.5,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  device['lastActive'].toString(),
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!current)
                            IconButton(
                              onPressed: () {
                                removeDevice(index);
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: dark
                                    ? const Color(
                                        0xFF382326,
                                      )
                                    : const Color(
                                        0xFFFFF0F0,
                                      ),
                              ),
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: Color(0xFFE34A4A),
                                size: 20,
                              ),
                            ),
                        ],
                      ),
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
