import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'booking_hours_page.dart';

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

Color _borderColor(BuildContext context) {
  return _isDark(context) ? const Color(0xFF2B343C) : const Color(0xFFE8EDF2);
}

class BookingDetailsPage extends StatefulWidget {
  const BookingDetailsPage({super.key});

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  bool isFavorite = true;

  static const String hotelImage =
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e'
      '?auto=format&fit=crop&w=1200&q=90';

  final List<String> hotelPhotos = const [
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e'
        '?auto=format&fit=crop&w=800&q=90',
    'https://images.unsplash.com/photo-1540541338287-41700207dee6'
        '?auto=format&fit=crop&w=800&q=90',
    'https://images.unsplash.com/photo-1566073771259-6a8506099945'
        '?auto=format&fit=crop&w=800&q=90',
    'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b'
        '?auto=format&fit=crop&w=800&q=90',
    'https://images.unsplash.com/photo-1571896349842-33c89424de2d'
        '?auto=format&fit=crop&w=800&q=90',
    'https://images.unsplash.com/photo-1564501049412-61c2a3083791'
        '?auto=format&fit=crop&w=800&q=90',
  ];

  void openBookingHours() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingHoursPage(),
      ),
    );
  }

  void openAllPhotos() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardBackground(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.78,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                12,
                18,
                20,
              ),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _borderColor(context),
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Hotel Photos',
                          style: TextStyle(
                            color: _primaryText(
                              context,
                            ),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(
                            sheetContext,
                          );
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: _primaryText(
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: GridView.builder(
                      itemCount: hotelPhotos.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        return TravelImage(
                          imageUrl: hotelPhotos[index],
                          borderRadius: 18,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                  8,
                  3,
                  16,
                  2,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                        );
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
                        size: 18,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Details',
                          style: TextStyle(
                            color: _primaryText(
                              context,
                            ),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 42,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    4,
                    20,
                    25,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 235,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const TravelImage(
                              imageUrl: hotelImage,
                              borderRadius: 23,
                            ),
                            Positioned(
                              top: 11,
                              right: 11,
                              child: Material(
                                color: _cardBackground(
                                  context,
                                ),
                                shape: const CircleBorder(),
                                elevation: 2,
                                child: IconButton(
                                  onPressed: () {
                                    setState(
                                      () {
                                        isFavorite = !isFavorite;
                                      },
                                    );
                                  },
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: isFavorite
                                        ? const Color(
                                            0xFFE85A75,
                                          )
                                        : AppColors.primaryBlue,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 13,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _FeatureItem(
                            icon: Icons.wifi_rounded,
                            text: 'Free WiFi',
                          ),
                          _FeatureItem(
                            icon: Icons.free_breakfast_rounded,
                            text: 'Free Breakfast',
                          ),
                          _FeatureItem(
                            icon: Icons.star_rounded,
                            text: '5.0',
                            iconColor: AppColors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 13,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'The Nautilus Maldives',
                              style: TextStyle(
                                color: _primaryText(
                                  context,
                                ),
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '\$85/Day',
                            style: TextStyle(
                              color: _primaryText(
                                context,
                              ),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primaryBlue,
                            size: 14,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Expanded(
                            child: Text(
                              'The Nautilus Maldives, Baa Atoll',
                              style: TextStyle(
                                color: _secondaryText(
                                  context,
                                ),
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 9,
                      ),
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Each of the 26 houses is a suite with separate living '
                        'and bedrooms, as well as a personal butler, private pool '
                        'and ocean views. In every house you enjoy the kind of '
                        'complete freedom, water, tea, coffee and soft drinks, '
                        'bottle of champagne on arrival.',
                        style: TextStyle(
                          color: _secondaryText(
                            context,
                          ),
                          fontSize: 9,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(
                        height: 11,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Photos',
                              style: TextStyle(
                                color: _primaryText(
                                  context,
                                ),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: openAllPhotos,
                            child: const Text(
                              'See all',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 74,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          separatorBuilder: (
                            context,
                            index,
                          ) {
                            return const SizedBox(
                              width: 8,
                            );
                          },
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: 70,
                              child: TravelImage(
                                imageUrl: hotelPhotos[index],
                                borderRadius: 20,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 19,
                      ),
                      Center(
                        child: SizedBox(
                          width: 155,
                          child: PrimaryButton(
                            text: 'Book Now',
                            onPressed: openBookingHours,
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

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.text,
    this.iconColor,
  });

  final IconData icon;
  final String text;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 13,
          color: iconColor ?? _primaryText(context),
        ),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 8.5,
          ),
        ),
      ],
    );
  }
}
