import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';

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
  return _isDark(context) ? const Color(0xFF2B343C) : const Color(0xFFE8EDF2);
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int selectedFilter = 0;

  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Booking Confirmed',
      'description': 'Your Santorini Summer Escape booking has been confirmed.',
      'time': '5 min ago',
      'type': 'Booking',
      'icon': Icons.check_circle_outline_rounded,
      'color': AppColors.primaryBlue,
      'isRead': false,
    },
    {
      'title': 'Special Travel Offer',
      'description': 'Save 25% on selected beach destinations this week.',
      'time': '2 hours ago',
      'type': 'Offer',
      'icon': Icons.local_offer_outlined,
      'color': AppColors.orange,
      'isRead': false,
    },
    {
      'title': 'Trip Reminder',
      'description': 'Your Paris City Experience starts in three days.',
      'time': 'Yesterday',
      'type': 'Booking',
      'icon': Icons.calendar_month_outlined,
      'color': const Color(0xFF7259D9),
      'isRead': true,
    },
    {
      'title': 'New Destination Added',
      'description': 'Discover new mountain retreats selected for you.',
      'time': '2 days ago',
      'type': 'Offer',
      'icon': Icons.explore_outlined,
      'color': const Color(0xFF21A875),
      'isRead': true,
    },
  ];

  List<Map<String, dynamic>> get filteredNotifications {
    if (selectedFilter == 1) {
      return notifications.where((item) => item['type'] == 'Booking').toList();
    }

    if (selectedFilter == 2) {
      return notifications.where((item) => item['type'] == 'Offer').toList();
    }

    return notifications;
  }

  void markAllAsRead() {
    setState(() {
      for (final notification in notifications) {
        notification['isRead'] = true;
      }
    });
  }

  void openNotification(
    Map<String, dynamic> notification,
  ) {
    setState(() {
      notification['isRead'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayedNotifications = filteredNotifications;

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
                  13,
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
                        'Notifications',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          color: _primaryText(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: markAllAsRead,
                      child: const Text(
                        'Read all',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  5,
                  18,
                  15,
                ),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: _cardBackground(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _borderColor(context),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _FilterButton(
                          text: 'All',
                          selected: selectedFilter == 0,
                          onPressed: () {
                            setState(() {
                              selectedFilter = 0;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _FilterButton(
                          text: 'Bookings',
                          selected: selectedFilter == 1,
                          onPressed: () {
                            setState(() {
                              selectedFilter = 1;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _FilterButton(
                          text: 'Offers',
                          selected: selectedFilter == 2,
                          onPressed: () {
                            setState(() {
                              selectedFilter = 2;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: displayedNotifications.isEmpty
                    ? const _EmptyNotifications()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          0,
                          18,
                          28,
                        ),
                        itemCount: displayedNotifications.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 11,
                          );
                        },
                        itemBuilder: (context, index) {
                          final notification = displayedNotifications[index];

                          return _NotificationCard(
                            notification: notification,
                            onPressed: () {
                              openNotification(
                                notification,
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

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.text,
    required this.selected,
    required this.onPressed,
  });

  final String text;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : _secondaryText(context),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onPressed,
  });

  final Map<String, dynamic> notification;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isRead = notification['isRead'] == true;

    final Color notificationColor = notification['color'] as Color;

    final bool dark = _isDark(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead
                ? _cardBackground(context)
                : dark
                    ? const Color(0xFF172B3D)
                    : const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isRead
                  ? _borderColor(context)
                  : dark
                      ? const Color(0xFF244763)
                      : const Color(0xFFCFE7FF),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: notificationColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  notification['icon'] as IconData,
                  color: notificationColor,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'].toString(),
                            style: GoogleFonts.poppins(
                              color: _primaryText(context),
                              fontSize: 12,
                              fontWeight:
                                  isRead ? FontWeight.w600 : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification['description'].toString(),
                      style: TextStyle(
                        color: _secondaryText(context),
                        fontSize: 9.5,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification['time'].toString(),
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                      ),
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

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

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
                Icons.notifications_none_rounded,
                color: AppColors.primaryBlue,
                size: 43,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No notifications',
              style: GoogleFonts.fredoka(
                color: _primaryText(context),
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'New booking updates and travel offers will appear here.',
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
