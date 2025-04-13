import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:roguelike_deckbuilder/data/card_registry.dart';
import 'package:roguelike_deckbuilder/models/base_card.dart'; // Import BaseCard for CardType and definitions
import 'package:roguelike_deckbuilder/models/card_in_play.dart'; // Import CardInPlay

// Removed old import: import '../models/card.dart';
import '../models/game_state.dart';

// No longer need the placeholder deck here

class GameController extends ValueNotifier<GameState> {
  final Random _random = Random();

  GameController() : super(GameState.initial()) {
    _initializeGame();
  }

  void _initializeGame() {
    // Use the starter deck definition from the registry and map to CardInPlay
    final initialDeck =
        CardRegistry.starterDeckDefinition
            .map((cardDef) => CardInPlay(cardDef)) // Create CardInPlay instances
            .toList();
    _shuffleDeck(initialDeck); // Shuffle the CardInPlay list

    // Initialize state with the prepared deck
    GameState initialState = GameState.initial().copyWith(deck: initialDeck);
    // Draw initial hand using the refactored method
    initialState = _drawUntil(initialState, 5);
    value = initialState;
  }

  // --- Core Actions ---

  /// Plays a regular card (Feature, Marketing, Utility) from hand.
  void playCard(CardInPlay cardInPlay, int handIndex) {
    final cardDefinition = cardInPlay.cardType;

    if (value.currentHours < cardDefinition.timeTaken) {
      debugPrint("Not enough hours to play ${cardDefinition.name}");
      return; // Cannot afford card
    }

    final newHand = List<CardInPlay>.from(value.hand);
    newHand.removeAt(handIndex);

    final newSprintBacklog = List<CardInPlay>.from(value.sprintBacklog);
    newSprintBacklog.add(cardInPlay); // Add the CardInPlay instance

    // Store the current state before handling OnPlay effects
    final stateBeforeOnPlay = value.copyWith(
      // timeTaken is already an int in BaseCard
      currentHours: value.currentHours - cardDefinition.timeTaken,
      hand: newHand,
      sprintBacklog: newSprintBacklog,
    );

    // Update the state *before* calling _handleOnPlay
    value = stateBeforeOnPlay;

    // Trigger immediate effects which might further modify the state
    _handleOnPlay(cardInPlay); // Pass the CardInPlay instance
  }

