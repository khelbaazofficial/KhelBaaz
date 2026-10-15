import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ludo_game.dart';
import 'ludo_match_hud.dart';
import 'ludo_rules_page.dart';

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

// ==================================================
// KHELBAAZ LUDO USER HOME
// FIREBASE ADMIN TABLES + LOCAL DEMO
// ==================================================

class LudoHubPage extends StatelessWidget {
  const LudoHubPage({super.key});

  static const Color _gold =
      Color(0xFFFFC43D);

  static const Color _red =
      Color(0xFFE83351);

  // ================================================
  // FIREBASE TABLE CARD
  // ================================================

  Widget _firebaseTableCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    final tableName =
        (data['name'] ?? 'KhelBaaz Ludo')
            .toString();

    final entryCredits =
        data['entryCredits'] ?? 0;

    final rewards =
        data['rewards'] is List
            ? List<dynamic>.from(
                data['rewards'] as List,
              )
            : <dynamic>[];

    final firstReward =
        rewards.isNotEmpty
            ? rewards[0]
            : 0;

    final secondReward =
        rewards.length > 1
            ? rewards[1]
            : 0;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: _panel,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: _gold,
          width: 1.5,
        ),

        boxShadow: const [
          BoxShadow(
            color: Color(0x22FFC43D),
            blurRadius: 10,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 55,
                height: 55,

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(13),
                ),

                child: const Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: _red,
                    ),

                    SizedBox(width: 5),

                    CircleAvatar(
                      radius: 11,
                      backgroundColor: _gold,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      tableName,

                      maxLines: 2,

                      overflow:
                          TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      '👥 2 PLAYER • RED vs YELLOW',

                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Divider(
            color: Colors.white24,
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                color: Colors.white70,
                size: 19,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  'Demo Entry: $entryCredits Credits',

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const Text(
                '● ENABLED',

                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            padding:
                const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color:
                  const Color(0xFF1A3655),

              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      '🥇',
                      style: TextStyle(
                        fontSize: 21,
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Expanded(
                      child: Text(
                        '1st Winner',

                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    Text(
                      '$firstReward Credits',

                      style: const TextStyle(
                        color: _gold,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Text(
                      '🥈',
                      style: TextStyle(
                        fontSize: 21,
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Expanded(
                      child: Text(
                        '2nd Position',

                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    Text(
                      '$secondReward Credits',

                      style: const TextStyle(
                        color: _gold,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,

            padding:
                const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 10,
            ),

            decoration: BoxDecoration(
              color:
                  const Color(0xFF32445D),

              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: const Text(
              '🔒 ONLINE JOINING • NEXT UPDATE',

              textAlign: TextAlign.center,

              style: TextStyle(
                color: _gold,
                fontSize: 12,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================
  // FIREBASE TABLE LIST
  // ================================================

  Widget _firebaseTablesList() {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('ludo_tables')
          .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            padding:
                const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: _panel,

              borderRadius:
                  BorderRadius.circular(15),

              border: Border.all(
                color: Colors.redAccent,
              ),
            ),

            child: Text(
              'Firebase Tables लोड नहीं हुईं।\n'
              '${snapshot.error}',

              textAlign: TextAlign.center,

              style: const TextStyle(
                color: Colors.redAccent,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(25),

            child: Center(
              child:
                  CircularProgressIndicator(
                color: _gold,
              ),
            ),
          );
        }

        // Only enabled 2-player tables
        // are displayed to users.

        final tables =
            snapshot.data!.docs.where(
          (doc) {
            final data = doc.data();

            return data['enabled'] == true &&
                data['playerCount'] == 2;
          },
        ).toList();

        if (tables.isEmpty) {
          return Container(
            width: double.infinity,

            padding:
                const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color: _panel,

              borderRadius:
                  BorderRadius.circular(18),

              border: Border.all(
                color: Colors.white24,
              ),
            ),

            child: const Column(
              children: [
                Text(
                  '🎲',
                  style: TextStyle(
                    fontSize: 48,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  'अभी कोई Ludo Table उपलब्ध नहीं है।',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Admin से Enabled 2 Player Table '
                  'बनाने के बाद यहाँ दिखाई देगी।',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              '${tables.length} Tables Available',

              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 13,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            for (final table in tables)
              _firebaseTableCard(table),
          ],
        );
      },
    );
  }

  // ================================================
  // MAIN LUDO HOME
  // ================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _night,

      appBar: AppBar(
        backgroundColor: _night,

        foregroundColor: Colors.white,

        title: const Text(
          'KhelBaaz Ludo',
        ),

        actions: [
          IconButton(
            tooltip: 'Classic Rules',

            icon: const Icon(
              Icons.menu_book_rounded,
            ),

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) =>
                      const LudoRulesPage(),
                ),
              );
            },
          ),
        ],
      ),

      body: Container(
        decoration:
            const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A2444),
              _night,
              Color(0xFF261640),
            ],

            begin: Alignment.topLeft,

            end: Alignment.bottomRight,
          ),
        ),

        child: ListView(
          padding:
              const EdgeInsets.all(18),

          children: [

            // ==============================
            // HEADER
            // ==============================

            Container(
              padding:
                  const EdgeInsets.all(23),

              decoration: BoxDecoration(
                color: _panel,

                borderRadius:
                    BorderRadius.circular(23),

                border: Border.all(
                  color: Colors.white24,
                ),
              ),

              child: const Column(
                children: [
                  Text(
                    '🎲',
                    style: TextStyle(
                      fontSize: 58,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'KHELBAAZ LUDO',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),

                  SizedBox(height: 9),

                  Text(
                    '2 Player • Red vs Yellow',

                    style: TextStyle(
                      color: _gold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ==============================
            // FIREBASE ADMIN TABLES
            // ==============================

            const Text(
              '🏆 ADMIN LUDO TABLES',

              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Admin द्वारा बनाई गई '
              '2 Player Tables',

              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 15),

            _firebaseTablesList(),

            const SizedBox(height: 25),

            // ==============================
            // LOCAL DEMO
            // ==============================

            const Text(
              '🎮 LOCAL DEMO',

              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(height: 12),

            _TablePreviewCard(
              players: 2,

              subtitle:
                  'Red vs Yellow • Practice Game',

              colors: const [
                _red,
                _gold,
              ],
            ),

            const SizedBox(height: 16),

            // ==============================
            // 4 PLAYER FUTURE UPDATE
            // ==============================

            Container(
              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color:
                    const Color(0xFF172642),

                borderRadius:
                    BorderRadius.circular(18),

                border: Border.all(
                  color:
                      const Color(0xFF8066A9),
                ),
              ),

              child: const Row(
                children: [
                  Text(
                    '🔒',
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          '4 PLAYER MULTIPLAYER',

                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Future Update • Coming Soon',

                          style: TextStyle(
                            color: _gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
          '🎲 KhelBaaz Ludo में Admin की Firebase Tables दिखाई देंगी। '
          'अभी Online Joining और Live Multiplayer चालू नहीं हैं। '
          'Local Demo इसी फोन पर खेल सकते हैं। '
          'Cricket या Ludo Wallet से कोई पैसा या क्रेडिट नहीं कटेगा।',
          style: TextStyle(
            color: Colors.white,
            height: 1.5,
          ),
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

  Timer? _moveTimer;

  LudoSeat? _movingSeat;
  int? _movingToken;
  int? _movingProgress;

  @override
  void initState() {
    super.initState();

    game = LudoGame(
      playerCount: widget.playerCount,
    );
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    super.dispose();
  }

    void _roll() {
    if (_movingSeat != null) {
      return;
    }

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
    if (_movingSeat != null ||
        !game.movablePieces.contains(index)) {
      return;
    }

    final seat = game.currentSeat;

    final oldPosition =
        game.pieces[seat]![index];

    final dice = game.pendingDice!;

    final targetPosition =
        oldPosition == -1
            ? 0
            : oldPosition + dice;

    setState(() {
      _movingSeat = seat;
      _movingToken = index;
      _movingProgress = oldPosition;

      message =
          '${_seatName(seat)} की गोटी चल रही है...';
    });

    _moveTimer?.cancel();

    _moveTimer = Timer.periodic(
      const Duration(milliseconds: 170),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        final nextPosition =
            _movingProgress! + 1;

        if (nextPosition < targetPosition) {
          setState(() {
            _movingProgress = nextPosition;
          });
          return;
        }

        timer.cancel();
        _moveTimer = null;

        setState(() {
          final result = game.move(index);

          _movingSeat = null;
          _movingToken = null;
          _movingProgress = null;

          if (result.completedSeat) {
            message =
                '${_seatName(seat)} को '
                '${game.rankingOf(seat)} स्थान मिला!';
          } else if (result.captured) {
            message =
                '${_seatName(seat)} ने गोटी काटी '
                '• एक्स्ट्रा बारी';
          } else {
            message =
                'अगली बारी: '
                '${_seatName(game.currentSeat)}';
          }

          if (result.gameOver) {
            message =
                '🏆 सभी खिलाड़ियों की रैंक तय हो गई!';
          }
        });
      },
    );
    }

    void _tapBoard(
    Offset localPosition,
    double boardWidth,
  ) {
    if (_movingSeat != null ||
        game.pendingDice == null) {
      return;
    }
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
            tooltip: 'Classic Rules',
            icon: const Icon(Icons.menu_book_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LudoRulesPage(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Restart demo',
            icon: const Icon(Icons.refresh),
                        onPressed: () {
              _moveTimer?.cancel();
              _moveTimer = null;

              setState(() {
                _movingSeat = null;
                _movingToken = null;
                _movingProgress = null;

                game = LudoGame(
                  playerCount: widget.playerCount,
                );

                lastDice = null;
                message = 'नया गेम • पासा फेंकें';
              });
            },
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
                                            painter: LudoBoardPainter(
                        game,
                        movingSeat: _movingSeat,
                        movingToken: _movingToken,
                        movingProgress: _movingProgress,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
                    const SizedBox(height: 10),

          if (widget.playerCount == 2) ...[
            LudoMatchHud(
              game: game,
              diceValue: lastDice,
                            canRoll: !game.isFinished &&
                  game.pendingDice == null &&
                  _movingSeat == null,
              onRoll: _roll,
            ),
            const SizedBox(height: 12),
          ],
          Text(message, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white,
                  fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
                    if (widget.playerCount != 2 &&
              !game.isFinished &&
              game.pendingDice == null)
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

  final LudoSeat? movingSeat;
  final int? movingToken;
  final int? movingProgress;

  LudoBoardPainter(
    this.game, {
    this.movingSeat,
    this.movingToken,
    this.movingProgress,
  });

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
  // ===== PREMIUM 3D LUDO TOKEN =====

  void _drawPremiumPawn(
    Canvas canvas,
    Offset p,
    double s,
    Color color, {
    required bool isActive,
  }) {

    // Ground shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(p.dx, p.dy + .28 * s),
        width: .65 * s,
        height: .16 * s,
      ),
      Paint()
        ..color = const Color(0x66000000),
    );

    // Token body
    final body = Path()
      ..moveTo(p.dx - .13 * s, p.dy - .08 * s)
      ..quadraticBezierTo(
        p.dx - .15 * s,
        p.dy + .04 * s,
        p.dx - .25 * s,
        p.dy + .22 * s,
      )
      ..quadraticBezierTo(
        p.dx,
        p.dy + .30 * s,
        p.dx + .25 * s,
        p.dy + .22 * s,
      )
      ..quadraticBezierTo(
        p.dx + .15 * s,
        p.dy + .04 * s,
        p.dx + .13 * s,
        p.dy - .08 * s,
      )
      ..close();

    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, .55)!,
            color,
            Color.lerp(color, Colors.black, .40)!,
          ],
        ).createShader(body.getBounds()),
    );

    // Bottom base
    final base = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(p.dx, p.dy + .24 * s),
        width: .62 * s,
        height: .15 * s,
      ),
      Radius.circular(.07 * s),
    );

    canvas.drawRRect(
      base,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Color.lerp(color, Colors.white, .45)!,
            color,
            Color.lerp(color, Colors.black, .35)!,
          ],
        ).createShader(base.outerRect),
    );

    // Round glossy head
    final head = Offset(
      p.dx,
      p.dy - .18 * s,
    );

    final headRect = Rect.fromCircle(
      center: head,
      radius: .19 * s,
    );

    canvas.drawCircle(
      head,
      .19 * s,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.4, -.5),
          colors: [
            Color.lerp(color, Colors.white, .65)!,
            color,
            Color.lerp(color, Colors.black, .30)!,
          ],
        ).createShader(headRect),
    );

    // Head shine
    canvas.drawCircle(
      Offset(
        head.dx - .055 * s,
        head.dy - .065 * s,
      ),
      .055 * s,
      Paint()
        ..color = Colors.white.withValues(alpha: .75),
    );

    // Active token highlight
    if (isActive) {
      canvas.drawCircle(
        p,
        .43 * s,
        Paint()
          ..color = const Color(0xFFFFD54F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .05 * s,
      );
    }
  }

  // ===== SAFE ZONE STAR =====

  void _drawSafeStar(
    Canvas canvas,
    Offset center,
    double radius,
  ) {
    final star = Path();

    for (int i = 0; i < 10; i++) {
      final angle = -pi / 2 + i * pi / 5;

      final distance =
          i.isEven ? radius : radius * .45;

      final x = center.dx + cos(angle) * distance;
      final y = center.dy + sin(angle) * distance;

      if (i == 0) {
        star.moveTo(x, y);
      } else {
        star.lineTo(x, y);
      }
    }

    star.close();

    canvas.drawPath(
      star,
      Paint()
        ..color = const Color(0xFFFFD54F),
    );

    canvas.drawPath(
      star,
      Paint()
        ..color = const Color(0xFF8A651A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * .12,
    );
  }
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 15;
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    for (final (seat, top, left) in [
      (LudoSeat.red, 0, 0), (LudoSeat.green, 0, 9),
      (LudoSeat.yellow, 9, 9), (LudoSeat.blue, 9, 0),
    ]) {
            final homeRect = Rect.fromLTWH(
        left * s,
        top * s,
        6 * s,
        6 * s,
      );

      final homeColor = _seatColor(seat);

      canvas.drawRect(
        homeRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(
                homeColor,
                Colors.white,
                .25,
              )!,
              homeColor,
              Color.lerp(
                homeColor,
                Colors.black,
                .15,
              )!,
            ],
          ).createShader(homeRect),
      );
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
            if (LudoGame.safeSquares.contains(i) &&
          seat.isEmpty) {
        _drawSafeStar(
          canvas,
          Offset(
            (col + .5) * s,
            (row + .5) * s,
          ),
          .34 * s,
        );
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

        // Animated premium Ludo tokens
    for (final seat in game.seats) {
      final positions = game.pieces[seat]!;

      for (int i = 0; i < positions.length; i++) {
        final isMoving =
            movingSeat == seat &&
            movingToken == i &&
            movingProgress != null;

        final progress =
            isMoving ? movingProgress! : positions[i];

        if (progress == LudoGame.homePosition) {
          continue;
        }

        final centerCell = tokenCenter(
          seat,
          i,
          progress,
        );

        final overlapping = <int>[
          for (int other = 0;
              other < positions.length;
              other++)
            if (positions[other] == progress)
              other,
        ];

        final overlapIndex =
            overlapping.indexOf(i);

        final shift =
            !isMoving &&
                    overlapping.length > 1 &&
                    progress != -1
                ? Offset(
                    (overlapIndex % 2 == 0
                            ? -.16
                            : .16) *
                        s,
                    (overlapIndex < 2
                            ? -.16
                            : .16) *
                        s,
                  )
                : Offset.zero;

        final p = Offset(
              centerCell.dx * s,
              centerCell.dy * s,
            ) +
            shift;

        _drawPremiumPawn(
          canvas,
          p,
          s,
          _seatColor(seat),
          isActive: isMoving ||
              (game.currentSeat == seat &&
                  game.pendingDice != null &&
                  game.movablePieces.contains(i)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant LudoBoardPainter oldDelegate) => true;
}
