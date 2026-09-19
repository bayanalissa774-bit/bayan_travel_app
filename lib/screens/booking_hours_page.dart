import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';

import 'booking_details_page.dart';
import 'choose_date_page.dart';
import 'ratings_reviews_page.dart';

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

class BookingHoursPage extends StatelessWidget {
  const BookingHoursPage({super.key});

  static const String hotelImage =
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e'
      '?auto=format&fit=crop&w=1200&q=90';

  void openDetailsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingDetailsPage(),
      ),
    );
  }

  void openReviewsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RatingsReviewsPage(),
      ),
    );
  }

  void openChooseDatePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChooseDatePage(),
      ),
    );
  }

  void showPhotosMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Hotel photos are available from the hotel gallery.',
          style: TextStyle(
            fontSize: 13,
          ),
        ),
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

    return Scaffold(
      backgroundColor: pageColor,
      body: PhonePage(
        backgroundColor: pageColor,
        child: SafeArea(
          child: Column(
            children: [
              _HotelImageHeader(
                onBack: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PageTabs(
                        onDetails: () {
                          openDetailsPage(context);
                        },
                        onReviews: () {
                          openReviewsPage(context);
                        },
                        onPhotos: () {
                          showPhotosMessage(context);
                        },
                      ),
                      const SizedBox(height: 25),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'The Nautilus Maldives',
                                  style: GoogleFonts.fredoka(
                                    color: _primaryText(
                                      context,
                                    ),
                                    fontSize: 23,
                                    height: 1.1,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      color: AppColors.primaryBlue,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        'Baa Atoll, Maldives',
                                        style: TextStyle(
                                          color: _secondaryText(
                                            context,
                                          ),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: _isDark(context)
                                  ? const Color(0xFF173653)
                                  : const Color(0xFFEAF4FF),
                              borderRadius: BorderRadius.circular(
                                17,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '\$85',
                                  style: GoogleFonts.fredoka(
                                    color: AppColors.primaryBlue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'per day',
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
                      const SizedBox(height: 25),
                      _AvailabilityCard(),
                      const SizedBox(height: 24),
                      Text(
                        'Plan your stay',
                        style: GoogleFonts.fredoka(
                          color: _primaryText(context),
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Choose your dates and guests before confirming the reservation.',
                        style: TextStyle(
                          color: _secondaryText(context),
                          fontSize: 12.5,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _StayPlannerCard(
                        onChooseDates: () {
                          openChooseDatePage(context);
                        },
                      ),
                      const SizedBox(height: 24),
                      _BookingBenefitsCard(),
                      const SizedBox(height: 27),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: FilledButton(
                          onPressed: () {
                            openChooseDatePage(context);
                          },
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
                              Icon(
                                Icons.calendar_month_rounded,
                                size: 21,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Choose Dates',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'You won’t be charged yet',
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

class _HotelImageHeader extends StatelessWidget {
  const _HotelImageHeader({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 245,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const TravelImage(
            imageUrl: BookingHoursPage.hotelImage,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x22000000),
                  Color(0x00000000),
                  Color(0x55000000),
                ],
              ),
            ),
          ),
          Positioned(
            top: 15,
            left: 15,
            child: Material(
              color: const Color(0xEEFFFFFF),
              shape: const CircleBorder(),
              elevation: 3,
              child: InkWell(
                onTap: onBack,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 45,
                  height: 45,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF202329),
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 17,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xDD191919),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.photo_library_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '12 photos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageTabs extends StatelessWidget {
  const _PageTabs({
    required this.onDetails,
    required this.onReviews,
    required this.onPhotos,
  });

  final VoidCallback onDetails;
  final VoidCallback onReviews;
  final VoidCallback onPhotos;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SmallTab(
            icon: Icons.info_outline_rounded,
            text: 'Details',
            onPressed: onDetails,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SmallTab(
            icon: Icons.star_outline_rounded,
            text: 'Reviews',
            onPressed: onReviews,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SmallTab(
            icon: Icons.photo_outlined,
            text: 'Photos',
            onPressed: onPhotos,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: _SmallTab(
            icon: Icons.calendar_month_rounded,
            text: 'Dates',
            selected: true,
          ),
        ),
      ],
    );
  }
}

class _SmallTab extends StatelessWidget {
  const _SmallTab({
    required this.icon,
    required this.text,
    this.selected = false,
    this.onPressed,
  });

  final IconData icon;
  final String text;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryBlue : _cardBackground(context),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: selected ? null : onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? AppColors.primaryBlue : _borderColor(context),
            ),
          ),
          child: Column(
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
              const SizedBox(height: 4),
              Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : _primaryText(
                          context,
                        ),
                  fontSize: 10.5,
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

class _AvailabilityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
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
              color: const Color(0xFFEAF9F1),
              borderRadius: BorderRadius.circular(
                15,
              ),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF1FA66A),
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available every day',
                  style: TextStyle(
                    color: _primaryText(
                      context,
                    ),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Flexible check-in dates are available for this stay.',
                  style: TextStyle(
                    color: _secondaryText(
                      context,
                    ),
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF9F1),
              borderRadius: BorderRadius.circular(
                13,
              ),
            ),
            child: const Text(
              'OPEN',
              style: TextStyle(
                color: Color(0xFF1FA66A),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StayPlannerCard extends StatelessWidget {
  const _StayPlannerCard({
    required this.onChooseDates,
  });

  final VoidCallback onChooseDates;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _borderColor(context),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _PlannerItem(
                  icon: Icons.login_rounded,
                  title: 'Check in',
                  value: 'Feb 06',
                  color: AppColors.primaryBlue,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: _borderColor(context),
              ),
              Expanded(
                child: _PlannerItem(
                  icon: Icons.logout_rounded,
                  title: 'Check out',
                  value: 'Feb 09',
                  color: const Color(
                    0xFF8B7CF6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: _borderColor(context),
            height: 1,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PlannerItem(
                  icon: Icons.nights_stay_rounded,
                  title: 'Stay',
                  value: '3 nights',
                  color: AppColors.orange,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: _borderColor(context),
              ),
              Expanded(
                child: _PlannerItem(
                  icon: Icons.people_alt_rounded,
                  title: 'Guests',
                  value: '2 guests',
                  color: const Color(
                    0xFF1FA66A,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Material(
            color: _isDark(context)
                ? const Color(0xFF173653)
                : const Color(0xFFEAF4FF),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onChooseDates,
              borderRadius: BorderRadius.circular(
                16,
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_calendar_rounded,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'Change dates & guests',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlannerItem extends StatelessWidget {
  const _PlannerItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 7),
        Text(
          title,
          style: TextStyle(
            color: _secondaryText(context),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BookingBenefitsCard extends StatelessWidget {
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
                    0xFFFFF8ED,
                  ),
                  Color(
                    0xFFF5F0FF,
                  ),
                ],
              ),
        color: _isDark(context) ? const Color(0xFF202833) : null,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          _BenefitRow(
            icon: Icons.verified_user_rounded,
            text: 'Secure booking with Bayan Travel',
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: 13),
          _BenefitRow(
            icon: Icons.event_available_rounded,
            text: 'Flexible date selection',
            color: const Color(0xFF1FA66A),
          ),
          const SizedBox(height: 13),
          _BenefitRow(
            icon: Icons.payments_outlined,
            text: 'Pay later from your Bayan Wallet',
            color: AppColors.orange,
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
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
            size: 19,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(
          Icons.check_rounded,
          color: color,
          size: 20,
        ),
      ],
    );
  }
}
