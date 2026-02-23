import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_rental/Core/services/review_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReviewService Logic Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      await ReviewService().resetReviewTracking();
    });

    test('trackAppOpen increments counter and saves it', () async {
      await ReviewService().trackAppOpen();
      expect(prefs.getInt('review_open_count'), 1);

      await ReviewService().trackAppOpen();
      expect(prefs.getInt('review_open_count'), 2);
    });

    test('trackSignificantEvent increments counter', () async {
      await ReviewService().trackSignificantEvent();
      expect(prefs.getInt('review_event_count'), 1);

      await ReviewService().trackSignificantEvent();
      expect(prefs.getInt('review_event_count'), 2);
    });

    test('neverAskAgain sets the correct flag', () async {
      await ReviewService().neverAskAgain();
      expect(prefs.getBool('review_never_ask_again'), true);
    });

    test('resetReviewTracking clears all data', () async {
      await ReviewService().trackAppOpen();
      await ReviewService().trackSignificantEvent();
      await ReviewService().neverAskAgain();

      await ReviewService().resetReviewTracking();

      expect(prefs.getInt('review_open_count'), null);
      expect(prefs.getInt('review_event_count'), null);
      expect(prefs.getBool('review_never_ask_again'), null);
    });

    test('Threshold logic: Does not trigger before threshold', () async {
      // Threshold is 5 for both opens and events
      for (int i = 0; i < 4; i++) {
        await ReviewService().trackAppOpen();
      }
      // Note: We can't easily check if the dialog was SHOWN in a unit test 
      // without mocking the navigator, but we can verify the counters.
      expect(prefs.getInt('review_open_count'), 4);
    });
  });
}
