import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';

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
  return _isDark(context) ? const Color(0xFFF5F7FA) : const Color(0xFF181A1F);
}

Color _secondaryText(BuildContext context) {
  return _isDark(context) ? const Color(0xFFAAB3BB) : const Color(0xFF747D89);
}

Color _borderColor(BuildContext context) {
  return _isDark(context) ? const Color(0xFF2D3740) : const Color(0xFFE4E9EF);
}

class AddMoneyPage extends StatefulWidget {
  const AddMoneyPage({super.key});

  @override
  State<AddMoneyPage> createState() => _AddMoneyPageState();
}

class _AddMoneyPageState extends State<AddMoneyPage> {
  static const String databaseUrl =
      'https://bayan-travel-app-2026-default-rtdb.europe-west1.firebasedatabase.app';

  final TextEditingController amountController = TextEditingController();

  final TextEditingController cardHolderController = TextEditingController();

  final TextEditingController cardNumberController = TextEditingController(
    text: '5412 7512 3412 3456',
  );

  final TextEditingController expiryController = TextEditingController(
    text: '12/30',
  );

  final TextEditingController cvvController = TextEditingController();

  final List<double> quickAmounts = [
    10,
    25,
    50,
    100,
  ];

  double selectedAmount = 0.0;

  bool isAdding = false;

  @override
  void initState() {
    super.initState();

    final User? user = FirebaseAuth.instance.currentUser;

    final String? name = user?.displayName;

    if (name != null && name.trim().isNotEmpty) {
      cardHolderController.text = name.toUpperCase();
    } else {
      final String email = user?.email ?? 'BAYAN USER';

      cardHolderController.text = email
          .split('@')
          .first
          .replaceAll('.', ' ')
          .replaceAll('_', ' ')
          .toUpperCase();
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    cardHolderController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();

    super.dispose();
  }

  DatabaseReference? getWalletReference() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    final FirebaseDatabase database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    );

