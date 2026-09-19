import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../models/saved_store.dart';
import '../widgets/common_widgets.dart';
import 'booking_page.dart';

bool _isDark(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

Color _pageBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF101418) : AppColors.softGrey;
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
  return _isDark(context) ? const Color(0xFF2B343C) : const Color(0xFFE9EDF2);
}

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  void openBookingPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingPage(),
      ),
    );
  }

  void removeDestination(
    BuildContext context,
    String destinationName,
  ) {
    SavedStore.removeDestination(destinationName);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$destinationName removed from saved.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void clearSavedPlaces(BuildContext context) {
    SavedStore.clearAll();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All saved places were removed.'),
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
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
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
                        'Saved Places',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          color: _primaryText(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: SavedStore.savedDestinations,
                      builder: (context, savedItems, child) {
                        return _CircleButton(
                          icon: Icons.delete_sweep_outlined,
                          enabled: savedItems.isNotEmpty,
                          onPressed: () {
                            clearSavedPlaces(context);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: SavedStore.savedDestinations,
                  builder: (context, savedItems, child) {
                    if (savedItems.isEmpty) {
                      return const _EmptySavedPlaces();
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        5,
                        18,
                        28,
                      ),
                      itemCount: savedItems.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 15);
                      },
                      itemBuilder: (context, index) {
                        final destination = savedItems[index];

                        return _SavedDestinationCard(
                          destination: destination,
                          onPressed: () {
                            openBookingPage(context);
                          },
                          onRemovePressed: () {
                            removeDestination(
                              context,
                              destination['name'].toString(),
                            );
                          },
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

class _SavedDestinationCard extends StatelessWidget {
  const _SavedDestinationCard({
    required this.destination,
    required this.onPressed,
    required this.onRemovePressed,
  });

  final Map<String, dynamic> destination;
  final VoidCallback onPressed;
  final VoidCallback onRemovePressed;

  @override
  Widget build(BuildContext context) {
    final String name = destination['name']?.toString() ?? 'Destination';
    final String location = destination['location']?.toString() ?? '';
    final String rating = destination['rating']?.toString() ?? '0.0';
    final String price = destination['price']?.toString() ?? '';
    final String imageUrl = destination['image']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            SizedBox(
              width: 108,
              height: 108,
              child: TravelImage(
                imageUrl: imageUrl,
                borderRadius: 18,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: SizedBox(
                height: 108,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.fredoka(
                              color: _primaryText(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onRemovePressed,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: const Icon(
                            Icons.favorite_rounded,
                            color: AppColors.primaryBlue,
                            size: 21,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primaryBlue,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _secondaryText(context),
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.orange,
                          size: 17,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          rating,
                          style: TextStyle(
                            color: _primaryText(context),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          price,
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 14,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySavedPlaces extends StatelessWidget {
  const _EmptySavedPlaces();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                color: _isDark(context)
                    ? const Color(0xFF173653)
                    : AppColors.lightBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: AppColors.primaryBlue,
                size: 43,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No saved places yet',
              style: GoogleFonts.fredoka(
                color: _primaryText(context),
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart on any destination and it will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText(context),
                fontSize: 11,
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
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _cardBackground(context),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: enabled ? _primaryText(context) : _secondaryText(context),
            size: 19,
          ),
        ),
      ),
    );
  }
}
