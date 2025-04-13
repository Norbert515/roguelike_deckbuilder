import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:roguelike_deckbuilder/data/card_registry.dart';

import '../models/card.dart';
import '../models/game_state.dart';

// No longer need the placeholder deck here

class GameController extends ValueNotifier<GameState> {
  final Random _random = Random();

  GameController() : super(GameState.initial()) {
    _initializeGame();
  }

  void _initializeGame() {
    // Use the starter deck from the registry
    final initialDeck = List<GameCard>.from(CardRegistry.starterDeck);
    _shuffleDeck(initialDeck);

    // Update the GameState.initial factory later if needed for cleaner setup
    GameState initialState = GameState.initial().copyWith(deck: initialDeck);
    // Draw initial hand using the refactored method
    initialState = _drawUntil(initialState, 5);
    value = initialState;
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

    // Store the current state before handling OnPlay effects
    final stateBeforeOnPlay = value.copyWith(
      currentHours: value.currentHours - card.timeTaken,
      hand: newHand,
      sprintBacklog: newSprintBacklog,
    );

    // Update the state *before* calling _handleOnPlay
    value = stateBeforeOnPlay;

    // Trigger immediate effects which might further modify the state
    _handleOnPlay(card);
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
    // Note: Bugs typically don't have OnPlay effects when fixed.
  }

  /// Ends the current sprint, resolves effects, and prepares the next sprint.
  void release() {
    // 1. Resolve effects of cards in the sprint backlog
    GameState stateAfterResolve = _handleOnResolve();
    // Apply the state changes from resolve effects immediately
    value = stateAfterResolve;

    // 2. Handle negative effects of unplayed bugs in hand (operates on the updated state)
    GameState stateAfterBugCheck = _handleUnplayedBugs();
    // Apply the state changes from bug effects immediately
    value = stateAfterBugCheck;

    // 3. Discard played cards (non-bugs) from backlog
    final List<GameCard> cardsToDiscard = [];
    // Use the most recent state (value) which includes resolved/bug effects
    final List<GameCard> currentBacklog = List.from(value.sprintBacklog);
    for (final card in currentBacklog) {
      if (card.type != CardType.bug) {
        cardsToDiscard.add(card);
      }
    }
    final newDiscard = List<GameCard>.from(value.discardPile)..addAll(cardsToDiscard);

    // 4. Check milestone (using the final user count after resolve/bugs)
    if (value.users < value.requiredUsers && _isMilestoneSprint(value.sprint)) {
      debugPrint(
        "Game Over: Failed to meet milestone for sprint ${value.sprint}. Required: ${value.requiredUsers}, Actual: ${value.users}",
      );
      // TODO: Implement actual game over state/handling
      // Potentially set a GameState flag like `isGameOver = true`
      // For now, just prevent proceeding
      return;
    }

    // 5. Start next sprint preparations using the current state
    final nextSprint = value.sprint + 1;
    final nextMilestone = _getMilestoneForSprint(nextSprint);

    // Create a temporary state for drawing, starting from the current state
    // Clear the sprint backlog here before drawing
    GameState stateForNextSprint = value.copyWith(
      sprint: nextSprint,
      requiredUsers: nextMilestone,
      currentHours: value.startingHoursPerSprint, // Reset hours
      discardPile: newDiscard,
      sprintBacklog: [], // Clear backlog for the new sprint
      // Keep hand and deck as they are before drawing
    );

    // 6. Draw cards for the new sprint - Modify the temporary state
    stateForNextSprint = _drawUntil(stateForNextSprint, 5);

    // 7. Update the actual value notifier with the final state for the new sprint
    value = stateForNextSprint;
  }

  // --- Helper Methods ---
  // Modified draw methods to operate on and return GameState

