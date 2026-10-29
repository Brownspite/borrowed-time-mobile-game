import 'dart:math' as math;

import 'debt_manager.dart';
import 'loan_shark_lines.dart';
import 'loan_shark_personality.dart';

/// The Loan Shark manager that controls the active loan shark personality,
/// mood calculations based on [DebtManager.totalDebtLevel], and dynamic line delivery.
class LoanShark {
  LoanShark({
    LoanSharkPersonality? initialPersonality,
    math.Random? random,
  })  : _random = random ?? math.Random(),
        personality = initialPersonality ?? _pickRandomPersonality(random ?? math.Random());

  final math.Random _random;

  /// Currently active personality for this run.
  LoanSharkPersonality personality;

  /// Last spoken line, cached for UI rendering.
  String lastSpokenLine = '';

  /// Last dialogue category triggered.
  SharkDialogueCategory? lastCategory;

  /// Picks a random personality among the four defined types.
  static LoanSharkPersonality _pickRandomPersonality(math.Random rng) {
    const values = LoanSharkPersonality.values;
    return values[rng.nextInt(values.length)];
  }

  /// Resets or re-rolls the personality at the start of a fresh run.
  void resetForNewRun({LoanSharkPersonality? specificPersonality}) {
    personality = specificPersonality ?? _pickRandomPersonality(_random);
    lastSpokenLine = '';
    lastCategory = null;
  }

  /// Calculates current mood based on total debt level:
  /// - 0..2 debt level: CALM
  /// - 3..5 debt level: ANNOYED
  /// - 6+ debt level: THREATENING
  SharkMood getMoodForDebtLevel(int debtLevel) {
    if (debtLevel <= 2) {
      return SharkMood.calm;
    } else if (debtLevel <= 5) {
      return SharkMood.annoyed;
    } else {
      return SharkMood.threatening;
    }
  }

  /// Retrieves the current mood based on a given [DebtManager] instance.
  SharkMood currentMood(DebtManager? debtManager) {
    final level = debtManager?.totalDebtLevel ?? 0;
    return getMoodForDebtLevel(level);
  }

  /// Returns and records a dialogue line for the requested [category].
  /// Tone is dynamically selected based on [debtLevel] (or [moodOverride] if specified).
  String speak(
    SharkDialogueCategory category, {
    int? debtLevel,
    SharkMood? moodOverride,
    int? lineIndex,
  }) {
    final mood = moodOverride ?? getMoodForDebtLevel(debtLevel ?? 0);
    final chosenIndex = lineIndex ?? _random.nextInt(3);

    final line = LoanSharkLines.getLine(
      personality: personality,
      category: category,
      mood: mood,
      index: chosenIndex,
    );

    lastSpokenLine = line;
    lastCategory = category;
    return line;
  }

  String get displayName => personality.displayName;
  String get title => personality.title;
  String get emojiFace => personality.emojiFace;
}
