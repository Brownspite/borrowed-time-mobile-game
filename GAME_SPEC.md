# Borrowed Time — Game Spec

## Core Idea

2D portrait arena survival game. The player survives enemy waves in a small arena.

Between waves the player is offered upgrades that are **loans**. Every upgrade has a debt attached that comes due after N waves (e.g. "pay back in 3 waves or lose 30% max HP"). Debts get worse the longer they are ignored. The player can pay a debt early by sacrificing health, score, or another upgrade.

A **loan shark** character talks to the player and gets nastier as total debt grows.

## Controls

- **One-thumb play.** Drag anywhere to move.
- Weapon **auto-fires** at the nearest enemy.
- A **dash button** for quick evasion.
- Loan choice is a **swipe**: left = take the loan, right = refuse.

## Run Length

- Target **2–3 minutes** per run.
- Death leads to a **one-tap instant restart**, no menus.

## Tech Stack

- **Flutter + Flame only.** No other game engine.
- **Portrait only.**
- Target **low-end Android phones** — keep it light: simple shapes, no heavy assets, no per-frame allocations in hot loops.

## Architecture Rules

1. Clean folder structure:
   ```
   lib/
     core/        — shared constants, helpers, base classes
     game/        — main game class, game loop, wave logic
     components/  — player, enemies, projectiles, arena
     loans/       — every loan is its own small class
     ui/          — HUD, loan-offer screen, debt tracker
     services/    — audio, input, persistence
   ```
2. Every loan is its own small class with `applyBonus()`, `applyPenalty()`, and a `dueInWaves` value. Adding a loan must never mean rewriting the game.
3. Write comments only where the logic is not obvious.
4. No per-frame heap allocations in hot loops.

## Development Rules

- After each task, list exactly what to test and how.
- Do not build things that have not been asked for yet. Work only on the current prompt.
