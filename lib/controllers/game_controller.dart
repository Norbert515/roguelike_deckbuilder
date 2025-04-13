import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/card.dart';
import '../models/game_state.dart';

// TODO: Load actual starter deck
const List<GameCard> _starterDeck = [
  // Add starter cards here based on game.md
];

class GameController extends ValueNotifier<GameState> {
  final Random _random = Random();

  GameController() : super(GameState.initial()) {
    _initializeGame();
  }

  void _initializeGame() {
    // TODO: Replace placeholder with actual starter deck loading
    final initialDeck = List<GameCard>.from(_starterDeck);
    _shuffleDeck(initialDeck);

    final initialState = GameState.initial().copyWith(deck: initialDeck);
    value = initialState;
    _drawUntil(5); // Draw initial hand
  }

  // --- Core Actions ---

  /// Plays a regular card (Feature, Marketing, Utility) from hand.
  void playCard(GameCard card, int handIndex) {
    if (value.currentHours < card.timeTaken) {
      debugPrint("Not enough hours to play ${card.name}");
      return; // Cannot afford card
    }

    final newHand = List<GameCard>.from(value.hand);
    newHand.removeAt(handIndex);

    final newSprintBacklog = List<GameCard>.from(value.sprintBacklog);
    newSprintBacklog.add(card);

    value = value.copyWith(
      currentHours: value.currentHours - card.timeTaken,
      hand: newHand,
      sprintBacklog: newSprintBacklog,
    );

    _handleOnPlay(card); // Trigger immediate effects
  }

  /// Fixes a Bug card from hand.
  void fixBug(GameCard bugCard, int handIndex) {
    if (bugCard.type != CardType.bug) {
      debugPrint("Tried to fix a non-bug card: ${bugCard.name}");
      return;
    }
    if (value.currentHours < bugCard.timeTaken) {
      debugPrint("Not enough hours to fix ${bugCard.name}");
      return; // Cannot afford to fix
    }

    final newHand = List<GameCard>.from(value.hand);
    newHand.removeAt(handIndex);

    final newRemovedCards = List<GameCard>.from(value.removedCards);
    newRemovedCards.add(bugCard);

    value = value.copyWith(
      currentHours: value.currentHours - bugCard.timeTaken,
      hand: newHand,
      removedCards: newRemovedCards,
    );
  }

  /// Ends the current sprint, resolves effects, and prepares the next sprint.
  void release() {
    // 1. Resolve effects of cards in the sprint backlog
    _handleOnResolve();

    // 2. Handle negative effects of unplayed bugs in hand
    _handleUnplayedBugs();

    // 3. Discard played cards (non-bugs) from backlog
    final List<GameCard> cardsToDiscard = [];
    final List<GameCard> remainingBacklog = []; // Should be empty unless bugs are handled differently
    for (final card in value.sprintBacklog) {
      if (card.type != CardType.bug) {
        // Assuming fixed bugs are already removed
        cardsToDiscard.add(card);
      } else {
        // This case might need refinement based on bug rules
        remainingBacklog.add(card);
      }
    }
    final newDiscard = List<GameCard>.from(value.discardPile)..addAll(cardsToDiscard);

    // 4. Check milestone
    if (value.users < value.requiredUsers && _isMilestoneSprint(value.sprint)) {
      debugPrint(
        "Game Over: Failed to meet milestone for sprint ${value.sprint}. Required: ${value.requiredUsers}, Actual: ${value.users}",
      );
      // TODO: Implement actual game over state/handling
      return;
    }

    // 5. Start next sprint
    final nextSprint = value.sprint + 1;
    final nextMilestone = _getMilestoneForSprint(nextSprint);

    value = value.copyWith(
      sprint: nextSprint,
      requiredUsers: nextMilestone,
      currentHours: value.startingHoursPerSprint, // Reset hours
      discardPile: newDiscard,
      sprintBacklog: remainingBacklog, // Clear backlog (or handle remaining items)
    );

    // 6. Draw cards for the new sprint
    _drawUntil(5);
  }

