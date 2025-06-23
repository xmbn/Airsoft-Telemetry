# Airsoft Telemetry Application - Project Summary

This document provides instructions for replicating the core features of the project in another language.

## Features Summary

### Local Data Storage
- Define a schema for game events (e.g. event ID, session ID, player ID, event type, timestamp, and GPS coordinates).
- Use a lightweight local DB (like SQLite) with asynchronous operations to insert, query, and clear events.

### Foreground Location Tracking Service
- Build a background service that requests continuous GPS updates (using the device’s GPS API).
- Enforce foreground operation with a persistent notification.
- Ensure location updates are delivered at a configurable interval.

### Event Capture and Game Session Management
- Implement start, pause (or resume), and stop endpoints for game sessions.
- Record real-time events such as "HIT", "SPAWN", and "KILL" with current location and sensor data.
- Associate events with the current game session using a unique identifier.

### Persistent User Preferences
- Save key parameters (player name, update interval, etc.) in a persistent store.
- Reload these settings on app startup.

### Responsive, Dark-Themed Single-Screen UI
- Create a dark mode user interface optimized for battery life.
- Design a compact layout that displays controls (start/pause/stop and event buttons) as well as the most recent events without scrolling.

### CSV Data Export
- Add functionality to export all stored events to a CSV file.
- Utilize the host platform’s file or data export APIs to allow user-directed file saving.

### Permission Handling and Sensor Integration
- Request and handle runtime permissions for location and notifications.
- Optionally integrate with device sensors (e.g. accelerometer, magnetometer) for orientation data.

This blueprint provides a high-level overview to aid in replicating the application using equivalent libraries and frameworks in your target programming language and platform.