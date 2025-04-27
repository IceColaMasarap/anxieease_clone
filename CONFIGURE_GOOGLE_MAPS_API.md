# Configuring Google Maps API for AnxieEase

## Current Issue

The nearby clinic feature is showing the error:

```
This IP, site or mobile application is not authorized to use this API key.
```

This means your Google Maps API key needs to be properly configured with restrictions to work with your app.

## Your API Key Information

- API Key: `AIzaSyCzIImQ-Yw5ZSWLiGq3JDDMLn-dnBeVNMQ`
- Package Name: `com.example.ctrlzed`
- SHA-1 Fingerprint: `49:03:1D:04:08:2E:A4:A2:D1:B5:A1:7E:71:F0:BB:96:7D:9A:44:4C`

## Step-by-Step Configuration Guide

### 1. Access Google Cloud Console

Go directly to the API credentials page:
[https://console.cloud.google.com/apis/credentials](https://console.cloud.google.com/apis/credentials)

### 2. Select Your Project

If prompted, select your existing project or create a new one.

### 3. Find and Edit Your API Key

1. Look for your API key in the list (`AIzaSyCzIImQ-Yw5ZSWLiGq3JDDMLn-dnBeVNMQ`)
2. Click the pencil icon (Edit) next to your API key

### 4. Configure Android App Restrictions

1. Under "Application restrictions", select "Android apps"
2. Click "ADD AN ITEM" button
3. Enter the following information exactly as shown:
   - Package name: `com.example.ctrlzed`
   - SHA-1 certificate fingerprint: `49:03:1D:04:08:2E:A4:A2:D1:B5:A1:7E:71:F0:BB:96:7D:9A:44:4C`
4. Click "DONE"

### 5. Configure API Restrictions

1. Under "API restrictions", select "Restrict key"
2. Click "Select APIs" dropdown
3. Select ALL of the following APIs:
   - Maps SDK for Android
   - Places API
   - Geocoding API
   - Directions API
   - Maps JavaScript API
4. Click "OK"

### 6. Save Your Changes

Click the "SAVE" button at the bottom of the page

### 7. Enable Required APIs

Go to [https://console.cloud.google.com/apis/library](https://console.cloud.google.com/apis/library) and enable each of these APIs:

1. Maps SDK for Android
2. Places API
3. Geocoding API
4. Directions API
5. Maps JavaScript API

## Testing Your API Key

### Method 1: Test in the App

After configuring your API key, rebuild and run the app to test the nearby clinic feature. The map should now load properly and show nearby clinics.

### Method 2: Test with HTML Page

For a quick test of your API key configuration:

1. Open the included `test_google_maps_api.html` file in your web browser
2. If the map loads successfully, your API key is working for web usage
3. Note that this only tests the Maps JavaScript API - your app requires additional APIs and Android-specific configuration

## Troubleshooting

If you're still experiencing issues after following the steps above:

### 1. Verify API Enablement

Go to [https://console.cloud.google.com/apis/dashboard](https://console.cloud.google.com/apis/dashboard) and check that all 5 required APIs are enabled (showing "API Enabled" status).

### 2. Check SHA-1 Fingerprint

The SHA-1 fingerprint depends on which build you're running:

- Debug builds use the debug keystore SHA-1
- Release builds use the release keystore SHA-1

You may need to add both fingerprints to your API key configuration.

To get your debug SHA-1 fingerprint, run the included script:

- Windows: Double-click `get_sha1_fingerprint.bat`
- Mac/Linux: Run `./get_sha1_fingerprint.sh` in terminal

### 3. Verify Package Name

Make sure the package name in your API key configuration exactly matches your app's package name:
`com.example.ctrlzed`

### 4. Check Billing Status

Google Maps Platform requires a billing account. Go to [https://console.cloud.google.com/billing](https://console.cloud.google.com/billing) to verify your billing is set up correctly.

### 5. Clear API Key Cache

Sometimes the API key changes need time to propagate. Try:

1. Rebuilding your app completely (`flutter clean` then `flutter build`)
2. Waiting 5-10 minutes after making API key changes
3. Restarting your device

### 6. Check API Key Usage

Go to [https://console.cloud.google.com/apis/credentials/key/](https://console.cloud.google.com/apis/credentials/key/) and select your API key to see if there are any usage errors or warnings.

### 7. Test with a New API Key

If all else fails, try creating a new API key and configuring it from scratch following the steps above.
