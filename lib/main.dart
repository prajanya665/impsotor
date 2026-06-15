import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const ImposterGameApp());
}

class ImposterGameApp extends StatelessWidget {
  const ImposterGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🕵️ Imposter Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A051B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFBD00FF), // Electric Purple
          secondary: Color(0xFF00F0FF), // Cyber Cyan
          error: Color(0xFFFF0055), // Neon Pink
          surface: Color(0xFF1A1135),
        ),
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
  // Game Configuration & Constants
  final Map<String, List<String>> wordsDatabase = {
    'animals': ["Elephant","Penguin","Dolphin","Kangaroo","Octopus","Giraffe","Hedgehog","Cheetah","Owl","Koala","Crocodile","Flamingo"],
    'food': ["Pizza","Sushi","Pancake","Spaghetti","Taco","Avocado","Hamburger","Croissant","Popcorn","Lasagna","Donut","Burrito"],
    'places': ["Beach","Library","Airport","Volcano","Desert","Hospital","Stadium","Castle","Museum","Jungle","Lighthouse","Subway"],
    'objects': ["Umbrella","Telescope","Toothbrush","Backpack","Candle","Scissors","Compass","Mirror","Ladder","Anchor","Hammer","Lantern"],
    'sports': ["Basketball","Tennis","Surfing","Boxing","Archery","Skiing","Bowling","Cricket","Hockey","Golf","Karate","Cycling"],
    'movies': ["Titanic","Jaws","Frozen","Avatar","Gladiator","Inception","Shrek","Rocky","Casablanca","Up","Matrix","Coco"],
    'clash royale': ["Barbarian","Giant","Witch","Goblin","Dragon","Knight","Archer","Wizard","Skeleton","Valkyrie","Golem","PEKKA"],
    'professions': ["Surgeon","Astronaut","Chef","Architect","Detective","Firefighter","Archaeologist","Pilot","Journalist","Lawyer","Scientist","Carpenter"],
  };

  // UI Setup State
  String currentScreen = 'setup'; // setup, reveal, play, results
  int numPlayers = 4;
  int numImposters = 1;
  String selectedCategory = 'random';
  bool hintMode = false;

  // Active Game State
  late String chosenCategory;
  late String secretWord;
  List<bool> playerRoles = []; // true if imposter
  List<int> imposterIndices = []; // 1-based indices for results
  int currentPlayerIndex = 0;
  bool isCardFlipped = false;

  void startGame() {
    if (numPlayers < 3) return;
    if (numImposters < 1 || numImposters >= numPlayers) return;

    // Pick Category & Word
    chosenCategory = selectedCategory;
    if (chosenCategory == 'random') {
      List<String> keys = wordsDatabase.keys.toList();
      chosenCategory = keys[Random().nextInt(keys.length)];
    }
    List<String> list = wordsDatabase[chosenCategory]!;
    secretWord = list[Random().nextInt(list.length)];

    // Assign Roles
    playerRoles = List<bool>.filled(numPlayers, false);
    Set<int> chosenImposters = {};
    while (chosenImposters.length < numImposters) {
      chosenImposters.add(Random().nextInt(numPlayers));
    }
    for (int idx in chosenImposters) {
      playerRoles[idx] = true;
    }

    imposterIndices = chosenImposters.map((i) => i + 1).toList()..sort();
    currentPlayerIndex = 0;
    isCardFlipped = false;

    setState(() {
      currentScreen = 'reveal';
    });
  }

  void nextPlayer() {
    setState(() {
      if (currentPlayerIndex + 1 >= numPlayers) {
        currentScreen = 'play';
      } else {
        currentPlayerIndex++;
        isCardFlipped = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.2,
            colors: [Color(0x25BD00FF), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentScreen(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (currentScreen) {
      case 'setup':
        return _buildSetupScreen();
      case 'reveal':
        return _buildRevealScreen();
      case 'play':
        return _buildPlayScreen();
      case 'results':
        return _buildResultsScreen();
      default:
        return _buildSetupScreen();
    }
  }

  // --- 1. SETUP SCREEN ---
  Widget _buildSetupScreen() {
    return Column(
      key: const ValueKey('setup'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('🕵️ Imposter', textAlign: TextAlign.center, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1)),
        const SizedBox(height: 4),
        const Text('A social deduction party game · pass & play', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF8B80b6), fontSize: 14)),
        const SizedBox(height: 32),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PLAYERS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: numPlayers,
                    decoration: _inputDecoration(),
                    items: List.generate(18, (i) => i + 3).map((val) => DropdownMenuItem(value: val, child: Text('$val'))).toList(),
                    onChanged: (val) => setState(() => numPlayers = val ?? 4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('IMPOSTERS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: numImposters < numPlayers ? numImposters : 1,
                    decoration: _inputDecoration(),
                    items: List.generate(5, (i) => i + 1).map((val) => DropdownMenuItem(value: val, child: Text('$val'))).toList(),
                    onChanged: (val) => setState(() => numImposters = val ?? 1),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        const Text('WORD CATEGORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
        const SizedBox(height: 10),
        _buildCategoryGrid(),

        const SizedBox(height: 12),
        InkWell(
          onTap: () => setState(() => hintMode = !hintMode),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0x15FFFFFF),
              border: Border.all(color: const Color(0x15FFFFFF)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: hintMode,
                  activeColor: const Color(0xFFBD00FF),
                  onChanged: (val) => setState(() => hintMode = val ?? false),
                ),
                const Text('Give imposter a category hint', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          style: _btnStyle(const Color(0xFFBD00FF)),
          onPressed: startGame,
          child: const Text('Start Game', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'id': 'random', 'label': '🎲 Random'},
      {'id': 'animals', 'label': '🐾 Animals'},
      {'id': 'food', 'label': '🍕 Food'},
      {'id': 'places', 'label': '🌍 Places'},
      {'id': 'objects', 'label': '📦 Objects'},
      {'id': 'sports', 'label': '⚽ Sports'},
      {'id': 'movies', 'label': '🎬 Movies'},
      {'id': 'clash royale',  'label': '⚔️ Clash Royale'},
      {'id': 'professions',   'label': '💼 Professions'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        bool isSelected = selectedCategory == cat['id'];
        return InkWell(
          onTap: () => setState(() => selectedCategory = cat['id']!),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0x25BD00FF) : const Color(0x601A1135),
              border: Border.all(color: isSelected ? const Color(0xFFBD00FF) : const Color(0x15FFFFFF)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(cat['label']!, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF8B80b6), fontWeight: FontWeight.w600)),
          ),
        );
      }).toList(),
    );
  }

  // --- 2. REVEAL (PASS & PLAY) SCREEN WITH 3D FLIP ---
  Widget _buildRevealScreen() {
    bool isImposter = playerRoles[currentPlayerIndex];

    return Column(
      key: ValueKey('reveal_$currentPlayerIndex'),
      children: [
        Text('Player ${currentPlayerIndex + 1}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text("Make sure others can't see your screen!", style: TextStyle(color: Color(0xFF8B80b6), fontSize: 13)),
        const SizedBox(height: 32),

        GestureDetector(
          onTap: () => setState(() => isCardFlipped = true),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: isCardFlipped ? pi : 0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
            builder: (context, val, __) {
              // Determine if we show front side or back side asset inside the rotation threshold
              final isBackSide = val >= pi / 2;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(val),
                child: isBackSide
                    ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi), // correct mirrored text
                  child: _buildCardBack(isImposter),
                )
                    : _buildCardFront(),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        if (isCardFlipped)
          ElevatedButton(
            style: _btnStyle(const Color(0xFF00F0FF)),
            onPressed: nextPlayer,
            child: const Text('Got it — Next player ▶', style: TextStyle(fontSize: 16, color: Color(0xFF0A051B))),
          ),
      ],
    );
  }

  Widget _buildCardFront() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF16102B),
        border: Border.all(color: const Color(0x15FFFFFF)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('👁️', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('Tap to reveal your word', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildCardBack(bool isImposter) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isImposter ? const Color(0xFF2B0B1A) : const Color(0xFF111E35),
        border: Border.all(color: isImposter ? const Color(0xFFFF0055) : const Color(0xFF00F0FF), width: 1.5),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isImposter ? '🕵️ IMPOSTER' : secretWord,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: isImposter ? const Color(0xFFFF0055) : Colors.white, letterSpacing: -0.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            isImposter
                ? (hintMode ? "Category Hint: ${chosenCategory.toUpperCase()}" : "Blend in and don't get caught!")
                : "Keep this word a complete secret",
            style: const TextStyle(color: Color(0xFF8B80b6), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --- 3. DISCUSSION TIME SCREEN ---
  Widget _buildPlayScreen() {
    return Column(
      key: const ValueKey('play'),
      children: [
        const Text('🗣️ Discussion Time!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0x10FFFFFF),
            border: Border.all(color: const Color(0x15FFFFFF)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Going clockwise, each player says exactly ONE WORD related to the secret item.\n\nImposters: Try to blend in perfectly! When ready, hold an open elimination vote.',
            style: TextStyle(fontSize: 16, height: 1.6, color: Color(0xFFE2E8F0)),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: _btnStyle(const Color(0xFFFF0055)),
          onPressed: () => setState(() => currentScreen = 'results'),
          child: const Text('Reveal the Imposter(s) 🔍', style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => currentScreen = 'setup'),
          child: const Text('Abort Game', style: TextStyle(color: Color(0xFF8B80b6))),
        )
      ],
    );
  }

  // --- 4. RESULTS SCREEN ---
  Widget _buildResultsScreen() {
    String namesList = imposterIndices.map((i) => "Player $i").join(", ");

    return Column(
      key: const ValueKey('results'),
      children: [
        const Text('🎭 The Reveal', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0x1500F0FF),
            border: Border.all(color: const Color(0x4000F0FF)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Text('SECRET WORD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00F0FF), letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(secretWord, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0x15FF0055),
            border: Border.all(color: const Color(0x40FF0055)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Text('IDENTITIES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFF0055), letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(
                'The imposter${numImposters > 1 ? "s were" : " was"}:',
                style: const TextStyle(fontSize: 15, color: Color(0xFF8B80b6)),
              ),
              const SizedBox(height: 4),
              Text(namesList, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 32),

        ElevatedButton(
          style: _btnStyle(const Color(0xFF00F0FF)),
          onPressed: startGame,
          child: const Text('Play Again 🔄', style: TextStyle(fontSize: 16, color: Color(0xFF0A051B))),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          style: _btnStyle(Colors.transparent).copyWith(
            side: WidgetStateProperty.all(const BorderSide(color: Color(0x20FFFFFF))),
            elevation: WidgetStateProperty.all(0),
          ),
          onPressed: () => setState(() => currentScreen = 'setup'),
          child: const Text('Change Settings', style: TextStyle(fontSize: 16, color: Color(0xFF8B80b6))),
        ),
      ],
    );
  }

  // --- REUSABLE UI STYLES ---
  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      fillColor: const Color(0xFF16102B),
      filled: true,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0x15FFFFFF))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFBD00FF))),
    );
  }

  ButtonStyle _btnStyle(Color bgColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      minimumSize: const Size(double.infinity, 54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: bgColor == Colors.transparent ? 0 : 8,
      shadowColor: bgColor.withOpacity(0.3),
    );
  }
}