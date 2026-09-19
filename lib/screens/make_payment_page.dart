import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../pages/my_wallet_page.dart';
import '../widgets/common_widgets.dart';
import 'booking_confirmed_page.dart';

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
  return _isDark(context) ? const Color(0xFFF4F7F9) : const Color(0xFF181A1F);
}

Color _secondaryText(BuildContext context) {
  return _isDark(context) ? const Color(0xFF9EA9B2) : const Color(0xFF747D89);
}

Color _borderColor(BuildContext context) {
  return _isDark(context) ? const Color(0xFF2B343C) : const Color(0xFFE4E9EF);
}

class MakePaymentPage extends StatefulWidget {
  const MakePaymentPage({
    super.key,
    this.amount = 85.0,
    this.checkInDate,
    this.checkOutDate,
    this.checkInTime,
    this.checkOutTime,
    this.guests = 2,
    this.nights = 3,
  });

  final double amount;

  final String? checkInDate;
  final String? checkOutDate;

  final String? checkInTime;
  final String? checkOutTime;

  final int guests;
  final int nights;

  @override
  State<MakePaymentPage> createState() => _MakePaymentPageState();
}

class _MakePaymentPageState extends State<MakePaymentPage> {
  static const String databaseUrl =
      'https://bayan-travel-app-2026-default-rtdb.europe-west1.firebasedatabase.app';

  double walletBalance = 0.0;

  bool isLoading = true;
  bool isPaying = false;
  bool paymentCompleted = false;

  @override
  void initState() {
    super.initState();
    loadWalletBalance();
  }