  GameState _drawCard(GameState currentState) {
    List<GameCard> currentDeck = List.from(currentState.deck);
    List<GameCard> currentDiscard = List.from(currentState.discardPile);
    List<GameCard> currentHand = List.from(currentState.hand);

    if (currentDeck.isEmpty) {
      if (currentDiscard.isEmpty) {
        debugPrint("Cannot draw card: Deck and discard pile are empty.");
        return currentState; // No cards left anywhere
      }
      debugPrint("Deck empty, shuffling discard pile.");
      _shuffleDeck(currentDiscard);
      currentDeck = currentDiscard;
      currentDiscard = [];
    }

    final cardToDraw = currentDeck.removeAt(0);
    currentHand.add(cardToDraw);

    return currentState.copyWith(deck: currentDeck, discardPile: currentDiscard, hand: currentHand);
  }

  GameState _drawUntil(GameState currentState, int targetHandSize) {
    GameState tempState = currentState;
    while (tempState.hand.length < targetHandSize) {
      if (tempState.deck.isEmpty && tempState.discardPile.isEmpty) {
        break; // Cannot draw anymore
      }
      tempState = _drawCard(tempState);
    }
    return tempState;
  }

  void _shuffleDeck(List<GameCard> deck) {
    deck.shuffle(_random);
  }

  int _getMilestoneForSprint(int sprint) {
    // Milestones are checked AT the end of the sprint (e.g., end of sprint 10)
    // So the requirement applies for sprint 11 onward based on sprint 10 result
    if (sprint <= 10) return 10000;
    if (sprint <= 20) return 100000;
    if (sprint <= 30) return 500000;
    if (sprint <= 40) return 1000000;
    // TODO: Define scaling beyond sprint 40
    // Corrected scaling: Apply milestone check at END of sprint X, requirement for X+1.
    int milestoneSprint = ((sprint - 1) ~/ 10) * 10;
    if (milestoneSprint >= 40) {
      return 1000000 + (milestoneSprint - 40) ~/ 10 * 500000; // Placeholder scaling
    }
    // Should not happen with current logic, but return base for safety
    return 1000000;
  }

  bool _isMilestoneSprint(int sprint) {
    // Check occurs at the end of the sprint, e.g. end of sprint 10, 20, etc.
    return sprint % 10 == 0 && sprint > 0;
  }

  // --- Effect Handlers ---
  // _handleOnPlay modifies value directly as it's called after the initial play update.
  // _handleOnResolve and _handleUnplayedBugs return modified state.

  void _handleOnPlay(GameCard card) {
    debugPrint("Handling OnPlay for: ${card.name} - ${card.onPlay}");

    GameState newState = value; // Start with the current state

    // --- Implement OnPlay effects here ---

    // Example: Microtransaction
    if (card == CardRegistry.microtransaction) {
      debugPrint("  - Applying Microtransaction: +2 Hours");
      newState = newState.copyWith(currentHours: newState.currentHours + 2);
    }

    // Example: Push Notification
    if (card == CardRegistry.pushNotification) {
      debugPrint("  - Applying Push Notification: Draw 1 card");
      newState = _drawCard(newState);
    }

    // TODO: Add other OnPlay effects based on card.onPlay string or a more robust system
    // e.g., Coffee Refactor: Draw 2, discard 1
    // e.g., Code Cleanup: Remove 1 Bug, draw 1

    // Update the state if any changes were made by OnPlay effects
    if (newState != value) {
      value = newState;
    }
  }

