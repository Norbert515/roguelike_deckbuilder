import 'package:flutter/material.dart';
import 'package:roguelike_deckbuilder/controllers/game_controller.dart';
import 'package:roguelike_deckbuilder/models/base_card.dart';
import 'package:roguelike_deckbuilder/models/card_in_play.dart';
import 'package:roguelike_deckbuilder/models/game_state.dart';
import 'package:roguelike_deckbuilder/widgets/card_hand.dart';
import 'package:roguelike_deckbuilder/widgets/game_card_widget.dart';

class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  late final GameController _gameController;
  CardInPlay? _selectedCardInPlay;
  int? _selectedCardIndex;

  @override
  void initState() {
    super.initState();
    _gameController = GameController();
    _gameController.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    _gameController.removeListener(_onGameStateChanged);
    _gameController.dispose();
    super.dispose();
  }

  void _onGameStateChanged() {
    final currentState = _gameController.value;
    if (_selectedCardInPlay != null) {
      final newIndex = currentState.hand.indexWhere((c) => c.instanceId == _selectedCardInPlay!.instanceId);

      if (newIndex == -1) {
        setState(() {
          _selectedCardInPlay = null;
          _selectedCardIndex = null;
        });
      } else {
        if (_selectedCardIndex != newIndex) {
          setState(() {
            _selectedCardIndex = newIndex;
          });
        }
      }
    }
  }

  void _playSelectedCard() {
    if (_selectedCardInPlay != null && _selectedCardIndex != null) {
      final cardInPlay = _selectedCardInPlay!;
      final index = _selectedCardIndex!;
      final cardDefinition = cardInPlay.cardType;

      if (index >= _gameController.value.hand.length ||
          _gameController.value.hand[index].instanceId != cardInPlay.instanceId) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Card selection issue, please re-select.')));
        setState(() {
          _selectedCardInPlay = null;
          _selectedCardIndex = null;
        });
        return;
      }

      if (_gameController.value.currentHours >= cardDefinition.timeTaken) {
        if (cardDefinition.type == CardType.bug) {
          _gameController.fixBug(cardInPlay, index);
        } else {
          _gameController.playCard(cardInPlay, index);
        }
        setState(() {
          _selectedCardInPlay = null;
          _selectedCardIndex = null;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Not enough hours to play ${cardDefinition.name}')));
      }
    }
  }

  void _releaseSprint() {
    _gameController.release();
    setState(() {
      _selectedCardInPlay = null;
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
          final bool canAffordSelected =
              _selectedCardInPlay != null && gameState.currentHours >= _selectedCardInPlay!.cardType.timeTaken;

          return Column(
            children: [
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

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Sprint Backlog', style: Theme.of(context).textTheme.titleMedium),
              ),
              Container(
                constraints: const BoxConstraints(maxHeight: 120),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child:
                    gameState.sprintBacklog.isEmpty
                        ? Center(
                          child: Text(
                            'Empty',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        )
                        : Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          alignment: WrapAlignment.center,
                          children:
                              gameState.sprintBacklog.map((cardInPlay) {
                                return GameCardWidget(
                                  cardInPlay: cardInPlay,
                                  width: 80,
                                  height: 112,
                                  isSelected: false,
                                );
                              }).toList(),
                        ),
              ),
              const Divider(),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _selectedCardInPlay != null && canAffordSelected ? _playSelectedCard : null,
                      child: Text(
                        _selectedCardInPlay?.cardType.type == CardType.bug ? 'Fix Selected Bug' : 'Play Selected Card',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _releaseSprint,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Release!'),
                    ),
                  ],
                ),
              ),

              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: CardHand(
                  cards: gameState.hand,
                  onCardSelected: (index, cardInPlay) {
                    setState(() {
                      if (_selectedCardIndex == index) {
                        _selectedCardInPlay = null;
                        _selectedCardIndex = null;
                      } else {
                        _selectedCardInPlay = cardInPlay;
                        _selectedCardIndex = index;
                      }
                    });
                  },
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
