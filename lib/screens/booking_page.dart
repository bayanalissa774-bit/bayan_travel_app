import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'booking_details_page.dart';
import 'booking_hours_page.dart';

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
  return _isDark(context) ? const Color(0xFFAAB3BB) : const Color(0xFF737D8A);
}

Color _borderColor(BuildContext context) {
  return _isDark(context) ? const Color(0xFF2D3740) : const Color(0xFFE5EAF0);
}

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  static const String hotelImage =
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e'
      '?auto=format&fit=crop&w=1200&q=90';

  void openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingDetailsPage(),
      ),
    );
  }

  void openBooking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingHoursPage(),
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
        child: Scaffold(
          backgroundColor: pageColor,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _HotelHero(
                    onBack: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    // خففنا صعود المحتوى فوق الصورة
                    offset: const Offset(0, -18),

                    child: Container(
                      width: double.infinity,

                      // زدنا المسافة فوق اسم الفندق
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        32,
                        20,
                        32,
                      ),

                      decoration: BoxDecoration(
                        color: pageColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // =========================
                          // HOTEL NAME + PRICE
                          // =========================
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'The Nautilus Maldives',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.fredoka(
                                        color: _primaryText(context),
                                        fontSize: 22,
                                        height: 1.15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          color: AppColors.primaryBlue,
                                          size: 17,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            'Baa Atoll, Maldives',
                                            style: TextStyle(
                                              color: _secondaryText(
                                                context,
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 10),

                              // PRICE CARD
                              Container(
                                width: 72,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _isDark(context)
                                      ? const Color(
                                          0xFF173653,
                                        )
                                      : const Color(
                                          0xFFEAF4FF,
                                        ),
                                  borderRadius: BorderRadius.circular(18),
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
                                    const SizedBox(height: 2),
                                    Text(
                                      'per day',
                                      style: TextStyle(
                                        color: _secondaryText(
                                          context,
                                        ),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // =========================
                          // HOTEL STATS
                          // =========================
                          const Row(
                            children: [
                              Expanded(
                                child: _HotelStat(
                                  icon: Icons.star_rounded,
                                  title: '4.9',
                                  subtitle: '2.5k reviews',
                                  background: Color(0xFFFFF4E8),
                                  iconColor: AppColors.orange,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: _HotelStat(
                                  icon: Icons.calendar_month_rounded,
                                  title: '3 Days',
                                  subtitle: 'Popular stay',
                                  background: Color(0xFFEAF4FF),
                                  iconColor: AppColors.primaryBlue,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: _HotelStat(
                                  icon: Icons.verified_rounded,
                                  title: 'Luxury',
                                  subtitle: 'Top rated',
                                  background: Color(0xFFEAF9F1),
                                  iconColor: Color(0xFF1FA66A),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // =========================
                          // WHY YOU'LL LOVE IT
                          // =========================
                          Text(
                            'Why you’ll love it',
                            style: GoogleFonts.fredoka(
                              color: _primaryText(context),
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 14),

                          const Wrap(
                            spacing: 9,
                            runSpacing: 10,
                            children: [
                              _FeaturePill(
                                icon: Icons.beach_access_rounded,
                                label: 'Private beach',
                              ),
                              _FeaturePill(
                                icon: Icons.wifi_rounded,
                                label: 'Free WiFi',
                              ),
                              _FeaturePill(
                                icon: Icons.free_breakfast_rounded,
                                label: 'Breakfast',
                              ),
                              _FeaturePill(
                                icon: Icons.pool_rounded,
                                label: 'Pool',
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // =========================
                          // ABOUT
                          // =========================
                          Text(
                            'About this stay',
                            style: GoogleFonts.fredoka(
                              color: _primaryText(context),
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'A private luxury island escape in the beautiful '
                            'Baa Atoll. Enjoy turquoise water, peaceful beaches '
                            'and an unforgettable Maldives experience surrounded '
                            'by nature.',
                            style: TextStyle(
                              color: _secondaryText(context),
                              fontSize: 13,
                              height: 1.55,
                            ),
                          ),

                          const SizedBox(height: 27),

                          // =========================
                          // TRAVELER FAVORITE
                          // =========================
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: _isDark(context)
                                  ? null
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xFFEAF4FF),
                                        Color(0xFFF1EEFF),
                                      ],
                                    ),
                              color: _isDark(context)
                                  ? const Color(0xFF202833)
                                  : null,
                              borderRadius: BorderRadius.circular(21),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Color(0xFF8B7CF6),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Traveler favorite',
                                        style: TextStyle(
                                          color: _isDark(context)
                                              ? Colors.white
                                              : const Color(
                                                  0xFF332D62,
                                                ),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Loved for its peaceful atmosphere and beautiful views.',
                                        style: TextStyle(
                                          color: _isDark(context)
                                              ? const Color(
                                                  0xFFAAB3BB,
                                                )
                                              : const Color(
                                                  0xFF6F6A85,
                                                ),
                                          fontSize: 11.5,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // =========================
                          // BOOK BUTTON
                          // =========================
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton(
                              onPressed: () {
                                openBooking(context);
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Book This Stay',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 7),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 11),

                          // =========================
                          // DETAILS BUTTON
                          // =========================
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: () {
                                openDetails(context);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryBlue,
                                side: BorderSide(
                                  color: _borderColor(context),
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    18,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'View All Details',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
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
      ),
    );
  }
}

// ======================================================
// HOTEL IMAGE
// ======================================================

class _HotelHero extends StatelessWidget {
  const _HotelHero({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // كان 345
      // صغرناه حتى لا تسيطر الصورة على الصفحة
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const TravelImage(
            imageUrl: BookingPage.hotelImage,
          ),

          // Gradient
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x18000000),
                  Color(0x00000000),
                  Color(0x77000000),
                ],
              ),
            ),
          ),

          // BACK BUTTON
          Positioned(
            top: 18,
            left: 16,
            child: Material(
              color: const Color(0xEEFFFFFF),
              shape: const CircleBorder(),
              elevation: 3,
              child: InkWell(
                onTap: onBack,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF202329),
                    size: 18,
                  ),
                ),
              ),
            ),
          ),

          // PHOTO COUNT
          Positioned(
            top: 18,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: const Color(0xDD1B1B1B),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
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

          // BAYAN CHOICE
          Positioned(
            left: 18,
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: const Color(0xF2FFFFFF),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: AppColors.primaryBlue,
                    size: 17,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Bayan Choice',
                    style: TextStyle(
                      color: AppColors.blackText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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

// ======================================================
// HOTEL STAT CARD
// ======================================================

class _HotelStat extends StatelessWidget {
  const _HotelStat({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// FEATURE PILL
// ======================================================

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 17,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
