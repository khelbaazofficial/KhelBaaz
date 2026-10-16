import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'ludo_online_game.dart';

// ===============================================
// KHELBAAZ LUDO - ONLINE MATCHMAKING DEMO
// ===============================================
//
// Two players per room.
// Firebase transaction-based joining.
// No wallet deduction.
// No prizes are credited.
// Live board sync will be added later.
//
// ===============================================

class LudoLobbyService {
  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  static Future<String> joinTable({
    required String tableId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError(
        'पहले अपने अकाउंट में Login करें।',
      );
    }

    final uid = user.uid;

        // ==========================================
    // LOAD REAL USERNAME FROM FIREBASE PROFILE
    // ==========================================

    String rawName =
        (user.displayName ?? '').trim();

    try {
      final profile = await _db
          .collection('users')
          .doc(uid)
          .get();

      final data = profile.data();

      if (data != null) {
        for (final key in [
          'username',
          'userName',
          'name',
          'fullName',
          'displayName',
        ]) {
          final value =
              (data[key] ?? '').toString().trim();

          if (value.isNotEmpty) {
            rawName = value;
            break;
          }
        }
      }
    } catch (_) {
      // Firebase Auth name remains the fallback.
    }

    final playerName = rawName.isEmpty
        ? 'PLAYER'
        : rawName.length > 35
            ? rawName.substring(0, 35)
            : rawName;

    final tableRef = _db
        .collection('ludo_tables')
        .doc(tableId);

    final queueRef = _db
        .collection('ludo_table_queue')
        .doc(tableId);

    final rooms = _db.collection('ludo_rooms');

    return _db.runTransaction<String>(
      (transaction) async {
        // ---------------------------------------
        // STEP A - Validate admin table
        // ---------------------------------------

        final tableSnapshot =
            await transaction.get(tableRef);

        final tableData = tableSnapshot.data();

        if (!tableSnapshot.exists ||
            tableData == null ||
            tableData['enabled'] != true ||
            tableData['playerCount'] != 2) {
          throw StateError(
            'यह Ludo Table उपलब्ध नहीं है।',
          );
        }

        final tableName =
            (tableData['name'] ?? 'Ludo Table')
                .toString();

        // ---------------------------------------
        // STEP B - Read waiting queue
        // ---------------------------------------

        final queueSnapshot =
            await transaction.get(queueRef);

        final waitingRoomId =
            (queueSnapshot.data()?['waitingRoomId']
                    ?? '')
                .toString();

        if (waitingRoomId.isNotEmpty) {
          final waitingRoomRef =
              rooms.doc(waitingRoomId);

          final waitingRoomSnapshot =
              await transaction.get(
            waitingRoomRef,
          );

          final roomData =
              waitingRoomSnapshot.data();

          final available =
              waitingRoomSnapshot.exists &&
              roomData != null &&
              roomData['tableId'] == tableId &&
              roomData['status'] == 'waiting' &&
              roomData['guestUid'] == '';

          if (available) {
            final hostUid =
                (roomData['hostUid'] ?? '')
                    .toString();

            // Same player reopening waiting room.
            if (hostUid == uid) {
              return waitingRoomId;
            }

            // ---------------------------------
            // SECOND PLAYER JOINS
            // ---------------------------------

            transaction.update(waitingRoomRef, {
              'guestUid': uid,
              'guestName': playerName,
              'status': 'ready',
              'updatedAt':
                  FieldValue.serverTimestamp(),
            });

            // Queue is available for next room.
            transaction.set(queueRef, {
              'waitingRoomId': '',
              'updatedAt':
                  FieldValue.serverTimestamp(),
            });

            return waitingRoomId;
          }
        }

        // ---------------------------------------
        // STEP C - CREATE NEW WAITING ROOM
        // ---------------------------------------

        final newRoomRef = rooms.doc();

        transaction.set(newRoomRef, {
          'tableId': tableId,
          'tableName': tableName,
          'playerCount': 2,

          'status': 'waiting',

          'hostUid': uid,
          'hostName': playerName,

          'guestUid': '',
          'guestName': '',

          'createdAt':
              FieldValue.serverTimestamp(),

          'updatedAt':
              FieldValue.serverTimestamp(),
        });

        transaction.set(queueRef, {
          'waitingRoomId': newRoomRef.id,
          'updatedAt':
              FieldValue.serverTimestamp(),
        });

        return newRoomRef.id;
      },
      maxAttempts: 5,
    );
  }
  // ==========================================
  // CANCEL LUDO WAITING ROOM
  // ==========================================

