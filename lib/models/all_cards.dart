part of 'base_card.dart';

// Shared constant for placeholder asset
const String _placeholderAsset = 'assets/cards/placeholder.png';

// --- Card Implementations ---

class AddAButtonCard extends BaseCard {
  @override
  String get id => 'add_a_button';

  @override
  String get name => 'Add a Button';

  @override
  CardType get type => CardType.feature;

  @override
  int get timeTaken => 1;

  @override
  String get onPlayText => ''; // No immediate effect on play

  @override
  String get onResolveText => ''; // Assuming no resolve effect based on original

  @override
  String get flavorText => 'It doesn\'t do much, but it *does* glow.';

  @override
  String get assetPath => _placeholderAsset;

  @override
  void onPlay(GameContext context) {
    // No specific onPlay logic defined in original data
    print('Playing Add a Button.');
  }

  @override
  void onResolve(GameContext context) {
    // No specific onResolve logic defined in original data
    print('Resolving Add a Button.');
  }
}

class PullToRefreshCard extends BaseCard {
  @override
  String get id => 'pull_to_refresh';

  @override
  String get name => 'Pull to Refresh';

  @override
  CardType get type => CardType.feature;

  @override
  int get timeTaken => 1;

  @override
  String get onPlayText => ''; // No immediate effect on play

  @override
  String get onResolveText => ''; // Assuming no resolve effect based on original

  @override
  String get flavorText => 'Because scrolling down is for peasants.';

  @override
  String get assetPath => _placeholderAsset;

  @override
  void onPlay(GameContext context) {
    // No specific onPlay logic defined in original data
    print('Playing Pull to Refresh.');
  }

  @override
  void onResolve(GameContext context) {
    // No specific onResolve logic defined in original data
    print('Resolving Pull to Refresh.');
  }
}

class DarkModeCard extends BaseCard {
  @override
  String get id => 'dark_mode';

  @override
  String get name => 'Dark Mode';

  @override
  CardType get type => CardType.feature;

  @override
  int get timeTaken => 2;

  @override
  String get onPlayText => ''; // No immediate effect on play

  @override
  String get onResolveText => ''; // Assuming no resolve effect based on original

  @override
  String get flavorText => 'Now your app is 38% more modern.';

  @override
  // Assuming asset path is correct based on original data
  String get assetPath => 'assets/cards/Dark_Mode.png';

  @override
  void onPlay(GameContext context) {
    // No specific onPlay logic defined in original data
    print('Playing Dark Mode.');
  }

  @override
  void onResolve(GameContext context) {
    // No specific onResolve logic defined in original data
    print('Resolving Dark Mode.');
  }
}

class TweetstormCard extends BaseCard {
  @override
  String get id => 'tweetstorm';

  @override
  String get name => 'Tweetstorm';

  @override
  CardType get type => CardType.marketing;

  @override
  int get timeTaken => 2;

  @override
  String get onPlayText => ''; // No immediate effect on play

  @override
  String get onResolveText => 'Gain 2,000 users for each Feature to the left';

  @override
  String get flavorText => 'Just 14 tweets deep and you\'re trending.';

  @override
  String get assetPath => _placeholderAsset;

  @override
  void onPlay(GameContext context) {
    // No specific onPlay logic defined in original data
    print('Playing Tweetstorm.');
  }

  @override
  void onResolve(GameContext context) {
    // TODO: Implement game logic:
    // 1. Identify features to the left of this card in the build area.
    // 2. Count them.
    // 3. Add 2000 users * count to the game state.
    print('Resolving Tweetstorm: $onResolveText');
  }
}

class PushNotificationCard extends BaseCard {
  @override
  String get id => 'push_notification';

  @override
  String get name => 'Push Notification';

  @override
  CardType get type => CardType.marketing;

  @override
  int get timeTaken => 2;

  @override
  String get onPlayText => 'Draw 1 card';

  @override
  String get onResolveText => '+10% bonus user gain';

  @override
  String get flavorText => 'Ping! You again.';

  @override
  String get assetPath => _placeholderAsset;

  @override
  void onPlay(GameContext context) {
    // TODO: Implement game logic:
    // 1. Draw 1 card from the player's deck.
    print('Playing Push Notification: $onPlayText');
  }

  @override
  void onResolve(GameContext context) {
    // TODO: Implement game logic:
    // 1. Apply a modifier to the game state that increases user gain for this turn/resolution phase by 10%.
    print('Resolving Push Notification: $onResolveText');
  }
}

class ProductHuntPostCard extends BaseCard {
  @override
  String get id => 'product_hunt_post';

  @override
  String get name => 'Product Hunt Post';

  @override
  CardType get type => CardType.marketing;

  @override
  int get timeTaken => 3;

  @override
  String get onPlayText => ''; // No immediate effect on play

  @override
  String get onResolveText => '+50% user gain for every Feature in your build';

  @override
  String get flavorText => 'Launched at midnight. Voted by mom.';

  @override
  String get assetPath => _placeholderAsset;

  @override
  void onPlay(GameContext context) {
    // No specific onPlay logic defined in original data
    print('Playing Product Hunt Post.');
  }

  @override
  void onResolve(GameContext context) {
    // TODO: Implement game logic:
    // 1. Count the number of cards with type CardType.feature in the player's build area.
    // 2. Apply a modifier to user gain: gain = gain * (1 + 0.5 * count).
    print('Resolving Product Hunt Post: $onResolveText');
  }
}

class CrashOnLaunchCard extends BaseCard {
  @override
  String get id => 'crash_on_launch';

  @override
  String get name => 'Crash on Launch';

  @override
  CardType get type => CardType.bug;

  @override
  int get timeTaken => 1;