  // Returns the state *after* resolving cards
  GameState _handleOnResolve() {
    debugPrint("Handling OnResolve for ${value.sprintBacklog.length} cards.");
    // Start with the current state before resolving anything
    GameState stateBeforeResolve = value;
    GameState stateAfterResolve = stateBeforeResolve;
    int totalUsersGained = 0;

    // TODO: Implement actual OnResolve logic
    // This needs to handle order, adjacency (left/right), multipliers etc.
    // A simple loop won't suffice for complex interactions.
    // Consider creating a list of effects/modifiers first, then applying them.

    final backlog = stateBeforeResolve.sprintBacklog;
    for (int i = 0; i < backlog.length; i++) {
      final card = backlog[i];
      debugPrint("  - Resolving: ${card.name} - ${card.onResolve}");
      int usersFromThisCard = 0;

      // --- Basic Placeholder Logic ---
      if (card == CardRegistry.tweetstorm) {
        int featuresLeft = 0;
        for (int j = 0; j < i; j++) {
          if (backlog[j].type == CardType.feature) {
            featuresLeft++;
          }
        }
        usersFromThisCard = featuresLeft * 2000;
        debugPrint("    Tweetstorm: Found $featuresLeft features left, +$usersFromThisCard users");
      }
      // Add more specific card checks here...
      // Example: Product Hunt Post (Placeholder)
      else if (card == CardRegistry.productHuntPost) {
        int featureCount = backlog.where((c) => c.type == CardType.feature).length;
        // Placeholder: Apply 50% bonus per feature to *current* gain (needs refinement)
        double bonusMultiplier = 1.0 + (featureCount * 0.5);
        // This is tricky - does it boost gains *before* it, or just its own potential?
        // Let's assume it boosts overall gain calculated *so far*.
        // This highlights complexity - effects need proper sequencing.
        debugPrint("    ProductHuntPost: Found $featureCount features. Applying multiplier later (or needs redesign).");
      } else if (card.type == CardType.marketing && card.onResolve.isNotEmpty) {
        // Fallback for generic marketing cards for now
        // usersFromThisCard += 1000; // Example base gain
      }
      // --- End Placeholder ---
      totalUsersGained += usersFromThisCard;
    }

    // Apply gain at the end (simple model)
    if (totalUsersGained > 0) {
      stateAfterResolve = stateBeforeResolve.copyWith(users: stateBeforeResolve.users + totalUsersGained);
      debugPrint("  Total base users gained from OnResolve: $totalUsersGained");
    }
    // TODO: Apply percentage bonuses like Push Notification (+10%) here, after base gain.

    return stateAfterResolve;
  }

  // Returns the state *after* handling unplayed bugs
  GameState _handleUnplayedBugs() {
    debugPrint("Handling unplayed bugs in hand.");
    // Start with the current state (which might include resolved gains)
    GameState stateBeforeBugs = value;
    GameState stateAfterBugs = stateBeforeBugs;
    int userPenalty = 0;
    double percentageMultiplier = 1.0; // Start with no percentage change

    // Iterate backwards to safely remove/modify if needed in the future
    for (int i = stateBeforeBugs.hand.length - 1; i >= 0; i--) {
      final card = stateBeforeBugs.hand[i];
      if (card.type == CardType.bug) {
        debugPrint("  - Unplayed Bug: ${card.name} - Triggering penalty: ${card.onResolve}");

        // --- Implement Bug Penalties ---
        if (card == CardRegistry.crashOnLaunch) {
          userPenalty += 2500;
          debugPrint("    CrashOnLaunch: +2500 user penalty");
        }
        if (card == CardRegistry.buggyCommit) {
          percentageMultiplier *= 0.90; // Apply 10% reduction
          debugPrint("    BuggyCommit: Applying 10% user gain reduction multiplier");
        }
        // TODO: Add other bug penalties
      }
    }

    // Apply penalties to the user count *before* bug handling
    int usersAfterResolve = stateBeforeBugs.users;
    int usersAfterMultiplier = (usersAfterResolve * percentageMultiplier).floor();
    int finalUserCount = max(0, usersAfterMultiplier - userPenalty);

    if (finalUserCount != usersAfterResolve) {
      debugPrint("  Total User Penalty Applied: ${usersAfterResolve - finalUserCount}. Final users: $finalUserCount");
      stateAfterBugs = stateBeforeBugs.copyWith(users: finalUserCount);
    }

    // Return the state after applying bug penalties
    return stateAfterBugs;
  }
}
