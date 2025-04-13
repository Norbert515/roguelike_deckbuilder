import 'package:flutter_test/flutter_test.dart';
import 'package:roguelike_deckbuilder/controllers/game_controller.dart';
import 'package:roguelike_deckbuilder/data/card_registry.dart';
import 'package:roguelike_deckbuilder/models/base_card.dart';
import 'package:roguelike_deckbuilder/models/card_in_play.dart';
import 'package:roguelike_deckbuilder/models/game_state.dart';

void main() {
  group('GameController', () {
    late GameController gameController;

    setUp(() {
      // Initialize a new GameController before each test
      gameController = GameController();
      // Ensure initialization logic runs if needed, although constructor does it.
      // Forcing a notification to ensure state is ready (might not be strictly necessary depending on test structure)
      // gameController.addListener(() {});
    });

    test('Initial state is correct', () {
      final initialState = gameController.value;

      expect(initialState.sprint, 1);
      expect(initialState.users, 0);
      expect(initialState.requiredUsers, 10000); // Initial milestone
      expect(initialState.currentHours, initialState.startingHoursPerSprint);
      expect(initialState.hand.length, 5); // Should draw 5 cards initially
      // Calculate expected deck size: Starter Deck - Initial Hand
      expect(initialState.deck.length, CardRegistry.starterDeckDefinition.length - 5);
      expect(initialState.discardPile, isEmpty);
      expect(initialState.sprintBacklog, isEmpty);
      expect(initialState.removedCards, isEmpty);
    });

    test('playCard moves card from hand to backlog and reduces hours', () {
      final initialHand = List<CardInPlay>.from(gameController.value.hand);
      final initialHours = gameController.value.currentHours;
      final initialBacklogSize = gameController.value.sprintBacklog.length;

      // Find a playable card (assuming enough hours for the first card)
      // Need a card that's not a bug and affordable
      final cardToPlayIndex = initialHand.indexWhere(
        (cip) => cip.cardType.type != CardType.bug && cip.cardType.timeTaken <= initialHours,
      );
      expect(cardToPlayIndex, isNot(-1), reason: "No affordable non-bug card found in initial hand for test.");

      final cardToPlay = initialHand[cardToPlayIndex];
      final cardCost = cardToPlay.cardType.timeTaken;

      gameController.playCard(cardToPlay, cardToPlayIndex);

      final newState = gameController.value;

      // Verify hand changes
      expect(newState.hand.length, initialHand.length - 1);
      expect(newState.hand.contains(cardToPlay), isFalse);

      // Verify backlog changes
      expect(newState.sprintBacklog.length, initialBacklogSize + 1);
      expect(newState.sprintBacklog.last, cardToPlay);

      // Verify hours reduction
      expect(newState.currentHours, initialHours - cardCost);
    });

    test('playCard fails if not enough hours', () {
      final initialHand = List<CardInPlay>.from(gameController.value.hand);
      final initialHours = gameController.value.currentHours;
      final initialBacklog = List<CardInPlay>.from(gameController.value.sprintBacklog);

      // Find an expensive card or manually set hours low
      // For simplicity, let's find the *most* expensive card in hand
      final costs = initialHand.map((cip) => cip.cardType.timeTaken).toList();
      costs.sort();
      final highestCost = costs.last;

      // Find the index of a card with the highest cost
      final cardToPlayIndex = initialHand.indexWhere((cip) => cip.cardType.timeTaken == highestCost);
      expect(cardToPlayIndex, isNot(-1)); // Should always find one
      final cardToPlay = initialHand[cardToPlayIndex];

      // Manually set hours too low
      gameController.value = gameController.value.copyWith(currentHours: highestCost - 1);
      final hoursBeforeAttempt = gameController.value.currentHours;

      gameController.playCard(cardToPlay, cardToPlayIndex);

      final newState = gameController.value;

      // Verify state hasn't changed
      expect(newState.hand.length, initialHand.length);
      expect(newState.hand.contains(cardToPlay), isTrue);
      expect(newState.sprintBacklog.length, initialBacklog.length);
      expect(newState.currentHours, hoursBeforeAttempt); // Hours unchanged
    });

    test('fixBug moves bug from hand to removedCards and reduces hours', () {
      // Find a bug card definition
      final bugCardDef = CardRegistry.allCardTypes.firstWhere(
        (card) => card.id == 'crash_on_launch',
        // orElse: () => null // This shouldn't happen if the card exists
      );
      expect(bugCardDef, isNotNull, reason: "Test requires 'crash_on_launch' card.");
      expect(bugCardDef.type, CardType.bug);

      final bugCardInPlay = CardInPlay(bugCardDef);
      final bugCost = bugCardDef.timeTaken;

      // Manually add the bug to the hand and ensure enough hours
      final initialHand = List<CardInPlay>.from(gameController.value.hand);
      final initialHours =
          gameController.value.currentHours > bugCost
              ? gameController.value.currentHours
              : bugCost + 1; // Ensure enough hours
      final initialRemovedCount = gameController.value.removedCards.length;

      gameController.value = gameController.value.copyWith(
        hand: [...initialHand, bugCardInPlay],
        currentHours: initialHours,
      );

      // Find the index of the added bug
      final bugIndex = gameController.value.hand.indexWhere((cip) => cip.instanceId == bugCardInPlay.instanceId);
      expect(bugIndex, isNot(-1));

      gameController.fixBug(bugCardInPlay, bugIndex);

      final newState = gameController.value;

      // Verify hand changes
      expect(newState.hand.length, initialHand.length); // Original hand size (bug removed)
      expect(newState.hand.contains(bugCardInPlay), isFalse);

      // Verify removedCards changes
      expect(newState.removedCards.length, initialRemovedCount + 1);
      expect(newState.removedCards.last, bugCardInPlay);

      // Verify hours reduction
      expect(newState.currentHours, initialHours - bugCost);
    });

    test('fixBug fails for non-bug cards', () {
      final initialHand = List<CardInPlay>.from(gameController.value.hand);
      final initialHours = gameController.value.currentHours;
      final initialRemoved = List<CardInPlay>.from(gameController.value.removedCards);

      // Find a non-bug card
      final nonBugIndex = initialHand.indexWhere((cip) => cip.cardType.type != CardType.bug);
      expect(nonBugIndex, isNot(-1), reason: "Hand needs at least one non-bug card for test.");
      final nonBugCard = initialHand[nonBugIndex];

      // Attempt to fix it
      gameController.fixBug(nonBugCard, nonBugIndex);

      final newState = gameController.value;

      // Verify state hasn't changed
      expect(newState.hand.length, initialHand.length);
      expect(newState.hand.contains(nonBugCard), isTrue);
      expect(newState.removedCards.length, initialRemoved.length);
      expect(newState.currentHours, initialHours);
    });

    test('fixBug fails if not enough hours', () {
      // Find a bug card definition
      final bugCardDef = CardRegistry.allCardTypes.firstWhere((card) => card.id == 'crash_on_launch');
      expect(bugCardDef, isNotNull);
      final bugCardInPlay = CardInPlay(bugCardDef);
      final bugCost = bugCardDef.timeTaken;

      // Manually add the bug and set hours too low
      final initialHand = List<CardInPlay>.from(gameController.value.hand);
      final initialRemoved = List<CardInPlay>.from(gameController.value.removedCards);
      gameController.value = gameController.value.copyWith(
        hand: [...initialHand, bugCardInPlay],
        currentHours: bugCost - 1, // Not enough hours
      );
      final hoursBeforeAttempt = gameController.value.currentHours;
      final handBeforeAttempt = List<CardInPlay>.from(gameController.value.hand);
      final bugIndex = gameController.value.hand.length - 1; // It's the last one we added

      // Attempt to fix
      gameController.fixBug(bugCardInPlay, bugIndex);

      final newState = gameController.value;

      // Verify state hasn't changed
      expect(newState.hand, handBeforeAttempt);
      expect(newState.removedCards, initialRemoved);
      expect(newState.currentHours, hoursBeforeAttempt);
    });

    test('release moves sprint forward, resets hours, discards backlog, draws cards', () {
      // 1. Setup: Play a card to the backlog
      final initialHand = List<CardInPlay>.from(gameController.value.hand);
      final initialHours = gameController.value.currentHours;
      final cardToPlayIndex = initialHand.indexWhere(
        (cip) => cip.cardType.type == CardType.feature && cip.cardType.timeTaken <= initialHours,
      );
      expect(cardToPlayIndex, isNot(-1), reason: "Need a playable feature card in hand");
      final cardPlayed = initialHand[cardToPlayIndex];
      gameController.playCard(cardPlayed, cardToPlayIndex);

      final stateBeforeRelease = gameController.value;
      expect(stateBeforeRelease.sprintBacklog, contains(cardPlayed));
      expect(stateBeforeRelease.discardPile, isEmpty);

      // 2. Action: Release
      gameController.release();

      // 3. Verification
      final newState = gameController.value;

      // Sprint advanced
      expect(newState.sprint, stateBeforeRelease.sprint + 1);
      // Hours reset
      expect(newState.currentHours, newState.startingHoursPerSprint);
      // Backlog cleared
      expect(newState.sprintBacklog, isEmpty);
      // Played card discarded (assuming it wasn't a bug)
      expect(newState.discardPile, contains(cardPlayed));
      // Hand refilled
      expect(newState.hand.length, 5); // Assuming default hand size
      // Deck size reduced accordingly (initial deck - 5 initial draw + 1 drawn after release)
      // This calculation depends on whether deck needed reshuffling
      // Simpler check: total cards in deck + hand + discard + backlog + removed should be constant
      final initialTotalCards = CardRegistry.starterDeckDefinition.length;
      final finalTotalCards =
          newState.deck.length +
          newState.hand.length +
          newState.discardPile.length +
          newState.sprintBacklog.length + // Should be 0
          newState.removedCards.length;
      expect(finalTotalCards, initialTotalCards);
    });

    test('release applies OnResolve effects (e.g., UnreadPrivacyPolicyCard)', () {
      // 1. Setup: Manually place UnreadPrivacyPolicyCard into backlog
      final policyCardDef = CardRegistry.allCardTypes.firstWhere((card) => card.id == 'unread_privacy_policy');
      expect(policyCardDef, isNotNull);
      final policyCardInPlay = CardInPlay(policyCardDef);

      final initialUsers = gameController.value.users;
      gameController.value = gameController.value.copyWith(
        sprintBacklog: [policyCardInPlay],
        // Ensure hand is empty so drawing doesn't complicate deck check later
        hand: [],
        deck: List<CardInPlay>.from(
          CardRegistry.starterDeckDefinition.map((def) => CardInPlay(def)),
        ), // Wrap BaseCard in CardInPlay
      );

      // 2. Action: Release
      gameController.release();

      // 3. Verification
      final newState = gameController.value;

      // Verify user gain
      expect(newState.users, initialUsers + 100, reason: "UnreadPrivacyPolicyCard should grant 100 users on resolve.");

      // Verify card was discarded
      expect(newState.discardPile, contains(policyCardInPlay));
      expect(newState.sprintBacklog, isEmpty);
      // Hand refilled
      expect(newState.hand.length, 5);
    });

    test('release applies OnResolve effects considering order (Tweetstorm)', () {
      // 1. Setup: Place Feature then Tweetstorm
      final featureCardDef = CardRegistry.allCardTypes.firstWhere((c) => c.type == CardType.feature);
      final tweetstormCardDef = CardRegistry.allCardTypes.firstWhere((c) => c.id == 'tweetstorm');
      expect(featureCardDef, isNotNull);
      expect(tweetstormCardDef, isNotNull);

      final featureCardInPlay = CardInPlay(featureCardDef);
      final tweetstormCardInPlay = CardInPlay(tweetstormCardDef);

      final initialUsers = gameController.value.users;
      gameController.value = gameController.value.copyWith(
        sprintBacklog: [featureCardInPlay, tweetstormCardInPlay], // Feature is to the left
        hand: [],
        deck: List<CardInPlay>.from(
          CardRegistry.starterDeckDefinition.map((def) => CardInPlay(def)),
        ), // Wrap BaseCard in CardInPlay
      );

      // 2. Action: Release
      gameController.release();

      // 3. Verification
      final newState = gameController.value;

      // Tweetstorm gains 2000 users for each Feature to its left
      expect(
        newState.users,
        initialUsers + 2000,
        reason: "Tweetstorm should grant 2000 users for the feature to its left.",
      );

      // Verify cards discarded
      expect(newState.discardPile, contains(featureCardInPlay));
      expect(newState.discardPile, contains(tweetstormCardInPlay));
      expect(newState.sprintBacklog, isEmpty);
      expect(newState.hand.length, 5);
    });

    test('release applies penalties for unplayed bugs in hand (CrashOnLaunch)', () {
      // 1. Setup: Manually add bug to hand, give some users to lose
      final bugCardDef = CardRegistry.allCardTypes.firstWhere((c) => c.id == 'crash_on_launch');
      expect(bugCardDef, isNotNull);
      final bugCardInPlay = CardInPlay(bugCardDef);
      final initialUsers = 5000;

      // Ensure hand has the bug and other cards to make 5 after draw
      // To isolate the bug effect, start with only the bug in hand before release.
      // The release process will draw 5 new cards.
      gameController.value = gameController.value.copyWith(
        users: initialUsers,
        hand: [bugCardInPlay], // Only the bug initially
        sprintBacklog: [], // No played cards this time
        // Ensure deck has enough cards to draw 5
        deck: List<CardInPlay>.from(
          CardRegistry.starterDeckDefinition.where((c) => c.id != bugCardDef.id).map((def) => CardInPlay(def)),
        ), // Wrap BaseCard in CardInPlay
        discardPile: [],
      );
      // Make sure deck + hand = starter deck size initially for card count check
      // Adjusting check because we manually removed one card type (the bug)
      expect(
        gameController.value.deck.length + gameController.value.hand.length,
        CardRegistry.starterDeckDefinition.length,
      );

      // 2. Action: Release
      gameController.release();

      // 3. Verification
      final newState = gameController.value;

      // Verify user penalty
      expect(newState.users, initialUsers - 2500, reason: "CrashOnLaunch penalty should be applied.");

      // Verify bug is *still* in hand (or discarded/reshuffled depending on exact logic, typically stays)
      // The current implementation leaves unplayed bugs in hand for the *next* turn.
      // After release, the hand is redrawn. The original bug should be in the discard pile now if hand was discarded implicitly (which it shouldn't be based on logic)
      // Let's re-read release(): it *doesn't* discard the hand.
      // It handles bugs in hand, discards backlog, advances sprint, resets hours, draws *until* 5.
      // So the bug *should* remain in the hand drawn for the next sprint.
      // But wait, _handleUnplayedBugs modifies state, THEN the draw happens.
      // The draw refills the hand. Does the original hand persist?
      // Let's trace: release() calls _handleUnplayedBugs(value) -> returns stateAfterBugs.
      // Then value = stateAfterBugs. Then stateForNextSprint = value.copyWith(... discardPile: newDiscard, sprintBacklog: []).
      // Then stateForNextSprint = _drawUntil(stateForNextSprint, 5).
      // So the hand *is* replaced by the draw. The bug card should end up in the discard pile if we follow the logic through.
      // BUT the _handleUnplayedBugs iterates the hand *before* drawing.
      // The code *doesn't* discard the hand contents before drawing.
      // _drawUntil adds cards to the existing hand.
      // Let's test the assumption: the bug stays in hand if hand < 5 after penalty.
      // RETHINK: _drawUntil *replaces* the hand effectively based on the state passed to it. Let's assume the bug is discarded.
      // The most logical place for the hand from the *previous* turn is the discard pile.
      // Let's refine the GameController logic description if needed, but test the expected outcome: penalty applied, hand refilled.

      // Check that the bug is NOT in the new hand (unless drawn again)
      // It's hard to guarantee it wasn't redrawn without controlling the deck.
      // Simpler check: verify the penalty occurred and the hand size is correct.
      expect(newState.hand.length, 5);
      expect(newState.sprintBacklog, isEmpty);
      expect(newState.sprint, 2);
    });

    test('release applies percentage penalty for unplayed bugs (BuggyCommit)', () {
      // 1. Setup: Add BuggyCommit to hand, resolve a card that gains users
      final bugCardDef = CardRegistry.allCardTypes.firstWhere((c) => c.id == 'buggy_commit');
      final featureCardDef = CardRegistry.allCardTypes.firstWhere(
        (c) => c.id == 'unread_privacy_policy',
      ); // Gains 100 users
      expect(bugCardDef, isNotNull);
      expect(featureCardDef, isNotNull);

      final bugCardInPlay = CardInPlay(bugCardDef);
      final featureCardInPlay = CardInPlay(featureCardDef);
      final initialUsers = 1000;

      gameController.value = gameController.value.copyWith(
        users: initialUsers,
        hand: [bugCardInPlay], // Only the bug in hand initially
        sprintBacklog: [featureCardInPlay], // This will resolve first
        deck: List<CardInPlay>.from(
          CardRegistry.starterDeckDefinition
              .where((c) => c.id != bugCardDef.id && c.id != featureCardDef.id)
              .map((def) => CardInPlay(def)), // Wrap BaseCard in CardInPlay
        ),
        discardPile: [],
      );
      // Adjusting check because we manually removed two card types
      expect(
        gameController.value.deck.length + gameController.value.hand.length + gameController.value.sprintBacklog.length,
        CardRegistry.starterDeckDefinition.length,
      );

      // 2. Action: Release
      gameController.release();

      // 3. Verification
      final newState = gameController.value;

      // Expected users: (initial + gained_from_feature) * 0.9 (due to bug)
      final expectedUsers = ((initialUsers + 100) * 0.9).floor();
      expect(newState.users, expectedUsers, reason: "BuggyCommit should reduce total user gain by 10%.");

      // Verify other state changes
      expect(newState.hand.length, 5);
      expect(newState.sprintBacklog, isEmpty);
      expect(newState.discardPile, contains(featureCardInPlay));
      // expect(newState.discardPile, contains(bugCardInPlay)); // Bug should remain in hand? See previous test comment.
      expect(newState.sprint, 2);
    });

    test('release triggers game over if milestone not met', () {
      // 1. Setup: Set sprint to 10, users below required (10000)
      final requiredUsersForSprint10 = 10000;
      gameController.value = gameController.value.copyWith(
        sprint: 10,
        users: requiredUsersForSprint10 - 1, // Fail the milestone
        requiredUsers: requiredUsersForSprint10,
        sprintBacklog: [], // No cards played
        hand: [], // Empty hand to simplify state
        deck: List<CardInPlay>.from(
          CardRegistry.starterDeckDefinition.map((def) => CardInPlay(def)),
        ), // Wrap BaseCard in CardInPlay
        discardPile: [],
      );

      final stateBeforeRelease = gameController.value;

      // 2. Action: Release (attempts to end sprint 10)
      gameController.release();

      // 3. Verification: Game should not proceed
      final newState = gameController.value;

      // Check that the state *did not* advance to sprint 11
      // because the milestone check failed.
      expect(newState.sprint, stateBeforeRelease.sprint, reason: "Sprint should not advance after failing milestone.");
      expect(newState.users, stateBeforeRelease.users); // Users unchanged
      expect(newState.currentHours, stateBeforeRelease.currentHours); // Hours unchanged
      // TODO: Add a specific isGameOver flag to GameState and check it here
      // For now, we check that the sprint didn't advance.
    });

    test('release proceeds normally if milestone is met', () {
      // 1. Setup: Set sprint to 10, users meet required (10000)
      final requiredUsersForSprint10 = 10000;
      final nextMilestone = 100000; // Milestone for sprint 20
      gameController.value = gameController.value.copyWith(
        sprint: 10,
        users: requiredUsersForSprint10, // Meet the milestone
        requiredUsers: requiredUsersForSprint10,
        sprintBacklog: [],
        hand: [],
        deck: List<CardInPlay>.from(
          CardRegistry.starterDeckDefinition.map((def) => CardInPlay(def)),
        ), // Wrap BaseCard in CardInPlay
        discardPile: [],
      );

      // 2. Action: Release (ends sprint 10 successfully)
      gameController.release();

      // 3. Verification: Game proceeds to sprint 11
      final newState = gameController.value;

      expect(newState.sprint, 11, reason: "Sprint should advance after meeting milestone.");
      expect(newState.users, requiredUsersForSprint10); // Users remain the same (no cards resolved)
      expect(
        newState.requiredUsers,
        nextMilestone,
        reason: "Required users should update for the next milestone block.",
      );
      expect(newState.currentHours, newState.startingHoursPerSprint); // Hours reset
      expect(newState.hand.length, 5); // Hand refilled
    });

    test('release correctly reshuffles discard pile into deck when drawing', () {
      // 1. Setup: Empty the deck, put cards in discard, leave hand empty
      final cardsToDiscard = List<CardInPlay>.from(CardRegistry.starterDeckDefinition.map((def) => CardInPlay(def)));
      expect(cardsToDiscard.length, greaterThan(5), reason: "Need more than hand size cards for this test");
      final cardFromDiscard = cardsToDiscard.first; // Remember one card

      gameController.value = gameController.value.copyWith(
        deck: [], // Empty deck
        discardPile: cardsToDiscard,
        hand: [], // Empty hand before release
        sprintBacklog: [],
        users: 0, // Reset other state for clarity
        sprint: 1,
        currentHours: 3,
      );

      final stateBeforeRelease = gameController.value;

      // 2. Action: Release (this will trigger draw from empty deck)
      gameController.release();

      // 3. Verification
      final newState = gameController.value;

      // Sprint advanced, hours reset
      expect(newState.sprint, stateBeforeRelease.sprint + 1);
      expect(newState.currentHours, newState.startingHoursPerSprint);

      // Deck should now contain the shuffled discard pile, minus the 5 drawn cards
      expect(newState.deck.length, cardsToDiscard.length - 5);
      // Discard pile should be empty
      expect(newState.discardPile, isEmpty);
      // Hand should have 5 cards
      expect(newState.hand.length, 5);
      // Check if a known card from the original discard pile is now in hand or deck
      final cardIsInHand = newState.hand.any((cip) => cip.instanceId == cardFromDiscard.instanceId);
      final cardIsInDeck = newState.deck.any((cip) => cip.instanceId == cardFromDiscard.instanceId);
      expect(cardIsInHand || cardIsInDeck, isTrue, reason: "Card from original discard should be in new hand or deck.");
    });

    test('playCard triggers OnPlay effect (MicrotransactionCard)', () {
      // 1. Setup: Manually place MicrotransactionCard in hand
      final microCardDef = CardRegistry.allCardTypes.firstWhere((c) => c.id == 'microtransaction');
      expect(microCardDef, isNotNull);
      final microCardInPlay = CardInPlay(microCardDef);
      final cardCost = microCardDef.timeTaken; // Should be 1
      final initialHours = 3;

      gameController.value = gameController.value.copyWith(
        hand: [microCardInPlay], // Only this card in hand
        currentHours: initialHours,
        deck: List<CardInPlay>.from(
          CardRegistry.starterDeckDefinition.where((c) => c.id != microCardDef.id).map((def) => CardInPlay(def)),
        ), // Wrap BaseCard in CardInPlay
        discardPile: [],
        sprintBacklog: [],
      );
      final handBeforePlay = List.from(gameController.value.hand);

      // 2. Action: Play the card
      gameController.playCard(microCardInPlay, 0); // It's the only card

      // 3. Verification
      final newState = gameController.value;

      // Hours = initial - cost + bonus
      expect(
        newState.currentHours,
        initialHours - cardCost + 2,
        reason: "Microtransaction should add 2 hours after cost.",
      );
      expect(newState.hand.length, handBeforePlay.length - 1); // Card removed from hand
      expect(newState.sprintBacklog, contains(microCardInPlay)); // Card added to backlog
    });

    test('playCard triggers OnPlay effect (PushNotificationCard)', () {
      // 1. Setup: Manually place PushNotificationCard in hand, ensure deck has cards
      final pushCardDef = CardRegistry.allCardTypes.firstWhere((c) => c.id == 'push_notification');
      expect(pushCardDef, isNotNull);
      final pushCardInPlay = CardInPlay(pushCardDef);
      final cardCost = pushCardDef.timeTaken; // Should be 2

      // Ensure deck has at least one card to draw
      final deckCards = List<CardInPlay>.from(
        CardRegistry.starterDeckDefinition.where((c) => c.id != pushCardDef.id).map((def) => CardInPlay(def)),
      );
      expect(deckCards.length, greaterThan(0), reason: "Deck needs cards to draw");

      gameController.value = gameController.value.copyWith(
        hand: [pushCardInPlay], // Only this card
        currentHours: 3, // Enough to play
        deck: deckCards,
        discardPile: [],
        sprintBacklog: [],
      );
      final handBeforePlay = List.from(gameController.value.hand);
      final deckBeforePlay = List.from(gameController.value.deck);

      // 2. Action: Play the card
      gameController.playCard(pushCardInPlay, 0);

      // 3. Verification
      final newState = gameController.value;

      // Hours reduced by cost
      expect(newState.currentHours, 3 - cardCost);
      // Hand size unchanged (1 played, 1 drawn)
      expect(newState.hand.length, handBeforePlay.length);
      // Deck size reduced by 1
      expect(newState.deck.length, deckBeforePlay.length - 1);
      // Card added to backlog
      expect(newState.sprintBacklog, contains(pushCardInPlay));
      // The played card itself should not be in the final hand
      expect(newState.hand.contains(pushCardInPlay), isFalse);
    });
  });
}
