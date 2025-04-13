import 'package:collection/collection.dart';

import 'card.dart';

class GameState {
  final int sprint;
  final int users;
  final int requiredUsers;
  final int currentHours;
  final int startingHoursPerSprint;
  final List<GameCard> deck;
  final List<GameCard> hand;
  final List<GameCard> discardPile;
  final List<GameCard> sprintBacklog; // Cards played this sprint, awaiting Release
  final List<GameCard> removedCards; // Fixed bugs, etc.

  const GameState({
    required this.sprint,
    required this.users,
    required this.requiredUsers,
    required this.currentHours,
    required this.startingHoursPerSprint,
    required this.deck,
    required this.hand,
    required this.discardPile,
    required this.sprintBacklog,
    required this.removedCards,
  });

  // TODO: Implement initial state logic (e.g., loading starter deck)
  factory GameState.initial() {
    return GameState(
      sprint: 1,
      users: 0,
      requiredUsers: 10000, // Initial milestone for sprint 10
      currentHours: 3,
      startingHoursPerSprint: 3,
      deck: [], // Starter deck should be loaded here
      hand: [], // Initial hand should be drawn here
      discardPile: [],
      sprintBacklog: [],
      removedCards: [],
    );
  }

  GameState copyWith({
    int? sprint,
    int? users,
    int? requiredUsers,
    int? currentHours,
    int? startingHoursPerSprint,
    List<GameCard>? deck,
    List<GameCard>? hand,
    List<GameCard>? discardPile,
    List<GameCard>? sprintBacklog,
    List<GameCard>? removedCards,
  }) {
    return GameState(
      sprint: sprint ?? this.sprint,
      users: users ?? this.users,
      requiredUsers: requiredUsers ?? this.requiredUsers,
      currentHours: currentHours ?? this.currentHours,
      startingHoursPerSprint: startingHoursPerSprint ?? this.startingHoursPerSprint,
      deck: deck ?? List.unmodifiable(this.deck),
      hand: hand ?? List.unmodifiable(this.hand),
      discardPile: discardPile ?? List.unmodifiable(this.discardPile),
      sprintBacklog: sprintBacklog ?? List.unmodifiable(this.sprintBacklog),
      removedCards: removedCards ?? List.unmodifiable(this.removedCards),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameState &&
          runtimeType == other.runtimeType &&
          sprint == other.sprint &&
          users == other.users &&
          requiredUsers == other.requiredUsers &&
          currentHours == other.currentHours &&
          startingHoursPerSprint == other.startingHoursPerSprint &&
          const ListEquality().equals(deck, other.deck) &&
          const ListEquality().equals(hand, other.hand) &&
          const ListEquality().equals(discardPile, other.discardPile) &&
          const ListEquality().equals(sprintBacklog, other.sprintBacklog) &&
          const ListEquality().equals(removedCards, other.removedCards);

  @override
  int get hashCode =>
      sprint.hashCode ^
      users.hashCode ^
      requiredUsers.hashCode ^
      currentHours.hashCode ^
      startingHoursPerSprint.hashCode ^
      const ListEquality().hash(deck) ^
      const ListEquality().hash(hand) ^
      const ListEquality().hash(discardPile) ^
      const ListEquality().hash(sprintBacklog) ^
      const ListEquality().hash(removedCards);

  @override
  String toString() {
    return 'GameState{sprint: $sprint, users: $users, requiredUsers: $requiredUsers, currentHours: $currentHours, startingHoursPerSprint: $startingHoursPerSprint, deck: ${deck.length}, hand: ${hand.length}, discardPile: ${discardPile.length}, sprintBacklog: ${sprintBacklog.length}, removedCards: ${removedCards.length}}';
  }
}
