import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../pages/my_bookings_page.dart';
import 'dashboard_page.dart';

bool _isDark(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

Color _pageBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF101418) : Colors.white;
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

class BookingConfirmedPage extends StatelessWidget {
  const BookingConfirmedPage({super.key});

  void openMyBookings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyBookingsPage(),
      ),
    );
  }

  void backToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const DashboardPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color pageColor = _pageBackground(context);

    final String email =
        FirebaseAuth.instance.currentUser?.email ?? 'your account';

    return Scaffold(
      backgroundColor: pageColor,
      body: PhonePage(
        backgroundColor: pageColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              26,
              7,
              26,
              30,
            ),
            child: Column(
              children: [
                const Spacer(
                  flex: 2,
                ),

                Text(
                  'Booking Confirmed!',
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  'Your booking has been confirmed successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 10,
                  ),
                ),

                const SizedBox(
                  height: 42,
                ),

                Container(
                  width: 125,
                  height: 125,
                  decoration: BoxDecoration(
                    color: _cardBackground(context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryBlue,
                      width: 8,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x24006EDC),
                        blurRadius: 25,
                        offset: Offset(
                          0,
                          10,
                        ),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.primaryBlue,
                    size: 76,
                  ),
                ),

                const SizedBox(
                  height: 43,
                ),

                Text(
                  'Booking belongs to',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 10,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  height: 45,
                ),

                // زر My Bookings
                SizedBox(
                  width: 285,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      openMyBookings(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'View My Bookings',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                // زر العودة للرئيسية
                SizedBox(
                  width: 285,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      backToHome(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      backgroundColor: _cardBackground(context),
                      side: const BorderSide(
                        color: AppColors.primaryBlue,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const Spacer(
                  flex: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