  static Future<void> cancelWaitingRoom({
    required String roomId,
  }) async {

    final uid =
        FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw StateError(
        'पहले Login करें।',
      );
    }

    final roomRef = _db
        .collection('ludo_rooms')
        .doc(roomId);

    await _db.runTransaction<void>(
      (transaction) async {

        final roomSnapshot =
            await transaction.get(roomRef);

        final roomData = roomSnapshot.data();

        if (roomData == null ||
            roomData['status'] != 'waiting' ||
            roomData['hostUid'] != uid ||
            roomData['guestUid'] != '') {

          throw StateError(
            'Room अब Cancel नहीं किया जा सकता।',
          );
        }

        final tableId = roomData['tableId'];

        if (tableId is! String ||
            tableId.isEmpty) {
          throw StateError(
            'Invalid Ludo Table',
          );
        }

        final queueRef = _db
            .collection('ludo_table_queue')
            .doc(tableId);

        final queueSnapshot =
            await transaction.get(queueRef);

        if (queueSnapshot.data()
                ?['waitingRoomId'] != roomId) {

          throw StateError(
            'Waiting Queue बदल चुकी है।',
          );
        }

        // Mark waiting room cancelled.
        transaction.update(roomRef, {
          'status': 'cancelled',
          'updatedAt':
              FieldValue.serverTimestamp(),
        });

        // Clear table waiting queue.
        transaction.set(queueRef, {
          'waitingRoomId': '',
          'updatedAt':
              FieldValue.serverTimestamp(),
        });
      },
      maxAttempts: 5,
    );
  }
  // ==========================================
  // REJOIN EXISTING ONLINE LUDO ROOM
  // ==========================================

  static Future<String> joinOrReopenTable({
    required String tableId,
  }) async {
    final uid =
        FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw StateError(
        'पहले Login करें।',
      );
    }

    final pointerRef = _db
        .collection('ludo_player_rooms')
        .doc(uid);

    // ------------------------------------------
    // STEP A - CHECK PREVIOUS ROOM
    // ------------------------------------------

    final pointerSnapshot = await pointerRef.get(
      const GetOptions(
        source: Source.server,
      ),
    );

    final pointer = pointerSnapshot.data();

    if (pointer != null &&
        pointer['tableId'] == tableId) {
      final oldRoomId =
          (pointer['roomId'] ?? '').toString();

      if (oldRoomId.isNotEmpty) {
        final oldRoomSnapshot = await _db
            .collection('ludo_rooms')
            .doc(oldRoomId)
            .get(
              const GetOptions(
                source: Source.server,
              ),
            );

        final oldRoom = oldRoomSnapshot.data();

                if (oldRoom != null &&
            oldRoom['tableId'] == tableId) {

          final isHost =
              oldRoom['hostUid'] == uid;

          final isGuest =
              oldRoom['guestUid'] == uid;

          final isMember = isHost || isGuest;

          final status =
              (oldRoom['status'] ?? '').toString();

          // =====================================
          // REOPEN UNFINISHED ONLINE GAME
          // =====================================

          if (isMember && status == 'ready') {

            final gameSnapshot =
                await oldRoomSnapshot.reference
                    .collection('game')
                    .doc('state')
                    .get(
                      const GetOptions(
                        source: Source.server,
                      ),
                    );

            final gameData = gameSnapshot.data();

            final finishOrder =
                gameData?['finishOrder'];

            final gameFinished =
                finishOrder is List &&
                finishOrder.length == 2;

            if (!gameFinished) {
              return oldRoomId;
            }

            // Finished game:
            // Continue below to join a new room.
          }

          // =====================================
          // EXPIRE OWN OLD WAITING ROOM
          // =====================================

          if (isHost &&
              status == 'waiting' &&
              oldRoom['guestUid'] == '') {

            final createdAt =
                oldRoom['createdAt'];

            final expired =
                createdAt is Timestamp &&
                DateTime.now().difference(
                  createdAt.toDate(),
                ) >= const Duration(minutes: 15);

            if (!expired) {
              return oldRoomId;
            }

            // Cancel expired waiting room.
            await cancelWaitingRoom(
              roomId: oldRoomId,
            );
          }
                }
      }
    }

    // ------------------------------------------
    // STEP B - JOIN OR CREATE NEW ROOM
    // ------------------------------------------

    final newRoomId = await joinTable(
      tableId: tableId,
    );

    // ------------------------------------------
    // STEP C - SAVE ROOM FOR REJOIN
    // ------------------------------------------

    await pointerRef.set({
      'roomId': newRoomId,
      'tableId': tableId,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    return newRoomId;
  }
}

