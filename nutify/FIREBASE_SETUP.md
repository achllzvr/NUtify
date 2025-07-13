# Firebase Setup Instructions for NUtify

This Flutter app now includes Firebase Cloud Messaging (FCM) for push notifications. To complete the setup, you need to configure Firebase for your project.

## Steps to Set Up Firebase:

### 1. Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or use an existing project
3. Follow the setup wizard

### 2. Add Flutter App to Firebase Project
1. In Firebase Console, click "Add app" and select Flutter
2. Register your app with package name: `com.example.nutify`
3. Download the configuration files

### 3. Install FlutterFire CLI (Recommended Method)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter project
cd /path/to/your/nutify/project
flutterfire configure
```

This will automatically generate the correct `firebase_options.dart` file with your project's configuration.

### 4. Manual Configuration (Alternative)
If you prefer manual setup, replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase configuration values:

- Get these values from Firebase Console > Project Settings > General tab
- For Android: Download `google-services.json` and place it in `android/app/`
- For iOS: Download `GoogleService-Info.plist` and add it to `ios/Runner/`

### 5. Platform-Specific Setup

#### Android Setup
1. Add to `android/app/build.gradle`:
```gradle
dependencies {
    // ... other dependencies
    implementation 'com.google.firebase:firebase-messaging:23.2.1'
}
```

2. Add to `android/build.gradle`:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

3. Add to `android/app/build.gradle` (at the bottom):
```gradle
apply plugin: 'com.google.gms.google-services'
```

#### iOS Setup
1. Open `ios/Runner.xcworkspace` in Xcode
2. Add `GoogleService-Info.plist` to the Runner target
3. Ensure it's added to the bundle

### 6. Test FCM Integration

After setup, the app will:
- Request notification permissions on startup
- Generate and send FCM tokens to your backend
- Handle incoming push notifications
- Update tokens when they refresh

### 7. Backend Integration

Your PHP backend already has endpoints for:
- `fetchToken` - Retrieve stored FCM tokens
- `updateToken` - Store/update FCM tokens

The Flutter app automatically:
- Gets FCM token during login
- Sends token to backend with user ID
- Updates token when it refreshes

## Features Implemented:

1. **FCM Token Management**: Automatically gets and manages device FCM tokens
2. **Backend Integration**: Sends tokens to your PHP API during login
3. **Token Refresh**: Handles token updates automatically
4. **Notification Handling**: Ready to receive and display push notifications
5. **Local Storage**: Saves tokens locally using SharedPreferences

## Testing Push Notifications:

Once setup is complete, you can test notifications by:
1. Login to the app (this registers the FCM token)
2. Use Firebase Console > Cloud Messaging to send a test notification
3. Or use your backend API to send notifications to specific users

## Troubleshooting:

- Ensure Firebase configuration is correct
- Check that google-services.json (Android) or GoogleService-Info.plist (iOS) are properly added
- Verify internet connection for token registration
- Check console logs for FCM-related messages

The app includes comprehensive logging to help debug any issues with FCM setup or token management.
