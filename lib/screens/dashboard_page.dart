import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../models/profile_store.dart';
import '../models/saved_store.dart';
import '../widgets/common_widgets.dart';

import 'all_destinations_page.dart';
import 'booking_page.dart';
import 'chats_page.dart';
import 'filter_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'saved_page.dart';
import 'schedule_page.dart';
import 'search_results_page.dart';
import 'settings_page.dart';

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
  return _isDark(context) ? const Color(0xFF2B343C) : const Color(0xFFE5EAF0);
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController searchController = TextEditingController();

  int selectedNavigationIndex = 0;
  int selectedCategoryIndex = 0;

  final List<Map<String, String>> cities = [
    {
      'name': 'Maldives',
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e'
          '?auto=format&fit=crop&w=400&q=85',
    },
    {
      'name': 'New York',
      'image': 'https://images.unsplash.com/photo-1485871981521-5b1fd3805eee'
          '?auto=format&fit=crop&w=400&q=85',
    },
    {
      'name': 'Sydney',
      'image': 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9'
          '?auto=format&fit=crop&w=400&q=85',
    },
    {
      'name': 'Toronto',
      'image': 'https://images.unsplash.com/photo-1517935706615-2717063c2225'
          '?auto=format&fit=crop&w=400&q=85',
    },
    {
      'name': 'London',
      'image': 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad'
          '?auto=format&fit=crop&w=400&q=85',
    },
  ];

  final List<Map<String, String>> destinations = [
    {
      'name': 'The Nautilus Maldives',
      'location': 'Malé, Maldives',
      'rating': '4.9',
      'price': '\$85',
      'category': 'Beach',
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e'
          '?auto=format&fit=crop&w=1000&q=90',
    },
    {
      'name': 'Erawan Falls',
      'location': 'Kanchanaburi, Thailand',
      'rating': '4.8',
      'price': '\$70',
      'category': 'Camping',
      'image': 'https://images.unsplash.com/photo-1432405972618-c60b0225b8f9'
          '?auto=format&fit=crop&w=1000&q=90',
    },
    {
      'name': 'Mountain Retreat',
      'location': 'Swiss Alps',
      'rating': '4.7',
      'price': '\$92',
      'category': 'Mountain',
      'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b'
          '?auto=format&fit=crop&w=1000&q=90',
    },
    {
      'name': 'Manhattan City Stay',
      'location': 'New York, USA',
      'rating': '4.8',
      'price': '\$120',
      'category': 'City',
      'image': 'https://images.unsplash.com/photo-1485871981521-5b1fd3805eee'
          '?auto=format&fit=crop&w=1000&q=90',
    },
    {
      'name': 'Sydney Harbour Escape',
      'location': 'Sydney, Australia',
      'rating': '4.9',
      'price': '\$110',
      'category': 'City',
      'image': 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9'
          '?auto=format&fit=crop&w=1000&q=90',
    },
    {
      'name': 'Toronto Downtown Stay',
      'location': 'Toronto, Canada',
      'rating': '4.7',
      'price': '\$95',
      'category': 'City',
      'image': 'https://images.unsplash.com/photo-1517935706615-2717063c2225'
          '?auto=format&fit=crop&w=1000&q=90',
    },
    {
      'name': 'London City Experience',
      'location': 'London, United Kingdom',
      'rating': '4.8',
      'price': '\$105',
      'category': 'City',
      'image': 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad'
          '?auto=format&fit=crop&w=1000&q=90',
    },
  ];

  final List<_CategoryData> categories = const [
    _CategoryData(
      title: 'Beach',
      icon: Icons.beach_access_rounded,
      backgroundColor: Color(0xFFEAF4FF),
      iconColor: AppColors.primaryBlue,
    ),
    _CategoryData(
      title: 'Mountain',
      icon: Icons.terrain_rounded,
      backgroundColor: Color(0xFFE9F9F1),
      iconColor: Color(0xFF1FA66A),
    ),
    _CategoryData(
      title: 'Camping',
      icon: Icons.cabin_rounded,
      backgroundColor: Color(0xFFFFF2E5),
      iconColor: AppColors.orange,
    ),
    _CategoryData(
      title: 'City',
      icon: Icons.location_city_rounded,
      backgroundColor: Color(0xFFF0EDFF),
      iconColor: Color(0xFF7259D9),
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void openBookingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingPage(),
      ),
    );
  }

  void openChatsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatsPage(),
      ),
    );
  }

  void openSettingsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  Future<void> openFilterPage() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const FilterPage(),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Filters applied successfully.',
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

  void handleNavigation(int index) {
    if (index == 0) {
      setState(() {
        selectedNavigationIndex = 0;
      });

      return;
    }

    if (index == 1) {
      openChatsPage();
      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SchedulePage(),
        ),
      );

      return;
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SavedPage(),
        ),
      );

      return;
    }

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        ),
      );
    }
  }

  void openSearch({
    String? query,
  }) {
    final String searchQuery = query ?? searchController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(
          initialQuery: searchQuery,
          destinations: destinations,
        ),
      ),
    );
  }

  void toggleSaved(
    Map<String, String> destination,
  ) {
    final bool wasSaved = SavedStore.isSaved(
      destination['name'].toString(),
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
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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
        child: Scaffold(
          backgroundColor: pageColor,
          bottomNavigationBar: _DashboardNavigationBar(
            selectedIndex: selectedNavigationIndex,
            onChanged: handleNavigation,
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                28,
              ),
              children: [
                _WelcomeHeader(
                  onSettingsPressed: openSettingsPage,
                  onNotificationsPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _ExploreHeroCard(
                  searchController: searchController,
                  onFilterPressed: openFilterPage,
                  onSearchPressed: openSearch,
                ),
                const SizedBox(height: 30),
                const _SectionHeader(
                  title: 'Popular Places',
                  subtitle: 'Explore destinations travelers love',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 112,
                  child: ScrollConfiguration(
                    behavior: const MaterialScrollBehavior().copyWith(
                      dragDevices: const {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                      },
                    ),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        right: 14,
                      ),
                      itemCount: cities.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          width: 14,
                        );
                      },
                      itemBuilder: (context, index) {
                        final city = cities[index];

                        return _CityItem(
                          name: city['name']!,
                          imageUrl: city['image']!,
                          onPressed: () {
                            final String cityName = city['name']!;

                            searchController.text = cityName;

                            openSearch(
                              query: cityName,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 27),
                _SectionHeader(
                  title: 'Top Destinations',
                  subtitle: 'Beautiful stays picked for you',
                  actionText: 'See all',
                  onActionPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllDestinationsPage(
                          destinations: destinations,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 286,
                  child: ScrollConfiguration(
                    behavior: const MaterialScrollBehavior().copyWith(
                      dragDevices: const {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                      },
                    ),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        right: 14,
                      ),
                      itemCount: destinations.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          width: 15,
                        );
                      },
                      itemBuilder: (context, index) {
                        final destination = destinations[index];

                        return _DestinationCard(
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
                ),
                const SizedBox(height: 30),
                const _SectionHeader(
                  title: 'Choose Category',
                  subtitle: 'Pick the travel mood you love',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 114,
                  child: ScrollConfiguration(
                    behavior: const MaterialScrollBehavior().copyWith(
                      dragDevices: const {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                      },
                    ),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        right: 12,
                      ),
                      itemCount: categories.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          width: 12,
                        );
                      },
                      itemBuilder: (context, index) {
                        final category = categories[index];

                        return _CategoryCard(
                          category: category,
                          selected: selectedCategoryIndex == index,
                          onPressed: () {
                            setState(() {
                              selectedCategoryIndex = index;
                            });

                            final String selectedCategory = category.title;

                            final categoryDestinations = destinations.where(
                              (destination) {
                                return destination['category'] ==
                                    selectedCategory;
                              },
                            ).toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllDestinationsPage(
                                  destinations: categoryDestinations,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _TravelOfferCard(
                  onPressed: openBookingPage,
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({
    required this.onSettingsPressed,
    required this.onNotificationsPressed,
  });

  final VoidCallback onSettingsPressed;
  final VoidCallback onNotificationsPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ValueListenableBuilder(
          valueListenable: ProfileStore.profileImage,
          builder: (context, imageBytes, child) {
            final String name = ProfileStore.userName.value.trim();

            final String firstLetter =
                name.isEmpty ? 'B' : name.substring(0, 1).toUpperCase();

            return Container(
              width: 58,
              height: 58,
              padding: const EdgeInsets.all(
                2.7,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue,
                    Color(0xFF8B7CF6),
                    AppColors.orange,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22006EDC),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: imageBytes != null
                    ? Image.memory(
                        imageBytes,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryBlue,
                              Color(0xFF8B7CF6),
                            ],
                          ),
                        ),
                        child: Text(
                          firstLetter,
                          style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
            );
          },
        ),
        const SizedBox(width: 13),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: ProfileStore.userName,
            builder: (context, userName, child) {
              final String cleanName = userName.toString().trim().isEmpty
                  ? 'Traveler'
                  : userName.toString();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back',
                    style: TextStyle(
                      color: _secondaryText(
                        context,
                      ),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$cleanName 👋',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                      color: _primaryText(
                        context,
                      ),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ready for your next adventure?',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _secondaryText(
                        context,
                      ),
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 6),
        _HeaderIconButton(
          icon: Icons.settings_outlined,
          onPressed: onSettingsPressed,
        ),
        const SizedBox(width: 7),
        Stack(
          clipBehavior: Clip.none,
          children: [
            _HeaderIconButton(
              icon: Icons.notifications_none_rounded,
              onPressed: onNotificationsPressed,
            ),
            const Positioned(
              top: 3,
              right: 4,
              child: CircleAvatar(
                radius: 4.5,
                backgroundColor: AppColors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
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
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _borderColor(context),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 9,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: _primaryText(context),
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _ExploreHeroCard extends StatelessWidget {
  const _ExploreHeroCard({
    required this.searchController,
    required this.onFilterPressed,
    required this.onSearchPressed,
  });

  final TextEditingController searchController;

  final VoidCallback onFilterPressed;
  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        20,
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
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30006EDC),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Where to next?',
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 27,
                        height: 1.05,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Find your perfect trip and make beautiful memories.',
                      style: TextStyle(
                        color: Color(
                          0xEEFFFFFF,
                        ),
                        fontSize: 12.5,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: Color(0x22FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flight_takeoff_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: TextField(
                    controller: searchController,
                    onSubmitted: (value) {
                      onSearchPressed();
                    },
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(
                      color: AppColors.blackText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search destination',
                      hintStyle: const TextStyle(
                        color: AppColors.hintText,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.primaryBlue,
                        size: 23,
                      ),
                      suffixIcon: IconButton(
                        onPressed: onSearchPressed,
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.primaryBlue,
                          size: 22,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 17,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  18,
                ),
                child: InkWell(
                  onTap: onFilterPressed,
                  borderRadius: BorderRadius.circular(
                    18,
                  ),
                  child: const SizedBox(
                    width: 55,
                    height: 55,
                    child: Icon(
                      Icons.tune_rounded,
                      color: AppColors.primaryBlue,
                      size: 24,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onActionPressed,
  });

  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.fredoka(
                  color: _primaryText(
                    context,
                  ),
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: _secondaryText(
                    context,
                  ),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: onActionPressed,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
            ),
            child: Text(
              actionText!,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _CityItem extends StatelessWidget {
  const _CityItem({
    required this.name,
    required this.imageUrl,
    required this.onPressed,
  });

  final String name;
  final String imageUrl;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          width: 82,
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: _cardBackground(
                    context,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _borderColor(
                      context,
                    ),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: TravelImage(
                    imageUrl: imageUrl,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _primaryText(
                    context,
                  ),
                  fontSize: 11.5,
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

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({
    required this.destination,
    required this.onPressed,
    required this.onFavoritePressed,
  });

  final Map<String, String> destination;

  final VoidCallback onPressed;
  final VoidCallback onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 205,
      child: Material(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            decoration: BoxDecoration(
              color: _cardBackground(
                context,
              ),
              borderRadius: BorderRadius.circular(
                25,
              ),
              border: Border.all(
                color: _borderColor(
                  context,
                ),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 16,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 170,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(
                            25,
                          ),
                        ),
                        child: TravelImage(
                          imageUrl: destination['image']!,
                        ),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(
                              25,
                            ),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x00000000),
                              Color(0x55000000),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child:
                            ValueListenableBuilder<List<Map<String, dynamic>>>(
                          valueListenable: SavedStore.savedDestinations,
                          builder: (
                            context,
                            savedItems,
                            child,
                          ) {
                            final bool isSaved = savedItems.any(
                              (item) => item['name'] == destination['name'],
                            );

                            return Material(
                              color: isSaved
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                              shape: const CircleBorder(),
                              elevation: 2,
                              child: InkWell(
                                onTap: onFavoritePressed,
                                customBorder: const CircleBorder(),
                                child: SizedBox(
                                  width: 39,
                                  height: 39,
                                  child: Icon(
                                    isSaved
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: isSaved
                                        ? Colors.white
                                        : AppColors.primaryBlue,
                                    size: 21,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        left: 12,
                        bottom: 11,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xEEFFFFFF,
                            ),
                            borderRadius: BorderRadius.circular(
                              14,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.orange,
                                size: 17,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                destination['rating']!,
                                style: const TextStyle(
                                  color: AppColors.blackText,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      14,
                      13,
                      14,
                      14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          destination['name']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _primaryText(
                              context,
                            ),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.primaryBlue,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                destination['location']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _secondaryText(
                                    context,
                                  ),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _isDark(
                                  context,
                                )
                                    ? const Color(0xFF173653)
                                    : const Color(0xFFEAF4FF),
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                              ),
                              child: Text(
                                destination['category']!,
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              destination['price']!,
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '/day',
                              style: TextStyle(
                                color: _secondaryText(
                                  context,
                                ),
                                fontSize: 10.5,
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
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.selected,
    required this.onPressed,
  });

  final _CategoryData category;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 220,
          ),
          width: 106,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryBlue
                : _cardBackground(
                    context,
                  ),
            borderRadius: BorderRadius.circular(
              22,
            ),
            border: Border.all(
              color: selected
                  ? AppColors.primaryBlue
                  : _borderColor(
                      context,
                    ),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0x30FFFFFF)
                      : category.backgroundColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  category.icon,
                  color: selected ? Colors.white : category.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.title,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : _primaryText(
                          context,
                        ),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TravelOfferCard extends StatelessWidget {
  const _TravelOfferCard({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 165,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const TravelImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1501785888041-af3ef285b470'
                  '?auto=format&fit=crop&w=1000&q=90',
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xEF00315E),
                    Color(0xB000315E),
                    Color(0x2000315E),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(
                20,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0x2FFFFFFF,
                            ),
                            borderRadius: BorderRadius.circular(
                              14,
                            ),
                          ),
                          child: const Text(
                            '25% OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          'Summer Escape',
                          style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Save on selected destinations and plan your dream trip.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(
                              0xEEFFFFFF,
                            ),
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: onPressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Explore',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
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

class _DashboardNavigationBar extends StatelessWidget {
  const _DashboardNavigationBar({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const List<_NavigationData> items = [
      _NavigationData(
        icon: Icons.home_rounded,
        label: 'Home',
      ),
      _NavigationData(
        icon: Icons.chat_bubble_rounded,
        label: 'Chat',
      ),
      _NavigationData(
        icon: Icons.calendar_month_rounded,
        label: 'Schedule',
      ),
      _NavigationData(
        icon: Icons.favorite_rounded,
        label: 'Saved',
      ),
      _NavigationData(
        icon: Icons.person_rounded,
        label: 'Profile',
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 76,
        padding: const EdgeInsets.fromLTRB(
          8,
          7,
          8,
          7,
        ),
        decoration: BoxDecoration(
          color: _cardBackground(context),
          border: Border(
            top: BorderSide(
              color: _borderColor(context),
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 16,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: List.generate(
            items.length,
            (index) {
              final bool selected = index == selectedIndex;

              final item = items[index];

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                  ),
                  child: InkWell(
                    onTap: () {
                      onChanged(index);
                    },
                    borderRadius: BorderRadius.circular(
                      18,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 200,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? (_isDark(context)
                                ? const Color(0xFF173653)
                                : const Color(0xFFEAF4FF))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          18,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            color: selected
                                ? AppColors.primaryBlue
                                : _secondaryText(
                                    context,
                                  ),
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            maxLines: 1,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.primaryBlue
                                  : _secondaryText(
                                      context,
                                    ),
                              fontSize: 10,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryData {
  const _CategoryData({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
}

class _NavigationData {
  const _NavigationData({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}
