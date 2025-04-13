import 'package:roguelike_deckbuilder/models/base_card.dart';

class CardRegistry {
  // --- Version 0.1 Starter Cards ---
  // Card definitions are now separate classes extending BaseCard,
  // consolidated in lib/models/all_cards.dart (part of base_card.dart library)

  // Note: Original GameCard constants are removed.
  // The _placeholderAsset is now handled within each card class as needed.

  // --- List of All Card Definitions ---
  // This list holds instances of the *card type* classes.
  // These are blueprints, not specific instances in play.
  static final List<BaseCard> allCardTypes = List.unmodifiable([
    AddAButtonCard(),
    PullToRefreshCard(),
    DarkModeCard(),
    TweetstormCard(),
    PushNotificationCard(),
    ProductHuntPostCard(),
    CrashOnLaunchCard(),
    BuggyCommitCard(),
    CodeCleanupCard(),
    CoffeeRefactorCard(),
    MicrotransactionCard(),
    UnreadPrivacyPolicyCard(),
  ]);

  // --- Starter Deck Definition ---
  // Based on game.md, the starter deck contains one instance of each defined card type.
  // When the game starts, these BaseCard definitions will be used to create
  // CardInPlay instances for the actual deck.
  static final List<BaseCard> starterDeckDefinition = List.unmodifiable([
    AddAButtonCard(),
    PullToRefreshCard(),
    DarkModeCard(),
    TweetstormCard(),
    PushNotificationCard(),
    ProductHuntPostCard(),
    CrashOnLaunchCard(),
    BuggyCommitCard(),
    CodeCleanupCard(),
    CoffeeRefactorCard(),
    MicrotransactionCard(),
    UnreadPrivacyPolicyCard(),
  ]);

  // TODO: Add definitions for all other cards mentioned in game.md
  //       by creating new classes extending BaseCard in all_cards.dart
  // TODO: Ensure placeholder.png asset exists or update paths in card classes.
}
