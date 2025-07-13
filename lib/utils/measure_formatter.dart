import 'package:intl/intl.dart';

class MeasureFormatter {
  static final NumberFormat _oneDecimal = NumberFormat('##0.0');
  static final NumberFormat _noDecimal = NumberFormat('##0');

  /// Formats azimuth in degrees, optionally with compass direction.
  static String formatAzimuth(double? azimuth, {bool withDirection = false}) {
    if (azimuth == null) return 'N/A';
    final deg = _noDecimal.format(azimuth);
    if (!withDirection) return '$deg°';
    return '$deg° ${_azimuthToCompass(azimuth)}';
  }

  /// Formats speed in m/s only (walking use case).
  static String formatSpeed(double? speed) {
    if (speed == null) return 'N/A';
    final ms = _oneDecimal.format(speed);
    return '$ms m/s';
  }

  /// Formats accuracy in meters.
  static String formatAccuracy(double? accuracy) {
    if (accuracy == null) return 'N/A';
    return '±${_oneDecimal.format(accuracy)} m';
  }

  /// Formats altitude in meters.
  static String formatAltitude(double? altitude) {
    if (altitude == null) return 'N/A';
    return '${_oneDecimal.format(altitude)} m';
  }

  static String _azimuthToCompass(double azimuth) {
    const directions = [
      'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N'
    ];
    final idx = ((azimuth % 360) / 45).round();
    return directions[idx];
  }
}
