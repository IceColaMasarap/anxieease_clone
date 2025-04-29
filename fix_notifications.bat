@echo off
echo Fixing Flutter Local Notifications plugin...

set PLUGIN_PATH=%USERPROFILE%\AppData\Local\Pub\Cache\hosted\pub.dev\flutter_local_notifications-13.0.0\android\src\main\java\com\dexterous\flutterlocalnotifications\FlutterLocalNotificationsPlugin.java

if not exist "%PLUGIN_PATH%" (
    echo Error: Plugin file not found at %PLUGIN_PATH%
    exit /b 1
)

echo Creating backup...
copy "%PLUGIN_PATH%" "%PLUGIN_PATH%.bak"

echo Applying fix...
powershell -Command "(Get-Content '%PLUGIN_PATH%') -replace 'bigPictureStyle.bigLargeIcon\(null\);', 'bigPictureStyle.bigLargeIcon((android.graphics.Bitmap) null);' | Set-Content '%PLUGIN_PATH%'"

echo Done! The plugin has been fixed.
echo Please run 'flutter clean' and then 'flutter run' to test the fix.
