import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'make_payment_page.dart';

bool _isDark(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

Color _pageBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF101418) : const Color(0xFFF7F8FA);
}

Color _cardBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF1B2229) : Colors.white;
}

Color _primaryText(BuildContext context) {
  return _isDark(context) ? const Color(0xFFF5F7FA) : const Color(0xFF181A1F);
}

Color _secondaryText(BuildContext context) {
  return _isDark(context) ? const Color(0xFFAAB3BB) : const Color(0xFF747D89);
}

Color _borderColor(BuildContext context) {
  return _isDark(context) ? const Color(0xFF2D3740) : const Color(0xFFE4E9EF);
}

class ConfirmBookingPage extends StatelessWidget {
  const ConfirmBookingPage({super.key});

  static const String hotelImage =
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e'
      '?auto=format&fit=crop&w=800&q=90';

  Map<String, dynamic> _getArguments(BuildContext context) {
    final Object? rawArguments = ModalRoute.of(context)?.settings.arguments;

    if (rawArguments is Map) {
      return Map<String, dynamic>.from(rawArguments);
    }

    return <String, dynamic>{};
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  String _shortDate(DateTime? date) {
    if (date == null) {
      return '--';
    }

    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} '
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _dayName(DateTime? date) {
    if (date == null) {
      return '--';
    }

    const List<String> days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return days[date.weekday - 1];
  }

  String _dateRange(
    DateTime? checkIn,
    DateTime? checkOut,
  ) {
    if (checkIn == null || checkOut == null) {
      return '--';
    }

    return '${_shortDate(checkIn)} – ${_shortDate(checkOut)}';
  }

  String _formatTime(dynamic value) {
    if (value == null) {
      return '--';
    }

    final String raw = value.toString();

    final List<String> parts = raw.split(':');

    if (parts.length != 2) {
      return raw;
    }

    final int? hour = int.tryParse(parts[0]);
    final int? minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return raw;
    }

    final TimeOfDay time = TimeOfDay(
      hour: hour,
      minute: minute,
    );

    final int displayHour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;

    final String displayMinute = time.minute.toString().padLeft(2, '0');

    final String period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$displayHour:$displayMinute $period';
  }