  // --- Helper Methods ---

  void _drawCard() {
    List<GameCard> currentDeck = List.from(value.deck);
    List<GameCard> currentDiscard = List.from(value.discardPile);
    List<GameCard> currentHand = List.from(value.hand);

    if (currentDeck.isEmpty) {
      if (currentDiscard.isEmpty) {
        debugPrint("Cannot draw card: Deck and discard pile are empty.");
        return; // No cards left anywhere
      }
      debugPrint("Deck empty, shuffling discard pile.");
      _shuffleDeck(currentDiscard);
      currentDeck = currentDiscard;
      currentDiscard = [];
    }

    final cardToDraw = currentDeck.removeAt(0);
    currentHand.add(cardToDraw);

    value = value.copyWith(deck: currentDeck, discardPile: currentDiscard, hand: currentHand);
  }

  void _drawUntil(int targetHandSize) {
    while (value.hand.length < targetHandSize) {
      if (value.deck.isEmpty && value.discardPile.isEmpty) {
        break; // Cannot draw anymore
      }
      _drawCard();
    }
  }

  void _shuffleDeck(List<GameCard> deck) {
    deck.shuffle(_random);
  }

  int _getMilestoneForSprint(int sprint) {
    if (sprint <= 10) return 10000;
    if (sprint <= 20) return 100000;
    if (sprint <= 30) return 500000;
    if (sprint <= 40) return 1000000;
    // TODO: Define scaling beyond sprint 40
    return 1000000 + (sprint - 40) * 100000; // Example scaling
  }

  bool _isMilestoneSprint(int sprint) {
    return sprint % 10 == 0 && sprint > 0;
  }

  // --- Effect Handlers (Placeholders) ---

  void _handleOnPlay(GameCard card) {
    debugPrint("Handling OnPlay for: ${card.name} - ${card.onPlay}");
    // TODO: Implement actual OnPlay logic (draw, gain hours, discard, etc.)
    // This might involve modifying the GameState directly or returning changes.
    // Example: if (card.onPlay == "Draw 1 card") { _drawCard(); }
  }

  void _handleOnResolve() {
    debugPrint("Handling OnResolve for ${value.sprintBacklog.length} cards.");
    // TODO: Implement actual OnResolve logic
    // Iterate through value.sprintBacklog, check card.onResolve
    // Calculate user gain, apply bonuses, handle card interactions (left/right)
    // Update value.users based on the results.
    // Needs careful handling of order and dependencies.
    int usersGained = 0;
    for (int i = 0; i < value.sprintBacklog.length; i++) {
      final card = value.sprintBacklog[i];
      debugPrint("  - Resolving: ${card.name} - ${card.onResolve}");
      // Placeholder user gain
      if (card.type == CardType.marketing && card.onResolve.isNotEmpty) {
        usersGained += 1000; // Example base gain
      }
    }

    if (usersGained > 0) {
      value = value.copyWith(users: value.users + usersGained);
    }
  }

  void _handleUnplayedBugs() {
    debugPrint("Handling unplayed bugs in hand.");
    // TODO: Implement actual unplayed bug logic
    // Iterate through value.hand, find CardType.bug
    // Apply negative effects (lose users, discard cards, etc.)
    // Update value.users or other state accordingly.
    int userPenalty = 0;
    for (final card in value.hand) {
      if (card.type == CardType.bug) {
        debugPrint("  - Unplayed Bug: ${card.name} - Triggering penalty: ${card.onResolve}");
        // Example penalty
        if (card.onResolve.contains("-2,500 users")) {
          userPenalty += 2500;
        }
      }
    }
    if (userPenalty > 0) {
      value = value.copyWith(users: max(0, value.users - userPenalty));
    }
  }
}
