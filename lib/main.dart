import 'package:flutter/material.dart';
import 'models/card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<GameCard> hand = [];
  List<GameCard> deck = [];
  int currentDay = 1;
  int totalTime = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // TODO: Initialize the game state, deck, and starting hand
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Software Development Card Game'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Day: $currentDay | Time: $totalTime hrs', style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Player stats area
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [Text('Deck: ${deck.length}'), Text('Hand: ${hand.length}')],
            ),
          ),

          // Game board area
          Expanded(
            child: Container(color: Colors.green.withOpacity(0.1), child: const Center(child: Text('Game Board'))),
          ),

          // Hand area
          Container(
            height: 200,
            padding: const EdgeInsets.all(16.0),
            color: Colors.black26,
            child:
                hand.isEmpty
                    ? const Center(child: Text('No cards in hand'))
                    : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: hand.length,
                      itemBuilder: (context, index) {
                        return _buildCard(hand[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(GameCard card) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: _getCardColor(card.type),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(card.type.toString(), style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            const Spacer(),
            Text('Time: ${card.timeTaken}hrs'),
          ],
        ),
      ),
    );
  }

  Color _getCardColor(CardType type) {
    switch (type) {
      case CardType.marketing:
        return Colors.blue.shade200;
      case CardType.feature:
        return Colors.green.shade200;
      case CardType.utility:
        return Colors.orange.shade200;
      case CardType.bug:
        return Colors.red.shade200;
    }
  }
}