  FirebaseDatabase get database {
    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    );
  }

  DatabaseReference? getWalletReference() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    return database.ref(
      'users/${user.uid}/wallet',
    );
  }

  Future<void> openMyWallet() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyWalletPage(),
      ),
    );

    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    await loadWalletBalance();
  }

  void showMessage(
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            error ? const Color(0xFFE34A4A) : const Color(0xFF1FA66A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Future<void> loadWalletBalance() async {
    final DatabaseReference? walletRef = getWalletReference();

    if (walletRef == null) {
      if (!mounted) return;

      setState(() {
        walletBalance = 0.0;
        isLoading = false;
      });

      return;
    }

    try {
      final DataSnapshot snapshot = await walletRef.child('balance').get();

      double loadedBalance = 0.0;

      if (snapshot.value is num) {
        loadedBalance = (snapshot.value as num).toDouble();
      }

      if (!mounted) return;

      setState(() {
        walletBalance = loadedBalance;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage(
        'Could not load wallet balance.',
        error: true,
      );
    }
  }

  Future<void> payFromWallet() async {
    if (isPaying || paymentCompleted) {
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage(
        'Please log in again.',
        error: true,
      );
      return;
    }

    final DatabaseReference? walletRef = getWalletReference();

    if (walletRef == null) {
      showMessage(
        'Wallet is unavailable.',
        error: true,
      );
      return;
    }

    setState(() {
      isPaying = true;
    });

    try {
      final DataSnapshot balanceSnapshot =
          await walletRef.child('balance').get();

      final double currentBalance = balanceSnapshot.value is num
          ? (balanceSnapshot.value as num).toDouble()
          : 0.0;

      if (currentBalance < widget.amount) {
        if (!mounted) return;

        setState(() {
          walletBalance = currentBalance;
          isPaying = false;
        });

        showMessage(
          'Insufficient wallet balance.',
          error: true,
        );

        return;
      }

      final double newBalance = currentBalance - widget.amount;

      final DatabaseReference transactionRef =
          walletRef.child('transactions').push();

      final DatabaseReference bookingRef = database
          .ref(
            'users/${user.uid}/bookings',
          )
          .push();

      final String? transactionId = transactionRef.key;

      final String? bookingId = bookingRef.key;

      if (transactionId == null || bookingId == null) {
        throw Exception(
          'Could not create payment records.',
        );
      }

      final int now = DateTime.now().millisecondsSinceEpoch;

      final DatabaseReference userRef = database.ref(
        'users/${user.uid}',
      );

      await userRef.update({
        // =====================
        // WALLET
        // =====================
        'wallet/balance': newBalance,

        // =====================
        // TRANSACTION
        // =====================
        'wallet/transactions/$transactionId': {
          'id': transactionId,
          'title': 'The Nautilus Maldives',
          'date': 'Booking payment',
          'amount': -widget.amount,
          'type': 'booking',
          'status': 'paid',
          'createdAt': now,
        },

        // =====================
        // BOOKING
        // =====================
        'bookings/$bookingId': {
          'id': bookingId,
          'hotelName': 'The Nautilus Maldives',
          'location': 'Baa Atoll, Maldives',
          'amount': widget.amount,
          'checkInDate': widget.checkInDate,
          'checkOutDate': widget.checkOutDate,
          'checkInTime': widget.checkInTime,
          'checkOutTime': widget.checkOutTime,
          'guests': widget.guests,
          'nights': widget.nights,
          'status': 'confirmed',
          'paymentStatus': 'paid',
          'createdAt': now,
          'bookingDate': DateTime.now().toIso8601String(),
        },
      });

      if (!mounted) return;

      setState(() {
        walletBalance = newBalance;
        paymentCompleted = true;
        isPaying = false;
      });

      showMessage(
        'Payment completed successfully.',
      );

      await Future.delayed(
        const Duration(
          milliseconds: 350,
        ),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BookingConfirmedPage(),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        isPaying = false;
      });

      showMessage(
        'Firebase error: ${e.message ?? e.code}',
        error: true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isPaying = false;
      });

      showMessage(
        'Payment failed: $e',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color pageColor = _pageBackground(context);

    final bool enoughMoney = walletBalance >= widget.amount;

    final double balanceAfter = walletBalance - widget.amount;

    return Scaffold(
      backgroundColor: pageColor,
      body: PhonePage(
        backgroundColor: pageColor,
        child: SafeArea(
          child: Column(
            children: [
              // =====================
              // HEADER
              // =====================
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  8,
                  5,
                  16,
                  5,
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
                        size: 17,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Make Payment',
                          style: TextStyle(
                            color: _primaryText(
                              context,
                            ),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 44,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          18,
                          20,
                          30,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Method',
                              style: TextStyle(
                                color: _primaryText(
                                  context,
                                ),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              'Pay securely using your Bayan Wallet.',
                              style: TextStyle(
                                color: _secondaryText(
                                  context,
                                ),
                                fontSize: 11.5,
                              ),
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // =====================
                            // WALLET
                            // =====================
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(
                                17,
                              ),
                              decoration: BoxDecoration(
                                color: _cardBackground(
                                  context,
                                ),
                                borderRadius: BorderRadius.circular(
                                  22,
                                ),
                                border: Border.all(
                                  color: _borderColor(
                                    context,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFEAF4FF,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        16,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: AppColors.primaryBlue,
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 14,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Bayan Wallet',
                                          style: TextStyle(
                                            color: _primaryText(
                                              context,
                                            ),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Available balance',
                                          style: TextStyle(
                                            color: _secondaryText(
                                              context,
                                            ),
                                            fontSize: 10,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          '\$${walletBalance.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: AppColors.primaryBlue,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 31,
                                    height: 31,
                                    decoration: const BoxDecoration(
                                      color: Color(
                                        0xFFE8F7EF,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: Color(
                                        0xFF1FA66A,
                                      ),
                                      size: 19,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 25,
                            ),

                            Text(
                              'Payment Summary',
                              style: TextStyle(
                                color: _primaryText(
                                  context,
                                ),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            // =====================
                            // SUMMARY
                            // =====================
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(
                                18,
                              ),
                              decoration: BoxDecoration(
                                color: _cardBackground(
                                  context,
                                ),
                                borderRadius: BorderRadius.circular(
                                  22,
                                ),
                                border: Border.all(
                                  color: _borderColor(
                                    context,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFEAF4FF,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            13,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.hotel_rounded,
                                          color: AppColors.primaryBlue,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'The Nautilus Maldives',
                                              style: TextStyle(
                                                color: _primaryText(
                                                  context,
                                                ),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              '${widget.nights} nights • ${widget.guests} guests',
                                              style: TextStyle(
                                                color: _secondaryText(
                                                  context,
                                                ),
                                                fontSize: 9.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 17,
                                  ),
                                  Divider(
                                    height: 1,
                                    color: _borderColor(
                                      context,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 17,
                                  ),
                                  _PaymentLine(
                                    title: 'Booking amount',
                                    value:
                                        '\$${widget.amount.toStringAsFixed(2)}',
                                  ),
                                  const SizedBox(
                                    height: 14,
                                  ),
                                  _PaymentLine(
                                    title: 'Wallet balance',
                                    value:
                                        '\$${walletBalance.toStringAsFixed(2)}',
                                  ),
                                  const SizedBox(
                                    height: 17,
                                  ),
                                  Divider(
                                    height: 1,
                                    color: _borderColor(
                                      context,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 17,
                                  ),
                                  _PaymentLine(
                                    title: 'Balance after payment',
                                    value: enoughMoney
                                        ? '\$${balanceAfter.toStringAsFixed(2)}'
                                        : 'Insufficient balance',
                                    valueColor: enoughMoney
                                        ? const Color(
                                            0xFF1FA66A,
                                          )
                                        : const Color(
                                            0xFFE34A4A,
                                          ),
                                    bold: true,
                                  ),
                                ],
                              ),
                            ),

                            if (!enoughMoney) ...[
                              const SizedBox(
                                height: 18,
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(
                                  16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFFEEEE,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    18,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: Color(
                                        0xFFE34A4A,
                                      ),
                                      size: 25,
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    const Text(
                                      'Not enough balance',
                                      style: TextStyle(
                                        color: Color(
                                          0xFFE34A4A,
                                        ),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'Add money to your Bayan Wallet before completing the payment.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _secondaryText(
                                          context,
                                        ),
                                        fontSize: 10.5,
                                        height: 1.45,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    TextButton.icon(
                                      onPressed: openMyWallet,
                                      icon: const Icon(
                                        Icons.add_circle_outline_rounded,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Add Money',
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(
                              height: 28,
                            ),

                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: FilledButton(
                                onPressed: isPaying
                                    ? null
                                    : () async {
                                        if (enoughMoney) {
                                          await payFromWallet();
                                        } else {
                                          await openMyWallet();
                                        }
                                      },
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      AppColors.primaryBlue.withOpacity(
                                    0.55,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      27,
                                    ),
                                  ),
                                ),
                                child: isPaying
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        paymentCompleted
                                            ? 'Payment Completed'
                                            : enoughMoney
                                                ? 'Pay \$${widget.amount.toStringAsFixed(2)}'
                                                : 'Go to My Wallet',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(
                              height: 13,
                            ),

                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    color: _secondaryText(
                                      context,
                                    ),
                                    size: 14,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Secure payment with Bayan Wallet',
                                    style: TextStyle(
                                      color: _secondaryText(
                                        context,
                                      ),
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
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

class _PaymentLine extends StatelessWidget {
  const _PaymentLine({
    required this.title,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  final String title;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 11.5,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? _primaryText(context),
              fontSize: 11.5,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
