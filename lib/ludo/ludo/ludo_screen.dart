import 'dart:math';

import 'package:flutter/material.dart';

import 'ludo_game.dart';

const _night = Color(0xFF07172C);
const _panel = Color(0xFF102944);

Color _seatColor(LudoSeat seat) => switch (seat) {
      LudoSeat.red => const Color(0xFFE83351),
      LudoSeat.green => const Color(0xFF15A977),
      LudoSeat.yellow => const Color(0xFFFFC43D),
      LudoSeat.blue => const Color(0xFF2886E8),
    };

String _seatName(LudoSeat seat) => switch (seat) {
      LudoSeat.red => 'RED',
      LudoSeat.green => 'GREEN',
      LudoSeat.yellow => 'YELLOW',
      LudoSeat.blue => 'BLUE',
    };

/// Safe UI-only introduction. This screen does not create online rooms,
/// charge entries or distribute rewards.
class LudoHubPage extends StatelessWidget {
  const LudoHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _night,
      appBar: AppBar(
        backgroundColor: _night,
        foregroundColor: Colors.white,
        title: const Text('KhelBaaz Ludo'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A2444), _night, Color(0xFF261640)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24),
              ),
              child: const Column(
                children: [
                  Text('🎲', style: TextStyle(fontSize: 62)),
                  SizedBox(height: 8),
                  Text('KHELBAAZ LUDO',
                      style: TextStyle(color: Colors.white, fontSize: 27,
                          fontWeight: FontWeight.w900, letterSpacing: 1)),
                  SizedBox(height: 10),
                  Text('चारों गोटियाँ HOME पहुँचाएँ और अपनी रैंक बनाएँ।',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('TABLE CHOOSE करें',
                style: TextStyle(color: Colors.white, fontSize: 19,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _TablePreviewCard(
              players: 2,
              subtitle: 'Red vs Yellow • 1st / 2nd Winner',
              colors: const [Color(0xFFE83351), Color(0xFFFFC43D)],
            ),
            const SizedBox(height: 14),
            _TablePreviewCard(
              players: 4,
              subtitle: 'Red • Green • Yellow • Blue • Rank 1–4',
              colors: const [
                Color(0xFFE83351), Color(0xFF15A977),
                Color(0xFFFFC43D), Color(0xFF2886E8),
              ],
            ),
            const SizedBox(height: 22),
            const _Notice(),
          ],
        ),
      ),
    );
  }
}

class _TablePreviewCard extends StatelessWidget {
  final int players;
  final String subtitle;
  final List<Color> colors;
  const _TablePreviewCard({
    required this.players,
    required this.subtitle,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => LudoLocalGamePage(playerCount: players),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: GridView.count(
                  crossAxisCount: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final color in colors)
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$players PLAYER TABLE',
                      style: const TextStyle(color: Colors.white,
                          fontSize: 19, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.white70,
                          fontSize: 12)),
                  const SizedBox(height: 6),
                  const Text('LOCAL DEMO • TEST GAME',
                      style: TextStyle(color: Color(0xFFFFCE6B),
                          fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF263455),
          border: Border.all(color: const Color(0xFFFFCE6B)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'अभी यह केवल उसी फोन पर खेलने वाला नियम/बोर्ड प्रीव्यू है। '
          'LIVE Multiplayer, Admin Tables और Wallet/Prize सिस्टम अभी चालू नहीं हैं। '
          'इस डेमो में कोई असली पैसे या वर्चुअल बैलेंस का लेनदेन नहीं होता।',
          style: TextStyle(color: Colors.white, height: 1.5),
        ),
      );
}

class LudoLocalGamePage extends StatefulWidget {
  final int playerCount;
  const LudoLocalGamePage({super.key, required this.playerCount});

  @override
  State<LudoLocalGamePage> createState() => _LudoLocalGamePageState();
}

class _LudoLocalGamePageState extends State<LudoLocalGamePage> {
  late LudoGame game;
  final Random random = Random();
  int? lastDice;
  String message = 'पासा फेंककर गेम शुरू करें';

