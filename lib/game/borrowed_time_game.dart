import 'package:flame/game.dart';

import '../components/arena_border.dart';

class BorrowedTimeGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await add(ArenaBorder());
  }
}
