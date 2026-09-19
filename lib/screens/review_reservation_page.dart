import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'booking_confirmed_page.dart';

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

Color _borderColor(BuildContext context) {
  return _isDark(context) ? const Color(0xFF303A43) : const Color(0xFFB8B8B8);
}

class ReviewReservationPage extends StatelessWidget {
  const ReviewReservationPage({super.key});

  static const String hotelImage =
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e'
      '?auto=format&fit=crop&w=500&q=90';

  void openBookingConfirmedPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingConfirmedPage(),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  8,
                  4,
                  16,
                  3,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _primaryText(context),
                        size: 18,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Review Reservation',
                          style: TextStyle(
                            color: _primaryText(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    22,
                    12,
                    22,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 72,
                            height: 48,
                            child: TravelImage(
                              imageUrl: hotelImage,
                              borderRadius: 15,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'The Nautilus Maldives',
                                  style: TextStyle(
                                    color: _primaryText(context),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      color: AppColors.primaryBlue,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        'The Nautilus Maldives, Baa Atoll',
                                        style: TextStyle(
                                          color: _secondaryText(context),
                                          fontSize: 7.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 21),
                      Text(
                        'Stay Information',
                        style: TextStyle(
                          color: _secondaryText(context),
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        'Feb 06-09 (3 Nights)',
                        style: TextStyle(
                          color: _primaryText(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1 Room, 2 Guests',
                        style: TextStyle(
                          color: _primaryText(context),
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 13),
                      Divider(
                        color: _borderColor(context),
                      ),
                      Text(
                        'Summary of charges',
                        style: TextStyle(
                          color: _secondaryText(context),
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const _ReservationPriceRow(
                        title: 'Mon, Feb 06',
                        value: '85 USD',
                      ),
                      const _ReservationPriceRow(
                        title: 'Tue, Feb 07',
                        value: '85 USD',
                      ),
                      const _ReservationPriceRow(
                        title: 'Wed, Feb 08',
                        value: '85 USD',
                      ),
                      const _ReservationPriceRow(
                        title: 'Tax',
                        value: '1.50 USD',
                      ),
                      Divider(
                        height: 17,
                        color: _borderColor(context),
                      ),
                      const _ReservationPriceRow(
                        title: 'Total',
                        value: '256.05 USD',
                        bold: true,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Payment Information',
                        style: TextStyle(
                          color: _secondaryText(context),
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          const _MiniVisaCard(),
                          const SizedBox(width: 8),
                          Text(
                            '••••   ••••   8979',
                            style: TextStyle(
                              color: _primaryText(context),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Modifying',
                        style: TextStyle(
                          color: _secondaryText(context),
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Any change in the length or dates of a reservation '
                        'may result in a rate change.',
                        style: TextStyle(
                          color: _primaryText(context),
                          fontSize: 8.5,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        color: _borderColor(context),
                      ),
                      Text(
                        'Cancellation Policy',
                        style: TextStyle(
                          color: _secondaryText(context),
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'You may cancel your reservation for no charge '
                        'before 3 days arrival. Please note that we will '
                        'assess a fee of 256.05 USD if you cancel after '
                        'this deadline.',
                        style: TextStyle(
                          color: _primaryText(context),
                          fontSize: 8.5,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: SizedBox(
                          width: 170,
                          child: PrimaryButton(
                            text: 'Confirm Booking',
                            onPressed: () {
                              openBookingConfirmedPage(
                                context,
                              );
                            },
                          ),
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

class _ReservationPriceRow extends StatelessWidget {
  const _ReservationPriceRow({
    required this.title,
    required this.value,
    this.bold = false,
  });

  final String title;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 9,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: bold ? AppColors.primaryBlue : _primaryText(context),
              fontSize: 9,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniVisaCard extends StatelessWidget {
  const _MiniVisaCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 37,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF075EBB),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text(
        'VISA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