  @override
  void initState() {
    super.initState();
    game = LudoGame(playerCount: widget.playerCount);
  }

  void _roll() {
    final seat = game.currentSeat;
    final dice = random.nextInt(6) + 1;
    setState(() {
      lastDice = dice;
      final outcome = game.roll(dice);
      message = switch (outcome) {
        LudoRollResult.chooseToken =>
          '${_seatName(seat)} ने $dice फेंका • अपनी गोटी चुनें',
        LudoRollResult.noMove =>
          '${_seatName(seat)} ने $dice फेंका • कोई चाल नहीं',
        LudoRollResult.thirdSix =>
          '${_seatName(seat)} के लगातार तीन 6 • बारी खत्म',
        LudoRollResult.finished => 'गेम पूरा हुआ',
      };
    });
  }

  void _move(int index) {
    if (!game.movablePieces.contains(index)) return;
    setState(() {
      final seat = game.currentSeat;
      final outcome = game.move(index);
      if (outcome.completedSeat) {
        message = '${_seatName(seat)} को ${game.rankingOf(seat)} स्थान मिला!';
      } else if (outcome.captured) {
        message = '${_seatName(seat)} ने गोटी काटी • एक्स्ट्रा बारी';
      } else {
        message = 'अगली बारी: ${_seatName(game.currentSeat)}';
      }
      if (outcome.gameOver) message = '🏆 सभी खिलाड़ियों की रैंक तय हो गई!';
    });
  }

  void _tapBoard(Offset localPosition, double boardWidth) {
    if (game.pendingDice == null) return;
    final movable = game.movablePieces;
    int? nearest;
    double minDistance = boardWidth * 0.65 / 15;
    for (final index in movable) {
      final place = LudoBoardPainter.tokenCenter(
          game.currentSeat, index, game.pieces[game.currentSeat]![index]);
      final distance = (Offset(place.dx * boardWidth / 15,
                  place.dy * boardWidth / 15) -
              localPosition)
          .distance;
      if (distance < minDistance) {
        minDistance = distance;
        nearest = index;
      }
    }
    if (nearest != null) _move(nearest);
  }

