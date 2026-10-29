/// The 4 distinct loan shark personalities available in Borrowed Time.
enum LoanSharkPersonality {
  politeBanker,
  friendlyMobster,
  boredBureaucrat,
  unhingedGambler;

  String get displayName {
    switch (this) {
      case LoanSharkPersonality.politeBanker:
        return 'Arthur Sterling';
      case LoanSharkPersonality.friendlyMobster:
        return 'Sal "The Cleaver"';
      case LoanSharkPersonality.boredBureaucrat:
        return 'Auditor Gray';
      case LoanSharkPersonality.unhingedGambler:
        return 'Lucky Bones';
    }
  }

  String get title {
    switch (this) {
      case LoanSharkPersonality.politeBanker:
        return 'Managing Director';
      case LoanSharkPersonality.friendlyMobster:
        return 'Neighborhood Enforcer';
      case LoanSharkPersonality.boredBureaucrat:
        return 'Collections Clerk IV';
      case LoanSharkPersonality.unhingedGambler:
        return 'High Roller';
    }
  }

  String get emojiFace {
    switch (this) {
      case LoanSharkPersonality.politeBanker:
        return '🧐';
      case LoanSharkPersonality.friendlyMobster:
        return '😎';
      case LoanSharkPersonality.boredBureaucrat:
        return '😐';
      case LoanSharkPersonality.unhingedGambler:
        return '🤪';
    }
  }
}

/// The 3 escalations of mood depending on DebtManager.totalDebtLevel.
enum SharkMood {
  calm,
  annoyed,
  threatening;

  String get displayName {
    switch (this) {
      case SharkMood.calm:
        return 'CALM';
      case SharkMood.annoyed:
        return 'ANNOYED';
      case SharkMood.threatening:
        return 'THREATENING';
    }
  }
}

/// Dialogue event triggers throughout the player's run.
enum SharkDialogueCategory {
  runStart,
  loanOffered,
  loanTaken,
  loanRefused,
  debtCollected,
  debtPaidEarly,
  playerLowHp,
  playerDied,
}
