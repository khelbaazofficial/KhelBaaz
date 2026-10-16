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
      if (mounted) setState(() => _error = '$e');
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
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text('LIVE DEMO • ${widget.tableName}'),
        backgroundColor: _bg,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _roomRef.snapshots(),
        builder: (context, roomSnap) {
          if (roomSnap.hasError) return _info('Room error: ${roomSnap.error}');
          if (!roomSnap.hasData) return _loading();
          final room = roomSnap.data!.data();
          final uid = FirebaseAuth.instance.currentUser?.uid;
          if (uid == null || room == null || room['status'] != 'ready' ||
              (uid != room['hostUid'] && uid != room['guestUid'])) {
            return _info('यह गेम आपके लिए उपलब्ध नहीं है।');
          }
          final mySeat = uid == room['hostUid'] ? LudoSeat.red : LudoSeat.yellow;
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _stateRef.snapshots(),
            builder: (context, stateSnap) {
              if (stateSnap.hasError) {
                return _info('Game error: ${stateSnap.error}');
              }
              if (!stateSnap.hasData) return _loading();
              final d = stateSnap.data!.data();
              if (d == null) {
                return _info('होस्ट गेम शुरू कर रहा है...');
              }
              late final LudoGame game;
              try {
                game = LudoGame.fromOnlineMap(d);
              } catch (e) {
                return _info('Game data error: $e');
              }
              final mine = !game.isFinished && game.currentSeat == mySeat;
              final turnName = game.currentSeat == LudoSeat.red ? 'RED' : 'YELLOW';
              final lastDice = (d['lastDice'] as int?) ?? 0;
              final lastActorUid = (d['updatedBy'] ?? '').toString();
              final revision = (d['revision'] as int?) ?? 0;
              final lastAction = (d['lastAction'] ?? '').toString();
              return ListView(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
                children: [
                  // Familiar two-seat Ludo layout: tap the glowing dice
                  // beside YOUR player card to roll. No wallet actions.
                  Row(
                    children: [
                      Expanded(
                        child: _OnlinePlayerDiceCard(
                          name: (room['hostName'] ?? 'RED PLAYER').toString(),
                          seatName: 'RED',
                          seatColor: _red,
                          isYou: mySeat == LudoSeat.red,
                          active: !game.isFinished &&
                              game.currentSeat == LudoSeat.red,
                          mustChooseToken: game.pendingDice != null &&
                              game.currentSeat == LudoSeat.red,
                          canRoll: mine && mySeat == LudoSeat.red &&
                              game.pendingDice == null && !_busy,
                          diceValue: lastActorUid == room['hostUid']
                              ? lastDice : 0,
                          diceRevision: revision,
                          diceAction: lastAction,
                          diceUpdatedHere: lastActorUid == room['hostUid'],
                          onRoll: () {
                            HapticFeedback.mediumImpact();
                            _action();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _OnlinePlayerDiceCard(
                          name: (room['guestName'] ?? 'YELLOW PLAYER').toString(),
                          seatName: 'YELLOW',
                          seatColor: _yellow,
                          isYou: mySeat == LudoSeat.yellow,
                          active: !game.isFinished &&
                              game.currentSeat == LudoSeat.yellow,
                          mustChooseToken: game.pendingDice != null &&
                              game.currentSeat == LudoSeat.yellow,
                          canRoll: mine && mySeat == LudoSeat.yellow &&
                              game.pendingDice == null && !_busy,
                          diceValue: lastActorUid == room['guestUid']
                              ? lastDice : 0,
                          diceRevision: revision,
                          diceAction: lastAction,
                          diceUpdatedHere: lastActorUid == room['guestUid'],
                          onRoll: () {
                            HapticFeedback.mediumImpact();
                            _action();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0xFF173755),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: game.currentSeat == LudoSeat.red
                            ? _red.withValues(alpha: 0.65)
                            : _yellow.withValues(alpha: 0.65),
                      ),
                    ),
                    child: Text(
                      game.isFinished
                          ? '🏆 GAME COMPLETE • नीचे रैंकिंग देखें'
                          : mine
                              ? game.pendingDice != null
                                  ? '✅ $turnName • अब अपनी चमकती गोटी चुनें'
                                  : '👆 YOUR TURN • ऊपर अपने चमकते पासे को दबाएँ'
                              : '⏳ $turnName की बारी • दूसरे खिलाड़ी का इंतजार करें',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LayoutBuilder(builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      return GestureDetector(
                        onTapDown: (e) => _tapToken(game, mine, e.localPosition, width),
                        child: SizedBox(
                          width: width,
                          height: width,
                          child: CustomPaint(painter: LudoBoardPainter(game)),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 13),
                  if (lastDice > 0)
                    Text(
                      '🎲 पिछला पासा: $lastDice',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (game.pendingDice != null) ...[
                    const Text('अपनी गोटी चुनें:', textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 10),
                    Wrap(alignment: WrapAlignment.center, spacing: 10,
                      children: [for (final i in game.movablePieces)
                        ElevatedButton(
                          onPressed: mine && !_busy ? () => _action(token: i) : null,
                          child: Text('गोटी ${i + 1}'),
                        ),
                      ],
                    ),
                  ],
                  if (_busy) const Center(child: CircularProgressIndicator()),
                  if (_error != null) Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_error!, textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent)),
                  ),
                  const SizedBox(height: 18),
                  const Text('🏆 RANKING', style: TextStyle(color: Colors.white,
                      fontSize: 20, fontWeight: FontWeight.bold)),
                  for (final s in [LudoSeat.red, LudoSeat.yellow])
                    Padding(padding: const EdgeInsets.symmetric(vertical: 5),
                      child: _infoBar(
                        '${s == LudoSeat.red ? 'RED' : 'YELLOW'}  '
                        '${game.pieces[s]!.where((p) => p == 56).length}/4 HOME  '
                        '${game.rankingOf(s) == null ? '' : '#${game.rankingOf(s)}'}',
                        s == LudoSeat.red ? _red : _yellow,
                      ),
                    ),
                  const SizedBox(height: 14),
                  const Text('ONLINE TEST ONLY • Wallet से कोई लेनदेन नहीं।\n'
                      'Dice अभी Client से आता है; यह पैसे/इनाम वाली गेम के लिए सुरक्षित नहीं है।',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoBar(String value, Color color) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFF102944),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(value, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white,
                fontWeight: FontWeight.bold)),
      );

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

class _OnlinePlayerDiceCard extends StatelessWidget {
  const _OnlinePlayerDiceCard({
    required this.name,
    required this.seatName,
    required this.seatColor,
    required this.isYou,
    required this.active,
    required this.mustChooseToken,
    required this.canRoll,
    required this.diceValue,
    required this.diceRevision,
    required this.diceAction,
    required this.diceUpdatedHere,
    required this.onRoll,
  });

  final String name;
  final String seatName;
  final Color seatColor;
  final bool isYou;
  final bool active;
  final bool mustChooseToken;
  final bool canRoll;
  final int diceValue;
  final int diceRevision;
  final String diceAction;
  final bool diceUpdatedHere;
  final VoidCallback onRoll;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF123152),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: active ? seatColor : Colors.white24,
          width: active ? 2.5 : 1,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: seatColor.withValues(alpha: 0.24),
                  blurRadius: 17,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: seatColor,
                child: Icon(
                  Icons.person_rounded,
                  size: 21,
                  color: seatName == 'YELLOW'
                      ? Colors.black87
                      : Colors.white,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '$seatName • ${isYou ? 'YOU' : 'PLAYER'}',
                      maxLines: 1,
                      style: TextStyle(
                        color: seatColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          _LiveDiceButton(
            enabled: canRoll,
            active: active,
            value: diceValue,
            revision: diceRevision,
            lastAction: diceAction,
            isLastActor: diceUpdatedHere,
            onTap: onRoll,
          ),
          const SizedBox(height: 8),
          Text(
            canRoll
                ? '👆 TAP TO ROLL'
                : active && mustChooseToken
                    ? '✅ गोटी चुनें'
                    : active
                        ? '🎲 आपकी बारी'
                        : '⏳ WAIT',
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: canRoll ? Colors.white : Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w900,
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
                    child: !spinning && widget.value == 0
                      ? const Center(
                          child: Text(
                            '?',
                            style: TextStyle(
                              color: Color(0xFF19222D),
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        )
                      : CustomPaint(
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
