# **AIRSOFT** Telemetry App - User Guide

This guide provides step-by-step instructions for using the **AIRSOFT** Telemetry mobile app to track and analyze your gameplay data.

## 📋 **Table of Contents**

- [Starting a Session](#starting-a-session)
- [Viewing Data](#viewing-data)
- [Exporting Data](#exporting-data)
- [Data Management](#data-management)
- [Tips for Best Results](#tips-for-best-results)

## **Starting a Session**

Follow these steps to begin tracking your **AIRSOFT** game:

1. **Open the app** and navigate to the **Settings** screen by swiping right
2. **Configure your settings**:
   - Set your **Player Name** for identification
   - Choose your **Update Interval** (1-60 seconds based on desired detail vs battery life)
3. **Return to the Home screen** by swiping left
4. **Press START** to begin telemetry collection
5. **Record events** during gameplay:
   - Press **HIT** when you take a hit
   - Press **SPAWN** when you respawn at a checkpoint
   - Press **KILL** when you eliminate another player
6. **Manage your session**:
   - Use **PAUSE/RESUME** to temporarily stop tracking
   - Press **STOP** to end the session completely

## **Viewing Data**

Monitor your gameplay data in real-time:

### **Settings Screen**
- **Event Log**: View real-time list of all recorded events with GPS coordinates
- **Live Position**: Monitor your current location, altitude, and GPS accuracy
- **Session Status**: Track active session state and recent activities

### **Home Screen**
- **Session Controls**: Start, pause, resume, or stop tracking
- **Quick Events**: Fast access to HIT, SPAWN, KILL buttons
- **Status Indicators**: Clear feedback on current session state

### **Insights Screen** *(In Development)*
- **Performance KPIs**: Kill/death ratio, distance traveled, session duration
- **Session Comparison**: Compare performance across multiple games
- **Movement Analysis**: Total distance and average speed calculations

## **Exporting Data**

Save your telemetry data for external analysis:

1. **Navigate to Settings screen**
2. **Press "Export Data" button**
3. **Choose save location** using your device's file picker
4. **Confirm export** - data will be saved as a CSV file

### **Export Content**
Your CSV file includes:
- Session ID and Player identification
- Complete timestamp data (milliseconds and human-readable)
- Event types (START, STOP, PAUSE, RESUME, HIT, SPAWN, KILL, LOCATION)
- Precise GPS coordinates (latitude, longitude, altitude)
- Additional metrics (speed, accuracy, azimuth/heading)

## **Data Management**

Keep your app organized and running efficiently:

### **Clear All Data**
- Navigate to **Settings** screen
- Press **"Clear All Data"** button
- **Confirm** the action in the safety dialog
- All sessions and events will be permanently removed

### **Data Organization**
- **Session Filtering**: All data automatically organized by unique session IDs
- **Automatic Backup**: Everything persisted locally in SQLite database
- **No Cloud Dependency**: All data stays on your device for privacy

## **Tips for Best Results**

### **GPS Accuracy**
- **Use outdoors**: GPS works best with clear sky visibility
- **Allow location permissions**: Enable "Always" or "While Using App" location access
- **Wait for GPS lock**: Allow 30-60 seconds for initial GPS accuracy improvement

### **Battery Optimization**
- **Adjust update interval**: Longer intervals (30-60 seconds) save battery
- **Use dark theme**: Already enabled by default for outdoor visibility
- **Monitor battery**: Check device battery level before long sessions

### **Field Testing**
- **Test before games**: Verify GPS accuracy and app functionality
- **Bring backup power**: Consider portable battery for extended sessions  
- **Practice navigation**: Familiarize yourself with screen gestures and button locations

### **Data Quality**
- **Record events promptly**: Log HIT/SPAWN/KILL events as they happen
- **Use meaningful player names**: Helps identify sessions when exporting data
- **Regular exports**: Save data periodically to avoid potential loss

---

**Need help?** Check the main [README.md](../README.md) for technical details or create an issue in the GitHub repository for support.