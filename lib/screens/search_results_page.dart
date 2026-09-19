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

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({
    super.key,
    required this.initialQuery,
    required this.destinations,
  });

  final String initialQuery;
  final List<Map<String, String>> destinations;

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late final TextEditingController searchController;

  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    searchQuery = widget.initialQuery.trim();

    searchController = TextEditingController(
      text: widget.initialQuery,
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get filteredDestinations {
    final query = searchQuery.toLowerCase().trim();

    if (query.isEmpty) {
      return widget.destinations;
    }

    return widget.destinations.where((destination) {
      final String name = destination['name']?.toLowerCase() ?? '';

      final String location = destination['location']?.toLowerCase() ?? '';

      return name.contains(query) || location.contains(query);
    }).toList();
  }

  void openBookingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingPage(),
      ),
    );
  }

  void toggleSaved(
    Map<String, String> destination,
  ) {
    final String name = destination['name'] ?? 'Destination';

    final bool wasSaved = SavedStore.isSaved(name);

    SavedStore.toggleDestination(
      destination,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasSaved ? '$name removed from saved.' : '$name added to saved.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = filteredDestinations;

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
                        'Search Destinations',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          color: _primaryText(context),
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  2,
                  18,
                  16,
                ),
                child: TextField(
                  controller: searchController,
                  autofocus: searchQuery.isEmpty,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  style: TextStyle(
                    color: _primaryText(context),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _cardBackground(context),
                    hintText: 'Search by place or country',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primaryBlue,
                    ),
                    suffixIcon: searchQuery.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              searchController.clear();

                              setState(() {
                                searchQuery = '';
                              });
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              color: _secondaryText(context),
                            ),
                          ),
                  ),
                ),
              ),
              Expanded(
                child: results.isEmpty
                    ? _EmptySearchResult(
                        searchQuery: searchQuery,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          0,
                          18,
                          28,
                        ),
                        itemCount: results.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 14,
                          );
                        },
                        itemBuilder: (context, index) {
                          final destination = results[index];

                          return _SearchDestinationCard(
                            destination: destination,
                            onPressed: openBookingPage,
                            onFavoritePressed: () {
                              toggleSaved(
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

class _SearchDestinationCard extends StatelessWidget {
  const _SearchDestinationCard({
    required this.destination,
    required this.onPressed,
    required this.onFavoritePressed,
  });

  final Map<String, String> destination;
  final VoidCallback onPressed;
  final VoidCallback onFavoritePressed;

  @override
  Widget build(BuildContext context) {
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
        borderRadius: BorderRadius.circular(19),
        child: Row(
          children: [
            SizedBox(
              width: 112,
              height: 112,
              child: TravelImage(
                imageUrl: destination['image'] ?? '',
                borderRadius: 18,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: SizedBox(
                height: 112,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            destination['name'] ?? 'Destination',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.fredoka(
                              color: _primaryText(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ValueListenableBuilder<List<Map<String, dynamic>>>(
                          valueListenable: SavedStore.savedDestinations,
                          builder: (context, savedItems, child) {
                            final bool isSaved = savedItems.any(
                              (item) => item['name'] == destination['name'],
                            );

                            return IconButton(
                              onPressed: onFavoritePressed,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              icon: Icon(
                                isSaved
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: AppColors.primaryBlue,
                                size: 21,
                              ),
                            );
                          },
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
                            destination['location'] ?? '',
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
                          destination['rating'] ?? '0.0',
                          style: TextStyle(
                            color: _primaryText(context),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          destination['price'] ?? '',
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

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult({
    required this.searchQuery,
  });

  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: _isDark(context)
                    ? const Color(0xFF173653)
                    : AppColors.lightBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.travel_explore_rounded,
                color: AppColors.primaryBlue,
                size: 43,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No destinations found',
              style: GoogleFonts.fredoka(
                color: _primaryText(context),
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              searchQuery.isEmpty
                  ? 'Start typing to search for your next destination.'
                  : 'We could not find a destination matching "$searchQuery".',
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
