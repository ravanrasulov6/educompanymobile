import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:educompany_mobile/features/student/courses/widgets/acquiring_premium_button.dart';
import 'package:educompany_mobile/features/student/courses/widgets/insufficient_balance_sheet.dart';

void main() {
  group('Premium Widgets Tests', () {
    testWidgets('AcquiringPremiumButton shows label initially', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AcquiringPremiumButton(
            label: 'Abunə ol',
            onPurchase: () async => true,
          ),
        ),
      ));

      expect(find.text('Abunə ol'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('AcquiringPremiumButton shows loading state when pressed', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AcquiringPremiumButton(
            label: 'Abunə ol',
            onPurchase: () async {
              await Future.delayed(const Duration(milliseconds: 500));
              return true;
            },
          ),
        ),
      ));

      await tester.tap(find.byType(AcquiringPremiumButton));
      await tester.pump(); // Register tap
      await tester.pump(const Duration(milliseconds: 350)); // Advance past the 300ms press animation

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Abunə ol'), findsNothing);
      
      // Complete the future
      await tester.pumpAndSettle();
    });

    testWidgets('InsufficientBalanceSheet shows correct amounts', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  InsufficientBalanceSheet.show(
                    context,
                    requiredAmount: 50.0,
                    currentBalance: 10.0,
                  );
                },
                child: const Text('Show Sheet'),
              );
            }
          ),
        ),
      ));

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Yetərsiz balans'), findsOneWidget);
      expect(find.text('50.00 AZN'), findsOneWidget);
      expect(find.text('10.00 AZN'), findsOneWidget);
      expect(find.text('Balansı artır'), findsOneWidget);
    });
  });
}
