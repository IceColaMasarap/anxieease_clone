@echo off
echo Getting SHA-1 fingerprint for AnxieEase app...
cd android
call gradlew signingReport
cd ..
echo.
echo Look for the SHA-1 fingerprint in the output above.
echo Use this fingerprint to configure your Google Maps API key in the Google Cloud Console.
echo See CONFIGURE_GOOGLE_MAPS_API.md for detailed instructions.
pause