  @override
  String get onPlayText => ''; // Bugs usually don't have voluntary OnPlay

  @override
  String get onResolveText => '−2,500 users'; // Penalty if not dealt with (played/removed)

  @override
  String get flavorText => 'At least the splash screen looked nice.';

  @override
  String get assetPath => _placeholderAsset;

  @override
  void onPlay(GameContext context) {
    // Typically, playing a bug might just remove it from hand or have
    // a different minor effect if it was forced to be played.
    // If it's voluntary (e.g. via Code Cleanup), it just gets discarded.
    print('Playing (Discarding?) Crash on Launch.');
  }

  @override
  void onResolve(GameContext context) {
    // TODO: Implement game logic:
    // 1. If this bug is still in the build/active area during resolution,
    //    subtract 2500 users from the game state.
    print('Resolving Crash on Launch: $onResolveText');
  }
}

class BuggyCommitCard extends BaseCard {
  @override
  String get id => 'buggy_commit';

  @override
  String get name => 'Buggy Commit';

  @override
  CardType get type => CardType.bug;

  @override
  int get timeTaken => 1;

  @override
  String get onPlayText => ''; // Bugs usually don't have voluntary OnPlay

  @override
  String get onResolveText => '−10% total user gain'; // Penalty if not dealt with

  @override
  String get flavorText => 'Works on my machine.';

  @override
  // Assuming asset path is correct based on original data
  String get assetPath => 'assets/cards/Buggy_Commit.png';

  @override
  void onPlay(GameContext context) {
    // See CrashOnLaunchCard comments on playing bugs.
    print('Playing (Discarding?) Buggy Commit.');
  }

  @override
  void onResolve(GameContext context) {
    // TODO: Implement game logic:
    // 1. If this bug is in the build/active area during resolution,
    //    apply a modifier to reduce total user gain by 10% for this turn.
    print('Resolving Buggy Commit: $onResolveText');
  }
}

class CodeCleanupCard extends BaseCard {
  @override
  String get id => 'code_cleanup'; // Explicitly defined ID

  @override
  String get name => 'Code Cleanup';

  @override
  CardType get type => CardType.utility;

  @override
  int get timeTaken => 2;

  @override
  String get onPlayText => 'Remove 1 Bug from your hand, draw 1 card';

  @override
  String get onResolveText => ''; // No effect on resolve

  @override
  String get flavorText => 'Finally deleted that one TODO from 2022.';

  @override
  String get assetPath => _placeholderAsset; // TODO: Update if asset becomes available

  @override
  void onPlay(GameContext context) {
    // TODO: Implement game logic:
    // 1. Check player's hand for a card with type CardType.bug.
    // 2. If found, allow player to select one to discard.
    // 3. Draw 1 card from the player's deck.
    print('Playing Code Cleanup: $onPlayText');
  }

  @override
  void onResolve(GameContext context) {
    // No effect on resolve for this card.
    print('Resolving Code Cleanup: No effect.');
  }
}

class CoffeeRefactorCard extends BaseCard {
  @override
  String get id => 'coffee_refactor';

  @override
  String get name => 'Coffee Refactor';

  @override
  CardType get type => CardType.utility;

  @override
  int get timeTaken => 2;

  @override
  String get onPlayText => 'Draw 2, discard 1';

  @override
  String get onResolveText => ''; // No effect on resolve

  @override
  String get flavorText => 'Clean code? No, *caffeinated* code.';

  @override
  String get assetPath => _placeholderAsset;

  @override
  void onPlay(GameContext context) {
    // TODO: Implement game logic:
    // 1. Draw 2 cards from the player's deck.
    // 2. Prompt player to choose 1 card from their hand to discard.
    print('Playing Coffee Refactor: $onPlayText');
  }

  @override
  void onResolve(GameContext context) {
    // No effect on resolve for this card.
    print('Resolving Coffee Refactor: No effect.');
  }
}

class MicrotransactionCard extends BaseCard {
  @override
  String get id => 'microtransaction';

  @override
  String get name => 'Microtransaction';

  @override
  CardType get type => CardType.utility;

  @override
  int get timeTaken => 1;

  @override
  String get onPlayText => 'Gain +2 Hours';

  @override
  String get onResolveText => ''; // No effect on resolve

  @override
  String get flavorText => 'Only costs your soul. And \$0.99.';

  @override
  String get assetPath => _placeholderAsset;

  @override
  void onPlay(GameContext context) {
    // TODO: Implement game logic:
    // 1. Add 2 to the player's available time/action points for the current turn.
    print('Playing Microtransaction: $onPlayText');
  }

  @override
  void onResolve(GameContext context) {
    // No effect on resolve for this card.
    print('Resolving Microtransaction: No effect.');
  }
}

class UnreadPrivacyPolicyCard extends BaseCard {
  @override
  String get id => 'unread_privacy_policy';

  @override
  String get name => 'Unread Privacy Policy';

  @override
  CardType get type => CardType.feature;

  @override
  int get timeTaken => 1;

  @override
  String get onPlayText => ''; // No immediate effect on play

  @override
  String get onResolveText => 'Gain 100 users';

  @override
  String get flavorText => 'Lawyers approved. We didn\'t read it.';

  @override
  // Assuming asset path is correct based on original data
  String get assetPath => 'assets/cards/Unread_Privacy_Policy.png';

  @override
  void onPlay(GameContext context) {
    // No specific onPlay logic defined in original data
    print('Playing Unread Privacy Policy.');
  }

  @override
  void onResolve(GameContext context) {
    // TODO: Implement game logic:
    // 1. Add 100 users to the game state.
    print('Resolving Unread Privacy Policy: $onResolveText');
  }
}
