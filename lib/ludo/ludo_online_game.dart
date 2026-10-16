import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
              return ListView(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
                children: [
                  _infoBar('${mySeat == LudoSeat.red ? '🔴 RED' : '🟡 YELLOW'} • आपकी गोटियाँ',
                      mySeat == LudoSeat.red ? _red : _yellow),
                  const SizedBox(height: 8),
                  _infoBar(game.isFinished ? '🏆 GAME COMPLETE' :
                      '$turnName की बारी ${mine ? '• YOUR TURN' : '• WAIT'}',
                      game.currentSeat == LudoSeat.red ? _red : _yellow),
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
                  const SizedBox(height: 16),
                  Center(child: Text(
                    lastDice == 0 ? '🎲 पासा फेंकें' : '🎲 Last Dice: $lastDice',
                    style: const TextStyle(color: Colors.white, fontSize: 19,
                        fontWeight: FontWeight.bold),
                  )),
                  const SizedBox(height: 12),
                  if (!game.isFinished && game.pendingDice == null)
                    FilledButton.icon(
                      onPressed: mine && !_busy ? () => _action() : null,
                      icon: const Icon(Icons.casino),
                      label: Text(mine ? 'ROLL DICE' : 'OPPONENT TURN'),
                    ),
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