  /// Fixes a Bug card from hand.
  void fixBug(CardInPlay bugCardInPlay, int handIndex) {
    final cardDefinition = bugCardInPlay.cardType;

    if (cardDefinition.type != CardType.bug) {
      debugPrint("Tried to fix a non-bug card: ${cardDefinition.name}");
      return;
    }
    if (value.currentHours < cardDefinition.timeTaken) {
      debugPrint("Not enough hours to fix ${cardDefinition.name}");
      return; // Cannot afford to fix
    }

    final newHand = List<CardInPlay>.from(value.hand);
    newHand.removeAt(handIndex);

    final newRemovedCards = List<CardInPlay>.from(value.removedCards);
    newRemovedCards.add(bugCardInPlay); // Add the CardInPlay instance

    value = value.copyWith(
      // timeTaken is already an int in BaseCard
      currentHours: value.currentHours - cardDefinition.timeTaken,
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
    final List<CardInPlay> cardsToDiscard = [];
    // Use the most recent state (value) which includes resolved/bug effects
    final List<CardInPlay> currentBacklog = List.from(value.sprintBacklog);
    for (final cardInPlay in currentBacklog) {
      // Access type via cardType
      if (cardInPlay.cardType.type != CardType.bug) {
        cardsToDiscard.add(cardInPlay);
      }
    }
    final newDiscard = List<CardInPlay>.from(value.discardPile)..addAll(cardsToDiscard);

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
    List<CardInPlay> currentDeck = List.from(currentState.deck);
    List<CardInPlay> currentDiscard = List.from(currentState.discardPile);
    List<CardInPlay> currentHand = List.from(currentState.hand);

    if (currentDeck.isEmpty) {
      if (currentDiscard.isEmpty) {
        debugPrint("Cannot draw card: Deck and discard pile are empty.");
        return currentState; // No cards left anywhere
      }
      debugPrint("Deck empty, shuffling discard pile.");
      _shuffleDeck(currentDiscard); // Pass CardInPlay list
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

  // Update to accept List<CardInPlay>
  void _shuffleDeck(List<CardInPlay> deck) {
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

  // Update to accept CardInPlay
  void _handleOnPlay(CardInPlay cardInPlay) {
    final cardDefinition = cardInPlay.cardType;
    debugPrint("Handling OnPlay for: ${cardDefinition.name} - ${cardDefinition.onPlayText}");

    // Option 1: Use the abstract method directly (requires GameContext)
    // final gameContext = GameContext(); // TODO: Create actual game context
    // cardDefinition.onPlay(gameContext);
    // value = gameContext.currentState; // Assuming context holds and modifies state

    // Option 2: Check type and implement logic here (as before)
    GameState newState = value; // Start with the current state

    // Use 'is' check for sealed class subtypes
    if (cardDefinition is MicrotransactionCard) {
      debugPrint("  - Applying Microtransaction: +2 Hours");
      newState = newState.copyWith(currentHours: newState.currentHours + 2);
    } else if (cardDefinition is PushNotificationCard) {
      debugPrint("  - Applying Push Notification: Draw 1 card");
      newState = _drawCard(newState);
    }
    // TODO: Add other OnPlay effects using 'is' checks or the abstract method approach
    // else if (cardDefinition is CoffeeRefactorCard) { ... }
    // else if (cardDefinition is CodeCleanupCard) { ... }

    // Update the state if any changes were made by OnPlay effects
    if (newState != value) {
      value = newState;
    }
  }

  // Returns the state *after* resolving cards
  GameState _handleOnResolve() {
    debugPrint("Handling OnResolve for ${value.sprintBacklog.length} cards.");
    GameState stateBeforeResolve = value;
    GameState stateAfterResolve = stateBeforeResolve;
    int totalUsersGained = 0;

    final backlog = stateBeforeResolve.sprintBacklog;
    for (int i = 0; i < backlog.length; i++) {
      final cardInPlay = backlog[i];
      final cardDefinition = cardInPlay.cardType;
      debugPrint("  - Resolving: ${cardDefinition.name} - ${cardDefinition.onResolveText}");
      int usersFromThisCard = 0;

      // --- Logic based on card type ---
      // Use 'is' checks for sealed class subtypes
      if (cardDefinition is TweetstormCard) {
        int featuresLeft = 0;
        for (int j = 0; j < i; j++) {
          // Check type of card definition in backlog
          if (backlog[j].cardType.type == CardType.feature) {
            featuresLeft++;
          }
        }
        usersFromThisCard = featuresLeft * 2000;
        debugPrint("    Tweetstorm: Found $featuresLeft features left, +$usersFromThisCard users");
      }
      // Add more specific card checks here...
      else if (cardDefinition is ProductHuntPostCard) {
        // Check type of card definition in backlog
        int featureCount = backlog.where((c) => c.cardType.type == CardType.feature).length;
        debugPrint("    ProductHuntPost: Found $featureCount features. Applying multiplier later (or needs redesign).");
        // TODO: Implement multiplier logic correctly
      } else if (cardDefinition is UnreadPrivacyPolicyCard) {
        usersFromThisCard = 100; // Gain 100 users
        debugPrint("    UnreadPrivacyPolicy: +$usersFromThisCard users");
      }
      // Add more OnResolve checks here...
      // --- End Logic ---

      totalUsersGained += usersFromThisCard;
    }

    // Apply gain at the end (simple model)
    if (totalUsersGained > 0) {
      // Apply to the state *before* resolve started
      stateAfterResolve = stateBeforeResolve.copyWith(users: stateBeforeResolve.users + totalUsersGained);
      debugPrint("  Total base users gained from OnResolve: $totalUsersGained");
    }
    // TODO: Apply percentage bonuses like Push Notification (+10%) here, after base gain.
    // Need to track which cards provide bonuses.

    return stateAfterResolve;
  }

  // Returns the state *after* handling unplayed bugs
  GameState _handleUnplayedBugs() {
    debugPrint("Handling unplayed bugs in hand.");
    GameState stateBeforeBugs = value; // Start with potentially resolved state
    GameState stateAfterBugs = stateBeforeBugs;
    int userPenalty = 0;
    double percentageMultiplier = 1.0;

    for (int i = stateBeforeBugs.hand.length - 1; i >= 0; i--) {
      final cardInPlay = stateBeforeBugs.hand[i];
      final cardDefinition = cardInPlay.cardType;

      // Check type of card definition
      if (cardDefinition.type == CardType.bug) {
        debugPrint("  - Unplayed Bug: ${cardDefinition.name} - Triggering penalty: ${cardDefinition.onResolveText}");

        // --- Implement Bug Penalties ---
        // Use 'is' checks for sealed class subtypes
        if (cardDefinition is CrashOnLaunchCard) {
          userPenalty += 2500;
          debugPrint("    CrashOnLaunch: +2500 user penalty");
        } else if (cardDefinition is BuggyCommitCard) {
          percentageMultiplier *= 0.90;
          debugPrint("    BuggyCommit: Applying 10% user gain reduction multiplier");
        }
        // TODO: Add other bug penalties
      }
    }

    // Apply penalties
    int usersBeforePenalty = stateBeforeBugs.users;
    int usersAfterMultiplier = (usersBeforePenalty * percentageMultiplier).floor();
    int finalUserCount = max(0, usersAfterMultiplier - userPenalty);

    if (finalUserCount != usersBeforePenalty) {
      debugPrint("  Total User Penalty Applied: ${usersBeforePenalty - finalUserCount}. Final users: $finalUserCount");
      stateAfterBugs = stateBeforeBugs.copyWith(users: finalUserCount);
    }

    return stateAfterBugs;
  }
}
