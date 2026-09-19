import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'booking_page.dart';

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
  return _isDark(context) ? const Color(0xFFF4F7F9) : AppColors.blackText;
}

Color _secondaryText(BuildContext context) {
  return _isDark(context) ? const Color(0xFFAAB3BB) : const Color(0xFF747D89);
}

Color _borderColor(BuildContext context) {
  return _isDark(context) ? const Color(0xFF2B343C) : const Color(0xFFE4E9EF);
}

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  static const String databaseUrl =
      'https://bayan-travel-app-2026-default-rtdb.europe-west1.firebasedatabase.app';

  int selectedTab = 0;
  bool isLoading = true;

  List<Map<String, dynamic>> bookings = [];

  StreamSubscription<DatabaseEvent>? bookingSubscription;

  DatabaseReference? bookingsReference;

  @override
  void initState() {
    super.initState();
    listenToBookings();
  }

  @override
  void dispose() {
    bookingSubscription?.cancel();
    super.dispose();
  }

  void listenToBookings() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final FirebaseDatabase database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    );

    bookingsReference = database.ref(
      'users/${user.uid}/bookings',
    );

    bookingSubscription = bookingsReference!.onValue.listen(
      (event) {
        final Object? value = event.snapshot.value;

        final List<Map<String, dynamic>> loadedBookings = [];

        if (value is Map) {
          final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
            value,
          );

          data.forEach(
            (key, value) {
              if (value is Map) {
                final Map<dynamic, dynamic> item = Map<dynamic, dynamic>.from(
                  value,
                );

                loadedBookings.add({
                  'id': key.toString(),
                  'title': item['title']?.toString() ?? 'Travel Booking',
                  'location': item['location']?.toString() ?? '',
                  'amount': item['amount'] is num
                      ? (item['amount'] as num).toDouble()
                      : 0.0,
                  'status': item['status']?.toString() ?? 'upcoming',
                  'bookingDate': item['bookingDate']?.toString() ?? '',
                  'createdAt': item['createdAt'] is num
                      ? (item['createdAt'] as num).toInt()
                      : 0,
                });
              }
            },
          );
        }

        loadedBookings.sort(
          (a, b) => (b['createdAt'] as int).compareTo(
            a['createdAt'] as int,
          ),
        );

        if (!mounted) return;

        setState(() {
          bookings = loadedBookings;
          isLoading = false;
        });
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        showMessage(
          'Could not load bookings.',
          error: true,
        );
      },
    );
  }

  List<Map<String, dynamic>> get displayedBookings {
    if (selectedTab == 0) {
      return bookings
          .where(
            (booking) => booking['status'] == 'upcoming',
          )
          .toList();
    }

    return bookings
        .where(
          (booking) => booking['status'] == 'completed',
        )
        .toList();
  }

  void showMessage(
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            error ? const Color(0xFFE34A4A) : const Color(0xFF1FA66A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Future<void> confirmCancelBooking(
    Map<String, dynamic> booking,
  ) async {
    final bool? shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _cardBackground(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Cancel booking?',
            style: GoogleFonts.fredoka(
              color: _primaryText(context),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel ${booking['title']}?',
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Keep Booking',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Cancel Booking',
                style: TextStyle(
                  color: Color(0xFFE34A4A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldCancel == true) {
      await cancelBooking(booking);
    }
  }

  Future<void> cancelBooking(
    Map<String, dynamic> booking,
  ) async {
    final String id = booking['id'].toString();

    if (bookingsReference == null) {
      return;
    }

    try {
      await bookingsReference!.child(id).remove();

      if (!mounted) return;

      showMessage(
        'Booking cancelled successfully.',
      );
    } catch (_) {
      if (!mounted) return;

      showMessage(
        'Could not cancel booking.',
        error: true,
      );
    }
  }

  void openBooking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingPage(),
      ),
    );
  }

  String formatBookingDate(
    String value,
  ) {
    if (value.isEmpty) {
      return 'Confirmed booking';
    }

    final DateTime? date = DateTime.tryParse(value);

    if (date == null) {
      return 'Confirmed booking';
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final Color pageColor = _pageBackground(context);

    final List<Map<String, dynamic>> shownBookings = displayedBookings;

    return Scaffold(
      backgroundColor: pageColor,
      body: PhonePage(
        backgroundColor: pageColor,
        child: SafeArea(
          child: Column(
            children: [
              _ScheduleHeader(
                onBack: () {
                  Navigator.pop(context);
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  4,
                  20,
                  16,
                ),
                child: _ScheduleSummary(
                  upcomingCount: bookings
                      .where(
                        (booking) => booking['status'] == 'upcoming',
                      )
                      .length,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  18,
                ),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: _cardBackground(
                      context,
                    ),
                    borderRadius: BorderRadius.circular(
                      19,
                    ),
                    border: Border.all(
                      color: _borderColor(
                        context,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ScheduleTab(
                          text: 'Upcoming',
                          icon: Icons.calendar_month_rounded,
                          selected: selectedTab == 0,
                          onPressed: () {
                            setState(() {
                              selectedTab = 0;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _ScheduleTab(
                          text: 'Completed',
                          icon: Icons.check_circle_outline_rounded,
                          selected: selectedTab == 1,
                          onPressed: () {
                            setState(() {
                              selectedTab = 1;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : shownBookings.isEmpty
                        ? _EmptySchedule(
                            completed: selectedTab == 1,
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await Future.delayed(
                                const Duration(
                                  milliseconds: 350,
                                ),
                              );
                            },
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                0,
                                20,
                                30,
                              ),
                              itemCount: shownBookings.length,
                              separatorBuilder: (
                                context,
                                index,
                              ) {
                                return const SizedBox(
                                  height: 16,
                                );
                              },
                              itemBuilder: (
                                context,
                                index,
                              ) {
                                final booking = shownBookings[index];

                                return _ScheduleCard(
                                  booking: booking,
                                  completed: selectedTab == 1,
                                  formattedDate: formatBookingDate(
                                    booking['bookingDate'].toString(),
                                  ),
                                  onMainPressed: openBooking,
                                  onCancelPressed: selectedTab == 0
                                      ? () {
                                          confirmCancelBooking(
                                            booking,
                                          );
                                        }
                                      : null,
                                );
                              },
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

class _ScheduleHeader extends StatelessWidget {
  const _ScheduleHeader({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        17,
        11,
        17,
        14,
      ),
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              'My Schedule',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                color: _primaryText(
                  context,
                ),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _ScheduleSummary extends StatelessWidget {
  const _ScheduleSummary({
    required this.upcomingCount,
  });

  final int upcomingCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        17,
        18,
        17,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF087BEA),
            Color(0xFF4AAAF6),
            Color(0xFF8B7CF6),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24006EDC),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0x26FFFFFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.luggage_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your trips',
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  upcomingCount == 0
                      ? 'No upcoming trips yet'
                      : '$upcomingCount upcoming ${upcomingCount == 1 ? 'trip' : 'trips'} ready for you',
                  style: const TextStyle(
                    color: Color(
                      0xE8FFFFFF,
                    ),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(
                0x26FFFFFF,
              ),
              borderRadius: BorderRadius.circular(
                14,
              ),
            ),
            child: Text(
              '$upcomingCount',
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({
    required this.text,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String text;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 220,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(
            15,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? Colors.white
                  : _secondaryText(
                      context,
                    ),
              size: 18,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: selected
                      ? Colors.white
                      : _secondaryText(
                          context,
                        ),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.booking,
    required this.completed,
    required this.formattedDate,
    required this.onMainPressed,
    this.onCancelPressed,
  });

  final Map<String, dynamic> booking;
  final bool completed;
  final String formattedDate;
  final VoidCallback onMainPressed;
  final VoidCallback? onCancelPressed;

  @override
  Widget build(BuildContext context) {
    final double amount = booking['amount'] as double;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _borderColor(context),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
              16,
            ),
            decoration: BoxDecoration(
              color: _isDark(context)
                  ? const Color(0xFF173653)
                  : const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(
                20,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: _cardBackground(
                      context,
                    ),
                    borderRadius: BorderRadius.circular(
                      17,
                    ),
                  ),
                  child: const Icon(
                    Icons.flight_takeoff_rounded,
                    color: AppColors.primaryBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        completed ? 'Completed Trip' : 'Upcoming Trip',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        completed
                            ? 'Hope you had a lovely journey'
                            : 'Your adventure is waiting',
                        style: TextStyle(
                          color: _secondaryText(
                            context,
                          ),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color:
                        completed ? const Color(0xFF1FA66A) : AppColors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          Text(
            booking['title'].toString(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.fredoka(
              color: _primaryText(context),
              fontSize: 18,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          _ScheduleInfoRow(
            icon: Icons.location_on_outlined,
            iconColor: AppColors.primaryBlue,
            label: 'Location',
            value: booking['location'].toString(),
          ),
          const SizedBox(height: 10),
          _ScheduleInfoRow(
            icon: Icons.calendar_month_outlined,
            iconColor: AppColors.orange,
            label: 'Date',
            value: formattedDate,
          ),
          const SizedBox(height: 10),
          _ScheduleInfoRow(
            icon: Icons.payments_outlined,
            iconColor: const Color(0xFF1FA66A),
            label: 'Paid',
            value: '\$${amount.toStringAsFixed(2)}',
            valueColor: const Color(0xFF1FA66A),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              if (onCancelPressed != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancelPressed,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                        0,
                        48,
                      ),
                      foregroundColor: const Color(
                        0xFFE34A4A,
                      ),
                      side: const BorderSide(
                        color: Color(
                          0xFFE7A0A0,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: onCancelPressed != null ? 1 : 2,
                child: ElevatedButton(
                  onPressed: onMainPressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(
                      0,
                      48,
                    ),
                    elevation: 0,
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                  child: Text(
                    completed ? 'Book Again' : 'View Details',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleInfoRow extends StatelessWidget {
  const _ScheduleInfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        12,
        11,
        12,
        11,
      ),
      decoration: BoxDecoration(
        color: _pageBackground(context),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 19,
          ),
          const SizedBox(width: 9),
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: TextStyle(
                color: _secondaryText(
                  context,
                ),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor ??
                    _primaryText(
                      context,
                    ),
                fontSize: 12.5,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule({
    required this.completed,
  });

  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: _isDark(context)
                    ? const Color(0xFF173653)
                    : const Color(0xFFEAF4FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                completed
                    ? Icons.check_circle_outline_rounded
                    : Icons.calendar_month_outlined,
                color: AppColors.primaryBlue,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              completed ? 'No completed trips' : 'No upcoming trips',
              style: GoogleFonts.fredoka(
                color: _primaryText(
                  context,
                ),
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              completed
                  ? 'Your completed journeys will appear here.'
                  : 'When you book a trip, it will appear here automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText(
                  context,
                ),
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ],
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
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _borderColor(
                context,
              ),
            ),
          ),
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
