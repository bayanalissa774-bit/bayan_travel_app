import 'package:flutter/material.dart';

class BookingDetailsPage extends StatelessWidget {
  const BookingDetailsPage({
    super.key,
    required this.booking,
  });

  final Map<String, dynamic> booking;

  String formatDate(dynamic timestamp) {
    if (timestamp == null || timestamp is! num) {
      return 'Not available';
    }

    final DateTime date = DateTime.fromMillisecondsSinceEpoch(
      timestamp.toInt(),
    );

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final String bookingId = booking['id']?.toString() ?? '-';

    final String hotelName = booking['hotelName']?.toString() ?? 'Hotel';

    final double amount = (booking['amount'] as num?)?.toDouble() ?? 0.0;

    final String status = booking['status']?.toString() ?? 'confirmed';

    final String paymentStatus = booking['paymentStatus']?.toString() ?? 'paid';

    final String bookingDate = formatDate(
      booking['createdAt'],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Booking Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.hotel_rounded,
                      size: 38,
                      color: Color(0xFF0877E8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hotelName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F7ED),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF1FA66A),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Booking Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFE5E8ED),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  BookingDetailRow(
                    icon: Icons.confirmation_number_outlined,
                    title: 'Booking ID',
                    value: bookingId,
                  ),
                  const Divider(height: 30),
                  BookingDetailRow(
                    icon: Icons.calendar_today_outlined,
                    title: 'Booking Date',
                    value: bookingDate,
                  ),
                  const Divider(height: 30),
                  BookingDetailRow(
                    icon: Icons.payments_outlined,
                    title: 'Amount',
                    value: '\$${amount.toStringAsFixed(2)}',
                  ),
                  const Divider(height: 30),
                  BookingDetailRow(
                    icon: Icons.credit_card_outlined,
                    title: 'Payment',
                    value: paymentStatus.toUpperCase(),
                    valueColor: const Color(0xFF1FA66A),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8F0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: Color(0xFF1FA66A),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your booking is confirmed and the payment has been completed successfully.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingDetailRow extends StatelessWidget {
  const BookingDetailRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF4FF),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF0877E8),
            size: 21,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
