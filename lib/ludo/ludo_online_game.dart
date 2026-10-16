import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ludo_game.dart';
import 'ludo_screen.dart';

// Online 2-player DEMO. Client-side dice/rules are NOT authoritative.
// No shared wallet, charges, or winning payouts.
class LudoOnlineGamePage extends StatefulWidget {
  const LudoOnlineGamePage({
    super.key,
    required this.roomId,
    required this.tableName,
  });

  final String roomId;
  final String tableName;

  @override
  State<LudoOnlineGamePage> createState() => _LudoOnlineGamePageState();
}

class _LudoOnlineGamePageState extends State<LudoOnlineGamePage> {
  static const _bg = Color(0xFF07172C);
  static const _red = Color(0xFFE83351);
  static const _yellow = Color(0xFFFFC43D);
  final _random = Random.secure();
  bool _busy = false;
  String? _error;

  DocumentReference<Map<String, dynamic>> get _roomRef =>
      FirebaseFirestore.instance.collection('ludo_rooms').doc(widget.roomId);

  DocumentReference<Map<String, dynamic>> get _stateRef =>
      _roomRef.collection('game').doc('state');

  @override
  void initState() {
    super.initState();
    _createGameIfHost();
  }

  Future<void> _createGameIfHost() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final room = await tx.get(_roomRef);
        final r = room.data();
        if (r == null || r['status'] != 'ready' || r['hostUid'] != uid) {
          return;
        }
        final state = await tx.get(_stateRef);
        if (!state.exists) {
          tx.set(_stateRef, {
            ...LudoGame(playerCount: 2).toOnlineMap(),
            'revision': 0,
            'lastDice': 0,
            'lastAction': 'start',
            'updatedBy': uid,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      if (mounted) setState(() => _error = 'Game start error: $e');
    }
  }

  Future<void> _action({int? token}) async {
    if (_busy) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final room = await tx.get(_roomRef);
        final state = await tx.get(_stateRef);
        final r = room.data();
        final d = state.data();
        if (r == null || d == null || r['status'] != 'ready') {
          throw StateError('Room तैयार नहीं है');
        }
        final game = LudoGame.fromOnlineMap(d);
        final expectedUid = game.currentSeat == LudoSeat.red
            ? r['hostUid']
            : r['guestUid'];
        if (uid != expectedUid || game.isFinished) {
          throw StateError('अभी आपकी बारी नहीं है');
        }
        final int lastDice;
        final String action;
        if (token == null) {
          if (game.pendingDice != null) {
            throw StateError('पहले गोटी चुनें');
          }
          lastDice = _random.nextInt(6) + 1;
          game.roll(lastDice);
          action = 'roll';
        } else {
          if (!game.movablePieces.contains(token)) {
            throw StateError('यह गोटी नहीं चल सकती');
          }
          game.move(token);
          lastDice = (d['lastDice'] as int?) ?? 0;
          action = 'move';
        }
        tx.update(_stateRef, {
          ...game.toOnlineMap(),
          'revision': ((d['revision'] as int?) ?? 0) + 1,
          'lastDice': lastDice,
          'lastAction': action,
          'updatedBy': uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          final message = e.toString();
          _error = message.contains('unavailable') ||
                  message.contains('deadline-exceeded')
              ? '⚠️ इंटरनेट / Firebase कनेक्शन नहीं है। नेटवर्क जाँचें और दोबारा कोशिश करें।'
              : message;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _tapToken(LudoGame game, bool mine, Offset point, double width) {
    if (!mine || _busy || game.pendingDice == null) return;
    int? selected;
    double nearest = width * .7 / 15;
    for (final i in game.movablePieces) {
      final p = LudoBoardPainter.tokenCenter(
        game.currentSeat, i, game.pieces[game.currentSeat]![i]);
      final dist = (Offset(p.dx * width / 15, p.dy * width / 15) - point).distance;
      if (dist < nearest) {
        nearest = dist;
        selected = i;
      }
    }
    if (selected != null) _action(token: selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061E4A),
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 48,
        backgroundColor: const Color(0xFF062653),
        foregroundColor: Colors.white,
        title: Text(
          'KHELBAAZ LUDO  •  ${widget.tableName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: _LudoBackdropPainter()),
          SafeArea(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _roomRef.snapshots(),
              builder: (context, roomSnap) {
                if (roomSnap.hasError) {
                  return _info('Room error: ${roomSnap.error}');
                }
                if (!roomSnap.hasData) return _loading();
                final room = roomSnap.data!.data();
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid == null || room == null || room['status'] != 'ready' ||
                    (uid != room['hostUid'] && uid != room['guestUid'])) {
                  return _info('यह गेम आपके लिए उपलब्ध नहीं है।');
                }

                final mySeat = uid == room['hostUid']
                    ? LudoSeat.red
                    : LudoSeat.yellow;

                return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _stateRef.snapshots(),
                  builder: (context, stateSnap) {
                    if (stateSnap.hasError) {
                      return _info('Game error: ${stateSnap.error}');
                    }
                    if (!stateSnap.hasData) return _loading();
                    final d = stateSnap.data!.data();
                    if (d == null) return _info('होस्ट गेम शुरू कर रहा है...');

                    late final LudoGame game;
                    try {
                      game = LudoGame.fromOnlineMap(d);
                    } catch (e) {
                      return _info('Game data error: $e');
                    }

                    final mine = !game.isFinished && game.currentSeat == mySeat;
                    final lastDice = (d['lastDice'] as int?) ?? 0;
                    final revision = (d['revision'] as int?) ?? 0;
                    final lastAction = (d['lastAction'] ?? '').toString();
                    final updatedBy = (d['updatedBy'] ?? '').toString();
                    final lastMover = updatedBy == room['hostUid']
                        ? LudoSeat.red
                        : updatedBy == room['guestUid']
                            ? LudoSeat.yellow
                            : null;
                    final redTurn = game.currentSeat == LudoSeat.red;
                    final activeColor = redTurn ? _red : _yellow;
                    final hostName = (room['hostName'] ?? 'RED PLAYER').toString();
                    final guestName = (room['guestName'] ?? 'YELLOW PLAYER').toString();

                    final String instruction;
                    if (game.isFinished) {
                      instruction = '🏆 GAME COMPLETE  •  नीचे रैंकिंग देखें';
                    } else if (mine && game.pendingDice != null) {
                      instruction = '👆 आपकी बारी  •  अपनी चमकती गोटी दबाएँ';
                    } else if (mine) {
                      instruction = '🎲 YOUR TURN  •  नीचे बीच में पासा दबाएँ';
                    } else {
                      instruction = '⏳ ${redTurn ? 'RED' : 'YELLOW'} की बारी  •  इंतजार करें';
                    }

                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(8, 7, 8, 7),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xE7062553),
                            border: Border.all(
                              color: activeColor.withValues(alpha: 0.95),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            instruction,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),

                        // Board FIRST; all player controls are fixed at bottom.
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
                            children: [
                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 600,
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Container(
                                      padding: const EdgeInsets.all(2.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEDAD),
                                        border: Border.all(
                                          color: const Color(0xFFFAE7A5),
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0xAA000B20),
                                            blurRadius: 13,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return _AnimatedOnlineLudoBoard(
                                            game: game,
                                            revision: revision,
                                            lastAction: lastAction,
                                            lastMover: lastMover,
                                            onTokenTap: (offset) => _tapToken(
                                              game,
                                              mine,
                                              offset,
                                              constraints.maxWidth,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 9),
                              if (game.pendingDice != null) ...[
                                Text(
                                  mine
                                      ? '✦ बोर्ड पर गोटी दबाएँ  •  ${game.pendingDice} कदम'
                                      : 'दूसरा खिलाड़ी गोटी चलाएगा',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFFFE48A),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                // Optional accessible token buttons for small screens.
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 6,
                                  runSpacing: 2,
                                  children: [
                                    for (final i in game.movablePieces)
                                      OutlinedButton(
                                        onPressed: mine && !_busy
                                            ? () => _action(token: i)
                                            : null,
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: const Color(0xCC173B72),
                                          minimumSize: const Size(64, 32),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 9,
                                            vertical: 1,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        child: Text('गोटी ${i + 1}'),
                                      ),
                                  ],
                                ),
                              ],
                              if (lastDice > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    '🎲 पिछला पासा: $lastDice',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              if (_busy)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                ),
                              if (_error != null)
                                Padding(
                                  padding: const EdgeInsets.all(7),
                                  child: Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFFF9898),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 9),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xE30C3772),
                                  border: Border.all(
                                    color: const Color(0xFF78B4EA),
                                  ),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(
                                  '🏆  RED ${game.pieces[LudoSeat.red]!.where((p) => p == 56).length}/4'
                                  '    •    YELLOW ${game.pieces[LudoSeat.yellow]!.where((p) => p == 56).length}/4'
                                  '  HOME',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              if (game.isFinished) ...[
                                const SizedBox(height: 8),
                                for (final seat in [LudoSeat.red, LudoSeat.yellow])
                                  Padding(
                                    padding: const EdgeInsets.all(3),
                                    child: Text(
                                      '${seat == LudoSeat.red ? '🔴 RED' : '🟡 YELLOW'}'
                                      '  •  Rank ${game.rankingOf(seat) ?? '-'}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                              const SizedBox(height: 8),
                              const Text(
                                'ONLINE DEMO  •  NO WALLET TRANSACTIONS',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Video-inspired placement: RED | CENTER DIE | YELLOW
                        // Die is single, interactive only for current user.
                        Container(
                          padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0B4389), Color(0xFF061C4D)],
                            ),
                            border: Border(
                              top: BorderSide(
                                color: Color(0xFFFFD455),
                                width: 2.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _BottomPlayerCard(
                                  name: hostName,
                                  seatName: 'RED',
                                  seatColor: _red,
                                  isYou: mySeat == LudoSeat.red,
                                  active: !game.isFinished && redTurn,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _LiveDiceButton(
                                    enabled: mine &&
                                        game.pendingDice == null &&
                                        !_busy,
                                    active: mine,
                                    value: lastDice,
                                    revision: revision,
                                    lastAction: lastAction,
                                    isLastActor: lastAction == 'roll',
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      _action();
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mine
                                        ? game.pendingDice == null
                                            ? 'TAP DICE'
                                            : 'MOVE'
                                        : 'WAIT',
                                    style: TextStyle(
                                      color: mine
                                          ? const Color(0xFFFFDB62)
                                          : Colors.white60,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: _BottomPlayerCard(
                                  name: guestName,
                                  seatName: 'YELLOW',
                                  seatColor: _yellow,
                                  isYou: mySeat == LudoSeat.yellow,
                                  active: !game.isFinished && !redTurn,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _loading() => const Center(child: CircularProgressIndicator());

  Widget _info(String msg) => Center(child: Padding(
        padding: const EdgeInsets.all(25),
        child: Text(msg, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70)),
      ));
}

// ============================================================
// KHELBAAZ LUDO • VISUAL DICE, ONLINE TEST MODE
// Inspired by familiar classic Ludo controls; original KhelBaaz UI.
// Rolling is only a visual effect. Firebase stores the actual result.
// ============================================================

class _BottomPlayerCard extends StatelessWidget {
  const _BottomPlayerCard({
    required this.name,
    required this.seatName,
    required this.seatColor,
    required this.isYou,
    required this.active,
  });

  final String name;
  final String seatName;
  final Color seatColor;
  final bool isYou;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 87,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? seatColor.withValues(alpha: 0.24)
            : const Color(0xFF092B62),
        border: Border.all(
          color: active ? seatColor : const Color(0xFF6794D2),
          width: active ? 2.1 : 1,
        ),
        borderRadius: BorderRadius.circular(9),
        boxShadow: active
            ? [
                BoxShadow(
                  color: seatColor.withValues(alpha: 0.27),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: seatColor,
            child: Icon(
              Icons.person_rounded,
              size: 22,
              color: seatName == 'YELLOW'
                  ? const Color(0xFF1C1E24)
                  : Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          Text(
            '$seatName${isYou ? '  •  YOU' : ''}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: seatColor,
              fontWeight: FontWeight.w800,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveDiceButton extends StatefulWidget {
  const _LiveDiceButton({
    required this.enabled,
    required this.active,
    required this.value,
    required this.revision,
    required this.lastAction,
    required this.isLastActor,
    required this.onTap,
  });

  final bool enabled;
  final bool active;
  final int value;
  final int revision;
  final String lastAction;
  final bool isLastActor;
  final VoidCallback onTap;

  @override
  State<_LiveDiceButton> createState() => _LiveDiceButtonState();
}

class _LiveDiceButtonState extends State<_LiveDiceButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rollAnimation;

  @override
  void initState() {
    super.initState();
    _rollAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
  }

  @override
  void didUpdateWidget(covariant _LiveDiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // An online dice roll also animates on the opponent's phone.
    if (widget.revision != oldWidget.revision &&
        widget.lastAction == 'roll' &&
        widget.isLastActor) {
      _rollAnimation.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _rollAnimation.dispose();
    super.dispose();
  }

  void _tap() {
    if (!widget.enabled) return;
    _rollAnimation.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.enabled
          ? 'पासा फेंकने के लिए यहाँ दबाएँ'
          : 'अभी आप पासा नहीं फेंक सकते',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.enabled ? _tap : null,
          borderRadius: BorderRadius.circular(15),
          child: AnimatedBuilder(
            animation: _rollAnimation,
            builder: (context, child) {
              final t = _rollAnimation.value;
              final spinning = _rollAnimation.isAnimating;
              final face = spinning
                  ? 1 + ((t * 32).floor() % 6)
                  : (widget.value >= 1 && widget.value <= 6
                      ? widget.value
                      : 6);
              return Transform.rotate(
                angle: spinning ? sin(t * pi * 10) * 0.30 : 0,
                child: Transform.scale(
                  scale: spinning ? 1 + 0.13 * sin(t * pi) : 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 66,
                    height: 66,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFF3F5F9),
                          Color(0xFFC2CBD6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: widget.enabled
                            ? const Color(0xFFFFD66B)
                            : const Color(0xFF99A7B4),
                        width: widget.enabled ? 3 : 1.6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          offset: const Offset(2, 4),
                          blurRadius: 5,
                        ),
                        if (widget.enabled)
                          BoxShadow(
                            color: const Color(0xFFFFD56B)
                                .withValues(alpha: 0.78),
                            blurRadius: 20,
                            spreadRadius: 3,
                          ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: _DicePipsPainter(face),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DicePipsPainter extends CustomPainter {
  const _DicePipsPainter(this.number);

  final int number;

  @override
  void paint(Canvas canvas, Size size) {
    const tl = Offset(0.22, 0.22);
    const tr = Offset(0.78, 0.22);
    const ml = Offset(0.22, 0.50);
    const mr = Offset(0.78, 0.50);
    const bl = Offset(0.22, 0.78);
    const br = Offset(0.78, 0.78);
    const mid = Offset(0.50, 0.50);

    final points = switch (number) {
      1 => [mid],
      2 => [tl, br],
      3 => [tl, mid, br],
      4 => [tl, tr, bl, br],
      5 => [tl, tr, mid, bl, br],
      _ => [tl, tr, ml, mr, bl, br],
    };

    final radius = size.shortestSide * 0.088;
    final shadow = Paint()..color = const Color(0xFF81909E);
    final dark = Paint()..color = const Color(0xFF161F29);
    final shine = Paint()..color = const Color(0xFF485360);

    for (final p in points) {
      final pos = Offset(size.width * p.dx, size.height * p.dy);
      canvas.drawCircle(pos + const Offset(0.7, 1.1), radius, shadow);
      canvas.drawCircle(pos, radius, dark);
      canvas.drawCircle(
        pos - Offset(radius * .22, radius * .22),
        radius * 0.38,
        shine,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DicePipsPainter oldDelegate) =>
      number != oldDelegate.number;
}


// =============================================================
// KHELBAAZ CLASSIC BOARD - ONLINE VISUALS ONLY
// No changes to movement rules, Firestore schema, or transactions.
// =============================================================

class _AnimatedOnlineLudoBoard extends StatefulWidget {
  const _AnimatedOnlineLudoBoard({
    required this.game,
    required this.revision,
    required this.lastAction,
    required this.lastMover,
    required this.onTokenTap,
  });

  final LudoGame game;
  final int revision;
  final String lastAction;
  final LudoSeat? lastMover;
  final ValueChanged<Offset> onTokenTap;

  @override
  State<_AnimatedOnlineLudoBoard> createState() =>
      _AnimatedOnlineLudoBoardState();
}

class _AnimatedOnlineLudoBoardState extends State<_AnimatedOnlineLudoBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _steps;
  LudoSeat? _movingSeat;
  int? _movingToken;
  int _from = 0;
  int _to = 0;
  int _lastSoundStep = 0;

  @override
  void initState() {
    super.initState();
    _steps = AnimationController(vsync: this)
      ..addListener(() {
        if (!_steps.isAnimating || _movingToken == null) return;
        final total = (_to - (_from < 0 ? 0 : _from)).clamp(1, 6).toInt();
        final step = (_steps.value * total).floor();
        if (step > _lastSoundStep) {
          _lastSoundStep = step;
          SystemSound.play(SystemSoundType.click);
        }
      });
  }

  @override
  void didUpdateWidget(covariant _AnimatedOnlineLudoBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.revision == oldWidget.revision) return;

    _movingSeat = null;
    _movingToken = null;
    _lastSoundStep = 0;
    _steps.stop();
    _steps.reset();

    if (widget.lastAction != 'move' || widget.lastMover == null) return;

    final seat = widget.lastMover!;
    final previous = oldWidget.game.pieces[seat];
    final current = widget.game.pieces[seat];
    if (previous == null || current == null) return;
    for (var i = 0; i < 4; i++) {
      if (previous[i] < current[i] && current[i] <= 56) {
        _movingSeat = seat;
        _movingToken = i;
        _from = previous[i];
        _to = current[i];
        final spaces = (_to - (_from < 0 ? 0 : _from)).clamp(1, 6).toInt();
        _steps.duration = Duration(milliseconds: 130 * spaces + 150);
        _steps.forward(from: 0);
        break;
      }
    }
  }

  @override
  void dispose() {
    _steps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _steps,
      builder: (context, child) {
        int? progress;
        if (_movingToken != null && _steps.value < 1) {
          if (_from == -1) {
            progress = _steps.value < .48 ? -1 : 0;
          } else {
            final count = _to - _from;
            final advanced = (_steps.value * (count + .999)).floor();
            progress = (_from + advanced).clamp(_from, _to).toInt();
          }
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                if (_steps.isAnimating) return;
                widget.onTokenTap(details.localPosition);
              },
              child: CustomPaint(
                size: Size.square(constraints.maxWidth),
                painter: _KhelBaazOnlineBoardPainter(
                  widget.game,
                  movingSeat: progress == null ? null : _movingSeat,
                  movingToken: progress == null ? null : _movingToken,
                  movingProgress: progress,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _KhelBaazOnlineBoardPainter extends CustomPainter {
  _KhelBaazOnlineBoardPainter(
    this.game, {
    this.movingSeat,
    this.movingToken,
    this.movingProgress,
  });

  final LudoGame game;
  final LudoSeat? movingSeat;
  final int? movingToken;
  final int? movingProgress;

  static const _red = Color(0xFFF32237);
  static const _green = Color(0xFF08B665);
  static const _blue = Color(0xFF208BE6);
  static const _yellow = Color(0xFFFFD02E);
  static const _grid = Color(0xFF637582);

  Color _color(LudoSeat seat) => switch (seat) {
        LudoSeat.red => _red,
        LudoSeat.green => _green,
        LudoSeat.yellow => _yellow,
        LudoSeat.blue => _blue,
      };

  void _cell(Canvas canvas, double s, int row, int col, Color color) {
    final rect = Rect.fromLTWH(col * s, row * s, s, s);
    canvas.drawRect(rect, Paint()..color = color);
    canvas.drawRect(
      rect,
      Paint()
        ..color = _grid
        ..strokeWidth = s * .025
        ..style = PaintingStyle.stroke,
    );
  }

  void _star(Canvas canvas, Offset center, double radius) {
    final p = Path();
    for (var i = 0; i < 10; i++) {
      final a = -pi / 2 + i * pi / 5;
      final r = i.isEven ? radius : radius * .45;
      final x = center.dx + cos(a) * r;
      final y = center.dy + sin(a) * r;
      if (i == 0) {
        p.moveTo(x, y);
      } else {
        p.lineTo(x, y);
      }
    }
    p.close();
    canvas.drawPath(p, Paint()..color = Colors.white);
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xFF616971)
        ..strokeWidth = radius * .085
        ..style = PaintingStyle.stroke,
    );
  }

  void _arrow(Canvas canvas, Offset p, double s, double radians, Color color) {
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(radians);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = s * .06;
    canvas.drawLine(Offset(-.30 * s, 0), Offset(.26 * s, 0), paint);
    canvas.drawLine(Offset(.07 * s, -.18 * s), Offset(.26 * s, 0), paint);
    canvas.drawLine(Offset(.07 * s, .18 * s), Offset(.26 * s, 0), paint);
    canvas.restore();
  }

  void _pawn(Canvas canvas, Offset p, double s, Color color, bool active) {
    if (active) {
      canvas.drawCircle(
        p,
        s * .47,
        Paint()..color = const Color(0x66FFEA7D),
      );
      canvas.drawCircle(
        p,
        s * .43,
        Paint()
          ..color = const Color(0xFFFFC92F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * .065,
      );
    }

    canvas.drawOval(
      Rect.fromCenter(
        center: p + Offset(0, .30 * s),
        width: .77 * s,
        height: .19 * s,
      ),
      Paint()..color = const Color(0x65000000),
    );

    final rim = Rect.fromCenter(
      center: p + Offset(0, .26 * s),
      width: .65 * s,
      height: .20 * s,
    );
    canvas.drawOval(
      rim,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Color.lerp(color, Colors.white, .65)!,
            color,
            Color.lerp(color, Colors.black, .55)!,
          ],
        ).createShader(rim),
    );

    final shape = Path()
      ..moveTo(p.dx - .19 * s, p.dy - .11 * s)
      ..cubicTo(
        p.dx - .36 * s, p.dy + .03 * s,
        p.dx - .23 * s, p.dy + .18 * s,
        p.dx - .23 * s, p.dy + .21 * s,
      )
      ..quadraticBezierTo(p.dx, p.dy + .31 * s, p.dx + .23 * s, p.dy + .21 * s)
      ..cubicTo(
        p.dx + .23 * s, p.dy + .13 * s,
        p.dx + .35 * s, p.dy - .01 * s,
        p.dx + .19 * s, p.dy - .11 * s,
      )
      ..close();
    canvas.drawPath(
      shape,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, .70)!,
            color,
            Color.lerp(color, Colors.black, .48)!,
          ],
        ).createShader(shape.getBounds()),
    );

    final head = p + Offset(0, -.15 * s);
    final face = Rect.fromCircle(center: head, radius: .205 * s);
    canvas.drawCircle(
      head,
      .205 * s,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.42, -.5),
          radius: .92,
          colors: [
            Color.lerp(color, Colors.white, .82)!,
            color,
            Color.lerp(color, Colors.black, .50)!,
          ],
        ).createShader(face),
    );
    canvas.drawCircle(
      head + Offset(-.055 * s, -.07 * s),
      .055 * s,
      Paint()..color = const Color(0xCFFFFFFF),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 15;
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    // Saturated classic quadrants with a bright inset tray and four bases.
    for (final (seat, top, left) in [
      (LudoSeat.red, 0, 0),
      (LudoSeat.green, 0, 9),
      (LudoSeat.blue, 9, 0),
      (LudoSeat.yellow, 9, 9),
    ]) {
      final c = _color(seat);
      final rect = Rect.fromLTWH(left * s, top * s, 6 * s, 6 * s);
      canvas.drawRect(rect, Paint()..color = c);
      canvas.drawRect(
        rect,
        Paint()
          ..color = Color.lerp(c, Colors.black, .25)!
          ..strokeWidth = .07 * s
          ..style = PaintingStyle.stroke,
      );
      final tray = RRect.fromRectAndRadius(
        Rect.fromLTWH((left + .82) * s, (top + .82) * s, 4.36 * s, 4.36 * s),
        Radius.circular(.20 * s),
      );
      canvas.drawRRect(tray, Paint()..color = const Color(0xFFF9FAFC));
      for (final row in [2, 4]) {
        for (final col in [2, 4]) {
          final center = Offset((left + col + .5) * s,
              (top + row + .5) * s);
          canvas.drawCircle(
            center + Offset(0, .05 * s),
            .47 * s,
            Paint()..color = const Color(0x33000000),
          );
          canvas.drawCircle(center, .45 * s, Paint()..color = c);
          canvas.drawCircle(
            center,
            .35 * s,
            Paint()..color = Color.lerp(c, Colors.white, .14)!,
          );
        }
      }
    }

    // 52-cell track and four home lanes.
    for (var i = 0; i < LudoBoardPainter.track.length; i++) {
      final (row, col) = LudoBoardPainter.track[i];
      final start = LudoGame.startingSquares.entries
          .where((e) => e.value == i);
      _cell(canvas, s, row, col,
          start.isEmpty ? Colors.white : _color(start.first.key));
    }
    for (final e in LudoBoardPainter.lanes.entries) {
      for (final (row, col) in e.value) {
        _cell(canvas, s, row, col, _color(e.key));
      }
    }
    for (var i = 0; i < LudoBoardPainter.track.length; i++) {
      if (!LudoGame.safeSquares.contains(i) ||
          LudoGame.startingSquares.values.contains(i)) {
        continue;
      }
      final (row, col) = LudoBoardPainter.track[i];
      _star(canvas, Offset((col + .5) * s, (row + .5) * s), .37 * s);
    }

    // Entry direction arrows (non-interactive).
    _arrow(canvas, Offset(7.5 * s, .5 * s), s, pi / 2, _green);
    _arrow(canvas, Offset(14.5 * s, 7.5 * s), s, pi, _yellow);
    _arrow(canvas, Offset(7.5 * s, 14.5 * s), s, -pi / 2, _blue);
    _arrow(canvas, Offset(.5 * s, 7.5 * s), s, 0, _red);

    // Four arrowhead triangles meeting in the center.
    final center = Offset(7.5 * s, 7.5 * s);
    for (final (color, a, b) in [
      (_red, Offset(6 * s, 6 * s), Offset(6 * s, 9 * s)),
      (_green, Offset(6 * s, 6 * s), Offset(9 * s, 6 * s)),
      (_yellow, Offset(9 * s, 6 * s), Offset(9 * s, 9 * s)),
      (_blue, Offset(6 * s, 9 * s), Offset(9 * s, 9 * s)),
    ]) {
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(center.dx, center.dy)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }
    canvas.drawCircle(center, .31 * s,
        Paint()..color = const Color(0xFFFFF6DB));
    canvas.drawCircle(center, .21 * s,
        Paint()..color = const Color(0xFFFFDA5B));

    // Render two playable seats only; green/blue are visual placeholders.
    for (final seat in game.seats) {
      final places = game.pieces[seat]!;
      for (var i = 0; i < places.length; i++) {
        final moving = movingSeat == seat &&
            movingToken == i && movingProgress != null;
        final progress = moving ? movingProgress! : places[i];
        if (progress >= LudoGame.homePosition) continue;

        final centerCell = LudoBoardPainter.tokenCenter(seat, i, progress);
        final same = <int>[
          for (var j = 0; j < places.length; j++)
            if (places[j] == progress) j,
        ];
        final idx = same.indexOf(i);
        final shift = !moving && progress >= 0 && same.length > 1
            ? Offset(
                ((idx % 2 == 0) ? -.16 : .16) * s,
                ((idx < 2) ? -.16 : .16) * s,
              )
            : Offset.zero;
        final centerPx = Offset(centerCell.dx * s, centerCell.dy * s) + shift;
        _pawn(
          canvas,
          centerPx,
          s,
          _color(seat),
          moving ||
              (game.currentSeat == seat &&
                  game.pendingDice != null &&
                  game.movablePieces.contains(i)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _KhelBaazOnlineBoardPainter oldDelegate) => true;
}

class _LudoBackdropPainter extends CustomPainter {
  const _LudoBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF195EA4), Color(0xFF082E68), Color(0xFF071843)],
        ).createShader(rect),
    );
    final s = size.width / 7;
    final border = Paint()
      ..color = const Color(0x0CFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var row = -2; row < size.height / s + 3; row++) {
      for (var col = -2; col < size.width / s + 3; col++) {
        final x = (col + (row.isEven ? .23 : 0)) * s;
        final y = row * s;
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(.22);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-.4 * s, -.4 * s, .8 * s, .8 * s),
            Radius.circular(.14 * s),
          ),
          border,
        );
        for (var d = 0; d < 4; d++) {
          canvas.drawCircle(
            Offset(((d % 2) - .5) * s * .30,
                ((d ~/ 2) - .5) * s * .30),
            s * .052,
            Paint()..color = const Color(0x09FFFFFF),
          );
        }
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LudoBackdropPainter oldDelegate) => false;
}
