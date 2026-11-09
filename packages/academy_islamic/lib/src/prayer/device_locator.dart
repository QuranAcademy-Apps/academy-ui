import 'package:geolocator/geolocator.dart';

import 'prayer_settings.dart';

enum LocateResult { done, denied, unavailable }

/// Current device position; swapped for a fake in tests.
abstract interface class DeviceLocator {
  Future<PrayerLocation?> locate();

  /// Reason of the last null result.
  LocateResult get failure;
}

/// Asks for when-in-use permission once and reads a coarse position (city
/// precision is enough for prayer times).
class GeolocatorDeviceLocator implements DeviceLocator {
  LocateResult _failure = LocateResult.unavailable;

  @override
  LocateResult get failure => _failure;

  @override
  Future<PrayerLocation?> locate() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _failure = LocateResult.unavailable;
        return null;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _failure = LocateResult.denied;
        return null;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return PrayerLocation(position.latitude, position.longitude);
    } on Exception {
      _failure = LocateResult.unavailable;
      return null;
    }
  }
}
