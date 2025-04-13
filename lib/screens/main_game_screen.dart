import 'package:flutter/material.dart';
import 'package:roguelike_deckbuilder/controllers/game_controller.dart';
import 'package:roguelike_deckbuilder/models/card.dart';
import 'package:roguelike_deckbuilder/models/game_state.dart';
import 'package:roguelike_deckbuilder/widgets/card_hand.dart';

class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  late final GameController _gameController;
  GameCard? _selectedCard;
  int? _selectedCardIndex; // Store index to pass to controller methods

  @override
  void initState() {
    super.initState();
    _gameController = GameController();
    // Listen for state changes to potentially reset selection if hand changes drastically
    _gameController.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    _gameController.removeListener(_onGameStateChanged);
    _gameController.dispose();
    super.dispose();
  }

  void _onGameStateChanged() {
    // If the hand composition changes (e.g., after drawing/discarding),
    // ensure the selected card still exists and its index is valid.
    final currentState = _gameController.value;
    if (_selectedCard != null) {
      final newIndex = currentState.hand.indexOf(_selectedCard!);
      if (newIndex == -1) {
        // Selected card is no longer in hand
        setState(() {
          _selectedCard = null;
          _selectedCardIndex = null;
        });
      } else {
        // Update index if it changed (less likely but possible)
        // Check if index actually changed before calling setState
        if (_selectedCardIndex != newIndex) {
          setState(() {
            _selectedCardIndex = newIndex;
          });
        }
      }
    }
  }

  void _handleCardSelection(GameCard card) {
    final currentState = _gameController.value;
    final index = currentState.hand.indexOf(card);

    setState(() {
      if (_selectedCard == card) {
        // Toggle off selection
        _selectedCard = null;
        _selectedCardIndex = null;
      } else {
        _selectedCard = card;
        _selectedCardIndex = index != -1 ? index : null;
      }
    });
  }

  void _playSelectedCard() {
    if (_selectedCard != null && _selectedCardIndex != null) {
      final card = _selectedCard!;
      final index = _selectedCardIndex!;

      // Double check the index is still valid before proceeding
      if (index >= _gameController.value.hand.length || _gameController.value.hand[index] != card) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Card selection issue, please re-select.')));
        setState(() {
          _selectedCard = null;
          _selectedCardIndex = null;
        });
        return;
      }

      if (_gameController.value.currentHours >= card.timeTaken) {
        if (card.type == CardType.bug) {
          _gameController.fixBug(card, index);
        } else {
          _gameController.playCard(card, index);
        }
        // Deselect after playing
        setState(() {
          _selectedCard = null;
          _selectedCardIndex = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Not enough hours to play ${card.name}')));
      }
    }
  }

  void _releaseSprint() {
    _gameController.release();
    // Deselect card after releasing, as hand state changes
    setState(() {
      _selectedCard = null;
      _selectedCardIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<GameState>(
          valueListenable: _gameController,
          builder: (context, state, child) {
            return Text('Sprint: ${state.sprint} | Users: ${state.users} / ${state.requiredUsers}');
          },
        ),
      ),
      body: ValueListenableBuilder<GameState>(
        valueListenable: _gameController,
        builder: (context, gameState, child) {
          final bool canAffordSelected = _selectedCard != null && gameState.currentHours >= _selectedCard!.timeTaken;

          return Column(
            children: [
              // Top Bar Info
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Hours: ${gameState.currentHours} / ${gameState.startingHoursPerSprint}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text('Deck: ${gameState.deck.length}'),
                    Text('Discard: ${gameState.discardPile.length}'),
                  ],
                ),
              ),

              // Sprint Backlog (Played Cards this turn)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(
                  'Sprint Backlog: ${gameState.sprintBacklog.isEmpty ? "Empty" : gameState.sprintBacklog.map((c) => c.name).join(', ')}',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _selectedCard != null && canAffordSelected ? _playSelectedCard : null,
                      child: Text(_selectedCard?.type == CardType.bug ? 'Fix Selected Bug' : 'Play Selected Card'),
                    ),
                    ElevatedButton(
                      onPressed: _releaseSprint,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Release!'),
                    ),
                  ],
                ),
              ),

              const Spacer(), // Pushes hand to the bottom
              // Card Hand
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: CardHand(
                  cards: gameState.hand,
                  // Use the updated callback signature from CardHand
                  onCardSelected: (index, card) {
                    setState(() {
                      if (_selectedCardIndex == index) {
                        // Tap selected card again to deselect
                        _selectedCard = null;
                        _selectedCardIndex = null;
                      } else {
                        _selectedCard = card;
                        _selectedCardIndex = index;
                      }
                    });
                  },
                  // Remove selectedCardIndex parameter - CardHand manages its internal selection
                  cardWidth: 150,
                  cardHeight: 210,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
