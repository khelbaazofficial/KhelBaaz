/// Local rules engine for the KhelBaaz Ludo preview.
/// This model is NOT authoritative for online or reward-bearing play.
enum LudoSeat { red, green, yellow, blue }

enum LudoRollResult { chooseToken, noMove, thirdSix, finished }

class LudoMoveResult {
  final bool captured;
  final bool completedSeat;
  final bool gameOver;

  const LudoMoveResult({
    required this.captured,
    required this.completedSeat,
    required this.gameOver,
  });
}

class LudoGame {
  LudoGame({required int playerCount})
      : assert(playerCount == 2 || playerCount == 4),
        seats = playerCount == 2
            ? [LudoSeat.red, LudoSeat.yellow]
            : LudoSeat.values.toList() {
    for (final seat in seats) {
      pieces[seat] = List<int>.filled(4, -1);
    }
  }

  /// -1: yard; 0..50: shared circular path;
  /// 51..55: own home lane; 56: HOME (finished token).
  static const int homePosition = 56;
  static const Set<int> safeSquares = {0, 8, 13, 21, 26, 34, 39, 47};
  static const Map<LudoSeat, int> startingSquares = {
    LudoSeat.red: 0,
    LudoSeat.green: 13,
    LudoSeat.yellow: 26,
    LudoSeat.blue: 39,
  };

  final List<LudoSeat> seats;
  final Map<LudoSeat, List<int>> pieces = {};
  final List<LudoSeat> finishOrder = [];

  int _turnIndex = 0;
  int _consecutiveSixes = 0;
  int? pendingDice;

  LudoSeat get currentSeat => seats[_turnIndex];
  bool get isFinished => finishOrder.length == seats.length;

  int? rankingOf(LudoSeat seat) {
    final index = finishOrder.indexOf(seat);
    return index == -1 ? null : index + 1;
  }

  List<int> get movablePieces {
    final dice = pendingDice;
    if (dice == null || isFinished) return [];
    final positions = pieces[currentSeat]!;
    return [
      for (int i = 0; i < positions.length; i++)
        if (positions[i] == -1
            ? dice == 6
            : positions[i] < homePosition &&
                positions[i] + dice <= homePosition)
          i,
    ];
  }

  LudoRollResult roll(int value) {
    if (value < 1 || value > 6) {
      throw ArgumentError.value(value, 'value', 'Dice must be 1..6');
    }
    if (isFinished) return LudoRollResult.finished;
    if (pendingDice != null) {
      throw StateError('Move the selected token before rolling again.');
    }
    _consecutiveSixes = value == 6 ? _consecutiveSixes + 1 : 0;
    if (_consecutiveSixes == 3) {
      _nextSeat();
      return LudoRollResult.thirdSix;
    }
    pendingDice = value;
    if (movablePieces.isEmpty) {
      pendingDice = null;
      if (value != 6) _nextSeat();
      return LudoRollResult.noMove;
    }
    return LudoRollResult.chooseToken;
  }

  LudoMoveResult move(int pieceIndex) {
    final dice = pendingDice;
    if (dice == null || !movablePieces.contains(pieceIndex)) {
      throw StateError('That token cannot move on this roll.');
    }
    final seat = currentSeat;
    final myPieces = pieces[seat]!;
    final wasInYard = myPieces[pieceIndex] == -1;
    final destination = wasInYard ? 0 : myPieces[pieceIndex] + dice;
    myPieces[pieceIndex] = destination;
    bool captured = false;

    if (destination <= 50) {
      final landing = (startingSquares[seat]! + destination) % 52;
      if (!safeSquares.contains(landing)) {
        for (final opponent in seats) {
          if (opponent == seat) continue;
          final tokens = pieces[opponent]!;
          for (int i = 0; i < tokens.length; i++) {
            final p = tokens[i];
            if (p >= 0 && p <= 50 &&
                (startingSquares[opponent]! + p) % 52 == landing) {
              tokens[i] = -1;
              captured = true;
            }
          }
        }
      }
    }

    final completedSeat = myPieces.every((p) => p == homePosition);
    if (completedSeat) finishOrder.add(seat);
    pendingDice = null;
    final extraTurn = !completedSeat && (dice == 6 || captured || destination == 56);
    if (!isFinished && !extraTurn) _nextSeat();
    return LudoMoveResult(
      captured: captured,
      completedSeat: completedSeat,
      gameOver: isFinished,
    );
  }

  void _nextSeat() {
    pendingDice = null;
    _consecutiveSixes = 0;
    if (isFinished) return;
    for (int i = 0; i < seats.length; i++) {
      _turnIndex = (_turnIndex + 1) % seats.length;
      if (!finishOrder.contains(seats[_turnIndex])) return;
    }
  }
  // ============================================
  // ONLINE LUDO GAME STATE
  // ============================================

  // Save current Ludo state to Firebase.
  Map<String, dynamic> toOnlineMap() => {
        'redPieces':
            List<int>.from(pieces[LudoSeat.red]!),

        'yellowPieces':
            List<int>.from(pieces[LudoSeat.yellow]!),

        'currentSeat': currentSeat.name,

        'pendingDice': pendingDice ?? 0,

        'consecutiveSixes': _consecutiveSixes,

        'finishOrder':
            finishOrder.map((s) => s.name).toList(),
      };

  // Restore game state from Firebase.
  factory LudoGame.fromOnlineMap(
    Map<String, dynamic> data,
  ) {
    final game = LudoGame(playerCount: 2);

    List<int> parsePieces(Object? value) {
      if (value is! List || value.length != 4) {
        throw StateError('Invalid online token list');
      }

      return value.map((v) {
        if (v is! int ||
            v < -1 ||
            v > homePosition) {
          throw StateError(
            'Invalid token progress',
          );
        }

        return v;
      }).toList();
    }

    game.pieces[LudoSeat.red] =
        parsePieces(data['redPieces']);

    game.pieces[LudoSeat.yellow] =
        parsePieces(data['yellowPieces']);

    final current = data['currentSeat'];

    if (current != 'red' &&
        current != 'yellow') {
      throw StateError('Invalid turn');
    }

    game._turnIndex =
        current == 'red' ? 0 : 1;

    final sixes = data['consecutiveSixes'];

    if (sixes is! int ||
        sixes < 0 ||
        sixes > 2) {
      throw StateError(
        'Invalid consecutive sixes',
      );
    }

    game._consecutiveSixes = sixes;

    final dice = data['pendingDice'];

    if (dice is! int ||
        dice < 0 ||
        dice > 6) {
      throw StateError(
        'Invalid pending dice',
      );
    }

    game.pendingDice =
        dice == 0 ? null : dice;

    final result = data['finishOrder'];

    if (result is! List ||
        result.length > 2) {
      throw StateError(
        'Invalid finish order',
      );
    }

    for (final name in result) {
      final seat = switch (name) {
        'red' => LudoSeat.red,
        'yellow' => LudoSeat.yellow,
        _ => throw StateError(
            'Invalid finishing seat',
          ),
      };

      if (game.finishOrder.contains(seat)) {
        throw StateError(
          'Duplicate finishing seat',
        );
      }

      game.finishOrder.add(seat);
    }

    return game;
  }
}
