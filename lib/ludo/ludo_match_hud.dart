import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'ludo_game.dart';

/// Displays a two-player local-preview match bar.
/// Uses the signed-in profile for Player 1 only; the other seat is a demo.
/// It does not create online opponents, charge the wallet, or write results.
class LudoMatchHud extends StatelessWidget {
  const LudoMatchHud({
    super.key,
    required this.game,
    required this.diceValue,
    required this.canRoll,
    required this.onRoll,
  });

  final LudoGame game;
  final int? diceValue;
  final bool canRoll;
  final VoidCallback onRoll;

  static const Color _gold = Color(0xFFFFC53D);
  static const Color _red = Color(0xFFE83351);
  static const Color _yellow = Color(0xFFFFC43D);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final signedInName = (user?.displayName ?? '').trim();
    final playerName = signedInName.isNotEmpty ? signedInName : 'PLAYER 1';
    final photo = user?.photoURL;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF0A2A4C),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF54749F)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _ProfilePanel(
                  name: playerName,
                  seat: LudoSeat.red,
                  color: _red,
                  photoUrl: photo,
                  isDemo: false,
                  isPlaying: !game.isFinished && game.currentSeat == LudoSeat.red,
                  completed: game.pieces[LudoSeat.red]!.where((p) => p == 56).length,
                  rank: game.rankingOf(LudoSeat.red),
                ),
              ),
              const SizedBox(width: 7),
                            _DiceButton(
                key: ObjectKey(game),
                value: diceValue,
                canRoll: canRoll,
                onRoll: onRoll,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _ProfilePanel(
                  name: 'PLAYER 2',
                  seat: LudoSeat.yellow,
                  color: _yellow,
                  isDemo: true,
                  isPlaying: !game.isFinished && game.currentSeat == LudoSeat.yellow,
                  completed: game.pieces[LudoSeat.yellow]!.where((p) => p == 56).length,
                  rank: game.rankingOf(LudoSeat.yellow),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'LOCAL DEMO • दोनों खिलाड़ियों की चाल इसी फोन पर',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFAFC6DE), fontSize: 11),
        ),
      ],
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({
    required this.name,
    required this.seat,
    required this.color,
    required this.isDemo,
    required this.isPlaying,
    required this.completed,
    required this.rank,
    this.photoUrl,
  });

  final String name;
  final LudoSeat seat;
  final Color color;
  final String? photoUrl;
  final bool isDemo;
  final bool isPlaying;
  final int completed;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF102441),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPlaying ? color : const Color(0xFF35597A),
          width: isPlaying ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 45,
            height: 45,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.22),
              border: Border.all(color: color, width: 2),
            ),
            child: !isDemo && photoUrl != null && photoUrl!.isNotEmpty
                ? Image.network(
                    photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.person, color: color, size: 31),
                  )
                : Icon(isDemo ? Icons.smart_toy_outlined : Icons.person,
                    color: color, size: 31),
          ),
          const SizedBox(height: 5),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rank != null ? '🏆 RANK $rank' : '$completed/4 HOME',
            maxLines: 1,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          Text(
            isPlaying ? '● TURN' : (isDemo ? 'DEMO RIVAL' : 'WAITING'),
            maxLines: 1,
            style: TextStyle(
              color: isPlaying ? const Color(0xFF74F0B5) : Colors.white54,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ===== PREMIUM ANIMATED LUDO DICE =====

class _DiceButton extends StatefulWidget {
  const _DiceButton({
    super.key,
    required this.value,
    required this.canRoll,
    required this.onRoll,
  });

  final int? value;
  final bool canRoll;
  final VoidCallback onRoll;

  @override
  State<_DiceButton> createState() =>
      _DiceButtonState();
}

class _DiceButtonState extends State<_DiceButton>
    with SingleTickerProviderStateMixin {

  late final AnimationController _spinController;

  final math.Random _random = math.Random();

  Timer? _previewTimer;

  bool _rolling = false;

  int _preview = 6;
  int _frames = 0;

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 450,
      ),
    );
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  void _startRoll() {

    if (_rolling || !widget.canRoll) {
      return;
    }

    setState(() {
      _rolling = true;
      _frames = 0;
      _preview = _random.nextInt(6) + 1;
    });

    _spinController.repeat();

    _previewTimer?.cancel();

    _previewTimer = Timer.periodic(
      const Duration(milliseconds: 85),
      (timer) {

        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_frames >= 12) {

          timer.cancel();
          _previewTimer = null;

          _spinController.stop();
          _spinController.value = 0;

          setState(() {
            _rolling = false;
          });

          // Actual dice result is generated
          // by the existing game logic.
          widget.onRoll();

          return;
        }

        setState(() {
          _preview = _random.nextInt(6) + 1;
          _frames++;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final diceNumber = _rolling
        ? _preview
        : (widget.value ?? 6);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        GestureDetector(
          onTap: widget.canRoll && !_rolling
              ? _startRoll
              : null,

          child: Container(
            height: 64,
            width: 67,

            padding: const EdgeInsets.all(8),

            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1A815A),
                  Color(0xFF06432A),
                ],
              ),

              borderRadius:
                  BorderRadius.circular(13),

              border: Border.all(
                color: LudoMatchHud._gold,
                width: 2,
              ),

              boxShadow: const [
                BoxShadow(
                  color: Color(0x66FFC53D),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),

            child: AnimatedBuilder(
              animation: _spinController,

              builder: (context, child) {

                final angle =
                    _spinController.value *
                        2 *
                        math.pi;

                final jump =
                    math.sin(angle).abs();

                return Transform(
                  alignment: Alignment.center,

                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateZ(angle)
                    ..rotateY(
                      math.sin(angle) * 0.35,
                    ),

                  child: Transform.scale(
                    scale: 1.0 + jump * 0.13,
                    child: child,
                  ),
                );
              },

              child: _DiceFace(
                value: diceNumber,
              ),
            ),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          _rolling
              ? '🎲 ROLLING'
              : widget.canRoll
                  ? '🎲 ROLL'
                  : 'SELECT',

          style: const TextStyle(
            color: LudoMatchHud._gold,
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
class _DiceFace extends StatelessWidget {
  const _DiceFace({super.key, required this.value});
  final int value;

  @override
  Widget build(BuildContext context) {
    const pipSlots = <int, List<int>>{
      1: [4],
      2: [0, 8],
      3: [0, 4, 8],
      4: [0, 2, 6, 8],
      5: [0, 2, 4, 6, 8],
      6: [0, 2, 3, 5, 6, 8],
    };
    final visible = pipSlots[value] ?? pipSlots[6]!;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      child: GridView.count(
        crossAxisCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          for (int index = 0; index < 9; index++)
            Center(
              child: visible.contains(index)
                  ? Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF13253A),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
