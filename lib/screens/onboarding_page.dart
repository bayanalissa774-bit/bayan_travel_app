import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';

import 'login_page.dart';
import 'sign_up_page.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController pageController = PageController();

  int currentPage = 0;

  static const List<OnboardingData> pages = [
    OnboardingData(
      firstTitle: 'Discover Your',
      secondTitle: 'Next Adventure',
      description: 'Plan your perfect trip with ease.',
      buttonText: 'Next',
      highlightSecondTitle: false,
      imageOne: 'https://images.unsplash.com/photo-1527631746610-bca00a040d60'
          '?auto=format&fit=crop&w=600&q=90',
      imageTwo: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470'
          '?auto=format&fit=crop&w=600&q=90',
      imageThree: 'https://images.unsplash.com/photo-1516483638261-f4dbaf036963'
          '?auto=format&fit=crop&w=900&q=90',
    ),
    OnboardingData(
      firstTitle: 'Book Your',
      secondTitle: 'Dream Trip',
      description: 'Find and book unforgettable trips with ease.',
      buttonText: 'Next',
      highlightSecondTitle: true,
      imageOne: 'https://images.unsplash.com/photo-1533104816931-20fa691ff6ca'
          '?auto=format&fit=crop&w=600&q=90',
      imageTwo: 'https://images.unsplash.com/photo-1533105079780-92b9be482077'
          '?auto=format&fit=crop&w=600&q=90',
      imageThree: 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a'
          '?auto=format&fit=crop&w=900&q=90',
    ),
    OnboardingData(
      firstTitle: 'Explore Hidden',
      secondTitle: 'Gems',
      description: 'Discover unique places and travel with confidence.',
      buttonText: 'Get Started',
      highlightSecondTitle: true,
      imageOne: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b'
          '?auto=format&fit=crop&w=600&q=90',
      imageTwo: 'https://images.unsplash.com/photo-1500534623283-312aade485b7'
          '?auto=format&fit=crop&w=600&q=90',
      imageThree: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470'
          '?auto=format&fit=crop&w=900&q=90',
    ),
  ];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void openLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  void openSignUpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpPage(),
      ),
    );
  }

  void handlePrimaryButton() {
    final bool isLastPage = currentPage == pages.length - 1;

    if (isLastPage) {
      openLoginPage();
      return;
    }

    pageController.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhonePage(
        child: SafeArea(
          child: PageView.builder(
            controller: pageController,
            itemCount: pages.length,
            onPageChanged: (int index) {
              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingScreen(
                page: pages[index],
                currentPage: currentPage,
                pageCount: pages.length,
                onSkip: openLoginPage,
                onPrimaryButton: handlePrimaryButton,
                onCreateAccount: openSignUpPage,
              );
            },
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    super.key,
    required this.page,
    required this.currentPage,
    required this.pageCount,
    required this.onSkip,
    required this.onPrimaryButton,
    required this.onCreateAccount,
  });

  final OnboardingData page;
  final int currentPage;
  final int pageCount;
  final VoidCallback onSkip;
  final VoidCallback onPrimaryButton;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 7, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.flight_takeoff_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Bayan Travel',
                              style: GoogleFonts.fredoka(
                                color: AppColors.blackText,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: onSkip,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                            backgroundColor: const Color(0xFFF1F7FD),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Skip',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    ImageCollage(page: page),
                    const SizedBox(height: 14),
                    OnboardingTitle(page: page),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F8FD),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFDDEEFF),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE2F1FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.primaryBlue,
                              size: 17,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              page.description,
                              style: GoogleFonts.poppins(
                                color: AppColors.greyText,
                                fontSize: 12,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    PageDots(
                      pageCount: pageCount,
                      currentPage: currentPage,
                    ),
                    const SizedBox(height: 13),
                    Center(
                      child: SizedBox(
                        width: 285,
                        child: PrimaryButton(
                          text: page.buttonText,
                          onPressed: onPrimaryButton,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: SizedBox(
                        width: 285,
                        child: SecondaryButton(
                          text: 'Create Account',
                          onPressed: onCreateAccount,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ImageCollage extends StatelessWidget {
  const ImageCollage({
    super.key,
    required this.page,
  });

  final OnboardingData page;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 245,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 3,
                top: 9,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE8D8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 7,
                bottom: 14,
                child: Container(
                  width: 57,
                  height: 57,
                  decoration: const BoxDecoration(
                    color: AppColors.lightBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: 8,
                top: 4,
                width: width * 0.43,
                height: 145,
                child: Transform.rotate(
                  angle: -0.035,
                  child: _OnboardingImageCard(
                    imageUrl: page.imageOne,
                    borderRadius: 26,
                  ),
                ),
              ),
              Positioned(
                right: 7,
                top: 15,
                width: width * 0.49,
                height: 125,
                child: Transform.rotate(
                  angle: 0.035,
                  child: _OnboardingImageCard(
                    imageUrl: page.imageTwo,
                    borderRadius: 26,
                  ),
                ),
              ),
              Positioned(
                left: width * 0.12,
                bottom: 0,
                width: width * 0.76,
                height: 132,
                child: _OnboardingImageCard(
                  imageUrl: page.imageThree,
                  borderRadius: 28,
                  strongerShadow: true,
                ),
              ),
              Positioned(
                right: width * 0.04,
                top: 142,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.flight_takeoff_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OnboardingImageCard extends StatelessWidget {
  const _OnboardingImageCard({
    required this.imageUrl,
    required this.borderRadius,
    this.strongerShadow = false,
  });

  final String imageUrl;
  final double borderRadius;
  final bool strongerShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius + 4),
        boxShadow: [
          BoxShadow(
            color: strongerShadow
                ? const Color(0x29000000)
                : const Color(0x18000000),
            blurRadius: strongerShadow ? 18 : 12,
            offset: Offset(
              0,
              strongerShadow ? 9 : 6,
            ),
          ),
        ],
      ),
      child: TravelImage(
        imageUrl: imageUrl,
        borderRadius: borderRadius,
      ),
    );
  }
}

class OnboardingTitle extends StatelessWidget {
  const OnboardingTitle({
    super.key,
    required this.page,
  });

  final OnboardingData page;

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = GoogleFonts.fredoka(
      color: AppColors.blackText,
      fontSize: 28,
      height: 1.05,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          page.firstTitle,
          style: titleStyle,
        ),
        const SizedBox(height: 4),
        if (page.highlightSecondTitle)
          ClipPath(
            clipper: OrangeTitleClipper(),
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                8,
                3,
                30,
                4,
              ),
              color: AppColors.orange,
              child: Text(
                page.secondTitle,
                style: titleStyle.copyWith(
                  color: Colors.white,
                  fontSize: 26,
                ),
              ),
            ),
          )
        else
          Text(
            page.secondTitle,
            style: titleStyle,
          ),
      ],
    );
  }
}

class OrangeTitleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - 18, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(8, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class PageDots extends StatelessWidget {
  const PageDots({
    super.key,
    required this.pageCount,
    required this.currentPage,
  });

  final int pageCount;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F7FD),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            pageCount,
            (index) {
              final bool isActive = index == currentPage;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                width: isActive ? 30 : 8,
                height: 8,
                margin: EdgeInsets.only(
                  right: index == pageCount - 1 ? 0 : 7,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primaryBlue
                      : const Color(0xFFB9D9F5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isActive
                      ? const [
                          BoxShadow(
                            color: Color(0x33006EDC),
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  const OnboardingData({
    required this.firstTitle,
    required this.secondTitle,
    required this.description,
    required this.buttonText,
    required this.highlightSecondTitle,
    required this.imageOne,
    required this.imageTwo,
    required this.imageThree,
  });

  final String firstTitle;
  final String secondTitle;
  final String description;
  final String buttonText;
  final bool highlightSecondTitle;
  final String imageOne;
  final String imageTwo;
  final String imageThree;
}
