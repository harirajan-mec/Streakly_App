# iOS Home Widget Setup Guide

## Overview
This guide walks through the complete iOS home widget implementation for Streakly app using WidgetKit.

## What's Been Implemented

### 1. Flutter Dependencies
- Added `home_widget: ^0.4.0` to `pubspec.yaml`

### 2. iOS Widget Extension (`ios/Widget/`)

#### StreaklyWidget.swift
Main widget implementation with:
- **StreaklyWidgetEntry**: Data model for widget display
- **StreaklyWidgetProvider**: Timeline provider that fetches data from shared app group
- **StreaklyWidgetEntryView**: SwiftUI view for widget UI
- Supports both small (.systemSmall) and medium (.systemMedium) widget sizes
- Displays:
  - Current streak count with flame emoji
  - Habit name
  - Today's completion status
  - Next reminder time

#### WidgetDataManager.swift
Manages data sharing between app and widget:
- Updates streak data in shared app group
- Refreshes widget timeline
- Retrieves current widget data
- Clears widget data

#### Info.plist
Widget extension configuration for WidgetKit

### 3. Dart Widget Communication (`lib/services/widget_service.dart`)
MethodChannel-based service with methods:
- `updateWidget()`: Send streak data to widget
- `refreshWidget()`: Force widget refresh
- `clearWidgetData()`: Clear all widget data
- `getWidgetData()`: Retrieve current widget data

### 4. Native iOS Communication (`ios/Runner/AppDelegate.swift`)
Added MethodChannel handlers:
- Receives widget updates from Flutter
- Manages shared UserDefaults with app group "group.com.streakly.app"
- Triggers widget timeline refresh
- Handles data persistence and retrieval

## Manual Setup Steps Required

### Step 1: Configure Xcode Project
1. Open `ios/Runner.xcworkspace` in Xcode
2. Go to **File > New > Target**
3. Select **WidgetKit** as the template
4. Set:
   - Product Name: `StreaklyWidget` (or similar)
   - Team ID: Your team
   - Bundle Identifier: `com.streakly.app.streaklywidget`
5. Click "Create"

### Step 2: Configure App Groups
Both the main app and widget extension need to share app group ID:

#### For Main App (Runner target):
1. Select **Runner** target → **Signing & Capabilities**
2. Click **+ Capability**
3. Add **App Groups**
4. Set identifier to: `group.com.streakly.app`

#### For Widget Extension:
1. Select **StreaklyWidget** target → **Signing & Capabilities**
2. Click **+ Capability**
3. Add **App Groups**
4. Set identifier to: `group.com.streakly.app` (same as main app)

### Step 3: Link Widget Extension
1. Select **StreaklyWidget** target
2. Go to **Build Phases**
3. Under **Copy Bundle Resources**, ensure needed resources are included
4. Go to **Build Settings**
5. Ensure **Code Signing Identity** matches your provisioning profile

### Step 4: Update Bundle Identifier
If your bundle ID is different from `com.streakly.app`:
1. Update in `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleIdentifier</key>
   <string>com.your-identifier.streakly</string>
   ```
2. Update in `AppDelegate.swift` app groups:
   ```swift
   UserDefaults(suiteName: "group.com.your-identifier.streakly")
   ```
3. Update in `StreaklyWidget.swift`:
   ```swift
   UserDefaults(suiteName: "group.com.your-identifier.streakly")
   ```

### Step 5: Widget Extension Files
The following files have been created:
- `ios/Widget/StreaklyWidget.swift` - Main widget code
- `ios/Widget/WidgetDataManager.swift` - Data management
- `ios/Widget/Info.plist` - Widget configuration

If these don't appear in Xcode:
1. Right-click the `Widget` folder in Xcode
2. Select "Add Files to Runner"
3. Select the files and click "Add"

## Usage in Flutter App

### Update Widget with Habit Completion
```dart
import 'package:Streakly/services/widget_service.dart';

// When user completes a habit
await WidgetService.updateWidget(
  streakCount: 7,
  todayCompleted: true,
  habitName: 'Morning Exercise',
  nextReminder: 'Tomorrow at 6:00 AM',
);
```

### Refresh Widget Display
```dart
await WidgetService.refreshWidget();
```

### Clear Widget Data
```dart
await WidgetService.clearWidgetData();
```

### Get Current Widget Data
```dart
final data = await WidgetService.getWidgetData();
print('Current streak: ${data['streakCount']}');
```

## Testing the Widget

1. **In Simulator:**
   - Run the app in Flutter
   - Go to home screen and long-press to add widgets
   - Select "StreaklyWidget"
   - Add it to your screen

2. **Update Data:**
   - Trigger habit completion in the app
   - Widget should refresh within a few minutes

3. **Preview in Xcode:**
   - Open `StreaklyWidget.swift` in Xcode
   - Click "Resume" on the preview canvas
   - See widget preview update

## Troubleshooting

### Widget Not Appearing
- Verify both app and widget have same app group capability
- Clean build folder (⌘⇧K) and rebuild
- Restart simulator

### Data Not Updating
- Check app group identifier matches exactly in all files
- Ensure `WidgetCenter.shared.reloadAllTimelines()` is called
- Verify UserDefaults is using correct suite name

### Build Errors
- Ensure `WidgetKit` import is present in AppDelegate
- Verify Swift version matches project settings
- Check bundle identifier consistency

## File Structure
```
ios/
├── Widget/
│   ├── StreaklyWidget.swift
│   ├── WidgetDataManager.swift
│   └── Info.plist
├── Runner/
│   ├── AppDelegate.swift (modified)
│   └── Info.plist (needs app group capability)

lib/
└── services/
    └── widget_service.dart (new)
```

## Next Steps
1. Run `flutter pub get` to install home_widget
2. Open Xcode and manually add the widget extension target
3. Configure app groups for both targets
4. Update bundle identifiers if needed
5. Build and test on simulator
6. Integrate `WidgetService` calls in habit completion logic

## Notes
- Widget updates every hour by default (configurable in StreaklyWidgetProvider)
- Supports iOS 14.0+
- Use app groups (UserDefaults) for data persistence
- Widget runs in a separate process with limited resources
- Keep widget updates lightweight for performance
