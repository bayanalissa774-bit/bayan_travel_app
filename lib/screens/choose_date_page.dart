import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'confirm_booking_page.dart';

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

class ChooseDatePage extends StatefulWidget {
  const ChooseDatePage({super.key});

  @override
  State<ChooseDatePage> createState() => _ChooseDatePageState();
}

class _ChooseDatePageState extends State<ChooseDatePage> {
  late DateTime checkInDate;
  late DateTime checkOutDate;

  TimeOfDay checkInTime = const TimeOfDay(hour: 14, minute: 30);

  TimeOfDay checkOutTime = const TimeOfDay(hour: 11, minute: 15);

  int guests = 2;

  @override
  void initState() {
    super.initState();

    final DateTime today = DateUtils.dateOnly(DateTime.now());

    checkInDate = today.add(const Duration(days: 1));

    checkOutDate = today.add(const Duration(days: 4));
  }

  int get numberOfNights {
    return checkOutDate.difference(checkInDate).inDays;
  }

  Future<void> chooseDates() async {
    final DateTime today = DateUtils.dateOnly(DateTime.now());

    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: DateTime(
        today.year + 2,
        today.month,
        today.day,
      ),
      initialDateRange: DateTimeRange(
        start: checkInDate,
        end: checkOutDate,
      ),
      helpText: 'Choose your stay',
      confirmText: 'Save Dates',
      saveText: 'Save',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primaryBlue,
                ),
            dialogTheme: DialogThemeData(
              backgroundColor: _cardBackground(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (result == null) {
      return;
    }

    if (result.end.isAtSameMomentAs(
      result.start,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please choose at least one night.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      checkInDate = result.start;
      checkOutDate = result.end;
    });
  }

  Future<void> chooseCheckInTime() async {
    final TimeOfDay? selected = await showTimePicker(
      context: context,
      initialTime: checkInTime,

      // يسمح تكتبي الساعة والدقائق بدقة.
      initialEntryMode: TimePickerEntryMode.input,

      helpText: 'Check-in time',
      hourLabelText: 'Hour',
      minuteLabelText: 'Minute',

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primaryBlue,
                ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      checkInTime = selected;
    });
  }