  @override
  Widget build(BuildContext context) {
    final active = game.currentSeat;
    return Scaffold(
      backgroundColor: _night,
      appBar: AppBar(
        backgroundColor: _night,
        foregroundColor: Colors.white,
        title: Text('${widget.playerCount} Player Ludo • DEMO'),
        actions: [
          IconButton(
            tooltip: 'Restart demo',
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              game = LudoGame(playerCount: widget.playerCount);
              lastDice = null;
              message = 'नया गेम • पासा फेंकें';
            }),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Text('🎲', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    game.isFinished ? 'GAME COMPLETE' : '${_seatName(active)} की बारी',
                    style: TextStyle(color: game.isFinished
                        ? const Color(0xFFFFCE6B) : _seatColor(active),
                        fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                if (lastDice != null)
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('$lastDice',
                        style: const TextStyle(color: Colors.black,
                            fontSize: 22, fontWeight: FontWeight.w900)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return GestureDetector(
                  onTapDown: (details) => _tapBoard(details.localPosition, width),
                  child: SizedBox(
                    width: width,
                    height: width,
                    child: CustomPaint(
                      painter: LudoBoardPainter(game),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white,
                  fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (!game.isFinished && game.pendingDice == null)
            SizedBox(
              height: 55,
              child: FilledButton.icon(
                onPressed: _roll,
                style: FilledButton.styleFrom(
                  backgroundColor: _seatColor(active),
                  foregroundColor: active == LudoSeat.yellow
                      ? Colors.black : Colors.white,
                ),
                icon: const Icon(Icons.casino, size: 27),
                label: const Text('ROLL DICE',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              ),
            ),
          if (game.pendingDice != null) ...[
            const Text('किस गोटी को चलाना है?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                for (final token in game.movablePieces)
                  ElevatedButton(
                    onPressed: () => _move(token),
                    child: Text('गोटी ${token + 1}'),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          const Text('🏆 LIVE RANKING',
              style: TextStyle(color: Colors.white,
                  fontSize: 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          for (final seat in game.seats)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(12),
                border: Border(left: BorderSide(color: _seatColor(seat), width: 5)),
              ),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: _seatColor(seat), radius: 10),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_seatName(seat),
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold))),
                  Text('${game.pieces[seat]!.where((p) => p == 56).length}/4 HOME',
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(width: 10),
                  Text(game.rankingOf(seat) == null
                      ? '—' : '#${game.rankingOf(seat)}',
                      style: const TextStyle(color: Color(0xFFFFCE6B),
                          fontWeight: FontWeight.w900, fontSize: 19)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          const _Notice(),
        ],
      ),
    );
  }
}

/// Standard 15x15 52-cell Ludo track, colored lanes, bases and movable tokens.
class LudoBoardPainter extends CustomPainter {
  final LudoGame game;
  LudoBoardPainter(this.game);

  static const List<(int, int)> track = [
    (6, 1), (6, 2), (6, 3), (6, 4), (6, 5),
    (5, 6), (4, 6), (3, 6), (2, 6), (1, 6), (0, 6),
    (0, 7), (0, 8),
    (1, 8), (2, 8), (3, 8), (4, 8), (5, 8),
    (6, 9), (6, 10), (6, 11), (6, 12), (6, 13), (6, 14),
    (7, 14),
    (8, 14), (8, 13), (8, 12), (8, 11), (8, 10), (8, 9),
    (9, 8), (10, 8), (11, 8), (12, 8), (13, 8), (14, 8),
    (14, 7), (14, 6),
    (13, 6), (12, 6), (11, 6), (10, 6), (9, 6),
    (8, 5), (8, 4), (8, 3), (8, 2), (8, 1), (8, 0),
    (7, 0), (6, 0),
  ];

  static const Map<LudoSeat, List<(int, int)>> lanes = {
    LudoSeat.red: [(7, 1), (7, 2), (7, 3), (7, 4), (7, 5)],
    LudoSeat.green: [(1, 7), (2, 7), (3, 7), (4, 7), (5, 7)],
    LudoSeat.yellow: [(7, 13), (7, 12), (7, 11), (7, 10), (7, 9)],
    LudoSeat.blue: [(13, 7), (12, 7), (11, 7), (10, 7), (9, 7)],
  };

  static Offset tokenCenter(LudoSeat seat, int tokenIndex, int progress) {
    if (progress == -1) {
      final corners = switch (seat) {
        LudoSeat.red => (1, 1),
        LudoSeat.green => (1, 10),
        LudoSeat.yellow => (10, 10),
        LudoSeat.blue => (10, 1),
      };
      final row = corners.$1 + (tokenIndex ~/ 2) * 2 + 1;
      final col = corners.$2 + (tokenIndex % 2) * 2 + 1;
      return Offset(col + 0.5, row + 0.5);
    }
    if (progress >= LudoGame.homePosition) {
      return const Offset(7.5, 7.5);
    }
    final (int row, int col) = progress <= 50
        ? track[(LudoGame.startingSquares[seat]! + progress) % 52]
        : lanes[seat]![progress - 51];
    return Offset(col + 0.5, row + 0.5);
  }

  void _cell(Canvas canvas, double s, int row, int col, Color color) {
    final rect = Rect.fromLTWH(col * s, row * s, s, s);
    canvas.drawRect(rect, Paint()..color = color);
    canvas.drawRect(rect,
        Paint()..color = const Color(0xFF73869A)
          ..strokeWidth = s * .035
          ..style = PaintingStyle.stroke);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 15;
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    for (final (seat, top, left) in [
      (LudoSeat.red, 0, 0), (LudoSeat.green, 0, 9),
      (LudoSeat.yellow, 9, 9), (LudoSeat.blue, 9, 0),
    ]) {
      canvas.drawRect(Rect.fromLTWH(left * s, top * s, 6 * s, 6 * s),
          Paint()..color = _seatColor(seat));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH((left + .75) * s, (top + .75) * s,
              4.5 * s, 4.5 * s),
          Radius.circular(.3 * s),
        ),
        Paint()..color = Colors.white,
      );
      for (final r in [2, 4]) {
        for (final c in [2, 4]) {
          canvas.drawCircle(
            Offset((left + c + .5) * s, (top + r + .5) * s),
            .41 * s,
            Paint()..color = _seatColor(seat),
          );
        }
      }
    }

    for (int i = 0; i < track.length; i++) {
      final (row, col) = track[i];
      final seat = LudoGame.startingSquares.entries
          .where((entry) => entry.value == i);
      _cell(canvas, s, row, col,
          seat.isEmpty ? Colors.white : _seatColor(seat.first.key));
      if (LudoGame.safeSquares.contains(i) && seat.isEmpty) {
        canvas.drawCircle(Offset((col + .5) * s, (row + .5) * s),
            .16 * s, Paint()..color = const Color(0xFFF4AD33));
      }
    }
    for (final entry in lanes.entries) {
      for (final (row, col) in entry.value) {
        _cell(canvas, s, row, col, _seatColor(entry.key).withValues(alpha: .8));
      }
    }

    // Four winner-lane arrows converge in the shared HOME diamond.
    final center = Offset(7.5 * s, 7.5 * s);
    for (final (seat, a, b) in [
      (LudoSeat.red, Offset(6 * s, 6 * s), Offset(6 * s, 9 * s)),
      (LudoSeat.green, Offset(6 * s, 6 * s), Offset(9 * s, 6 * s)),
      (LudoSeat.yellow, Offset(9 * s, 6 * s), Offset(9 * s, 9 * s)),
      (LudoSeat.blue, Offset(6 * s, 9 * s), Offset(9 * s, 9 * s)),
    ]) {
      final path = Path()..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(center.dx, center.dy)..close();
      canvas.drawPath(path, Paint()..color = _seatColor(seat));
    }
    canvas.drawCircle(center, .38 * s,
        Paint()..color = const Color(0xFFFFF3BE));
    canvas.drawCircle(center, .26 * s,
        Paint()..color = const Color(0xFFEDBB39));

    // Draw only seats in this match. Finished pieces are tracked in the rank UI.
    for (final seat in game.seats) {
      final positions = game.pieces[seat]!;
      for (int i = 0; i < positions.length; i++) {
        if (positions[i] == 56) continue;
        final centerCell = tokenCenter(seat, i, positions[i]);
        final overlapping = <int>[
          for (int other = 0; other < positions.length; other++)
            if (positions[other] == positions[i]) other,
        ];
        final overlapIndex = overlapping.indexOf(i);
        final shift = overlapping.length > 1 && positions[i] != -1
            ? Offset((overlapIndex % 2 == 0 ? -.16 : .16) * s,
                (overlapIndex < 2 ? -.16 : .16) * s)
            : Offset.zero;
        final p = Offset(centerCell.dx * s, centerCell.dy * s) + shift;
        canvas.drawCircle(p + Offset(0, .08 * s), .33 * s,
            Paint()..color = const Color(0x77000000));
        canvas.drawCircle(p, .31 * s, Paint()..color = Colors.white);
        canvas.drawCircle(p, .25 * s, Paint()..color = _seatColor(seat));
        canvas.drawCircle(p - Offset(.065 * s, .065 * s), .065 * s,
            Paint()..color = Colors.white.withValues(alpha: .8));
      }
    }
  }

  @override
  bool shouldRepaint(covariant LudoBoardPainter oldDelegate) => true;
}
