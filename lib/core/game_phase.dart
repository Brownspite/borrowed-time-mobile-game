/// The top-level state machine for a run.
enum GamePhase {
  /// Normal gameplay — enemies are alive and being spawned.
  playing,

  /// All enemies in the wave are dead; short pause before the next wave.
  betweenWaves,

  /// The player died — game is frozen, death overlay is shown.
  dead,
}
