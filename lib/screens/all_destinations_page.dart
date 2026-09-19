import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../models/saved_store.dart';
import '../widgets/common_widgets.dart';
import 'booking_page.dart';

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _pageBackground(BuildContext context) =>
    _isDark(context) ? const Color(0xFF101418) : AppColors.softGrey;

Color _cardBackground(BuildContext context) =>
    _isDark(context) ? const Color(0xFF1B2229) : Colors.white;

Color _primaryText(BuildContext context) =>
    _isDark(context) ? const Color(0xFFF4F7F9) : AppColors.blackText;

Color _secondaryText(BuildContext context) =>
    _isDark(context) ? const Color(0xFF9EA9B2) : AppColors.greyText;

Color _borderColor(BuildContext context) =>
    _isDark(context) ? const Color(0xFF2B343C) : const Color(0xFFE8EDF2);

class AllDestinationsPage extends StatelessWidget {
  const AllDestinationsPage({
    super.key,
    required this.destinations,
  });

  final List<Map<String, String>> destinations;

  void openBookingPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingPage(),
      ),
    );
  }

  void toggleSaved(
    BuildContext context,
    Map<String, String> destination,
  ) {
    final bool wasSaved = SavedStore.isSaved(
      destination['name'] ?? '',
    );

    SavedStore.toggleDestination(
      destination,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasSaved
              ? '${destination['name']} removed from saved.'
              : '${destination['name']} added to saved.',
        ),
        behavior: SnackBarBehavior.floating,
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
                  18,
                  12,
                  18,
                  14,
                ),
                child: Row(
                  children: [
                    _CircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Text(
                        'All Destinations',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          color: _primaryText(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
              ),
              Expanded(
                child: destinations.isEmpty
                    ? Center(
                        child: Text(
                          'No destinations available.',
                          style: TextStyle(
                            color: _secondaryText(context),
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          4,
                          18,
                          28,
                        ),
                        itemCount: destinations.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (context, index) {
                          final destination = destinations[index];

                          return _DestinationGridCard(
                            destination: destination,
                            onPressed: () {
                              openBookingPage(context);
                            },
                            onFavoritePressed: () {
                              toggleSaved(
                                context,
                                destination,
                              );
                            },
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

class _DestinationGridCard extends StatelessWidget {
  const _DestinationGridCard({
    required this.destination,
    required this.onPressed,
    required this.onFavoritePressed,
  });

  final Map<String, String> destination;

  final VoidCallback onPressed;
  final VoidCallback onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _cardBackground(context),
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(23),
        child: Container(
          decoration: BoxDecoration(
            color: _cardBackground(context),
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: _borderColor(context),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    TravelImage(
                      imageUrl: destination['image'] ?? '',
                      borderRadius: 23,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(23),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x00000000),
                            Color(0x44000000),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                        valueListenable: SavedStore.savedDestinations,
                        builder: (context, savedItems, child) {
                          final bool isSaved = savedItems.any(
                            (item) => item['name'] == destination['name'],
                          );

                          return Material(
                            color: isSaved
                                ? AppColors.primaryBlue
                                : _cardBackground(context),
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: InkWell(
                              onTap: onFavoritePressed,
                              customBorder: const CircleBorder(),
                              child: SizedBox(
                                width: 34,
                                height: 34,
                                child: Icon(
                                  isSaved
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: isSaved
                                      ? Colors.white
                                      : AppColors.primaryBlue,
                                  size: 19,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xEFFFFFFF,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.orange,
                              size: 15,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              destination['rating'] ?? '0.0',
                              style: const TextStyle(
                                color: AppColors.blackText,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  11,
                  11,
                  11,
                  12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination['name'] ?? 'Destination',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.fredoka(
                        color: _primaryText(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primaryBlue,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            destination['location'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _secondaryText(context),
                              fontSize: 7.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Text(
                          destination['price'] ?? '',
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '/day',
                          style: TextStyle(
                            color: _secondaryText(context),
                            fontSize: 7,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
        child: SizedBox(
          width: 42,
          height: 42,
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
