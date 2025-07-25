class GameEvent {
  final int? id;
  final String gameSessionId;
  final String playerId;
  final String
      eventType; // "HIT", "RESPAWN", "KILL", "LOCATION", "START", "STOP", "PAUSE", "RESUME"
  final int timestamp;
  final double latitude;
  final double longitude;
  final double altitude;
  final double? azimuth; // in degrees
  final double? speed; // in m/s
  final double? accuracy; // in meters

  GameEvent({
    this.id,
    required this.gameSessionId,
    required this.playerId,
    required this.eventType,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    this.azimuth,
    this.speed,
    this.accuracy,
  });
  factory GameEvent.fromJson(Map<String, dynamic> json) => GameEvent(
        id: json['id'],
        gameSessionId: json['gameSessionId'],
        playerId: json['playerId'],
        eventType: json['eventType'],
        timestamp: json['timestamp'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        altitude: json['altitude'],
        azimuth: json['azimuth'],
        speed: json['speed'],
        accuracy: json['accuracy'],
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'gameSessionId': gameSessionId,
        'playerId': playerId,
        'eventType': eventType,
        'timestamp': timestamp,
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'azimuth': azimuth,
        'speed': speed,
        'accuracy': accuracy,
      };
}
