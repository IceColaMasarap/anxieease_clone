Write-Host "Fixing Flutter Local Notifications plugin..." -ForegroundColor Green

$pluginPath = "$env:USERPROFILE\AppData\Local\Pub\Cache\hosted\pub.dev\flutter_local_notifications-16.3.3\android\src\main\java\com\dexterous\flutterlocalnotifications\FlutterLocalNotificationsPlugin.java"

if (-not (Test-Path $pluginPath)) {
    Write-Host "Error: Plugin file not found at $pluginPath" -ForegroundColor Red
    exit 1
}

Write-Host "Creating backup..." -ForegroundColor Yellow
Copy-Item $pluginPath "$pluginPath.bak"

Write-Host "Applying fix..." -ForegroundColor Yellow
$content = Get-Content $pluginPath
$content = $content -replace 'bigPictureStyle\.bigLargeIcon\(null\);', 'bigPictureStyle.bigLargeIcon((android.graphics.Bitmap) null);'
Set-Content -Path $pluginPath -Value $content

Write-Host "Done! The plugin has been fixed." -ForegroundColor Green
Write-Host "Please run 'flutter clean' and then 'flutter run' to test the fix." -ForegroundColor Green
