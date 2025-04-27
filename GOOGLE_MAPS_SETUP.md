# Google Maps API Setup for AnxieEase

This document provides instructions on how to properly configure the Google Maps API key for the AnxieEase app.

## Current Issue

If you see an error message like this when using the Nearby Clinics feature:

```
This IP, site or mobile application is not authorized to use this API key. Request received from IP address X.X.X.X, with empty referer
```

It means your Google Maps API key is not properly configured to allow requests from your Android app.

## How to Fix

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select your existing project
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Directions API

4. Create a new API key or use your existing one
5. Restrict the API key:
   - For Android: Add your app's package name (`com.example.ctrlzed`) and SHA-1 certificate fingerprint
   - For iOS: Add your app's bundle identifier

## Getting Your SHA-1 Certificate Fingerprint

For Android, you need to provide your app's SHA-1 certificate fingerprint:

### For Debug:

```bash
cd android
./gradlew signingReport
```

Look for the SHA-1 fingerprint in the output.

### For Release:

If you have a keystore file for signing your app, use:

```bash
keytool -list -v -keystore your-keystore-file.keystore
```

## Updating the API Key in the App

The API key is stored in:

- Android: `android/app/src/main/res/values/google_maps_api.xml`
- iOS: `ios/Runner/AppDelegate.swift`

Update these files with your properly configured API key.

## Testing

After configuring your API key, test the Nearby Clinics feature again. If it's still not working, check the Google Cloud Console for any error messages or quota issues.
