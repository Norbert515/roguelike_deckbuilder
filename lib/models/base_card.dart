import 'package:flutter/foundation.dart'; // For @required if needed, or just use required keyword

part 'all_cards.dart';

// TODO: Define actual game state context needed for card effects
class GameContext {
  // Placeholder for game state, player hands, deck, etc.
}

// Defines the categories of cards in the game.
enum CardType {
  feature, // Represents app features
  marketing, // Represents user acquisition/marketing efforts
  bug, // Represents problems hindering progress
  utility, // Represents development actions, refactoring, etc.
}

// Base class for all card definitions in the game.
// Each specific card will extend this class.
// Sealed ensures all direct subtypes are within this library (base_card.dart + all_cards.dart)
sealed class BaseCard {
  // A unique, code-friendly identifier (e.g., "code_cleanup")
  // Must be explicitly defined in implementations.
  String get id;

  // The display name of the card (e.g., "Code Cleanup")
  String get name;

  // The category this card belongs to.
  CardType get type;

  // The time/effort cost to develop/play this card.
  int get timeTaken;

  // Descriptive text explaining the card's effect when played.
  String get onPlayText;

  // Descriptive text explaining the card's effect when the turn resolves.
  String get onResolveText;

  // Flavor text adding personality to the card.
  String get flavorText;

  // Path to the card's visual asset.
  String get assetPath;

  // Abstract method defining the action taken when the card is played.
  // Takes the current game context to allow interaction with game state.
  void onPlay(GameContext context);

  // Abstract method defining the action taken when the turn resolves
  // if this card is in the active build/play area.
  void onResolve(GameContext context);

  // Helper to generate the ID from the name.
  // static String generateIdFromName(String name) {
  //   return name
  //       .toLowerCase()
  //       .replaceAll(RegExp(r'[^\w\s]+'), '') // Remove punctuation
  //       .replaceAll(RegExp(r'\s+'), '_'); // Replace spaces with underscores
  // }
}