// ===============================================
// USER JOIN BUTTON
// ===============================================

class LudoJoinButton extends StatefulWidget {
  const LudoJoinButton({
    super.key,
    required this.tableId,
    required this.tableName,
  });

  final String tableId;
  final String tableName;

  @override
  State<LudoJoinButton> createState() =>
      _LudoJoinButtonState();
}

class _LudoJoinButtonState
    extends State<LudoJoinButton> {
  bool _joining = false;

  Future<void> _join() async {
    if (_joining) return;

    setState(() {
      _joining = true;
    });

    try {
      final roomId =
                     await LudoLobbyService.joinOrReopenTable(
        tableId: widget.tableId,
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LudoWaitingRoomPage(
            roomId: roomId,
            tableName: widget.tableName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joining Error: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _joining = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: _joining ? null : _join,

        style: FilledButton.styleFrom(
          backgroundColor:
              const Color(0xFFFFC43D),

          foregroundColor: Colors.black,

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(13),
          ),
        ),

        icon: _joining
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.sports_esports,
              ),

        label: Text(
          _joining
              ? 'JOINING...'
              : 'JOIN 2 PLAYER TABLE',

          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// ===============================================
// WAITING ROOM SCREEN
// ===============================================

class LudoWaitingRoomPage extends StatelessWidget {
  const LudoWaitingRoomPage({
    super.key,
    required this.roomId,
    required this.tableName,
  });

  final String roomId;
  final String tableName;

  static const Color _background =
      Color(0xFF07172C);

  static const Color _panel =
      Color(0xFF102944);

  static const Color _gold =
      Color(0xFFFFC43D);

  static const Color _red =
      Color(0xFFE83351);

  Widget _playerCard({
    required String title,
    required String playerName,
    required Color color,
    required bool connected,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: _panel,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: connected
              ? color
              : Colors.white24,
          width: 1.5,
        ),
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 23,

            backgroundColor:
                color.withValues(alpha: 0.20),

            child: Icon(
              connected
                  ? Icons.person
                  : Icons.person_outline,

              color: color,
              size: 28,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: TextStyle(
                    color: color,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  playerName,

                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            connected
                ? Icons.check_circle
                : Icons.hourglass_empty,

            color: connected
                ? Colors.greenAccent
                : Colors.white38,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomRef =
        FirebaseFirestore.instance
            .collection('ludo_rooms')
            .doc(roomId);

        return WillPopScope(
      onWillPop: () async {

        final uid =
            FirebaseAuth.instance.currentUser?.uid;

        if (uid == null) {
          return true;
        }

        try {
          final snapshot = await roomRef.get(
            const GetOptions(
              source: Source.server,
            ),
          );

          final data = snapshot.data();

          if (data != null &&
              data['status'] == 'waiting' &&
              data['hostUid'] == uid &&
              data['guestUid'] == '') {

            await LudoLobbyService
                .cancelWaitingRoom(
              roomId: roomId,
            );
          }

          return true;

        } catch (e) {

          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(
                  'Waiting Room Error: $e',
                ),
              ),
            );
          }

          return false;
        }
      },

      child: Scaffold(
      backgroundColor: _background,

      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,

        title: const Text(
          'Ludo Waiting Room',
        ),
      ),

      body: StreamBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        stream: roomRef.snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),

                child: Text(
                  'Room Load Error:\n'
                  '${snapshot.error}',

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: Colors.redAccent,
                  ),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: _gold,
              ),
            );
          }

          final roomData =
              snapshot.data!.data();

          if (roomData == null) {
            return const Center(
              child: Text(
                'Game Room नहीं मिला।',

                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            );
          }

          final hostName =
              (roomData['hostName'] ?? 'PLAYER 1')
                  .toString();

          final guestName =
              (roomData['guestName'] ?? '')
                  .toString();

          final guestUid =
              (roomData['guestUid'] ?? '')
                  .toString();

          final ready =
              roomData['status'] == 'ready' &&
              guestUid.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.all(20),

            children: [
              Container(
                padding:
                    const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(0xFF173B61),
                      Color(0xFF261B4B),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(22),

                  border: Border.all(
                    color: Colors.white24,
                  ),
                ),

                child: Column(
                  children: [
                    const Text(
                      '🎲',
                      style: TextStyle(
                        fontSize: 60,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      tableName,

                      textAlign:
                          TextAlign.center,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      '2 PLAYER ONLINE DEMO',

                      style: TextStyle(
                        color: _gold,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _playerCard(
                title: '🔴 RED • PLAYER 1',
                playerName: hostName,
                color: _red,
                connected: true,
              ),

              const SizedBox(height: 14),

              _playerCard(
                title: '🟡 YELLOW • PLAYER 2',

                playerName: ready
                    ? guestName
                    : 'WAITING FOR PLAYER...',

                color: _gold,
                connected: ready,
              ),

              const SizedBox(height: 28),

              if (!ready) ...[
                const Center(
                  child: CircularProgressIndicator(
                    color: _gold,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  '⏳ WAITING FOR PLAYER 2',

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'दूसरे खिलाड़ी के इसी Table '
                  'पर Join करने का इंतजार है।',

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ] else ...[
                const Icon(
                  Icons.check_circle,
                  size: 58,
                  color: Colors.greenAccent,
                ),

                const SizedBox(height: 15),

                const Text(
                  '✅ 2 PLAYERS CONNECTED',

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 12),

                                const Text(
                  '🎮 दोनों खिलाड़ी तैयार हैं!\n'
                  'अब दोनों अपने-अपने मोबाइल पर '
                  'START LIVE GAME दबाएँ।',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 22),

                // ==================================
                // START ONLINE LUDO GAME
                // ==================================

                SizedBox(
                  width: double.infinity,
                  height: 58,

                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute<void>(
                          builder: (_) =>
                              LudoOnlineGamePage(
                            roomId: roomId,
                            tableName: tableName,
                          ),
                        ),
                      );
                    },

                    style: FilledButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFFFC43D),

                      foregroundColor: Colors.black,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),

                    icon: const Icon(
                      Icons.sports_esports_rounded,
                      size: 27,
                    ),

                    label: const Text(
                      'START LIVE GAME',

                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  '🔴 RED vs 🟡 YELLOW\n'
                  '2 PLAYER • ONLINE DEMO',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Color(0xFFFFC43D),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],

              const SizedBox(height: 30),

                            // ==================================
              // CANCEL WAITING ROOM OR GO BACK
              // ==================================

              OutlinedButton.icon(
                onPressed: () async {

                  final isHost =
                      roomData['hostUid'] ==
                      FirebaseAuth
                          .instance
                          .currentUser
                          ?.uid;

                  if (!ready && isHost) {
                    try {
                      await LudoLobbyService
                          .cancelWaitingRoom(
                        roomId: roomId,
                      );
                    } catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            'Cancel Error: $e',
                          ),
                        ),
                      );

                      return;
                    }
                  }

                  if (!context.mounted) return;

                  Navigator.pop(context);
                },

                icon: Icon(
                  !ready
                      ? Icons.cancel_outlined
                      : Icons.arrow_back,
                ),

                label: Text(
                  !ready
                      ? 'CANCEL WAITING & BACK'
                      : 'BACK TO TABLES',
                ),
              ),

              const SizedBox(height: 15),

                            const Text(
                'TEST MODE • NO WALLET TRANSACTIONS\n'
                'दूसरा खिलाड़ी JOIN करने से पहले '
                'Back दबाने पर Waiting Room Cancel होगा।\n'
                'दोनों खिलाड़ी जुड़ने के बाद '
                'Back करने से Game Cancel नहीं होगा।',

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ],
          );
        },
      ),
          ),
    );
  }
}
