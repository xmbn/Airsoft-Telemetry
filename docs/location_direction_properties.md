# Location Metrics in Flutter (Geolocator)

This document describes all possible location metrics available in the `Position` object from the [geolocator](https://pub.dev/packages/geolocator) package, as used in the Airsoft Telemetry Flutter project.

## Position Object Properties

| Property            | Type         | Description                                                                                 |
|---------------------|--------------|---------------------------------------------------------------------------------------------|
| `latitude`          | `double`     | Latitude in degrees. North is positive, south is negative.                                  |
| `longitude`         | `double`     | Longitude in degrees. East is positive, west is negative.                                   |
| `accuracy`          | `double`     | Estimated horizontal accuracy of the location, in meters.                                   |
| `altitude`          | `double`     | Altitude above sea level, in meters.                                                        |
| `altitudeAccuracy`  | `double?`    | Estimated vertical accuracy of the altitude, in meters. (May be null on some platforms.)    |
| `speed`             | `double`     | Device speed in meters per second.                                                          |
| `speedAccuracy`     | `double?`    | Estimated accuracy of the speed, in meters per second. (May be null on some platforms.)     |
| `heading`           | `double`     | Direction of travel in degrees relative to true north (0° = North, 90° = East, etc.).       |
| `headingAccuracy`   | `double?`    | Estimated accuracy of the heading, in degrees. (May be null on some platforms.)             |
| `timestamp`         | `DateTime`   | Time when the location was determined (UTC).                                                |
| `floor`             | `int?`       | Floor number if available (e.g., in indoor positioning).                                    |
| `isMocked`          | `bool`       | True if the location is from a mock provider (e.g., emulator or test), false otherwise.     |

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

## Property Explanations

- **Latitude / Longitude**: Geographic coordinates of the device.
- **Accuracy**: Horizontal accuracy (radius of 68% confidence circle) in meters.
- **Altitude**: Height above mean sea level in meters.
- **Altitude Accuracy**: Vertical accuracy in meters (may be null).
- **Speed**: Device speed in meters per second.
- **Speed Accuracy**: Accuracy of speed measurement (may be null).
- **Heading**: Direction of travel relative to true north, in degrees.
- **Heading Accuracy**: Accuracy of heading measurement (may be null).
- **Timestamp**: UTC time when the location was determined.
- **Floor**: Floor number if available (may be null).
- **Is Mocked**: True if the location is simulated or faked.

## Notes
- Some properties may be null depending on platform, device, or permissions.
- Heading, bearing, and azimuth are all represented by the `heading` property.
- For more details, see the [Geolocator Position API documentation](https://pub.dev/documentation/geolocator/latest/geolocator/Position-class.html).

## References
- [Geolocator Position API](https://pub.dev/documentation/geolocator/latest/geolocator/Position-class.html)
- [Wikipedia: Geographic coordinate system](https://en.wikipedia.org/wiki/Geographic_coordinate_system)
- [Wikipedia: GNSS accuracy](https://en.wikipedia.org/wiki/Satellite_navigation#Accuracy)
