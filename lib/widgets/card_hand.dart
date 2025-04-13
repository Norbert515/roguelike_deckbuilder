import 'dart:math';

import 'package:flutter/material.dart';
import 'package:roguelike_deckbuilder/models/card.dart';
import 'package:roguelike_deckbuilder/widgets/game_card_widget.dart';

class CardHand extends StatefulWidget {
  final List<GameCard> cards;
  final Function(int index, GameCard card)? onCardSelected;
  final double cardWidth;
  final double cardHeight;
  final double overlapFactor;

  const CardHand({
    Key? key,
    required this.cards,
    this.onCardSelected,
    this.cardWidth = 180,
    this.cardHeight = 250,
    this.overlapFactor = 0.7,
  }) : super(key: key);

  @override
  State<CardHand> createState() => _CardHandState();
}

class _CardHandState extends State<CardHand> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalWidth = widget.cardWidth + (widget.cards.length - 1) * (widget.cardWidth * widget.overlapFactor);

    return SizedBox(
      height: widget.cardHeight + 20, // Extra space for card elevation and curve
      child: Center(
        child: SizedBox(
          width: totalWidth,
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(widget.cards.length, (index) {
              final card = widget.cards[index];
              final horizontalOffset = index * (widget.cardWidth * widget.overlapFactor);

              // Calculate transformation values for the curve
              final int numCards = widget.cards.length;
              final double centerIndex = (numCards - 1) / 2.0;
              final double distanceFromCenter = index - centerIndex;

              // Max rotation angle (e.g., 5 degrees per card from center)
              final double maxAngleDegrees = 5.0;
              final double angleRadians = (distanceFromCenter / (numCards / 2.0)) * (maxAngleDegrees * pi / 180.0);

              // Max vertical offset for the curve (adjust as needed)
              final double maxVerticalOffset = 15.0;
              // Use a parabolic curve for vertical offset
              final double verticalOffset = pow(distanceFromCenter / (numCards / 2.0), 2) * maxVerticalOffset;

              return Positioned(
                left: horizontalOffset,
                // Adjust top position based on the curve
                top: verticalOffset,
                child: Transform.rotate(
                  angle: angleRadians,
                  // Rotate around the bottom center of the card
                  alignment: Alignment.bottomCenter,
                  child: GameCardWidget(
                    card: card,
                    width: widget.cardWidth,
                    height: widget.cardHeight,
                    isSelected: selectedIndex == index,
                    onTap: () {
                      setState(() {
                        if (selectedIndex == index) {
                          selectedIndex = null;
                        } else {
                          selectedIndex = index;
                        }
                      });
                      if (widget.onCardSelected != null) {
                        widget.onCardSelected!(index, card);
                      }
                    },
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
