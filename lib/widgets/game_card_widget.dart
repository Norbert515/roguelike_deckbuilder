import 'package:flutter/material.dart';
import 'package:roguelike_deckbuilder/models/card_in_play.dart';

class GameCardWidget extends StatelessWidget {
  final CardInPlay cardInPlay;
  final bool isSelected;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const GameCardWidget({
    Key? key,
    required this.cardInPlay,
    this.isSelected = false,
    this.onTap,
    this.width = 200,
    this.height = 280,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardDefinition = cardInPlay.cardType;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        transform: isSelected ? Matrix4.translationValues(0, -20, 0) : Matrix4.identity(),
        child: Card(
          elevation: isSelected ? 8 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isSelected ? Colors.white : Colors.transparent, width: isSelected ? 2 : 0),
          ),
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(cardDefinition.assetPath, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
