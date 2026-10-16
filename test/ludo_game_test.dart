import 'package:flutter_test/flutter_test.dart';
import 'package:khelbaaz/ludo/ludo_game.dart';

void main() {
  group('KhelBaaz Ludo Rules', () {
    test('Six releases token and gives extra turn', () {
      final game = LudoGame(playerCount: 2);

      expect(
        game.roll(6),
        LudoRollResult.chooseToken,
      );

      game.move(0);

      expect(game.pieces[LudoSeat.red]![0], 0);
      expect(game.currentSeat, LudoSeat.red);
      expect(game.pendingDice, isNull);
    });

    test('Normal move switches player', () {
      final game = LudoGame(playerCount: 2);

      game.roll(6);
      game.move(0);

      game.roll(2);
      game.move(0);

      expect(game.pieces[LudoSeat.red]![0], 2);
      expect(game.currentSeat, LudoSeat.yellow);
    });

    test('Three consecutive sixes end turn', () {
      final game = LudoGame(playerCount: 2);

      game.roll(6);
      game.move(0);

      game.roll(6);
      game.move(1);

      expect(
        game.roll(6),
        LudoRollResult.thirdSix,
      );

      expect(game.currentSeat, LudoSeat.yellow);
      expect(game.pendingDice, isNull);
    });

    test('Capture sends opponent token to yard', () {
      final data =
          LudoGame(playerCount: 2).toOnlineMap();

      data['redPieces'] = [1, -1, -1, -1];
      data['yellowPieces'] = [28, -1, -1, -1];

      final game = LudoGame.fromOnlineMap(data);

      game.roll(1);
      final result = game.move(0);

      expect(result.captured, isTrue);
      expect(game.pieces[LudoSeat.red]![0], 2);
      expect(game.pieces[LudoSeat.yellow]![0], -1);
      expect(game.currentSeat, LudoSeat.red);
    });

    test('Fourth token home records winner', () {
      final data =
          LudoGame(playerCount: 2).toOnlineMap();

      data['redPieces'] = [56, 56, 56, 55];

      final game = LudoGame.fromOnlineMap(data);

      game.roll(1);
      final result = game.move(3);

      expect(result.completedSeat, isTrue);
      expect(game.finishOrder, [LudoSeat.red]);
      expect(game.currentSeat, LudoSeat.yellow);
    });
  });
}
