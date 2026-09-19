import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'add_money_page.dart';

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

class MyWalletPage extends StatefulWidget {
  const MyWalletPage({super.key});

  @override
  State<MyWalletPage> createState() => _MyWalletPageState();
}

class _MyWalletPageState extends State<MyWalletPage> {
  static const String databaseUrl =
      'https://bayan-travel-app-2026-default-rtdb.europe-west1.firebasedatabase.app';

  double walletBalance = 0.0;

  bool isLoading = true;

  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    loadWalletData();
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

  String get cardHolderName {
    final User? user = FirebaseAuth.instance.currentUser;

    final String? displayName = user?.displayName;

    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName;
    }

    final String email = user?.email ?? 'Bayan User';

    final String name = email.split('@').first;

    if (name.trim().isEmpty) {
      return 'Bayan User';
    }

    return name.replaceAll('.', ' ').replaceAll('_', ' ');
  }

  Future<void> loadWalletData() async {
    final DatabaseReference? walletRef = getWalletReference();

    if (walletRef == null) {
      if (!mounted) return;

      setState(() {
        walletBalance = 0.0;
        transactions = [];
        isLoading = false;
      });

      return;
    }

    try {
      // تحميل الرصيد
      final DataSnapshot balanceSnapshot =
          await walletRef.child('balance').get();

      double loadedBalance = 0.0;

      if (balanceSnapshot.value is num) {
        loadedBalance = (balanceSnapshot.value as num).toDouble();
      }

      // تحميل العمليات
      final DataSnapshot transactionsSnapshot =
          await walletRef.child('transactions').get();

      final List<Map<String, dynamic>> loadedTransactions = [];

      if (transactionsSnapshot.value is Map) {
        final Map<dynamic, dynamic> data =
            transactionsSnapshot.value as Map<dynamic, dynamic>;

        data.forEach(
          (key, value) {
            if (value is Map) {
              loadedTransactions.add(
                {
                  'id': key.toString(),
                  ...Map<String, dynamic>.from(
                    value,
                  ),
                },
              );
            }
          },
        );
      }

      loadedTransactions.sort(
        (a, b) {
          final int first = (a['createdAt'] as num?)?.toInt() ?? 0;

          final int second = (b['createdAt'] as num?)?.toInt() ?? 0;

          return second.compareTo(first);
        },
      );

      if (!mounted) return;

      setState(() {
        walletBalance = loadedBalance;
        transactions = loadedTransactions;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not load wallet data.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> openAddMoney() async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddMoneyPage(),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        isLoading = true;
      });

      await loadWalletData();
    }
  }

  void showCardsMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Your Visa card is linked to Bayan Wallet.',
        ),
        behavior: SnackBarBehavior.floating,
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
        child: SafeArea(
          child: Column(
            children: [
              // =========================
              // HEADER
              // =========================
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  8,
                  7,
                  16,
                  5,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: _cardBackground(context),
                        shape: const CircleBorder(),
                      ),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _primaryText(context),
                        size: 17,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'My Wallet',
                          style: TextStyle(
                            color: _primaryText(context),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : RefreshIndicator(
                        onRefresh: loadWalletData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            14,
                            20,
                            35,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // =========================
                              // AVAILABLE BALANCE
                              // =========================
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: _cardBackground(
                                    context,
                                  ),
                                  borderRadius: BorderRadius.circular(23),
                                  border: Border.all(
                                    color: _borderColor(
                                      context,
                                    ),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(
                                        0x09000000,
                                      ),
                                      blurRadius: 16,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
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
                                          15,
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
                                            'Available Balance',
                                            style: TextStyle(
                                              color: _secondaryText(
                                                context,
                                              ),
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            '\$${walletBalance.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: _primaryText(
                                                context,
                                              ),
                                              fontSize: 26,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFE8F7EF,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          20,
                                        ),
                                      ),
                                      child: const Text(
                                        'USD',
                                        style: TextStyle(
                                          color: Color(
                                            0xFF1FA66A,
                                          ),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                height: 27,
                              ),

                              Text(
                                'Payment Card',
                                style: TextStyle(
                                  color: _primaryText(
                                    context,
                                  ),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              const SizedBox(
                                height: 14,
                              ),

                              // =========================
                              // VISA CARD
                              // =========================
                              AspectRatio(
                                aspectRatio: 1.58,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(21),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      24,
                                    ),

                                    // خلفية Visa زرقاء
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(
                                          0xFF1BA8E8,
                                        ),
                                        Color(
                                          0xFF0878D1,
                                        ),
                                        Color(
                                          0xFF06428F,
                                        ),
                                      ],
                                    ),

                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(
                                          0x380068D7,
                                        ),
                                        blurRadius: 25,
                                        offset: Offset(
                                          0,
                                          12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // دوائر ديكور بالخلفية
                                      Positioned(
                                        right: -50,
                                        top: -65,
                                        child: Container(
                                          width: 180,
                                          height: 180,
                                          decoration: const BoxDecoration(
                                            color: Color(
                                              0x16FFFFFF,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),

                                      Positioned(
                                        right: -70,
                                        bottom: -95,
                                        child: Container(
                                          width: 210,
                                          height: 210,
                                          decoration: const BoxDecoration(
                                            color: Color(
                                              0x0CFFFFFF,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),

                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // أعلى البطاقة
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
                                                size: 29,
                                              ),
                                            ],
                                          ),

                                          const Spacer(),

                                          // Chip + VISA
                                          Row(
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 38,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    8,
                                                  ),
                                                  gradient:
                                                      const LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Color(
                                                        0xFFFFE082,
                                                      ),
                                                      Color(
                                                        0xFFF5B82E,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Center(
                                                      child: Container(
                                                        width: 1,
                                                        height: 38,
                                                        color: const Color(
                                                          0x55906600,
                                                        ),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Container(
                                                        width: 50,
                                                        height: 1,
                                                        color: const Color(
                                                          0x55906600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Spacer(),
                                              const Text(
                                                'VISA',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 27,
                                                  fontWeight: FontWeight.w900,
                                                  fontStyle: FontStyle.italic,
                                                  letterSpacing: -1.5,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(
                                            height: 16,
                                          ),

                                          // رقم البطاقة
                                          const Text(
                                            '••••   ••••   ••••   8979',
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              letterSpacing: 1.2,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),

                                          const Spacer(),

                                          // الاسم + الصلاحية
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'CARD HOLDER',
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 7.5,
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 4,
                                                    ),
                                                    Text(
                                                      cardHolderName,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'VALID THRU',
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 7.5,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 4,
                                                  ),
                                                  Text(
                                                    '03/28',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                height: 22,
                              ),

                              // =========================
                              // ACTION BUTTONS
                              // =========================
                              Row(
                                children: [
                                  Expanded(
                                    child: _WalletAction(
                                      icon: Icons.add_rounded,
                                      title: 'Add Money',
                                      subtitle: 'Top up wallet',
                                      onTap: openAddMoney,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Expanded(
                                    child: _WalletAction(
                                      icon: Icons.credit_card_rounded,
                                      title: 'My Cards',
                                      subtitle: 'View card',
                                      onTap: showCardsMessage,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 30,
                              ),

                              // =========================
                              // RECENT TRANSACTIONS
                              // =========================
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Recent Transactions',
                                      style: TextStyle(
                                        color: _primaryText(
                                          context,
                                        ),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
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
                                        16,
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
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 14,
                              ),

                              if (transactions.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(25),
                                  decoration: BoxDecoration(
                                    color: _cardBackground(
                                      context,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      20,
                                    ),
                                    border: Border.all(
                                      color: _borderColor(
                                        context,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.receipt_long_outlined,
                                        color: _secondaryText(
                                          context,
                                        ),
                                        size: 32,
                                      ),
                                      const SizedBox(
                                        height: 9,
                                      ),
                                      Text(
                                        'No transactions yet',
                                        style: TextStyle(
                                          color: _primaryText(
                                            context,
                                          ),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: transactions.length > 5
                                      ? 5
                                      : transactions.length,
                                  separatorBuilder: (
                                    context,
                                    index,
                                  ) {
                                    return const SizedBox(
                                      height: 10,
                                    );
                                  },
                                  itemBuilder: (
                                    context,
                                    index,
                                  ) {
                                    return _TransactionCard(
                                      transaction: transactions[index],
                                    );
                                  },
                                ),
                            ],
                          ),
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

class _WalletAction extends StatelessWidget {
  const _WalletAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _cardBackground(context),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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
                  color: const Color(
                    0xFFEAF4FF,
                  ),
                  borderRadius: BorderRadius.circular(
                    13,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryBlue,
                  size: 21,
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
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      subtitle,
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
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.transaction,
  });

  final Map<String, dynamic> transaction;

  @override
  Widget build(BuildContext context) {
    final String title = transaction['title']?.toString() ?? 'Transaction';

    final double amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;

    final bool positive = amount >= 0;

    final String type = transaction['type']?.toString() ?? '';

    final IconData icon =
        type == 'topup' ? Icons.add_card_rounded : Icons.hotel_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBackground(context),
        borderRadius: BorderRadius.circular(18),
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
              color: positive
                  ? const Color(
                      0xFFE8F7EF,
                    )
                  : const Color(
                      0xFFEAF4FF,
                    ),
              borderRadius: BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              icon,
              color: positive
                  ? const Color(
                      0xFF1FA66A,
                    )
                  : AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  type == 'topup' ? 'Wallet Top Up' : 'Booking Payment',
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
          Text(
            '${positive ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: positive
                  ? const Color(
                      0xFF1FA66A,
                    )
                  : const Color(
                      0xFFE34A4A,
                    ),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
