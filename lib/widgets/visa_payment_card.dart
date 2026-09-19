import 'package:flutter/material.dart';

class VisaPaymentCard extends StatelessWidget {
  const VisaPaymentCard({
    super.key,
    this.cardHolder = 'Bayan Alissa',
    this.last4 = '8979',
    this.expiry = '03/28',
  });

  final String cardHolder;
  final String last4;
  final String expiry;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.58,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF13A2E8),
              Color(0xFF0878D1),
              Color(0xFF06438F),
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x350064C8),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // دائرة زخرفية
            Positioned(
              right: -45,
              top: -55,
              child: Container(
                width: 170,
                height: 170,
                decoration: const BoxDecoration(
                  color: Color(0x18FFFFFF),
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
                  color: Color(0x0DFFFFFF),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // أعلى البطاقة
                const Row(
                  children: [
                    Text(
                      'BAYAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.contactless_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ],
                ),

                const Spacer(),

                // CHIP
                Container(
                  width: 52,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFE58A),
                        Color(0xFFF3B92F),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: 1,
                          height: 40,
                          color: const Color(0x66906A00),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 52,
                          height: 1,
                          color: const Color(0x66906A00),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 10,
                        child: Container(
                          height: 1,
                          color: const Color(0x44906A00),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 10,
                        child: Container(
                          height: 1,
                          color: const Color(0x44906A00),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 17),

                // رقم البطاقة
                Text(
                  '••••   ••••   ••••   $last4',
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                  ),
                ),

                const Spacer(),

                // أسفل البطاقة
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CARD HOLDER',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 8,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cardHolder,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VALID THRU',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expiry,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 18),
                    const Text(
                      'VISA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
