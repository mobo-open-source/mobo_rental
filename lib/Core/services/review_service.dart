import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../navigation/global_keys.dart';
import '../Widgets/rating_dialog.dart';
import 'package:flutter/material.dart';

/// A service that manages the logic for requesting app reviews.
/// 
/// Tracks app opens, significant events, and usage duration to determine 
/// when to show the review dialog based on predefined thresholds.
class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final InAppReview _inAppReview = InAppReview.instance;
  
  // Keys for SharedPreferences
  static const String _keyOpenCount = 'review_open_count';
  static const String _keyEventCount = 'review_event_count';
  static const String _keyFirstOpenDate = 'review_first_open_date';
  static const String _keyLastRequestDate = 'review_last_request_date';
  static const String _keyNeverAskAgain = 'review_never_ask_again';

  // Thresholds
  static const int _thresholdOpens = 5; 
  static const int _thresholdEvents = 5;
  static const int _thresholdDays = 5;

  bool _wasRequestedThisRun = false;

  /// Tracks an app open event and checks if review criteria are met.
  Future<void> trackAppOpen([BuildContext? context]) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. First Open Date
    if (!prefs.containsKey(_keyFirstOpenDate)) {
      await prefs.setInt(_keyFirstOpenDate, DateTime.now().millisecondsSinceEpoch);
    }

    // 2. Increment Open Count
    int currentOpens = prefs.getInt(_keyOpenCount) ?? 0;
    currentOpens++;
    await prefs.setInt(_keyOpenCount, currentOpens);
    
    // Automatically check thresholds
    await _checkAndRequestReview(prefs, context ?? navigatorKey.currentContext);
  }

  /// Tracks a significant user event (e.g., order completion) and checks criteria.
  Future<void> trackSignificantEvent() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Increment Event Count
    int currentEvents = prefs.getInt(_keyEventCount) ?? 0;
    currentEvents++;
    await prefs.setInt(_keyEventCount, currentEvents);
    
    // Automatically check thresholds
    await _checkAndRequestReview(prefs, navigatorKey.currentContext);
  }

  Future<void> _checkAndRequestReview(SharedPreferences prefs, [BuildContext? context]) async {
    if (_wasRequestedThisRun) return;

    if (prefs.getBool(_keyNeverAskAgain) ?? false) {
      return;
    }

    bool shouldRequest = false;

    // Criteria 1: Nth usage (open)
    int openCount = prefs.getInt(_keyOpenCount) ?? 0;
    if (openCount >= _thresholdOpens) {
      shouldRequest = true;
    }

    // Criteria 2: Nth significant event
    int eventCount = prefs.getInt(_keyEventCount) ?? 0;
    if (eventCount >= _thresholdEvents) {
      shouldRequest = true;
    }

    // Criteria 3: N days usage
    int? firstOpenEpoch = prefs.getInt(_keyFirstOpenDate);
    if (firstOpenEpoch != null) {
      final firstOpenDate = DateTime.fromMillisecondsSinceEpoch(firstOpenEpoch);
      final diff = DateTime.now().difference(firstOpenDate).inDays;
      if (diff >= _thresholdDays) {
         shouldRequest = true;
      }
    }

    if (shouldRequest) {
      int? lastRequestEpoch = prefs.getInt(_keyLastRequestDate);
      if (lastRequestEpoch != null) {
        final lastRequest = DateTime.fromMillisecondsSinceEpoch(lastRequestEpoch);
        final daysSinceLastRequest = DateTime.now().difference(lastRequest).inDays;
        
        // Request again only if it's been a long time (e.g. 30 days)
        if (daysSinceLastRequest < 30) {
          if (kDebugMode) {
          } else {
            return;
          }
        }
      }

      if (context != null && context.mounted) {
         _wasRequestedThisRun = true;
         
         // Update last request date to enforce cooldown period
         await prefs.setInt(_keyLastRequestDate, DateTime.now().millisecondsSinceEpoch);
         
         CustomRatingDialog.show(context);
      } else {
      }
    } else {
    }
  }

  /// Checks tracking criteria and shows the rating dialog if met.
  Future<void> checkAndShowRating(BuildContext context) async {
     final prefs = await SharedPreferences.getInstance();
     await _checkAndRequestReview(prefs, context);
  }

  /// Forces the native review request flow, bypassing all tracking criteria.
  /// 
  /// Falls back to [openStoreListing] if the native flow is unavailable.
  Future<void> forceRequestReview() async {
    
    // Update last request date
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastRequestDate, DateTime.now().millisecondsSinceEpoch);
    
    // Show a small snackbar so the user knows the code is working
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: const Text('🔄 Requesting Google Play review...'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue[700],
      ),
    );

    try {
      if (await _inAppReview.isAvailable()) {
        _wasRequestedThisRun = true;
        // Increase delay to 2.5 seconds to ensure stable activity transition
        await Future.delayed(const Duration(milliseconds: 2500));
        await _inAppReview.requestReview();
      } else {
        await openStoreListing();
      }
    } catch (e) {
      await openStoreListing();
    }
  }

  /// Opens the application's store listing in the platform's app store.
  Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing();
    } catch (e) {
    }
  }

  /// Launches the default email client to send feedback.
  Future<void> sendEmailFeedback(double rating, String comment) async {
    try {
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'cybroplay@gmail.com', // Updated support email
        query: encodeQueryParameters(<String, String>{
          'subject': 'Feedback for Mobo Rental for Odoo (${rating.toInt()} Stars)',
          'body': 'Rating: ${rating.toInt()}/5\n\nComment:\n$comment\n\n---\nSent from Mobo Rental for Odoo'
        }),
      );

      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
      }
    } catch (e) {
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  /// Disables review requests permanently for the current user.
  Future<void> neverAskAgain() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNeverAskAgain, true);
  }

  /// Prints the current review tracking statistics to the debug console.
  Future<void> printReviewStats() async {
    final prefs = await SharedPreferences.getInstance();
    
    int openCount = prefs.getInt(_keyOpenCount) ?? 0;
    int eventCount = prefs.getInt(_keyEventCount) ?? 0;
    int? firstOpenEpoch = prefs.getInt(_keyFirstOpenDate);
    int? lastRequestEpoch = prefs.getInt(_keyLastRequestDate);
    
    
    if (firstOpenEpoch != null) {
      final firstOpenDate = DateTime.fromMillisecondsSinceEpoch(firstOpenEpoch);
      final daysSinceFirst = DateTime.now().difference(firstOpenDate).inDays;
    } else {
    }
    
    if (lastRequestEpoch != null) {
      final lastRequestDate = DateTime.fromMillisecondsSinceEpoch(lastRequestEpoch);
    } else {
    }
    
  }

  /// Resets all review tracking data in [SharedPreferences].
  Future<void> resetReviewTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOpenCount);
    await prefs.remove(_keyEventCount);
    await prefs.remove(_keyFirstOpenDate);
    await prefs.remove(_keyLastRequestDate);
    await prefs.remove(_keyNeverAskAgain);
  }
}
