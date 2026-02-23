import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_rental/Core/Widgets/rating_dialog.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void main() {
  group('CustomRatingDialog Widget Tests', () {
    testWidgets('Dialog displays core elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRatingDialog(
              onGoodReview: (_, __) {},
              onBadReview: (_, __) {},
            ),
          ),
        ),
      );

      expect(find.text('Rate Us'), findsOneWidget);
      expect(find.text('Tell others what you think about this app'), findsOneWidget);
      expect(find.byType(RatingBar), findsOneWidget);
      expect(find.text('CONTINUE'), findsOneWidget);
    });

    testWidgets('Selecting 5 stars triggers onGoodReview', (WidgetTester tester) async {
      double? capturedRating;
      bool goodCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRatingDialog(
              onGoodReview: (rating, _) {
                goodCalled = true;
                capturedRating = rating;
              },
              onBadReview: (_, __) {},
            ),
          ),
        ),
      );

      // Default is 5.0
      await tester.tap(find.text('CONTINUE'));
      await tester.pump();

      expect(goodCalled, true);
      expect(capturedRating, 5.0);
    });

    testWidgets('Selecting 2 stars shows comment box and triggers onBadReview', (WidgetTester tester) async {
      double? capturedRating;
      bool badCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomRatingDialog(
              onGoodReview: (_, __) {},
              onBadReview: (rating, _) {
                badCalled = true;
                capturedRating = rating;
              },
            ),
          ),
        ),
      );

      // Find the RatingBar and tap on the second star (approximate position)
      // Since RatingBar doesn't have easy key-based star access, we'll use a shortcut:
      // In CustomRatingDialog, the rating is updated by onRatingUpdate.
      
      // Update rating to 2.0 manually via the widget state if possible, 
      // or find the icon. Let's try finding the icon.
      final stars = find.byIcon(Icons.star_rounded);
      await tester.tap(stars.at(1)); // 2nd star
      await tester.pump();

      // Comment box should be visible now
      expect(find.byType(TextField), findsOneWidget);

      await tester.tap(find.text('CONTINUE'));
      await tester.pump();

      expect(badCalled, true);
      expect(capturedRating, 2.0);
    });

    testWidgets('Ask Me Later closes the dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => CustomRatingDialog.show(context),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomRatingDialog), findsOneWidget);

      await tester.tap(find.text('ASK ME LATER'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomRatingDialog), findsNothing);
    });
  });
}
