import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/visa_payment_card.dart';

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
  return _isDark(context) ? const Color(0xFF2B343C) : const Color(0xFFE6EAF0);
}

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  static const String databaseUrl =
      'https://bayan-travel-app-2026-default-rtdb.europe-west1.firebasedatabase.app';

  double balance = 0.0;

  String holderName = 'Bayan Traveler';

  List<Map<String, dynamic>> transactions = [];

  bool isLoading = true;
  bool isAddingMoney = false;

  DatabaseReference? walletReference;

  @override
  void initState() {
    super.initState();
    loadWallet();
  }

  Future<void> loadWallet() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    try {
      final FirebaseDatabase database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: databaseUrl,
      );

      walletReference = database.ref('users/${user.uid}/wallet');

      final DataSnapshot profileSnapshot =
          await database.ref('users/${user.uid}/profile/fullName').get();

      String loadedName = '';

      if (profileSnapshot.value != null) {
        loadedName = profileSnapshot.value.toString().trim();
      }

      if (loadedName.isEmpty) {
        loadedName = (user.displayName ?? '').trim();
      }

      if (loadedName.isEmpty) {
        final String email = user.email ?? '';

        loadedName =
            email.contains('@') ? email.split('@').first : 'Bayan Traveler';
      }

      final DataSnapshot snapshot = await walletReference!.get();

      if (!snapshot.exists) {
        await walletReference!.set({
          'balance': 0.0,
          'transactions': {},
        });

        if (!mounted) return;

        setState(() {
          holderName = loadedName;
          balance = 0.0;
          transactions = [];
          isLoading = false;
        });

        return;
      }

      final Object? value = snapshot.value;

      if (value is! Map) {
        if (!mounted) return;

        setState(() {
          holderName = loadedName;
          balance = 0.0;
          transactions = [];
          isLoading = false;
        });

        return;
      }

      final Map<dynamic, dynamic> walletData = Map<dynamic, dynamic>.from(
        value,
      );

      final Object? balanceValue = walletData['balance'];

      double loadedBalance = 0.0;

      if (balanceValue is num) {
        loadedBalance = balanceValue.toDouble();
      }

      final List<Map<String, dynamic>> loadedTransactions = [];

      final Object? transactionsValue = walletData['transactions'];

      if (transactionsValue is Map) {
        final Map<dynamic, dynamic> transactionMap = Map<dynamic, dynamic>.from(
          transactionsValue,
        );

        transactionMap.forEach(
          (key, value) {
            if (value is Map) {
              final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                value,
              );

              loadedTransactions.add({
                'id': key.toString(),
                'title': data['title']?.toString() ?? 'Transaction',
                'date': data['date']?.toString() ?? '',
                'amount': data['amount'] is num
                    ? (data['amount'] as num).toDouble()
                    : 0.0,
                'type': data['type']?.toString() ?? 'wallet',
                'createdAt': data['createdAt'] is num
                    ? (data['createdAt'] as num).toInt()
                    : 0,
              });
            }
          },
        );
      }

      loadedTransactions.sort(
        (a, b) => (b['createdAt'] as int).compareTo(
          a['createdAt'] as int,
        ),
      );

      if (!mounted) return;

      setState(() {
        holderName = loadedName;
        balance = loadedBalance;
        transactions = loadedTransactions;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage(
        'Could not load wallet. Please try again.',
        error: true,
      );
    }
  }

  void showMessage(
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            error ? const Color(0xFFE34A4A) : const Color(0xFF1FA66A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Future<void> saveMoney(
    double amount,
    BuildContext sheetContext,
  ) async {
    if (isAddingMoney) return;

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage(
        'Please log in again.',
        error: true,
      );
      return;
    }

    setState(() {
      isAddingMoney = true;
    });

    try {
      final FirebaseDatabase database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: databaseUrl,
      );

      final DatabaseReference walletRef = database.ref(
        'users/${user.uid}/wallet',
      );

      final DataSnapshot balanceSnapshot =
          await walletRef.child('balance').get();

      double currentBalance = 0.0;

      if (balanceSnapshot.value is num) {
        currentBalance = (balanceSnapshot.value as num).toDouble();
      }

      final double newBalance = currentBalance + amount;

      final DatabaseReference transactionRef =
          walletRef.child('transactions').push();

      final int now = DateTime.now().millisecondsSinceEpoch;

      await walletRef.update({
        'balance': newBalance,
        'transactions/${transactionRef.key}': {
          'title': 'Wallet Top Up',
          'date': formatTransactionDate(
            now,
          ),
          'amount': amount,
          'type': 'topup',
          'createdAt': now,
        },
      });

      if (!mounted) return;

      setState(() {
        balance = newBalance;

        transactions.insert(
          0,
          {
            'id': transactionRef.key,
            'title': 'Wallet Top Up',
            'date': formatTransactionDate(
              now,
            ),
            'amount': amount,
            'type': 'topup',
            'createdAt': now,
          },
        );
      });

      if (sheetContext.mounted) {
        Navigator.pop(sheetContext);
      }

      showMessage(
        '\$${amount.toStringAsFixed(2)} added successfully.',
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      showMessage(
        'Firebase error: ${e.message ?? e.code}',
        error: true,
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Could not add money: $e',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isAddingMoney = false;
        });
      }
    }
  }

  String formatTransactionDate(
    int milliseconds,
  ) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(
      milliseconds,
    );

    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final String hour = date.hour.toString().padLeft(2, '0');

    final String minute = date.minute.toString().padLeft(2, '0');

    return '${date.day} ${months[date.month - 1]} ${date.year} • $hour:$minute';
  }

  IconData transactionIcon(
    String type,
  ) {
    switch (type) {
      case 'topup':
        return Icons.add_card_rounded;

      case 'booking':
        return Icons.flight_takeoff_rounded;

      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  void addMoney() {
    final TextEditingController amountController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardBackground(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            18,
            22,
            MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _borderColor(
                      context,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Add Money',
                style: GoogleFonts.fredoka(
                  color: _primaryText(
                    context,
                  ),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the amount you want to add to your Bayan Wallet.',
                style: TextStyle(
                  color: _secondaryText(
                    context,
                  ),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(
                  color: _primaryText(
                    context,
                  ),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Amount',
                  hintStyle: TextStyle(
                    color: _secondaryText(
                      context,
                    ),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.attach_money_rounded,
                    color: AppColors.primaryBlue,
                  ),
                  filled: true,
                  fillColor: _pageBackground(
                    context,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: _borderColor(
                        context,
                      ),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: AppColors.primaryBlue,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: isAddingMoney ? 'Adding...' : 'Add to Wallet',
                  onPressed: () {
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

                    saveMoney(
                      amount,
                      sheetContext,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showCardMessage() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _cardBackground(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            22,
            18,
            22,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: _borderColor(
                    context,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'My Card',
                style: GoogleFonts.fredoka(
                  color: _primaryText(
                    context,
                  ),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              _PaymentCard(
                holderName: holderName,
                compact: true,
              ),
            ],
          ),
        );
      },
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
              _WalletHeader(
                onBack: () {
                  Navigator.pop(
                    context,
                  );
                },
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : RefreshIndicator(
                        onRefresh: loadWallet,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            4,
                            20,
                            30,
                          ),
                          children: [
                            _BalanceSummary(
                              balance: balance,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Payment Card',
                              style: GoogleFonts.fredoka(
                                color: _primaryText(
                                  context,
                                ),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            VisaPaymentCard(
                              cardHolder: holderName,
                              last4: '8979',
                              expiry: '03/28',
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _WalletAction(
                                    icon: Icons.add_rounded,
                                    title: 'Add Money',
                                    subtitle: 'Top up wallet',
                                    onPressed: addMoney,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _WalletAction(
                                    icon: Icons.credit_card_rounded,
                                    title: 'My Cards',
                                    subtitle: 'View card',
                                    onPressed: showCardMessage,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Recent Transactions',
                                    style: GoogleFonts.fredoka(
                                      color: _primaryText(
                                        context,
                                      ),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _cardBackground(
                                      context,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      14,
                                    ),
                                    border: Border.all(
                                      color: _borderColor(
                                        context,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    '${transactions.length} items',
                                    style: TextStyle(
                                      color: _secondaryText(
                                        context,
                                      ),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 13),
                            if (transactions.isEmpty)
                              const _EmptyTransactions()
                            else
                              ...transactions.map(
                                (
                                  transaction,
                                ) {
                                  final double amount =
                                      transaction['amount'] as double;

                                  final bool incoming = amount > 0;

                                  final String type =
                                      transaction['type'].toString();

                                  return _TransactionCard(
                                    title: transaction['title'].toString(),
                                    date: transaction['date'].toString(),
                                    amount: amount,
                                    incoming: incoming,
                                    icon: transactionIcon(
                                      type,
                                    ),
                                  );
                                },
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

class _WalletHeader extends StatelessWidget {
  const _WalletHeader({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        17,
        11,
        17,
        14,
      ),
      child: Row(
        children: [
          Material(
            color: _cardBackground(context),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _primaryText(
                    context,
                  ),
                  size: 18,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'My Wallet',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                color: _primaryText(
                  context,
                ),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _BalanceSummary extends StatelessWidget {
  const _BalanceSummary({
    required this.balance,
  });

  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _borderColor(context),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _isDark(context)
                  ? const Color(0xFF173653)
                  : const Color(0xFFEAF4FF),
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Balance',
                  style: TextStyle(
                    color: _secondaryText(
                      context,
                    ),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '\$${balance.toStringAsFixed(2)}',
                  style: GoogleFonts.fredoka(
                    color: _primaryText(
                      context,
                    ),
                    fontSize: 27,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(
                0xFFEAF8F1,
              ),
              borderRadius: BorderRadius.circular(
                14,
              ),
            ),
            child: const Text(
              'USD',
              style: TextStyle(
                color: Color(0xFF1A9B64),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.holderName,
    this.compact = false,
  });

  final String holderName;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bool dark = _isDark(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: compact ? 185 : 205,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF202833) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: dark ? const Color(0xFF36414B) : const Color(0xFFE0E5EB),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 35,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFFFD76A,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 15,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 1,
                        color: const Color(
                          0xFFCFAB4A,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 14,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 1,
                        color: const Color(
                          0xFFCFAB4A,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 16,
                      child: Container(
                        height: 1,
                        color: const Color(
                          0xFFCFAB4A,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Bayan Card',
                style: GoogleFonts.fredoka(
                  color: _primaryText(
                    context,
                  ),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.contactless_rounded,
                color: _secondaryText(
                  context,
                ),
                size: 27,
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            '••••  ••••  ••••  8979',
            style: GoogleFonts.fredoka(
              color: _primaryText(
                context,
              ),
              fontSize: compact ? 19 : 21,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARD HOLDER',
                      style: TextStyle(
                        color: _secondaryText(
                          context,
                        ),
                        fontSize: 10,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      holderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText(
                          context,
                        ),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPIRES',
                    style: TextStyle(
                      color: _secondaryText(
                        context,
                      ),
                      fontSize: 10,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '03/28',
                    style: TextStyle(
                      color: _primaryText(
                        context,
                      ),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 22),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF075EBB,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'VISA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w900,
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

class _WalletAction extends StatelessWidget {
  const _WalletAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _cardBackground(context),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              20,
            ),
            border: Border.all(
              color: _borderColor(context),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: _isDark(context)
                      ? const Color(0xFF173653)
                      : const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: _primaryText(
                          context,
                        ),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.title,
    required this.date,
    required this.amount,
    required this.incoming,
    required this.icon,
  });

  final String title;
  final String date;
  final double amount;
  final bool incoming;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 11,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: incoming
                  ? const Color(0xFFE9F9F1)
                  : _isDark(context)
                      ? const Color(0xFF173653)
                      : const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(
                15,
              ),
            ),
            child: Icon(
              icon,
              color: incoming ? const Color(0xFF1FA66A) : AppColors.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(
                      context,
                    ),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          const SizedBox(width: 8),
          Text(
            '${incoming ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color:
                  incoming ? const Color(0xFF1FA66A) : const Color(0xFFE34A4A),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _isDark(context)
                  ? const Color(0xFF173653)
                  : const Color(0xFFEAF4FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: TextStyle(
              color: _primaryText(
                context,
              ),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Your wallet activity will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryText(
                context,
              ),
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