  Future<void> chooseCheckOutTime() async {
    final TimeOfDay? selected = await showTimePicker(
      context: context,
      initialTime: checkOutTime,
      initialEntryMode: TimePickerEntryMode.input,
      helpText: 'Check-out time',
      hourLabelText: 'Hour',
      minuteLabelText: 'Minute',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primaryBlue,
                ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      checkOutTime = selected;
    });
  }

  void decreaseGuests() {
    if (guests <= 1) {
      return;
    }

    setState(() {
      guests--;
    });
  }

  void increaseGuests() {
    if (guests >= 10) {
      return;
    }

    setState(() {
      guests++;
    });
  }

  String formatDate(DateTime date) {
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

    const List<String> weekdays = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return '${weekdays[date.weekday - 1]}, '
        '${date.day} ${months[date.month - 1]}';
  }

  String formatFullDate(DateTime date) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  String formatTime(TimeOfDay time) {
    final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;

    final String minute = time.minute.toString().padLeft(2, '0');

    final String period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  void openConfirmBookingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          arguments: {
            'checkInDate': checkInDate.toIso8601String(),
            'checkOutDate': checkOutDate.toIso8601String(),
            'checkInTime': '${checkInTime.hour.toString().padLeft(2, '0')}:'
                '${checkInTime.minute.toString().padLeft(2, '0')}',
            'checkOutTime': '${checkOutTime.hour.toString().padLeft(2, '0')}:'
                '${checkOutTime.minute.toString().padLeft(2, '0')}',
            'guests': guests,
            'nights': numberOfNights,
            'pricePerNight': 85.0,
          },
        ),
        builder: (context) => const ConfirmBookingPage(),
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
              _PageHeader(
                onBack: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    5,
                    20,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BookingIntroCard(),
                      const SizedBox(height: 26),
                      _SectionTitle(
                        title: 'Your stay',
                        subtitle: 'Choose the dates that work best for you.',
                      ),
                      const SizedBox(height: 14),
                      _DateRangeCard(
                        checkInDate: formatDate(
                          checkInDate,
                        ),
                        checkOutDate: formatDate(
                          checkOutDate,
                        ),
                        nights: numberOfNights,
                        onPressed: chooseDates,
                      ),
                      const SizedBox(height: 26),
                      _SectionTitle(
                        title: 'Choose time',
                        subtitle: 'Set the exact check-in and check-out time.',
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _TimeSelectionCard(
                              title: 'Check in',
                              time: formatTime(
                                checkInTime,
                              ),
                              icon: Icons.login_rounded,
                              color: AppColors.primaryBlue,
                              onPressed: chooseCheckInTime,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TimeSelectionCard(
                              title: 'Check out',
                              time: formatTime(
                                checkOutTime,
                              ),
                              icon: Icons.logout_rounded,
                              color: const Color(
                                0xFF8B7CF6,
                              ),
                              onPressed: chooseCheckOutTime,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: _isDark(context)
                              ? const Color(0xFF202833)
                              : const Color(0xFFFFF7EA),
                          borderRadius: BorderRadius.circular(
                            16,
                          ),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              color: AppColors.orange,
                              size: 20,
                            ),
                            SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'You can choose the exact hour and minute, for example 2:37 PM.',
                                style: TextStyle(
                                  color: Color(
                                    0xFF7B633C,
                                  ),
                                  fontSize: 12,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      _SectionTitle(
                        title: 'Guests',
                        subtitle: 'How many travelers are staying?',
                      ),
                      const SizedBox(height: 14),
                      _GuestsCard(
                        guests: guests,
                        onMinus: decreaseGuests,
                        onPlus: increaseGuests,
                      ),
                      const SizedBox(height: 27),
                      _StaySummaryCard(
                        checkIn: formatFullDate(
                          checkInDate,
                        ),
                        checkOut: formatFullDate(
                          checkOutDate,
                        ),
                        checkInTime: formatTime(
                          checkInTime,
                        ),
                        checkOutTime: formatTime(
                          checkOutTime,
                        ),
                        nights: numberOfNights,
                        guests: guests,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: openConfirmBookingPage,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                18,
                              ),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Confirm Stay',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 21,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 11),
                      Center(
                        child: Text(
                          'You can review everything before payment',
                          style: TextStyle(
                            color: _secondaryText(
                              context,
                            ),
                            fontSize: 11.5,
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

class _PageHeader extends StatelessWidget {
  const _PageHeader({
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
        15,
      ),
      child: Row(
        children: [
          Material(
            color: _cardBackground(context),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onBack,
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
                  Icons.arrow_back_ios_new_rounded,
                  color: _primaryText(
                    context,
                  ),
                  size: 18,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Plan Your Stay',
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

class _BookingIntroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF087BEA),
            Color(0xFF55B5F5),
            Color(0xFF8B7CF6),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26006EDC),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 53,
            height: 53,
            decoration: const BoxDecoration(
              color: Color(0x29FFFFFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
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
                  'Make it yours',
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pick your dates, exact times and guests.',
                  style: TextStyle(
                    color: Color(
                      0xEDFFFFFF,
                    ),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.fredoka(
            color: _primaryText(context),
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: _secondaryText(context),
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _DateRangeCard extends StatelessWidget {
  const _DateRangeCard({
    required this.checkInDate,
    required this.checkOutDate,
    required this.nights,
    required this.onPressed,
  });

  final String checkInDate;
  final String checkOutDate;
  final int nights;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _cardBackground(context),
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(23),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              23,
            ),
            border: Border.all(
              color: _borderColor(context),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _DateItem(
                      label: 'Check in',
                      value: checkInDate,
                      color: AppColors.primaryBlue,
                      icon: Icons.flight_land_rounded,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: _secondaryText(
                        context,
                      ),
                      size: 21,
                    ),
                  ),
                  Expanded(
                    child: _DateItem(
                      label: 'Check out',
                      value: checkOutDate,
                      color: const Color(
                        0xFF8B7CF6,
                      ),
                      icon: Icons.flight_takeoff_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Divider(
                height: 1,
                color: _borderColor(context),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.nights_stay_rounded,
                    color: AppColors.orange,
                    size: 19,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '$nights ${nights == 1 ? 'night' : 'nights'}',
                    style: TextStyle(
                      color: _primaryText(
                        context,
                      ),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.edit_calendar_rounded,
                    color: AppColors.primaryBlue,
                    size: 19,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Change dates',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateItem extends StatelessWidget {
  const _DateItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: 0.12,
            ),
            borderRadius: BorderRadius.circular(
              13,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: _secondaryText(context),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 2,
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 13,
            height: 1.25,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TimeSelectionCard extends StatelessWidget {
  const _TimeSelectionCard({
    required this.title,
    required this.time,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String title;
  final String time;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _cardBackground(context),
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              21,
            ),
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
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.edit_rounded,
                    color: _secondaryText(
                      context,
                    ),
                    size: 17,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: _secondaryText(
                    context,
                  ),
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: GoogleFonts.fredoka(
                  color: _primaryText(
                    context,
                  ),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestsCard extends StatelessWidget {
  const _GuestsCard({
    required this.guests,
    required this.onMinus,
    required this.onPlus,
  });

  final int guests;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              color: _isDark(context)
                  ? const Color(0xFF173653)
                  : const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(
                15,
              ),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$guests ${guests == 1 ? 'guest' : 'guests'}',
                  style: TextStyle(
                    color: _primaryText(
                      context,
                    ),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Maximum 10 guests',
                  style: TextStyle(
                    color: _secondaryText(
                      context,
                    ),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _CounterButton(
            icon: Icons.remove_rounded,
            onPressed: onMinus,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
            ),
            child: Text(
              '$guests',
              style: GoogleFonts.fredoka(
                color: _primaryText(
                  context,
                ),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _CounterButton(
            icon: Icons.add_rounded,
            selected: true,
            onPressed: onPlus,
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryBlue : _pageBackground(context),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          width: 39,
          height: 39,
          child: Icon(
            icon,
            color: selected
                ? Colors.white
                : _primaryText(
                    context,
                  ),
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _StaySummaryCard extends StatelessWidget {
  const _StaySummaryCard({
    required this.checkIn,
    required this.checkOut,
    required this.checkInTime,
    required this.checkOutTime,
    required this.nights,
    required this.guests,
  });

  final String checkIn;
  final String checkOut;
  final String checkInTime;
  final String checkOutTime;
  final int nights;
  final int guests;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: _isDark(context)
            ? null
            : const LinearGradient(
                colors: [
                  Color(
                    0xFFEAF4FF,
                  ),
                  Color(
                    0xFFF3EFFF,
                  ),
                ],
              ),
        color: _isDark(context) ? const Color(0xFF202833) : null,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF8B7CF6),
                size: 21,
              ),
              const SizedBox(width: 8),
              Text(
                'Stay Summary',
                style: GoogleFonts.fredoka(
                  color: _primaryText(
                    context,
                  ),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _SummaryRow(
            label: 'Check in',
            value: '$checkIn • $checkInTime',
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Check out',
            value: '$checkOut • $checkOutTime',
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Stay',
            value: '$nights nights • $guests guests',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(
              color: _secondaryText(
                context,
              ),
              fontSize: 11.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
