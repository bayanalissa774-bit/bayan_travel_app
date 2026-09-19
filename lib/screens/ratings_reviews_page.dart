import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';

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

class RatingsReviewsPage extends StatefulWidget {
  const RatingsReviewsPage({super.key});

  @override
  State<RatingsReviewsPage> createState() => _RatingsReviewsPageState();
}

class _RatingsReviewsPageState extends State<RatingsReviewsPage> {
  String searchText = '';

  static const List<Map<String, dynamic>> ratingDetails = [
    {
      'title': 'Accuracy',
      'rating': 4.7,
    },
    {
      'title': 'Location',
      'rating': 4.5,
    },
    {
      'title': 'Communication',
      'rating': 4.6,
    },
    {
      'title': 'Cleanliness',
      'rating': 4.7,
    },
    {
      'title': 'Check-in',
      'rating': 4.9,
    },
    {
      'title': 'Value',
      'rating': 4.7,
    },
  ];

  static const List<Map<String, String>> reviews = [
    {
      'name': 'Opeyemi',
      'date': '2 Days ago',
      'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330'
          '?auto=format&fit=crop&w=300&q=85',
      'review': 'Great location, very easy to find and access.\n'
          'Super easy and swift check-in process.\n'
          'Beautiful, clean and spacious rooms and apartment.\n'
          'Nice location and good food.\n'
          'Good services.',
    },
    {
      'name': 'Abisola',
      'date': '3 Days ago',
      'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb'
          '?auto=format&fit=crop&w=300&q=85',
      'review': 'Great location, very easy to find.\n'
          'Can’t hate this place.\n'
          'Beautiful, clean and spacious rooms and apartment.\n'
          'Hosts were great to communicate with.\n'
          'Very helpful and kind customer service. Will be back!',
    },
  ];

  List<Map<String, String>> get filteredReviews {
    if (searchText.trim().isEmpty) {
      return reviews;
    }

    final String query = searchText.trim().toLowerCase();

    return reviews.where((review) {
      final String name = review['name']!.toLowerCase();

      final String text = review['review']!.toLowerCase();

      return name.contains(query) || text.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visibleReviews = filteredReviews;

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
                  4,
                  16,
                  3,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _primaryText(context),
                        size: 18,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Ratings and Reviews',
                          style: TextStyle(
                            color: _primaryText(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    12,
                    24,
                    28,
                  ),
                  children: [
                    SizedBox(
                      height: 42,
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                        style: TextStyle(
                          color: _primaryText(context),
                          fontSize: 10,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search Reviews',
                          hintStyle: TextStyle(
                            color: _secondaryText(context),
                            fontSize: 9,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 17,
                            color: _secondaryText(context),
                          ),
                          filled: true,
                          fillColor: _cardBackground(context),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: const BorderSide(
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: const BorderSide(
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: const BorderSide(
                              color: AppColors.primaryBlue,
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFC928),
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '4.82',
                          style: TextStyle(
                            color: _primaryText(context),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          '32 Reviews',
                          style: TextStyle(
                            color: _primaryText(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ...ratingDetails.map(
                      (rating) {
                        return _RatingDetailRow(
                          title: rating['title'] as String,
                          rating: rating['rating'] as double,
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    if (visibleReviews.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 50,
                        ),
                        child: Center(
                          child: Text(
                            'No reviews found',
                            style: TextStyle(
                              color: _secondaryText(context),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    else
                      ...visibleReviews.map(
                        (review) {
                          return _ReviewItem(
                            name: review['name']!,
                            date: review['date']!,
                            imageUrl: review['image']!,
                            review: review['review']!,
                          );
                        },
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

class _RatingDetailRow extends StatelessWidget {
  const _RatingDetailRow({
    required this.title,
    required this.rating,
  });

  final String title;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: Text(
              title,
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 10,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: rating / 5,
                minHeight: 4,
                backgroundColor: _isDark(context)
                    ? const Color(0xFF303A43)
                    : const Color(0xFFDADADA),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          SizedBox(
            width: 25,
            child: Text(
              rating.toStringAsFixed(1),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({
    required this.name,
    required this.date,
    required this.imageUrl,
    required this.review,
  });

  final String name;
  final String date;
  final String imageUrl;
  final String review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isDark(context)
              ? const Color(0xFF2B343C)
              : const Color(0xFFEDF0F3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: AppColors.lightBlue,
                backgroundImage: NetworkImage(imageUrl),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: _primaryText(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: _secondaryText(context),
                        size: 11,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        date,
                        style: TextStyle(
                          color: _secondaryText(context),
                          fontSize: 8.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            review,
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 9,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
