# Location Metrics in Flutter (Geolocator)

This document describes all possible location metrics available in the `Position` object from the [geolocator](https://pub.dev/packages/geolocator) package, as used in the Airsoft Telemetry Flutter project.

## Quick Reference

For airsoft telemetry, the most important properties are:
- **`latitude`** & **`longitude`** - Player position on the field
- **`accuracy`** - How precise the GPS reading is (lower is better)
- **`heading`** - Direction the player is facing/moving
- **`speed`** - How fast the player is moving
- **`timestamp`** - When the reading was taken

## Position Object Properties

| Property            | Type         | Description                                                                                 | Typical Range/Values |
|---------------------|--------------|---------------------------------------------------------------------------------------------|---------------------|
| `latitude`          | `double`     | Latitude in degrees. North is positive, south is negative.                                  | -90.0 to 90.0 |
| `longitude`         | `double`     | Longitude in degrees. East is positive, west is negative.                                   | -180.0 to 180.0 |
| `accuracy`          | `double`     | Estimated horizontal accuracy of the location, in meters.                                   | 1-50m (outdoor GPS) |
| `altitude`          | `double`     | Altitude above sea level, in meters.                                                        | Varies by location |
| `altitudeAccuracy`  | `double?`    | Estimated vertical accuracy of the altitude, in meters. (May be null on some platforms.)    | 1-10m or null |
| `speed`             | `double`     | Device speed in meters per second.                                                          | 0-50 m/s (0-180 km/h) |
| `speedAccuracy`     | `double?`    | Estimated accuracy of the speed, in meters per second. (May be null on some platforms.)     | 0.1-5.0 m/s or null |
| `heading`           | `double`     | Direction of travel in degrees relative to true north (0° = North, 90° = East, etc.).       | 0.0-359.9 degrees |
| `headingAccuracy`   | `double?`    | Estimated accuracy of the heading, in degrees. (May be null on some platforms.)             | 1-45 degrees or null |
| `timestamp`         | `DateTime`   | Time when the location was determined (UTC).                                                | Current UTC time |
| `floor`             | `int?`       | Floor number if available (e.g., in indoor positioning).                                    | null (outdoor use) |
| `isMocked`          | `bool`       | True if the location is from a mock provider (e.g., emulator or test), false otherwise.     | false (real device) |

## Example Output

```
--- Location Details ---
Latitude: 42.7836009
Longitude: -87.8565401
Accuracy: 10.70
Altitude: 182.60
Speed: 0.0002
Speed Accuracy: 0.24
Heading: 0.0
Heading Accuracy: 0.0
Timestamp: 2025-06-24 05:24:31.075Z
Floor: null
Is Mocked: false
Altitude Accuracy: 2.45
-----------------------
```

## Code Usage Examples

### Basic Position Access
```dart
Position position = await Geolocator.getCurrentPosition();
print('Player at: ${position.latitude}, ${position.longitude}');
print('Accuracy: ${position.accuracy}m');
```

### GameEvent Creation
```dart
final gameEvent = GameEvent(
  gameSessionId: sessionId,
  playerId: playerId,
  eventType: 'LOCATION',
  timestamp: position.timestamp.millisecondsSinceEpoch,
  latitude: position.latitude,
  longitude: position.longitude,
  altitude: position.altitude,
  azimuth: position.heading,  // Note: heading maps to azimuth
  speed: position.speed,
  accuracy: position.accuracy,
);
```

### Filtering by Accuracy
```dart
// Only use high-accuracy readings for airsoft telemetry
if (position.accuracy <= 10.0) {
  // Process the position data
} else {
  print('GPS accuracy too low: ${position.accuracy}m');
}
```

## Airsoft-Specific Considerations

### GPS Accuracy for Outdoor Games
- **Good accuracy**: 1-5 meters (ideal for airsoft)
- **Acceptable**: 5-15 meters (usable but less precise)
- **Poor**: >15 meters (may cause positioning errors)

### Speed Interpretation
- **Stationary**: 0-0.5 m/s (player not moving)
- **Walking**: 0.5-2 m/s (normal movement)
- **Running**: 2-6 m/s (tactical movement)
- **Sprinting**: 6+ m/s (emergency movement)

### Heading/Direction Usage
- Use `heading` property for player facing direction
- 0° = North, 90° = East, 180° = South, 270° = West
- May be inaccurate when stationary (speed < 0.5 m/s)

## Notes
- Some properties may be null depending on platform, device, or permissions
- Heading, bearing, and azimuth are all represented by the `heading` property
- GPS accuracy can vary significantly based on environment (open field vs. forest/buildings)
- Position updates may be less frequent in power-saving mode
- Consider implementing position smoothing/filtering for better telemetry data
- For more details, see the [Geolocator Position API documentation](https://pub.dev/documentation/geolocator/latest/geolocator/Position-class.html)

## Troubleshooting

### Common Issues
- **No position data**: Check location permissions and GPS enabled
- **Poor accuracy**: Move to open area, away from buildings/trees
- **Heading not updating**: Ensure device is moving (>0.5 m/s)
- **Null values**: Normal on some platforms (iOS vs Android differences)

### Performance Tips
- Use `LocationSettings` to balance accuracy vs battery life
- Consider caching recent positions for offline analysis
- Implement position validation (reasonable speed/distance changes)

## References
- [Geolocator Position API](https://pub.dev/documentation/geolocator/latest/geolocator/Position-class.html)
- [Geolocator Package Documentation](https://pub.dev/packages/geolocator)
- [Wikipedia: Geographic coordinate system](https://en.wikipedia.org/wiki/Geographic_coordinate_system)
- [Wikipedia: GNSS accuracy](https://en.wikipedia.org/wiki/Satellite_navigation#Accuracy)
- [Flutter Location Best Practices](https://docs.flutter.dev/development/platform-integration/platform-channels)
