import 'package:flutter/material.dart';

class CardDeck extends StatelessWidget {
  final int cardCount;
  final VoidCallback? onTap;
  final Color cardColor;
  final double width;
  final double height;
  final String label;
  final IconData? icon;

  const CardDeck({
    Key? key,
    required this.cardCount,
    this.onTap,
    this.cardColor = Colors.blueGrey,
    this.width = 120,
    this.height = 160,
    this.label = 'Deck',
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Generate cards in the stack
            for (int i = 0; i < min(5, cardCount); i++)
              Positioned(
                top: i * 2.0,
                left: i * 2.0,
                child: Container(
                  width: width - i * 4,
                  height: height - i * 4,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              
            // Top card with content
            Positioned(
              top: min(5, cardCount) * 2.0,
              left: min(5, cardCount) * 2.0,
              child: Container(
                width: width - min(5, cardCount) * 4,
                height: height - min(5, cardCount) * 4,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null)
                      Icon(
                        icon,
                        size: 36,
                        color: Colors.white,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$cardCount cards',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  int min(int a, int b) => a < b ? a : b;
}