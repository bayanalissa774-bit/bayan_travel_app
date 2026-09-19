import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'booking_details_page.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  static const String databaseUrl =
      'https://bayan-travel-app-2026-default-rtdb.europe-west1.firebasedatabase.app';

  bool isLoading = true;

  List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final FirebaseDatabase database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: databaseUrl,
      );

      final DataSnapshot snapshot =
          await database.ref('users/${user.uid}/bookings').get();

      final List<Map<String, dynamic>> loadedBookings = [];

      if (snapshot.value is Map) {
        final Map data = snapshot.value as Map;

        data.forEach((key, value) {
          if (value is Map) {
            loadedBookings.add({
              'id': key.toString(),
              ...Map<String, dynamic>.from(value),
            });
          }
        });
      }

      loadedBookings.sort(
        (a, b) {
          final int aTime = (a['createdAt'] as num?)?.toInt() ?? 0;

          final int bTime = (b['createdAt'] as num?)?.toInt() ?? 0;

          return bTime.compareTo(aTime);
        },
      );

      if (!mounted) return;

      setState(() {
        bookings = loadedBookings;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not load bookings: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : bookings.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.luggage_outlined,
                        size: 70,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 18),
                      Text(
                        'No bookings yet',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your confirmed trips will appear here.',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadBookings,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: bookings.length,
                    separatorBuilder: (
                      context,
                      index,
                    ) {
                      return const SizedBox(
                        height: 18,
                      );
                    },
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final booking = bookings[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return BookingDetailsPage(
                                  booking: booking,
                                );
                              },
                            ),
                          );
                        },
                        child: BookingCard(
                          booking: booking,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
  });

  final Map<String, dynamic> booking;

  @override
  Widget build(BuildContext context) {
    final String hotelName = booking['hotelName']?.toString() ?? 'Hotel';

    final double amount = (booking['amount'] as num?)?.toDouble() ?? 0;

    final String status = booking['status']?.toString() ?? 'confirmed';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E8ED),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                ),
                child: const Icon(
                  Icons.hotel_rounded,
                  color: Color(0xFF0877E8),
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotelName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF0877E8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7EF),
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF1FA66A),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF1FA66A),
                size: 19,
              ),
              SizedBox(width: 8),
              Text(
                'Payment completed',
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
