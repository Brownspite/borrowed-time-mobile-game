import 'game_phase.dart';

class GameState {
  int score;
  int wave;
  GamePhase phase;

  GameState({
    this.score = 0,
    this.wave = 0,
    this.phase = GamePhase.betweenWaves,
  });

  void reset() {
    score = 0;
    wave = 0;
    phase = GamePhase.betweenWaves;
  }
}
