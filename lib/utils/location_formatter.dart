class LocationFormatter {
  static String formatLatitude(double latitude) {
    return decimalToDms(latitude, true);
  }

  static String formatLongitude(double longitude) {
    return decimalToDms(longitude, false);
  }

  static String decimalToDms(double decimal, bool isLat) {
    int degrees = decimal.truncate();
    double minutesBeforeConversion = (decimal - degrees).abs() * 60;
    int minutes = minutesBeforeConversion.truncate();
    double seconds = (minutesBeforeConversion - minutes) * 60;
    String cardinalDirection;
    if (isLat) {
      cardinalDirection = decimal >= 0 ? 'N' : 'S';
    } else {
      cardinalDirection = decimal >= 0 ? 'E' : 'W';
    }
    return "${degrees.abs()}° $minutes' ${seconds.toStringAsFixed(2)}\" $cardinalDirection";
  }
}
