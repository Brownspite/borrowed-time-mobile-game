import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:borrowed_time/game/borrowed_time_game.dart';
import 'package:borrowed_time/loans/loan_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BorrowedTimeGame game;

  setUp(() async {
    game = BorrowedTimeGame();
    // Simulate game size and load
    game.onGameResize(Vector2(400, 800));
    await game.onLoad();
  });

  group('Loan Registry & Base Loan Logic', () {
    test('LoanRegistry contains all 15 unique loans', () {
      final loans = LoanRegistry.getAll();
      expect(loans.length, 15);

      final ids = loans.map((l) => l.id).toSet();
      expect(ids.length, 15, reason: 'All loan IDs must be distinct');

      for (final loan in loans) {
        expect(loan.name, isNotEmpty);
        expect(loan.description, isNotEmpty);
        expect(loan.debtDescription, isNotEmpty);
        expect(loan.dueInWaves, greaterThan(0));
        expect(LoanRegistry.getById(loan.id), equals(loan));
      }
    });

    test('LoanRegistry getAvailable filters out active loans', () {
      final all = LoanRegistry.getAll();
      final available = LoanRegistry.getAvailable(['double_damage', 'big_heart']);
      expect(available.length, all.length - 2);
      expect(available.any((l) => l.id == 'double_damage'), isFalse);
      expect(available.any((l) => l.id == 'big_heart'), isFalse);
    });

    test('Overdue penalty multiplier escalates correctly', () {
      final loan = LoanRegistry.getById('double_damage')!;
      expect(loan.calculatePenaltyMultiplier(0), 1.0);
      expect(loan.calculatePenaltyMultiplier(1), 1.0 + LoanTuning.overduePenaltyGrowth);
      expect(loan.calculatePenaltyMultiplier(2), 1.0 + 2 * LoanTuning.overduePenaltyGrowth);
    });
  });

  group('DebtManager Lifecycle & Early Payment', () {
    test('Adding a loan applies bonus and tracks active debt', () {
      final initialDamage = game.playerStats.damage;
      final loan = LoanRegistry.getById('double_damage')!;

      final debt = game.debtManager.addLoan(loan);
      expect(game.playerStats.damage, initialDamage * LoanTuning.doubleDamageMultiplier);
      expect(game.debtManager.activeDebts.length, 1);
      expect(debt.remainingWaves, loan.dueInWaves);
      expect(debt.isDue, isFalse);
      expect(debt.penaltyApplied, isFalse);
      expect(game.debtManager.totalDebtLevel, 1);
    });

    test('onWaveCleared decrements countdown and triggers penalty at 0', () {
      final loan = LoanRegistry.getById('double_damage')!;
      final debt = game.debtManager.addLoan(loan);
      final initialMaxHp = game.playerStats.maxHp;

      // Wave 1
      game.debtManager.onWaveCleared();
      expect(debt.remainingWaves, loan.dueInWaves - 1);
      expect(debt.penaltyApplied, isFalse);
      expect(game.playerStats.maxHp, initialMaxHp);

      // Wave 2
      game.debtManager.onWaveCleared();
      expect(debt.remainingWaves, loan.dueInWaves - 2);
      expect(debt.penaltyApplied, isFalse);

      // Wave 3 (due!)
      game.debtManager.onWaveCleared();
      expect(debt.remainingWaves, 0);
      expect(debt.isDue, isTrue);
      expect(debt.penaltyApplied, isTrue);
      expect(debt.overdueWaves, 0);
      // Base penalty applied: max HP lost
      expect(game.playerStats.maxHp, lessThan(initialMaxHp));
      expect(game.debtManager.totalDebtLevel, 2); // Due debt pressure increases
    });

    test('Overdue debt escalates penalty multiplier each wave after 0', () {
      final loan = LoanRegistry.getById('double_damage')!;
      final debt = game.debtManager.addLoan(loan);

      // Fast-forward to due
      for (int i = 0; i < loan.dueInWaves; i++) {
        game.debtManager.onWaveCleared();
      }
      expect(debt.remainingWaves, 0);
      expect(debt.overdueWaves, 0);
      expect(debt.currentPenaltyMultiplier, 1.0);

      // Wave 4: 1 wave overdue
      game.debtManager.onWaveCleared();
      expect(debt.overdueWaves, 1);
      expect(debt.currentPenaltyMultiplier, 1.5);
      expect(game.debtManager.totalDebtLevel, 4); // 2 + (1 * 2)

      // Wave 5: 2 waves overdue
      game.debtManager.onWaveCleared();
      expect(debt.overdueWaves, 2);
      expect(debt.currentPenaltyMultiplier, 2.0);
      expect(game.debtManager.totalDebtLevel, 6); // 2 + (2 * 2)
    });

    test('payEarly with HP succeeds and clears debt', () {
      final loan = LoanRegistry.getById('double_damage')!;
      final debt = game.debtManager.addLoan(loan);
      game.playerStats.hp = 100.0;

      final success = game.debtManager.payEarly(debt, PaymentType.hp);
      expect(success, isTrue);
      expect(game.playerStats.hp, lessThan(100.0));
      expect(game.debtManager.activeDebts, isEmpty);
      expect(game.debtManager.totalDebtLevel, 0);
    });

    test('payEarly with score succeeds when sufficient and fails when insufficient', () {
      final loan = LoanRegistry.getById('double_damage')!;
      final debt = game.debtManager.addLoan(loan);

      // Insufficient score
      game.gameState.score = 10;
      final fail = game.debtManager.payEarly(debt, PaymentType.score);
      expect(fail, isFalse);
      expect(game.debtManager.activeDebts.length, 1);

      // Sufficient score
      game.gameState.score = 100;
      final success = game.debtManager.payEarly(debt, PaymentType.score);
      expect(success, isTrue);
      expect(game.gameState.score, 100 - LoanTuning.earlyPayScoreCost);
      expect(game.debtManager.activeDebts, isEmpty);
    });

    test('payEarly with sacrificeUpgrade removes another upgrade', () {
      final loan1 = LoanRegistry.getById('double_damage')!;
      final loan2 = LoanRegistry.getById('rapid_fire')!;

      final debt1 = game.debtManager.addLoan(loan1);
      game.debtManager.addLoan(loan2);

      expect(game.debtManager.activeDebts.length, 2);
      final rapidFireRate = game.playerStats.fireRate;

      // Pay debt1 by sacrificing loan2
      final success = game.debtManager.payEarly(debt1, PaymentType.sacrificeUpgrade);
      expect(success, isTrue);
      expect(game.debtManager.activeDebts, isEmpty);
      // loan2's bonus was revoked
      expect(game.playerStats.fireRate, lessThan(rapidFireRate));
    });

    test('repossess removes bonus and clears debt', () {
      final loan = LoanRegistry.getById('double_damage')!;
      final debt = game.debtManager.addLoan(loan);
      expect(game.playerStats.damage, 50.0);

      game.debtManager.repossess(debt);
      expect(game.playerStats.damage, 25.0);
      expect(game.debtManager.activeDebts, isEmpty);
    });
  });

  group('Individual 15 Loans: Bonus, Penalty & Repossession', () {
    test('1. Double Damage', () {
      final loan = LoanRegistry.getById('double_damage')!;
      loan.applyBonus(game);
      expect(game.playerStats.damage, 50.0);

      final initialMaxHp = game.playerStats.maxHp;
      loan.applyPenalty(game);
      expect(game.playerStats.maxHp, closeTo(initialMaxHp * 0.70, 0.01));

      loan.removeBonus(game);
      expect(game.playerStats.damage, 25.0);
    });

    test('2. Dash Boots', () {
      final loan = LoanRegistry.getById('dash_boots')!;
      final initialCooldown = game.playerStats.dashCooldown;
      loan.applyBonus(game);
      expect(game.playerStats.dashCooldown, initialCooldown * 0.5);
      expect(game.player.dashEnabled, isTrue);

      final initialEnemySpeedMult = game.enemySpeedMultiplier;
      loan.applyPenalty(game);
      expect(game.player.dashEnabled, isFalse);
      expect(game.enemySpeedMultiplier, initialEnemySpeedMult + 0.15);

      loan.removeBonus(game);
      expect(game.playerStats.dashCooldown, initialCooldown);
    });

    test('3. Homing Bullets', () {
      final loan = LoanRegistry.getById('homing_bullets')!;
      loan.applyBonus(game);
      expect(game.player.bulletConfig.isHoming, isTrue);

      final initialSpeed = game.player.bulletConfig.speed;
      loan.applyPenalty(game);
      expect(game.player.bulletConfig.speed, lessThan(initialSpeed));

      loan.removeBonus(game);
      expect(game.player.bulletConfig.isHoming, isFalse);
    });

    test('4. Rapid Fire', () {
      final loan = LoanRegistry.getById('rapid_fire')!;
      final initialFireRate = game.playerStats.fireRate;
      loan.applyBonus(game);
      expect(game.playerStats.fireRate, initialFireRate * LoanTuning.rapidFireMultiplier);

      loan.applyPenalty(game);
      expect(game.playerStats.fireRate, lessThan(initialFireRate));

      loan.removeBonus(game);
      expect(game.playerStats.fireRate, closeTo(initialFireRate * 0.5, 0.05));
    });

    test('5. Big Heart', () {
      final loan = LoanRegistry.getById('big_heart')!;
      final initialMaxHp = game.playerStats.maxHp;
      loan.applyBonus(game);
      expect(game.playerStats.maxHp, initialMaxHp + 50.0);

      loan.applyPenalty(game);
      expect(game.playerStats.maxHp, initialMaxHp);

      loan.removeBonus(game);
      expect(game.playerStats.maxHp, initialMaxHp - 50.0);
    });

    test('6. Energy Shield', () {
      final loan = LoanRegistry.getById('energy_shield')!;
      loan.applyBonus(game);
      expect(game.player.shieldHits, 3);

      final initialEnemyCountMult = game.enemyCountMultiplier;
      loan.applyPenalty(game);
      expect(game.enemyCountMultiplier, initialEnemyCountMult + 0.25);

      loan.removeBonus(game);
      expect(game.player.shieldHits, 0);
    });

    test('7. Triple Shot', () {
      final loan = LoanRegistry.getById('triple_shot')!;
      final initialExtra = game.player.bulletConfig.extraProjectiles;
      loan.applyBonus(game);
      expect(game.player.bulletConfig.extraProjectiles, initialExtra + 2);

      // Adding another loan to test repossession debt
      final dummyLoan = LoanRegistry.getById('double_damage')!;
      game.debtManager.addLoan(dummyLoan);
      expect(game.playerStats.damage, 50.0);

      loan.applyPenalty(game);
      // Dummy loan should have been repossessed
      expect(game.playerStats.damage, 25.0);

      loan.removeBonus(game);
      expect(game.player.bulletConfig.extraProjectiles, initialExtra);
    });

    test('8. Piercing Shots', () {
      final loan = LoanRegistry.getById('piercing_shots')!;
      final initialPierce = game.player.bulletConfig.pierceCount;
      loan.applyBonus(game);
      expect(game.player.bulletConfig.pierceCount, initialPierce + 2);

      final initialWidth = game.arenaBounds.width;
      loan.applyPenalty(game);
      expect(game.arenaBounds.width, lessThan(initialWidth));

      loan.removeBonus(game);
      expect(game.player.bulletConfig.pierceCount, initialPierce);
    });

    test('9. Time Slow Aura', () {
      final loan = LoanRegistry.getById('time_slow_aura')!;
      loan.applyBonus(game);
      expect(game.player.hasSlowAura, isTrue);

      final initialSpeedMult = game.enemySpeedMultiplier;
      loan.applyPenalty(game);
      expect(game.enemySpeedMultiplier, initialSpeedMult + 0.20);

      loan.removeBonus(game);
      expect(game.player.hasSlowAura, isFalse);
    });

    test('10. Lifesteal', () {
      final loan = LoanRegistry.getById('lifesteal')!;
      loan.applyBonus(game);
      expect(game.player.lifestealAmount, LoanTuning.lifestealHeal);

      final initialScoreMult = game.scoreMultiplier;
      loan.applyPenalty(game);
      expect(game.scoreMultiplier, initialScoreMult * 0.5);

      loan.removeBonus(game);
      expect(game.player.lifestealAmount, 0.0);
    });

    test('11. Giant Bullets', () {
      final loan = LoanRegistry.getById('giant_bullets')!;
      final initialRadius = game.player.bulletConfig.radius;
      final initialDamage = game.player.bulletConfig.damage;
      loan.applyBonus(game);
      expect(game.player.bulletConfig.radius, closeTo(initialRadius * 2.2, 0.01));
      expect(game.player.bulletConfig.damage, initialDamage + 15.0);

      final initialMoveSpeed = game.playerStats.moveSpeed;
      loan.applyPenalty(game);
      expect(game.playerStats.moveSpeed, closeTo(initialMoveSpeed * 0.75, 0.1));

      loan.removeBonus(game);
      expect(game.player.bulletConfig.radius, closeTo(initialRadius, 0.01));
      expect(game.player.bulletConfig.damage, initialDamage);
    });

    test('12. Speed Boost', () {
      final loan = LoanRegistry.getById('speed_boost')!;
      final initialSpeed = game.playerStats.moveSpeed;
      loan.applyBonus(game);
      expect(game.playerStats.moveSpeed, initialSpeed * 1.5);

      loan.applyPenalty(game);
      expect(game.player.reverseControlsTimer, LoanTuning.reverseControlsDuration);

      loan.removeBonus(game);
      expect(game.playerStats.moveSpeed, initialSpeed);
    });

    test('13. Score x2', () {
      final loan = LoanRegistry.getById('score_x2')!;
      loan.applyBonus(game);
      expect(game.scoreMultiplier, 2.0);

      game.playerStats.hp = 100.0;
      loan.applyPenalty(game);
      expect(game.playerStats.hp, 80.0);

      loan.removeBonus(game);
      expect(game.scoreMultiplier, 1.0);
    });

    test('14. Explosive Kills', () {
      final loan = LoanRegistry.getById('explosive_kills')!;
      loan.applyBonus(game);
      expect(game.explosiveKillsEnabled, isTrue);

      loan.applyPenalty(game);
      expect(game.explosionsHurtPlayer, isTrue);
      expect(game.explosionSelfDamage, LoanTuning.explosionSelfDamage);

      loan.removeBonus(game);
      expect(game.explosiveKillsEnabled, isFalse);
    });

    test('15. Second Wind', () {
      final loan = LoanRegistry.getById('second_wind')!;
      loan.applyBonus(game);
      expect(game.player.secondWindCharges, 1);

      loan.applyPenalty(game);
      expect(game.nextWaveStartingHp, 1.0);

      loan.removeBonus(game);
      expect(game.player.secondWindCharges, 0);
    });
  });
}
