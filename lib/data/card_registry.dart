import 'package:roguelike_deckbuilder/models/card.dart';

class CardRegistry {
  // --- Version 0.1 Starter Cards ---
  // Note: Using placeholder for missing assets
  static const String _placeholderAsset = 'assets/cards/placeholder.png';

  static const GameCard addAButton = GameCard(
    name: 'Add a Button',
    type: CardType.feature,
    timeTaken: 1,
    onPlay: '',
    onResolve: '',
    flavorText: 'It doesn\'t do much, but it *does* glow.',
    assetPath: _placeholderAsset, // Placeholder
  );

  static const GameCard pullToRefresh = GameCard(
    name: 'Pull to Refresh',
    type: CardType.feature,
    timeTaken: 1,
    onPlay: '',
    onResolve: '',
    flavorText: 'Because scrolling down is for peasants.',
    assetPath: _placeholderAsset, // Placeholder
  );

  static const GameCard darkMode = GameCard(
    name: 'Dark Mode',
    type: CardType.feature,
    timeTaken: 2,
    onPlay: '',
    onResolve: '',
    flavorText: 'Now your app is 38% more modern.',
    assetPath: 'assets/cards/Dark_Mode.png', // Available
  );

  static const GameCard tweetstorm = GameCard(
    name: 'Tweetstorm',
    type: CardType.marketing,
    timeTaken: 2,
    onPlay: '',
    onResolve: 'Gain 2,000 users for each Feature to the left',
    flavorText: 'Just 14 tweets deep and you\'re trending.',
    assetPath: _placeholderAsset, // Placeholder
  );

  static const GameCard pushNotification = GameCard(
    name: 'Push Notification',
    type: CardType.marketing,
    timeTaken: 2,
    onPlay: 'Draw 1 card',
    onResolve: '+10% bonus user gain',
    flavorText: 'Ping! You again.',
    assetPath: _placeholderAsset, // Placeholder
  );

  static const GameCard productHuntPost = GameCard(
    name: 'Product Hunt Post',
    type: CardType.marketing,
    timeTaken: 3,
    onPlay: '',
    onResolve: '+50% user gain for every Feature in your build',
    flavorText: 'Launched at midnight. Voted by mom.',
    assetPath: _placeholderAsset, // Placeholder
  );

  static const GameCard crashOnLaunch = GameCard(
    name: 'Crash on Launch',
    type: CardType.bug,
    timeTaken: 1,
    onPlay: '', // Bugs usually don't have voluntary OnPlay
    onResolve: '−2,500 users', // This happens if unplayed
    flavorText: 'At least the splash screen looked nice.',
    assetPath: _placeholderAsset, // Placeholder
  );

  static const GameCard buggyCommit = GameCard(
    name: 'Buggy Commit',
    type: CardType.bug,
    timeTaken: 1,
    onPlay: '',
    onResolve: '−10% total user gain', // If unplayed
    flavorText: 'Works on my machine.',
    assetPath: 'assets/cards/Buggy_Commit.png', // Available
  );

  static const GameCard codeCleanup = GameCard(
    name: 'Code Cleanup',
    type: CardType.utility,
    timeTaken: 2,
    onPlay: 'Remove 1 Bug from your hand, draw 1 card',
    onResolve: '',
    flavorText: 'Finally deleted that one TODO from 2022.',
    assetPath: _placeholderAsset, // Placeholder
  );

  static const GameCard coffeeRefactor = GameCard(
    name: 'Coffee Refactor',
    type: CardType.utility,
    timeTaken: 2,
    onPlay: 'Draw 2, discard 1',
    onResolve: '',
    flavorText: 'Clean code? No, *caffeinated* code.',
    assetPath: _placeholderAsset, // Placeholder
  );

  static const GameCard microtransaction = GameCard(
    name: 'Microtransaction',
    type: CardType.utility,
    timeTaken: 1,
    onPlay: 'Gain +2 Hours',
    onResolve: '',
    flavorText: 'Only costs your soul. And \$0.99.',
    assetPath: _placeholderAsset, // Placeholder
  );

  // --- Starter Deck Definition ---

  // Based on game.md, the starter deck contains one of each listed card.
  static final List<GameCard> starterDeck = List.unmodifiable([
    addAButton,
    pullToRefresh,
    darkMode,
    tweetstorm,
    pushNotification,
    productHuntPost,
    crashOnLaunch,
    buggyCommit,
    codeCleanup,
    coffeeRefactor,
    microtransaction,
  ]);

  // TODO: Add definitions for all other cards mentioned in game.md
  // TODO: Create or obtain placeholder.png asset
}
