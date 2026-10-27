import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:borrowed_time/loans/loan_registry.dart';
import 'package:borrowed_time/ui/loan_card_widget.dart';

void main() {
  testWidgets('LoanCardWidget renders title, green bonus, red debt, and due waves', (tester) async {
    final loan = LoanRegistry.getById('double_damage')!;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: LoanCardWidget(
              loan: loan,
              offerIndex: 0,
              totalOffers: 3,
            ),
          ),
        ),
      ),
    );

    // Title
    expect(find.text(loan.name), findsOneWidget);

    // Offer counter
    expect(find.text('OFFER 1 OF 3'), findsOneWidget);

    // Due badge
    expect(find.text('DUE IN ${loan.dueInWaves} WAVES'), findsOneWidget);

    // Bonus text
    expect(find.text(loan.description), findsOneWidget);

    // Debt text
    expect(find.text(loan.debtDescription), findsOneWidget);

    // Verify green text color for bonus
    final bonusWidget = tester.widget<Text>(find.text(loan.description));
    expect(bonusWidget.style?.color, const Color(0xFF00FF9D));

    // Verify red text color for debt
    final debtWidget = tester.widget<Text>(find.text(loan.debtDescription));
    expect(debtWidget.style?.color, const Color(0xFFEF476F));
  });
}
