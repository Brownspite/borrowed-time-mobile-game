import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';

import 'package:borrowed_time/loans/loan_shark.dart';
import 'package:borrowed_time/loans/loan_shark_lines.dart';
import 'package:borrowed_time/loans/loan_shark_personality.dart';

void main() {
  group('LoanShark Personality & Dialogue Tests', () {
    test('All 4 personalities have complete dialogue matrix across all categories and moods', () {
      for (final personality in LoanSharkPersonality.values) {
        final personalityMap = LoanSharkLines.dialogue[personality];
        expect(personalityMap, isNotNull,
            reason: 'Personality $personality must have a dialogue entry');

        for (final category in SharkDialogueCategory.values) {
          final categoryMap = personalityMap![category];
          expect(categoryMap, isNotNull,
              reason: 'Category $category missing for $personality');

          for (final mood in SharkMood.values) {
            final lines = categoryMap![mood];
            expect(lines, isNotNull,
                reason: 'Mood $mood missing for $personality, category $category');
            expect(lines!.length, equals(3),
                reason: 'Each mood must have exactly 3 lines for $personality, category $category, mood $mood');

            // Verify each line is non-empty and strictly under 12 words
            for (final line in lines) {
              expect(line.trim().isNotEmpty, isTrue);
              final wordCount = line.trim().split(RegExp(r'\s+')).length;
              expect(wordCount, lessThan(12),
                  reason: 'Line "$line" for $personality / $category / $mood has $wordCount words (must be < 12 words)');
            }
          }
        }
      }
    });

    test('Mood thresholds scale correctly with totalDebtLevel', () {
      final shark = LoanShark(initialPersonality: LoanSharkPersonality.politeBanker);

      // 0..2 debt level => calm
      expect(shark.getMoodForDebtLevel(0), equals(SharkMood.calm));
      expect(shark.getMoodForDebtLevel(1), equals(SharkMood.calm));
      expect(shark.getMoodForDebtLevel(2), equals(SharkMood.calm));

      // 3..5 debt level => annoyed
      expect(shark.getMoodForDebtLevel(3), equals(SharkMood.annoyed));
      expect(shark.getMoodForDebtLevel(4), equals(SharkMood.annoyed));
      expect(shark.getMoodForDebtLevel(5), equals(SharkMood.annoyed));

      // 6+ debt level => threatening
      expect(shark.getMoodForDebtLevel(6), equals(SharkMood.threatening));
      expect(shark.getMoodForDebtLevel(10), equals(SharkMood.threatening));
      expect(shark.getMoodForDebtLevel(50), equals(SharkMood.threatening));
    });

    test('LoanShark selects dialogue lines and tracks lastSpokenLine', () {
      final shark = LoanShark(
        initialPersonality: LoanSharkPersonality.friendlyMobster,
        random: math.Random(42),
      );

      final line1 = shark.speak(
        SharkDialogueCategory.loanOffered,
        debtLevel: 0,
        lineIndex: 0,
      );
      expect(line1, equals('Special deal for my favorite guy. Take a look.'));
      expect(shark.lastSpokenLine, equals(line1));
      expect(shark.lastCategory, equals(SharkDialogueCategory.loanOffered));

      // Speak with higher debt level (threatening)
      final lineThreat = shark.speak(
        SharkDialogueCategory.debtCollected,
        debtLevel: 8,
        lineIndex: 0,
      );
      expect(lineThreat, equals('Repo time! Hand over the vital organs, pal.'));
      expect(shark.lastSpokenLine, equals(lineThreat));
      expect(shark.lastCategory, equals(SharkDialogueCategory.debtCollected));
    });

    test('resetForNewRun re-initializes personality and clears cache', () {
      final shark = LoanShark(initialPersonality: LoanSharkPersonality.boredBureaucrat);
      shark.speak(SharkDialogueCategory.runStart, debtLevel: 1);
      expect(shark.lastSpokenLine.isNotEmpty, isTrue);

      shark.resetForNewRun(specificPersonality: LoanSharkPersonality.unhingedGambler);
      expect(shark.personality, equals(LoanSharkPersonality.unhingedGambler));
      expect(shark.lastSpokenLine, isEmpty);
      expect(shark.lastCategory, isNull);
      expect(shark.displayName, equals('Lucky Bones'));
      expect(shark.title, equals('High Roller'));
      expect(shark.emojiFace, equals('🤪'));
    });
  });
}
