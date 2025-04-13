import 'package:roguelike_deckbuilder/models/base_card.dart';
import 'package:uuid/uuid.dart';

// Represents a specific instance of a card that is currently in play,
// in a hand, or otherwise active in the game world.
// This is a simple data holder linking a card definition (BaseCard)
// with a unique runtime identifier.
class CardInPlay {
  // The definition of the card (e.g., type, name, effects).
  final BaseCard cardType;

  // Unique identifier for this specific instance of the card.
  final String instanceId;

  // --- State --- (Add more state as needed: position, animation, etc.)
  // Example:
  // String currentAnimationState = 'idle';

  // Creates a new instance wrapper for a given card definition.
  CardInPlay(this.cardType) : instanceId = const Uuid().v4();

  // Static registry and methods removed. Instance tracking is now managed
  // elsewhere (e.g., in the game state or UI state).
}