  void _openPayment({
    required BuildContext context,
    required double total,
    required DateTime? checkInDate,
    required DateTime? checkOutDate,
    required String checkInTime,
    required String checkOutTime,
    required int guests,
    required int nights,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MakePaymentPage(
            amount: total,
            checkInDate: checkInDate?.toIso8601String(),
            checkOutDate: checkOutDate?.toIso8601String(),
            checkInTime: checkInTime,
            checkOutTime: checkOutTime,
            guests: guests,
            nights: nights,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = _getArguments(context);

    final DateTime? checkInDate = _parseDate(args['checkInDate']);

    final DateTime? checkOutDate = _parseDate(args['checkOutDate']);

    final String checkInTime = _formatTime(args['checkInTime']);

    final String checkOutTime = _formatTime(args['checkOutTime']);

    final int guests = (args['guests'] as num?)?.toInt() ?? 2;

    final int nights = (args['nights'] as num?)?.toInt() ?? 3;

    final double pricePerNight =
        (args['pricePerNight'] as num?)?.toDouble() ?? 85.0;

    const int rooms = 1;
    const double tax = 1.50;

    final double subTotal = pricePerNight * nights;

    final double total = subTotal + tax;

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
                  5,
                  16,
                  5,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: _cardBackground(
                          context,
                        ),
                        shape: const CircleBorder(),
                      ),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _primaryText(
                          context,
                        ),
                        size: 17,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Confirm Booking',
                          style: GoogleFonts.fredoka(
                            color: _primaryText(
                              context,
                            ),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Review your stay',
                        style: GoogleFonts.fredoka(
                          color: _primaryText(
                            context,
                          ),
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Check your booking details before continuing to payment.',
                        style: TextStyle(
                          color: _secondaryText(
                            context,
                          ),
                          fontSize: 11.5,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(
                          14,
                        ),
                        decoration: BoxDecoration(
                          color: _cardBackground(
                            context,
                          ),
                          borderRadius: BorderRadius.circular(
                            22,
                          ),
                          border: Border.all(
                            color: _borderColor(
                              context,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 78,
                              height: 78,
                              child: TravelImage(
                                imageUrl: hotelImage,
                                borderRadius: 16,
                              ),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'The Nautilus Maldives',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _primaryText(
                                        context,
                                      ),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        color: AppColors.primaryBlue,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Baa Atoll, Maldives',
                                          style: TextStyle(
                                            color: _secondaryText(
                                              context,
                                            ),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    '\$${pricePerNight.toStringAsFixed(2)} / night',
                                    style: const TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Booking Summary',
                        style: GoogleFonts.fredoka(
                          color: _primaryText(
                            context,
                          ),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 13),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(
                          18,
                        ),
                        decoration: BoxDecoration(
                          color: _cardBackground(
                            context,
                          ),
                          borderRadius: BorderRadius.circular(
                            22,
                          ),
                          border: Border.all(
                            color: _borderColor(
                              context,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            _BookingInfoRow(
                              icon: Icons.payments_outlined,
                              iconColor: AppColors.primaryBlue,
                              title: 'Price / Night',
                              value: '\$${pricePerNight.toStringAsFixed(2)}',
                            ),
                            _InfoDivider(),
                            _BookingInfoRow(
                              icon: Icons.date_range_rounded,
                              iconColor: const Color(
                                0xFF8B7CF6,
                              ),
                              title: 'Dates',
                              value: _dateRange(
                                checkInDate,
                                checkOutDate,
                              ),
                            ),
                            _InfoDivider(),
                            _BookingInfoRow(
                              icon: Icons.hotel_outlined,
                              iconColor: AppColors.orange,
                              title: 'Room',
                              value: '$rooms Room',
                            ),
                            _InfoDivider(),
                            _BookingInfoRow(
                              icon: Icons.people_alt_outlined,
                              iconColor: const Color(
                                0xFF1FA66A,
                              ),
                              title: 'Guests',
                              value:
                                  '$guests ${guests == 1 ? 'Guest' : 'Guests'}',
                            ),
                            _InfoDivider(),
                            _BookingInfoRow(
                              icon: Icons.nights_stay_outlined,
                              iconColor: const Color(
                                0xFFEC7A40,
                              ),
                              title: 'Stay',
                              value:
                                  '$nights ${nights == 1 ? 'Night' : 'Nights'}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _DateCard(
                              title: 'Check In',
                              date: _shortDate(
                                checkInDate,
                              ),
                              day: _dayName(
                                checkInDate,
                              ),
                              time: checkInTime,
                              icon: Icons.login_rounded,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DateCard(
                              title: 'Check Out',
                              date: _shortDate(
                                checkOutDate,
                              ),
                              day: _dayName(
                                checkOutDate,
                              ),
                              time: checkOutTime,
                              icon: Icons.logout_rounded,
                              color: const Color(
                                0xFF8B7CF6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(
                          18,
                        ),
                        decoration: BoxDecoration(
                          color: _cardBackground(
                            context,
                          ),
                          borderRadius: BorderRadius.circular(
                            22,
                          ),
                          border: Border.all(
                            color: _borderColor(
                              context,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            _PriceRow(
                              title:
                                  '\$${pricePerNight.toStringAsFixed(2)} × $nights nights',
                              value: '\$${subTotal.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 13),
                            _PriceRow(
                              title: 'Taxes & fees',
                              value: '\$${tax.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 16),
                            Divider(
                              height: 1,
                              color: _borderColor(
                                context,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    color: _primaryText(
                                      context,
                                    ),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '\$${total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 27),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: FilledButton(
                          onPressed: () {
                            _openPayment(
                              context: context,
                              total: total,
                              checkInDate: checkInDate,
                              checkOutDate: checkOutDate,
                              checkInTime: checkInTime,
                              checkOutTime: checkOutTime,
                              guests: guests,
                              nights: nights,
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                27,
                              ),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Proceed to Payment',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              color: _secondaryText(
                                context,
                              ),
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Secure payment with Bayan Wallet',
                              style: TextStyle(
                                color: _secondaryText(
                                  context,
                                ),
                                fontSize: 10.5,
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

class _BookingInfoRow extends StatelessWidget {
  const _BookingInfoRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.11),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 19,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 11.5,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 13,
      ),
      child: Divider(
        height: 1,
        color: _borderColor(context),
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.title,
    required this.date,
    required this.day,
    required this.time,
    required this.icon,
    required this.color,
  });

  final String title;
  final String date;
  final String day;
  final String time;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(
                    11,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: _secondaryText(
                      context,
                    ),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            date,
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '$day • $time',
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 11.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
