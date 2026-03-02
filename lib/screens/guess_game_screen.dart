import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class GuessGameScreen extends StatefulWidget {
  const GuessGameScreen({super.key});

  @override
  State<GuessGameScreen> createState() => _GuessGameScreenState();
}

class _GuessGameScreenState extends State<GuessGameScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _random = Random();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  int _secret = 0;
  int _attemptsLeft = 5;
  int _attemptsTotal = 5;
  String _message = '';
  String _hint = '';
  bool _gameOver = false;
  bool _won = false;
  List<_Attempt> _history = [];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _startGame();
  }

  void _startGame() {
    setState(() {
      _secret = _random.nextInt(20) + 1;
      _attemptsLeft = 5;
      _message = '';
      _hint = '';
      _gameOver = false;
      _won = false;
      _history = [];
      _ctrl.clear();
    });
  }

  void _guess() {
    if (_gameOver) return;
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    final guess = int.tryParse(text);
    if (guess == null || guess < 1 || guess > 20) {
      setState(() => _message = '1-ден 20-ға дейінгі бүтін сан енгізіңіз!');
      _shakeController.forward(from: 0);
      return;
    }

    _attemptsLeft--;
    _history.add(
      _Attempt(
        guess: guess,
        result: guess == _secret
            ? 'тура'
            : guess < _secret
            ? 'кем'
            : 'артық',
      ),
    );

    if (guess == _secret) {
      setState(() {
        _won = true;
        _gameOver = true;
        _message = 'Сен жеңдің! 🎉';
        _hint = 'Жауабы: $_secret. ${5 - _attemptsLeft} қадамда таптың!';
      });
    } else if (_attemptsLeft == 0) {
      setState(() {
        _won = false;
        _gameOver = true;
        _message = 'Сен жеңілдің! 😔';
        _hint = 'Дұрыс жауабы: $_secret еді.';
      });
    } else {
      if (guess < _secret) {
        setState(() {
          _hint = 'Сіз енгіздіңіз: $guess — бұл саннан көбірек 🔼';
          _message = 'Ойланба, жоғарырақ!';
        });
      } else {
        setState(() {
          _hint = 'Сіз енгіздіңіз: $guess — бұл саннан кемірек 🔽';
          _message = 'Ойланба, төмендеу!';
        });
      }
      _ctrl.clear();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildAttemptsBar(),
              const SizedBox(height: 20),
              if (!_gameOver) _buildGuessInput(),
              const SizedBox(height: 20),
              if (_message.isNotEmpty) _buildMessageCard(),
              const SizedBox(height: 16),
              if (_history.isNotEmpty) _buildHistory(),
              const SizedBox(height: 16),
              if (_gameOver) _buildPlayAgain(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6584), Color(0xFFFF4757)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.sports_esports,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Санды тап!',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Text(
              '1-ден 20-ға дейін · B деңгей',
              style: TextStyle(color: Color(0xFFFF6584), fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttemptsBar() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFF6584).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Қалған қадамдар',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: const Color(0xFFAAAAAA),
                ),
              ),
              Text(
                '$_attemptsLeft / $_attemptsTotal',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _attemptsLeft > 2
                      ? const Color(0xFF03DAC6)
                      : const Color(0xFFFF6584),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_attemptsTotal, (i) {
              final filled = i < _attemptsLeft;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: filled
                        ? (i < 2
                              ? const Color(0xFFFF6584)
                              : const Color(0xFF03DAC6))
                        : const Color(0xFF2A2A4A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGuessInput() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6584).withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFFF6584).withOpacity(0.25),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFFFF6584), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '1-ден 20-ға дейінгі бүтін сан енгізіңіз. Қадам саны 5-тен аспасын.',
                  style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: AnimatedBuilder(
                animation: _shakeAnim,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(sin(_shakeAnim.value * pi * 4) * 6, 0),
                    child: child,
                  );
                },
                child: TextField(
                  controller: _ctrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Санды енгізіңіз',
                    prefixIcon: Icon(Icons.tag),
                    hintText: '1 — 20',
                  ),
                  onSubmitted: (_) => _guess(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _guess,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6584),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageCard() {
    final Color color = _gameOver
        ? (_won ? const Color(0xFF03DAC6) : const Color(0xFFFF6584))
        : const Color(0xFFFFB347);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              _message,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            if (_hint.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                _hint,
                textAlign: TextAlign.center,
                style: TextStyle(color: color.withOpacity(0.8), fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Тарих',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: const Color(0xFFAAAAAA),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ..._history.asMap().entries.map((e) {
            final a = e.value;
            final color = a.result == 'тура'
                ? const Color(0xFF03DAC6)
                : const Color(0xFFAAAAAA);
            final icon = a.result == 'кем'
                ? '🔼'
                : a.result == 'артық'
                ? '🔽'
                : '✅';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F23),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${e.key + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF666680),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${a.guess}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(icon),
                  const SizedBox(width: 6),
                  Text(a.result, style: TextStyle(color: color, fontSize: 13)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlayAgain() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _startGame,
        icon: const Icon(Icons.refresh),
        label: const Text('Қайтадан ойнау'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _won
              ? const Color(0xFF03DAC6)
              : const Color(0xFFFF6584),
        ),
      ),
    );
  }
}

class _Attempt {
  final int guess;
  final String result;
  const _Attempt({required this.guess, required this.result});
}