    return database.ref(
      'users/${user.uid}/wallet',
    );
  }

  void selectAmount(double amount) {
    setState(() {
      selectedAmount = amount;

      amountController.text = amount.toStringAsFixed(0);
    });
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

  Future<void> addMoney() async {
    if (isAdding) {
      return;
    }

    final double? amount = double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      showMessage(
        'Please enter a valid amount.',
        error: true,
      );
      return;
    }

    if (cardHolderController.text.trim().isEmpty) {
      showMessage(
        'Please enter the card holder name.',
        error: true,
      );
      return;
    }

    if (cardNumberController.text.trim().isEmpty) {
      showMessage(
        'Please enter the card number.',
        error: true,
      );
      return;
    }

    if (expiryController.text.trim().isEmpty) {
      showMessage(
        'Please enter the expiry date.',
        error: true,
      );
      return;
    }

    if (cvvController.text.trim().length < 3) {
      showMessage(
        'Please enter a valid CVV.',
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
      isAdding = true;
    });

    try {
      final DataSnapshot snapshot = await walletRef.child('balance').get();

      final double currentBalance =
          snapshot.value is num ? (snapshot.value as num).toDouble() : 0.0;

      final double newBalance = currentBalance + amount;

      final DatabaseReference transactionRef =
          walletRef.child('transactions').push();

      final String? transactionId = transactionRef.key;

      if (transactionId == null) {
        throw Exception(
          'Could not create transaction.',
        );
      }

      final int now = DateTime.now().millisecondsSinceEpoch;

      await walletRef.update({
        'balance': newBalance,
        'transactions/$transactionId': {
          'id': transactionId,
          'title': 'Money Added',
          'date': 'Visa card top up',
          'amount': amount,
          'type': 'topup',
          'status': 'completed',
          'createdAt': now,

          // نحفظ فقط آخر 4 أرقام
          // ولا نحفظ رقم البطاقة أو CVV.
          'cardLast4': '3456',
        },
      });

      if (!mounted) return;

      setState(() {
        isAdding = false;
      });

      showMessage(
        '\$${amount.toStringAsFixed(2)} added successfully.',
      );

      await Future.delayed(
        const Duration(
          milliseconds: 350,
        ),
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        isAdding = false;
      });

      showMessage(
        'Firebase error: ${e.message ?? e.code}',
        error: true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isAdding = false;
      });

      showMessage(
        'Could not add money: $e',
        error: true,
      );
    }
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
                          'Add Money',
                          style: TextStyle(
                            color: _primaryText(
                              context,
                            ),
                            fontSize: 17,
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top Up Wallet',
                        style: TextStyle(
                          color: _primaryText(
                            context,
                          ),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        'Add money securely using your Visa card.',
                        style: TextStyle(
                          color: _secondaryText(
                            context,
                          ),
                          fontSize: 11.5,
                        ),
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      // =====================
                      // MINI VISA CARD
                      // =====================
                      AspectRatio(
                        aspectRatio: 1.65,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(
                            20,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              24,
                            ),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(
                                  0xFF087BEA,
                                ),
                                Color(
                                  0xFF0057B8,
                                ),
                                Color(
                                  0xFF003C87,
                                ),
                              ],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(
                                  0x33004BA8,
                                ),
                                blurRadius: 22,
                                offset: Offset(
                                  0,
                                  10,
                                ),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -40,
                                top: -55,
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: const BoxDecoration(
                                    color: Color(
                                      0x14FFFFFF,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Text(
                                        'BAYAN',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.contactless_rounded,
                                        color: Colors.white,
                                        size: 27,
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(
                                                0xFFFFD76A,
                                              ),
                                              Color(
                                                0xFFD9A928,
                                              ),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            7,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.grid_view_rounded,
                                          color: Color(
                                            0xFF9E7812,
                                          ),
                                          size: 21,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Text(
                                        'VISA',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 14,
                                  ),
                                  Text(
                                    cardNumberController.text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      letterSpacing: 1.25,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'CARD HOLDER',
                                              style: TextStyle(
                                                color: Colors.white60,
                                                fontSize: 7,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              cardHolderController.text,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'VALID THRU',
                                            style: TextStyle(
                                              color: Colors.white60,
                                              fontSize: 7,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            expiryController.text,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // =====================
                      // AMOUNT
                      // =====================
                      Text(
                        'Select Amount',
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

                      Row(
                        children: quickAmounts.map(
                          (amount) {
                            final bool selected = selectedAmount == amount;

                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: amount == quickAmounts.last ? 0 : 8,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    selectAmount(
                                      amount,
                                    );
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(
                                      milliseconds: 180,
                                    ),
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? AppColors.primaryBlue
                                          : _cardBackground(
                                              context,
                                            ),
                                      borderRadius: BorderRadius.circular(
                                        15,
                                      ),
                                      border: Border.all(
                                        color: selected
                                            ? AppColors.primaryBlue
                                            : _borderColor(
                                                context,
                                              ),
                                      ),
                                    ),
                                    child: Text(
                                      '\$${amount.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : _primaryText(
                                                context,
                                              ),
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),

                      const SizedBox(
                        height: 17,
                      ),

                      _InputField(
                        controller: amountController,
                        title: 'Custom Amount',
                        hint: 'Enter amount',
                        icon: Icons.attach_money_rounded,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedAmount = double.tryParse(
                                  value,
                                ) ??
                                0;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // =====================
                      // CARD INFORMATION
                      // =====================
                      Text(
                        'Card Information',
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

                      _InputField(
                        controller: cardHolderController,
                        title: 'Card Holder',
                        hint: 'Name on card',
                        icon: Icons.person_outline_rounded,
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),

                      const SizedBox(
                        height: 13,
                      ),

                      _InputField(
                        controller: cardNumberController,
                        title: 'Card Number',
                        hint: '0000 0000 0000 0000',
                        icon: Icons.credit_card_rounded,
                        keyboardType: TextInputType.number,
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),

                      const SizedBox(
                        height: 13,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: _InputField(
                              controller: expiryController,
                              title: 'Expiry Date',
                              hint: 'MM/YY',
                              icon: Icons.calendar_month_outlined,
                              keyboardType: TextInputType.number,
                              onChanged: (_) {
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: _InputField(
                              controller: cvvController,
                              title: 'CVV',
                              hint: '•••',
                              icon: Icons.lock_outline_rounded,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // Security note
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(
                          14,
                        ),
                        decoration: BoxDecoration(
                          color: _isDark(
                            context,
                          )
                              ? const Color(
                                  0xFF173653,
                                )
                              : const Color(
                                  0xFFEAF4FF,
                                ),
                          borderRadius: BorderRadius.circular(
                            17,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              color: AppColors.primaryBlue,
                              size: 21,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                'Card details are used only for this demo top-up. Full card data is not stored in Firebase.',
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 10.5,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // =====================
                      // ADD BUTTON
                      // =====================
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: FilledButton(
                          onPressed: isAdding ? null : addMoney,
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
                          child: isAdding
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  amountController.text.trim().isEmpty
                                      ? 'Add Money'
                                      : 'Add \$${amountController.text}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 14,
                              color: _secondaryText(
                                context,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Secure wallet top up',
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

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.title,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String title;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: _secondaryText(context),
              fontSize: 11.5,
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 20,
            ),
            filled: true,
            fillColor: _cardBackground(context),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _borderColor(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
