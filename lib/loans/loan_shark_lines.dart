import 'loan_shark_personality.dart';

/// Centralized repository of all dialogue lines for the Loan Shark.
/// All lines feature dark humor and are strictly under 12 words.
abstract class LoanSharkLines {
  /// Map of [Personality] -> [Category] -> [Mood] -> List of 3 dialogue lines.
  static final Map<LoanSharkPersonality,
      Map<SharkDialogueCategory, Map<SharkMood, List<String>>>> dialogue = {
    // =========================================================================
    // POLITE BANKER (Arthur Sterling)
    // =========================================================================
    LoanSharkPersonality.politeBanker: {
      SharkDialogueCategory.runStart: {
        SharkMood.calm: [
          'Welcome to your premier financial opportunity.',
          'Borrow responsibly. Or don’t, we profit regardless.',
          'A splendid morning to incur compound interest.',
        ],
        SharkMood.annoyed: [
          'Please sign quickly, my polo club awaits.',
          'Try not to default immediately this time.',
          'Time is money, and you have neither.',
        ],
        SharkMood.threatening: [
          'Our liquidation team is already en route.',
          'Your collateral includes all internal organs today.',
          'Defaulting will terminate your physical account.',
        ],
      },
      SharkDialogueCategory.loanOffered: {
        SharkMood.calm: [
          'A competitive rate tailored to your desperation.',
          'Prime rates today. Ignore the sub-clauses.',
          'Consider this a luxury lifeline with stipulations.',
        ],
        SharkMood.annoyed: [
          'Take the capital or cease wasting air.',
          'The prime rate rises every second you stall.',
          'Accept the terms. Rejection hurts your credit.',
        ],
        SharkMood.threatening: [
          'Sign before I repossess your marrow today.',
          'This offer is mandatory for continued breathing.',
          'Take the funds or forfeit your kneecaps.',
        ],
      },
      SharkDialogueCategory.loanTaken: {
        SharkMood.calm: [
          'A wise leverage of your mortality.',
          'Funds disbursed. Do enjoy the brief illusion.',
          'Splendid! Read page forty regarding repo rights.',
        ],
        SharkMood.annoyed: [
          'Finally. Do remember deadlines are fatal here.',
          'Transaction logged. The clock ticks rather aggressively.',
          'Capital released. Don’t disappoint our actuaries.',
        ],
        SharkMood.threatening: [
          'Another nail hammered into your portfolio.',
          'You just mortgaged what remains of tomorrow.',
          'Splendid! Your funeral costs were pre-deducted.',
        ],
      },
      SharkDialogueCategory.loanRefused: {
        SharkMood.calm: [
          'Fiscal prudence will merely hasten your demise.',
          'Pity. Dead men hold remarkably poor portfolios.',
          'A bold stance for a pauper running out of time.',
        ],
        SharkMood.annoyed: [
          'Pride is notoriously ineffective against ballistics.',
          'Fine. Bleed out without my premium capital.',
          'Refusal noted. Your credit score plummeted drastically.',
        ],
        SharkMood.threatening: [
          'Defiance will incur a severe processing fee.',
          'Refusing me carries a severe physical penalty.',
          'Run along then. The mortician is booking.',
        ],
      },
      SharkDialogueCategory.debtCollected: {
        SharkMood.calm: [
          'Maturity reached. We have garnished your vigor.',
          'Payment deducted directly from your biological assets.',
          'Our restructuring policy strictly requires vital fluids.',
        ],
        SharkMood.annoyed: [
          'Past due! Our collection team takes pieces.',
          'Penalty enforced. Punctuality keeps bones intact.',
          'Garnished as promised. Read the bold italics.',
        ],
        SharkMood.threatening: [
          'Foreclosure executed! We own your bloodstream now.',
          'Liquidated! You are now statistically insolvent.',
          'Repossession complete. We took your vital organs.',
        ],
      },
      SharkDialogueCategory.debtPaidEarly: {
        SharkMood.calm: [
          'Early settlement? You wound our expected margins.',
          'Paid in full. What an irritatingly disciplined debtor.',
          'Cleared early. Our yachts are slightly delayed.',
        ],
        SharkMood.annoyed: [
          'Hmph. Early payoff denied us lucrative penalties.',
          'Cleared. Do incur more debt promptly, please.',
          'Account settled. Cease being so predictably solvent.',
        ],
        SharkMood.threatening: [
          'You survived collection. We shall rectify that.',
          'Paid off? You only bought twenty seconds.',
          'Cleared. But we hold first lien on your grave.',
        ],
      },
      SharkDialogueCategory.playerLowHp: {
        SharkMood.calm: [
          'Your vital signs reflect high market volatility.',
          'Do refrain from expiring before full maturity.',
          'A grim prognosis. Our insurers are weeping.',
        ],
        SharkMood.annoyed: [
          'Stand upright! Corpses pay notoriously dismal dividends.',
          'Do not die yet, your debt is outstanding!',
          'Bleeding voids section twelve of your guarantee.',
        ],
        SharkMood.threatening: [
          'If you expire now, I harvest your corpse.',
          'Do not dare die until I collect every cent.',
          'Your death will be treated as contractual breach.',
        ],
      },
      SharkDialogueCategory.playerDied: {
        SharkMood.calm: [
          'Account closed. Mortuary costs billed to heirs.',
          'A regrettable default. We liquidate your boots.',
          'Insolvent. The cleaning crew will scrap you.',
        ],
        SharkMood.annoyed: [
          'Total default. What an utter waste of ink.',
          'Dying with unpaid debt is profoundly discourteous.',
          'Unforgivable. Send the repo drone to the morgue.',
        ],
        SharkMood.threatening: [
          'Even in hell, my interest accrues endlessly.',
          'Dead? We shall auction your dental gold.',
          'Your carcass belongs to the board of directors.',
        ],
      },
    },

    // =========================================================================
    // FRIENDLY MOBSTER (Sal "The Cleaver")
    // =========================================================================
    LoanSharkPersonality.friendlyMobster: {
      SharkDialogueCategory.runStart: {
        SharkMood.calm: [
          'Hey buddy! Uncle Sal wants to help you out.',
          'Look at ya! Full of hope and unbroken bones.',
          'Come on, let’s make a friendly little arrangement.',
        ],
        SharkMood.annoyed: [
          'Move your feet, kid! Sal ain’t got all day.',
          'Don’t make me come down there with pliers.',
          'I like you, pal. Don’t make me change my mind.',
        ],
        SharkMood.threatening: [
          'You smell like hospital bills and cheap pine.',
          'One wrong step and you sleep with the scrap metal.',
          'Sal’s patience just left the building, pal.',
        ],
      },
      SharkDialogueCategory.loanOffered: {
        SharkMood.calm: [
          'Special deal for my favorite guy. Take a look.',
          'A little boost from the family. Don’t be shy.',
          'I got just the juice to keep your engine humming.',
        ],
        SharkMood.annoyed: [
          'Grab the package before Sal gets an ulcer.',
          'Take the juice, kid! It’s practically charity.',
          'Quit stalling. I got three other hits to schedule.',
        ],
        SharkMood.threatening: [
          'Take the boost or take a crowbar to the teeth.',
          'This ain’t a retail shop, kid. It’s an order.',
          'Grab it now, or Sal snaps your favorite femur.',
        ],
      },
      SharkDialogueCategory.loanTaken: {
        SharkMood.calm: [
          'Attaboy! You and me, we’re practically family now.',
          'Done deal! Just remember who bought your shoes.',
          'Look at you shiny! Sal’s counting the days, pal.',
        ],
        SharkMood.annoyed: [
          'About time. Don’t make Sal chase you on collections.',
          'Good choice. Broken kneecaps don’t run very fast.',
          'You got the juice. Now don’t dodge my boys.',
        ],
        SharkMood.threatening: [
          'You took it. Now you belong to Uncle Sal.',
          'Signed in sweat. Break this and we break you.',
          'That juice comes with a heavy cement boot, kid.',
        ],
      },
      SharkDialogueCategory.loanRefused: {
        SharkMood.calm: [
          'Walking away? Sal’s feelings are legitimately hurt.',
          'Suit yourself. Concrete is tough on empty pockets.',
          'Hey, brave guy! Let’s see how tough you dodge.',
        ],
        SharkMood.annoyed: [
          'Disrespecting the family? That’s bad for health.',
          'You turn Sal down? You got rocks in your head.',
          'Nobody says no to Sal and walks straight.',
        ],
        SharkMood.threatening: [
          'You’ll be begging Sal when they corner you.',
          'That no is gonna cost you a couple ribs.',
          'Big mistake, pal. Sal writes names in blood.',
        ],
      },
      SharkDialogueCategory.debtCollected: {
        SharkMood.calm: [
          'Time’s up, buddy! Sal takes a pound of flesh.',
          'Rent came due! Hope you didn’t need that chunk.',
          'A little off the top for the family, pal.',
        ],
        SharkMood.annoyed: [
          'Ignored Uncle Sal? Now the boys break things.',
          'Overdue, kid! That means extra juice on top.',
          'You made Sal come collect personally. Big mistake.',
        ],
        SharkMood.threatening: [
          'Repo time! Hand over the vital organs, pal.',
          'Vigor collected! Consider that an introductory beating.',
          'You owe Sal blood, and Sal always cashes out.',
        ],
      },
      SharkDialogueCategory.debtPaidEarly: {
        SharkMood.calm: [
          'Paid early? Look at Mr. Reliable over here!',
          'Clean slate, buddy. Sal knew you were a winner.',
          'Settled up sweet! Now go buy yourself something pretty.',
        ],
        SharkMood.annoyed: [
          'What, you don’t trust Sal with a tab?',
          'Paid already? You’re cutting into my weekend cut.',
          'Fine, you’re square. Don’t get cocky about it.',
        ],
        SharkMood.threatening: [
          'You paid off, but Sal’s eyes are on you.',
          'Clean for five minutes. You’ll be crawling back.',
          'Cleared the vig? Better watch your rear regardless.',
        ],
      },
      SharkDialogueCategory.playerLowHp: {
        SharkMood.calm: [
          'Ouch, kid! You’re leaking oil all over my rug.',
          'Duck and roll, buddy! Dying is bad for business.',
          'Take a breath, pal. Sal can’t collect from ghosts.',
        ],
        SharkMood.annoyed: [
          'Quit bleeding on my merchandise, you knucklehead!',
          'Don’t drop yet! You still owe Sal three waves!',
          'If you croak here, Sal loses his vig!',
        ],
        SharkMood.threatening: [
          'Die on me and I exhume your whole family!',
          'Get up! Sal didn’t give you permission to die!',
          'You drop dead now and Sal takes your limbs.',
        ],
      },
      SharkDialogueCategory.playerDied: {
        SharkMood.calm: [
          'Ah, what a shame. Sal liked your jacket too.',
          'He was a good kid. Dumb, but prompt with cash.',
          'Rest in pieces, buddy. Sal’s keeping your boots.',
        ],
        SharkMood.annoyed: [
          'Deadbeat! Stiffing Uncle Sal at the final bell!',
          'I knew I should’ve charged double up front.',
          'Unbelievable. Sal got stiffed by a corpse today.',
        ],
        SharkMood.threatening: [
          'Drag him back! He owes Sal three more vigs!',
          'I’m looting your dental fillings right now, pal.',
          'Nobody dies on Sal’s watch without paying up.',
        ],
      },
    },

    // =========================================================================
    // BORED BUREAUCRAT (Auditor Gray)
    // =========================================================================
    LoanSharkPersonality.boredBureaucrat: {
      SharkDialogueCategory.runStart: {
        SharkMood.calm: [
          'File 409-B opened. Try to survive until lunch.',
          'Another applicant. Please die in an orderly fashion.',
          'Processing run. Form 82-C requires carbon copy gore.',
        ],
        SharkMood.annoyed: [
          'Hurry up. My coffee break is in four minutes.',
          'Fill the blanks. My department detests overtime.',
          'Another file. Why won’t applicants simply cease existing?',
        ],
        SharkMood.threatening: [
          'Auditing your life expectancy: approximately twenty seconds remaining.',
          'Non-compliance triggers automated physical liquidation procedures today.',
          'Your existence has been flagged for expedited disposal.',
        ],
      },
      SharkDialogueCategory.loanOffered: {
        SharkMood.calm: [
          'Subsidized allocation. Review line items twelve through ninety.',
          'Standard relief parcel. Sign on dotted line with blood.',
          'Government surplus power. Side effects include catastrophic forfeiture.',
        ],
        SharkMood.annoyed: [
          'Take it or leave it. My stamp is drying.',
          'Choose quickly. Bureaucracy does not tolerate hesitation.',
          'Do not read the terms. It causes bureaucratic delays.',
        ],
        SharkMood.threatening: [
          'Mandatory asset injection. Refusal violates municipal statutes.',
          'Accept the liability or face immediate biometric repossession.',
          'Sign now. We have pre-authorized your coroner report.',
        ],
      },
      SharkDialogueCategory.loanTaken: {
        SharkMood.calm: [
          'Stamped approved. Penalty countdown initiated in annex three.',
          'Transaction logged. The state thanks you for your organs.',
          'Approved. Expected lifespan decremented by thirty-seven percent.',
        ],
        SharkMood.annoyed: [
          'Processed. Filing this paperwork gives me massive migraines.',
          'Another ledger line. Please expire during business hours.',
          'Noted. Do not track entrails onto municipal linoleum.',
        ],
        SharkMood.threatening: [
          'You have legally surrendered all rights to continued pulse.',
          'Lien registered against your skeleton and surviving next-of-kin.',
          'Processed. Your autopsy is already scheduled for wave four.',
        ],
      },
      SharkDialogueCategory.loanRefused: {
        SharkMood.calm: [
          'Refusal logged. You remain statistically doomed regardless.',
          'Opt-out recorded. No refund on prospective mortuary costs.',
          'Denied. Survival probability drops to four percent.',
        ],
        SharkMood.annoyed: [
          'Voiding this form requires seventeen supplementary signatures.',
          'Great. More paperwork because you felt heroic today.',
          'Refusal rejected. Just kidding, bleed out then.',
        ],
        SharkMood.threatening: [
          'Declining assistance is classified as treason against the auditor.',
          'Audit penalty activated. Expect immediate physical confiscation.',
          'Non-participation carries mandatory punitive bodily harm.',
        ],
      },
      SharkDialogueCategory.debtCollected: {
        SharkMood.calm: [
          'Maturity reached. Automatic payroll deduction executed from flesh.',
          'Form 1040-O applied. Penalty extracted directly from vitality.',
          'Collection automated. Have a compliant municipal afternoon.',
        ],
        SharkMood.annoyed: [
          'Past due. Penalties incurred three separate administrative surcharges.',
          'Default status achieved. Confiscating vital statistics with prejudice.',
          'Notice ignored. Withholding biological integrity effective immediately.',
        ],
        SharkMood.threatening: [
          'Total confiscation warrant enforced. We now own your lungs.',
          'Biometric garnishment complete. You are ninety percent municipal property.',
          'Foreclosure. Your bodily autonomy is permanently terminated.',
        ],
      },
      SharkDialogueCategory.debtPaidEarly: {
        SharkMood.calm: [
          'Early settlement recorded. Folder filed under non-profitable anomalies.',
          'Payment accepted. Surplus forms shredded with mild regret.',
          'Account reconciled. You may now perish unencumbered.',
        ],
        SharkMood.annoyed: [
          'Early pay requires six cancellation stamps. Such tedious hassle.',
          'Paid already? Now I must balance the ledger again.',
          'Settled. Cease disturbing my meticulously planned spreadsheets.',
        ],
        SharkMood.threatening: [
          'Debt cleared. However, administrative fees remain fatal.',
          'You paid early. We opened an audit into your assets.',
          'Zero balance. We shall fabricate new violations shortly.',
        ],
      },
      SharkDialogueCategory.playerLowHp: {
        SharkMood.calm: [
          'Vitals dropping below minimum acceptable municipal thresholds.',
          'Form 6-D: Impending Mortuary Incident detected. Please prepare.',
          'Biological breakdown noted. Shredder standing by for records.',
        ],
        SharkMood.annoyed: [
          'Cease hemorrhaging on the official department carpet.',
          'Do not perish yet, file 9 requires your signature.',
          'Incompetence noted in your permanent municipal file.',
        ],
        SharkMood.threatening: [
          'If you expire before filing, we impound your family.',
          'Unauthorized organ failure will result in severe legal action.',
          'Stay alive or suffer posthumous bureaucratic prosecution.',
        ],
      },
      SharkDialogueCategory.playerDied: {
        SharkMood.calm: [
          'Subject expired. Case closed. Time for a tea break.',
          'Death certificate stamped. Archiving file in circular bin.',
          'Deceased. Organ salvage protocol initiating in five minutes.',
        ],
        SharkMood.annoyed: [
          'Another dead applicant. The paperwork never truly ends.',
          'Unfinished paperwork. The most dreadful crime of all.',
          'Filing posthumous default. What a tedious afternoon.',
        ],
        SharkMood.threatening: [
          'We will sue your ghost for outstanding balances.',
          'Death does not discharge municipal debt. We own your soul.',
          'Postmortem liquidation authorized. Strip the carcass immediately.',
        ],
      },
    },

    // =========================================================================
    // UNHINGED GAMBLER (Lucky Bones)
    // =========================================================================
    LoanSharkPersonality.unhingedGambler: {
      SharkDialogueCategory.runStart: {
        SharkMood.calm: [
          'Snake eyes or jackpot! Let’s roll those shiny dice!',
          'Place your bets! The house always smells blood!',
          'Spin the wheel! Loser gets ground into confetti!',
        ],
        SharkMood.annoyed: [
          'Quit shuffling and roll! My lucky itch is screaming!',
          'Double or nothing right now! Don’t bore me!',
          'Faster! The roulette wheel doesn’t spin on hesitation!',
        ],
        SharkMood.threatening: [
          'I bet all my chips your head comes off today!',
          'Russian roulette, baby! Every single chamber is loaded!',
          'The house wants your teeth as poker chips!',
        ],
      },
      SharkDialogueCategory.loanOffered: {
        SharkMood.calm: [
          'Double-down deal! Pure adrenaline wrapped in a ticking bomb!',
          'Take the high-roller card! What’s a little organ failure?',
          'Golden opportunity! Fifty-to-one payout on your skin!',
        ],
        SharkMood.annoyed: [
          'Draw the card! Don’t fold before the flop!',
          'Bet big or bleed out! No cowards at my table!',
          'Grab it! The dice are burning through my palms!',
        ],
        SharkMood.threatening: [
          'Take the gamble or I pull the pin right now!',
          'This card is wild! Take it or lose your eyes!',
          'Sign the ticket! The pit boss wants fresh meat!',
        ],
      },
      SharkDialogueCategory.loanTaken: {
        SharkMood.calm: [
          'All in! Woohoo! Now watch the reaper spin!',
          'Jackpot baby! Hope you like thirty percent house edge!',
          'Locked in! Pray to the gods of neon velocity!',
        ],
        SharkMood.annoyed: [
          'You took it! Now run before the house collects!',
          'Chips on the table! Don’t you dare crap out!',
          'That ticket is hot! Don’t burn off your fingers!',
        ],
        SharkMood.threatening: [
          'You sold your soul to the casino floor, pal!',
          'All in on red! Red like your spraying jugular!',
          'Hahaha! That card carries a five-hundred volt penalty!',
        ],
      },
      SharkDialogueCategory.loanRefused: {
        SharkMood.calm: [
          'Folded? Coward! The house spits on cautious cowards!',
          'Walking away from the table? No jackpot for you!',
          'Tsk tsk. Lady Luck just turned her back on you.',
        ],
        SharkMood.annoyed: [
          'Boring! You’re gonna die poor and full of lead!',
          'Folding on a royal flush? You make me sick!',
          'Chicken! The pit boss is laughing in your face!',
        ],
        SharkMood.threatening: [
          'You don’t play? Then I break your lucky dice!',
          'Refuse me? I’ll bet your life on snake eyes!',
          'You walked away. Now the house hunts you down!',
        ],
      },
      SharkDialogueCategory.debtCollected: {
        SharkMood.calm: [
          'House rules! The pit boss takes a bite!',
          'Bust! The casino always collects from the marrow!',
          'Time’s up! That’s house rake straight from your spine!',
        ],
        SharkMood.annoyed: [
          'Past due! Interest rate just exploded like fireworks, baby!',
          'Overdue penalty! We’re sawing off your good arm!',
          'You crapped out! Pay the vig or get chopped!',
        ],
        SharkMood.threatening: [
          'BANKRUPT! We’re cashing in your ribs as white chips!',
          'Total wipeout! Strip him down to raw meat!',
          'House wins! Your life is confiscated for casino decor!',
        ],
      },
      SharkDialogueCategory.debtPaidEarly: {
        SharkMood.calm: [
          'Cashing out early? Where is the wild fun in that?',
          'Settled up? You took all the gamble away!',
          'Paid off! But the table calls you back soon!',
        ],
        SharkMood.annoyed: [
          'Buzzkill! I had money riding on your gory default!',
          'Square already? You ruin every single high-stakes bet!',
          'Cleared? Don’t leave the table, deal another hand!',
        ],
        SharkMood.threatening: [
          'You beat the spread today. Next roll breaks you!',
          'Paid up? I’ll rig the next wheel just for you!',
          'Cleared the tab? The pit boss never forgets!',
        ],
      },
      SharkDialogueCategory.playerLowHp: {
        SharkMood.calm: [
          'Down to your last chip! What a glorious sweat!',
          'One hit from bust! Double down right now, baby!',
          'Red line! My favorite kind of high-stakes gamble!',
        ],
        SharkMood.annoyed: [
          'Don’t tap out now, the odds are getting tasty!',
          'Stay on your feet! I’ve got three grand riding on you!',
          'Shake the dice, baby! Don’t choke on your blood!',
        ],
        SharkMood.threatening: [
          'Don’t you dare die before the final payoff!',
          'If you crap out now, I’ll bet on your corpse!',
          'Bleed out later! Finish the round or I detonate!',
        ],
      },
      SharkDialogueCategory.playerDied: {
        SharkMood.calm: [
          'Crapped out! House wins again! Clean the felt!',
          'Bust! Thanks for playing Borrowed Time, high roller!',
          'Flatline! A glorious way to lose every chip!',
        ],
        SharkMood.annoyed: [
          'Lost it all! I bet my gold watch on you!',
          'What a choke! You blew the easiest parlay ever!',
          'Deadbeat! You took my lucky dice down with you!',
        ],
        SharkMood.threatening: [
          'Winner takes all, and the house takes your teeth!',
          'Another dead gambler for the basement furnace! Woohoo!',
          'Game over! Next sucker to the table, step right up!',
        ],
      },
    },
  };

  /// Returns a line for the given [personality], [category], and [mood].
  /// If [index] is provided (0..2), selects that specific line.
  /// Otherwise, selects randomly among the 3 lines.
  static String getLine({
    required LoanSharkPersonality personality,
    required SharkDialogueCategory category,
    required SharkMood mood,
    int? index,
  }) {
    final personalityMap = dialogue[personality];
    final categoryMap = personalityMap?[category];
    final lines = categoryMap?[mood];

    if (lines == null || lines.isEmpty) {
      return 'Tick tock. Time is money.';
    }

    if (index != null && index >= 0 && index < lines.length) {
      return lines[index];
    }

    // Default to the first line if index is out of bounds or not provided
    return lines.first;
  }
}
