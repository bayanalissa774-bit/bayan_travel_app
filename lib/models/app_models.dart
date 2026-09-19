class OnboardingData {
  const OnboardingData({
    required this.first,
    required this.second,
    required this.description,
    required this.button,
    required this.orangeTitle,
    required this.images,
  });

  final String first;
  final String second;
  final String description;
  final String button;
  final bool orangeTitle;
  final List<String> images;
}

class DestinationData {
  const DestinationData({
    required this.title,
    required this.place,
    required this.rating,
    required this.url,
  });

  final String title;
  final String place;
  final String rating;
  final String url;
}
