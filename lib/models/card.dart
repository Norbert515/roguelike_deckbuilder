enum CardType {
  marketing,
  feature,
  utility,
  bug;

  @override
  String toString() {
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }
}

class GameCard {
  final String name;
  final CardType type;
  final String onResolve;
  final String onPlay;
  final int timeTaken;
  final String flavorText;
  final String assetPath;

  const GameCard({
    required this.name,
    required this.type,
    required this.onResolve,
    required this.onPlay,
    required this.timeTaken,
    required this.flavorText,
    required this.assetPath,
  });

  @override
  String toString() {
    return 'GameCard(name: $name, type: $type, timeTaken: $timeTaken)';
  }

  GameCard copyWith({
    String? name,
    CardType? type,
    String? onResolve,
    String? onPlay,
    int? timeTaken,
    String? flavorText,
    String? assetPath,
  }) {
    return GameCard(
      name: name ?? this.name,
      type: type ?? this.type,
      onResolve: onResolve ?? this.onResolve,
      onPlay: onPlay ?? this.onPlay,
      timeTaken: timeTaken ?? this.timeTaken,
      flavorText: flavorText ?? this.flavorText,
      assetPath: assetPath ?? this.assetPath,
    );
  }
}
