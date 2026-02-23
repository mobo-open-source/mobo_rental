import 'package:flutter/material.dart';
import 'package:mobo_rental/shared/widgets/snackbars/custom_snackbar.dart';
import 'package:permission_handler/permission_handler.dart';

class RuntimePermissionService {
  /// Requests microphone permission from the user.
  ///
  /// Returns true if the permission is granted, otherwise false.
  static Future<bool> requestMicrophonePermission(
    BuildContext context, {
    bool showRationale = true,
  }) async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      if (showRationale && context.mounted) {
        await _showPermissionDialog(
          context,
          'Microphone Permission',
          'Voice search requires microphone access. Please enable it in settings.',
        );
      }
      return false;
    }

    return false;
  }

  /// Requests location permission from the user.
  ///
  /// Returns true if the permission is granted, otherwise false.
  static Future<bool> requestLocationPermission(
    BuildContext context, {
    bool showRationale = true,
  }) async {
    try {
      var status = await Permission.location.status;

      if (status.isGranted) return true;

      if (showRationale &&
          await Permission.location.shouldShowRequestRationale) {
        final shouldRequest = await _showPermissionRationale(
          context,
          'Location Access',
          'This app needs location access to show customer locations on maps, find nearby customers, and provide location-based services.',
          Icons.location_on,
        );

        if (!shouldRequest) return false;
      }

      status = await Permission.location.request();

      if (status.isPermanentlyDenied) {
        await _showPermanentlyDeniedDialog(
          context,
          'Location Permission',
          'Location permission is permanently denied. Please enable it in app settings to use location features.',
        );
        return false;
      }

      if (!status.isGranted) {
        if (context.mounted) {
          CustomSnackbar.showError(
            context,
            'Location permission denied. Location features will not work.',
          );
        }
        return false;
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(
          context,
          'Failed to request location permission',
        );
      }
      return false;
    }
  }

  static Future<bool> _showPermissionRationale(
    BuildContext context,
    String title,
    String message,
    IconData icon,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(icon, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Expanded(child: Text(title)),
                ],
              ),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Not Now'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Grant Permission'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  static Future<void> _showPermanentlyDeniedDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.settings, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 12),
              Expanded(child: Text(title)),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Requests camera permission from the user.
  ///
  /// Returns true if the permission is granted, otherwise false.
  static Future<bool> requestCameraPermission(
    BuildContext context, {
    bool showRationale = true,
  }) async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      if (showRationale && context.mounted) {
        await _showPermissionDialog(
          context,
          'Camera Permission',
          'Barcode scanning requires camera access. Please enable it in settings.',
        );
      }
      return false;
    }

    return false;
  }

  static Future<void> _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Now'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    if (shouldOpenSettings == true) {
      await openAppSettings();
    }
  }
}
