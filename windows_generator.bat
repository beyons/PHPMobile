@echo off
chcp 65001 >nul
cls

REM ============================================================
REM GÉNÉRATEUR DE PROJET ANDROID + PHP EMBARQUÉ - WINDOWS
REM ============================================================

echo.
echo ============================================================
echo   GÉNÉRATEUR DE PROJET ANDROID + PHP EMBARQUÉ
echo ============================================================
echo.

REM Vérifier que le dossier php7 existe à côté du script
if not exist "php7" (
    echo ❌ ERREUR : Le dossier 'php7' est introuvable !
    echo.
    echo Assurez-vous que la structure est :
    echo   📁 Votre dossier/
    echo      📄 generate-project.bat
    echo      📁 php7/           ^<-- DOIT ÊTRE ICI
    echo         📄 php ou php7
    echo         📁 lib/
    echo         etc...
    echo.
    pause
    exit /b 1
)

echo ✓ Dossier php7 détecté
echo.

REM Demander le nom du projet
set /p PROJECT_NAME="Nom du projet (ex: MonAppPHP) : "
if "%PROJECT_NAME%"=="" set PROJECT_NAME=MonAppPHP

REM Demander le package
set /p PACKAGE="Package Java (ex: com.monapp.php) : "
if "%PACKAGE%"=="" set PACKAGE=com.monapp.php

REM Convertir le package en chemin (remplacer . par \)
set PACKAGE_PATH=%PACKAGE:.=\%

echo.
echo Création du projet '%PROJECT_NAME%'...
echo.

REM Créer le dossier principal
mkdir "%PROJECT_NAME%" 2>nul
cd "%PROJECT_NAME%"

REM ============================================================
REM [1/9] Créer la structure
REM ============================================================
echo [1/9] Création de la structure...

mkdir "app\src\main\java\%PACKAGE_PATH%" 2>nul
mkdir "app\src\main\res\layout" 2>nul
mkdir "app\src\main\res\values" 2>nul
mkdir "app\src\main\res\mipmap-hdpi" 2>nul
mkdir "app\src\main\res\mipmap-mdpi" 2>nul
mkdir "app\src\main\res\mipmap-xhdpi" 2>nul
mkdir "app\src\main\res\mipmap-xxhdpi" 2>nul
mkdir "app\src\main\res\mipmap-xxxhdpi" 2>nul
mkdir "app\src\main\assets\php7" 2>nul
mkdir "app\src\main\assets\www" 2>nul
mkdir "app\src\main\assets\www\photos" 2>nul

echo       ✓ Structure créée

REM ============================================================
REM [2/9] Copier PHP7
REM ============================================================
echo [2/9] Copie du dossier php7...

xcopy /E /I /Y "..\php7" "app\src\main\assets\php7" >nul

if %ERRORLEVEL% EQU 0 (
    echo       ✓ PHP7 copié avec succès
    
    REM Vérifier le binaire
    if exist "app\src\main\assets\php7\php" (
        echo       ✓ Binaire 'php' détecté
    ) else if exist "app\src\main\assets\php7\php7" (
        echo       ✓ Binaire 'php7' détecté
    ) else (
        echo       ⚠ Attention : Aucun binaire PHP trouvé dans php7/
    )
) else (
    echo       ✗ Erreur lors de la copie de php7
)

REM ============================================================
REM [3/9] Copier Material & Cupertino (offline)
REM ============================================================
echo [3/9] Copie des librairies Material & Cupertino...

REM Créer les dossiers de destination
mkdir "app\src\main\assets\www\assets\material" 2>nul
mkdir "app\src\main\assets\www\assets\cupertino" 2>nul

REM Copier les fichiers depuis la racine
copy /Y "material.min.css" "app\src\main\assets\www\assets\material\" >nul
copy /Y "material.min.js"  "app\src\main\assets\www\assets\material\" >nul
copy /Y "cupertino.min.css" "app\src\main\assets\www\assets\cupertino\" >nul

echo ✓ Librairies copiées

REM ============================================================
REM [3/9] MainActivity.java
REM ============================================================
echo [3/9] Création de MainActivity.java...

(
echo package %PACKAGE%;
echo.
echo import android.os.Bundle;
echo import android.webkit.WebSettings;
echo import android.webkit.WebView;
echo import android.webkit.WebViewClient;
echo import android.widget.Toast;
echo import androidx.appcompat.app.AppCompatActivity;
echo import java.io.*;
echo import android.webkit.WebChromeClient;
echo import android.Manifest;
echo import android.content.pm.PackageManager;
echo import android.os.Build;
echo import android.webkit.PermissionRequest;
echo.
echo public class MainActivity extends AppCompatActivity {
echo.    
echo     private WebView webView;
echo     private Process phpProcess;
echo     private String phpPath;
echo     private String wwwPath;
echo.
echo     @Override
echo     protected void onCreate^(Bundle savedInstanceState^) {
echo         super.onCreate^(savedInstanceState^);
echo         setContentView^(R.layout.activity_main^);
echo.
echo         if ^(Build.VERSION.SDK_INT ^>= 23^) {
echo             if ^(checkSelfPermission^(Manifest.permission.ACCESS_FINE_LOCATION^)
echo                     != PackageManager.PERMISSION_GRANTED^) {
echo                 requestPermissions^(
echo                         new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
echo                         1
echo                 ^);
echo             }
echo         }
echo.
echo         if ^(Build.VERSION.SDK_INT ^>= 23^) {
echo             if ^(checkSelfPermission^(Manifest.permission.CAMERA^)
echo                     != PackageManager.PERMISSION_GRANTED^) {
echo                 requestPermissions^(
echo                         new String[]{Manifest.permission.CAMERA},
echo                         2
echo                 ^);
echo             }
echo         }
echo.
echo         phpPath = getFilesDir^(^) + "/php7";
echo         wwwPath = getFilesDir^(^) + "/www";
echo         webView = findViewById^(R.id.webview^);
echo         webView.addJavascriptInterface(new PHPBridge(this), "PHPBridge");
echo.        
echo         demarrerApplication^(^);
echo     }
echo.
echo     private void demarrerApplication^(^) {
echo         new Thread^(^(^) -^> {
echo             try {
echo                 installerPHP^(^);
echo                 demarrerServeurPHP^(^);
echo                 Thread.sleep^(2000^);
echo.                
echo                 runOnUiThread^(^(^) -^> {
echo                     configurerWebView^(^);
echo                     webView.loadUrl^("http://127.0.0.1:8080"^);
echo                     Toast.makeText^(this, "✓ Application démarrée", Toast.LENGTH_SHORT^).show^(^);
echo                 }^);
echo.                
echo             } catch ^(Exception e^) {
echo                 runOnUiThread^(^(^) -^>
echo                     Toast.makeText^(this, "Erreur: " + e.getMessage^(^), Toast.LENGTH_LONG^).show^(^)
echo                 ^);
echo             }
echo         }^).start^(^);
echo     }
echo.
echo     private void installerPHP^(^) throws IOException, InterruptedException {
echo         new File^(phpPath^).mkdirs^(^);
echo         new File^(wwwPath^).mkdirs^(^);
echo.
echo         copierDossierAssets^("php7", phpPath^);
echo.
echo         File phpBin = new File^(phpPath + "/php"^);
echo         if ^(!phpBin.exists^(^)^) {
echo             phpBin = new File^(phpPath + "/php7"^);
echo         }
echo.        
echo         if ^(phpBin.exists^(^)^) {
echo             phpBin.setExecutable^(true^);
echo             Runtime.getRuntime^(^).exec^("chmod 755 " + phpBin.getAbsolutePath^(^)^).waitFor^(^);
echo         }
echo.
echo         copierDossierAssets^("www", wwwPath^);
echo     }
echo.
echo     private void demarrerServeurPHP^(^) throws IOException {
echo         String phpBinary = phpPath + "/php";
echo         if ^(!new File^(phpBinary^).exists^(^)^) {
echo             phpBinary = phpPath + "/php7";
echo         }
echo.
echo         String phpIni = phpPath + "/php.ini";
echo.        
echo         String[] cmd;
echo         if ^(new File^(phpIni^).exists^(^)^) {
echo             cmd = new String[]{phpBinary, "-S", "127.0.0.1:8080", "-t", wwwPath, "-c", phpIni};
echo         } else {
echo             cmd = new String[]{phpBinary, "-S", "127.0.0.1:8080", "-t", wwwPath};
echo         }
echo.
echo         ProcessBuilder pb = new ProcessBuilder^(cmd^);
echo         phpProcess = pb.start^(^);
echo.
echo         new Thread^(^(^) -^> {
echo             try ^(BufferedReader br = new BufferedReader^(
echo                     new InputStreamReader^(phpProcess.getErrorStream^(^)^)^)^) {
echo                 String ligne;
echo                 while ^(^(ligne = br.readLine^(^)^) != null^) {
echo                     android.util.Log.e^("PHP", ligne^);
echo                 }
echo             } catch ^(Exception ignored^) {}
echo         }^).start^(^);
echo     }
echo.
echo     private void configurerWebView^(^) {
echo         WebSettings settings = webView.getSettings^(^);
echo         settings.setJavaScriptEnabled^(true^);
echo         settings.setDomStorageEnabled^(true^);
echo         settings.setAllowFileAccess^(true^);
echo         settings.setGeolocationEnabled^(true^);
echo.
echo         webView.setWebViewClient^(new WebViewClient^(^) {
echo             @Override
echo             public boolean shouldOverrideUrlLoading^(WebView view, String url^) {
echo                 view.loadUrl^(url^);
echo                 return true;
echo             }
echo         }^);
echo.
echo         webView.setWebChromeClient^(new WebChromeClient^(^) {
echo             @Override
echo             public void onGeolocationPermissionsShowPrompt^(
echo                     String origin,
echo                     GeolocationPermissions.Callback callback^) {
echo                 callback.invoke^(origin, true, false^);
echo             }
echo.
echo             @Override
echo             public void onPermissionRequest^(final PermissionRequest request^) {
echo                 request.grant^(request.getResources^(^)^);
echo             }
echo         }^);
echo     }
echo.
echo     private void copierAsset^(String assetPath, String destination^) throws IOException {
echo         try ^(InputStream in = getAssets^(^).open^(assetPath^);
echo              FileOutputStream out = new FileOutputStream^(destination^)^) {
echo             byte[] buffer = new byte[8192];
echo             int read;
echo             while ^(^(read = in.read^(buffer^)^) != -1^) {
echo                 out.write^(buffer, 0, read^);
echo             }
echo         }
echo     }
echo.
echo     private void copierDossierAssets^(String dossierAsset, String destination^) throws IOException {
echo         String[] fichiers = getAssets^(^).list^(dossierAsset^);
echo         if ^(fichiers == null ^|^| fichiers.length == 0^) return;
echo.
echo         new File^(destination^).mkdirs^(^);
echo.
echo         for ^(String fichier : fichiers^) {
echo             String assetPath = dossierAsset + "/" + fichier;
echo             String destPath = destination + "/" + fichier;
echo.
echo             String[] sousFichiers = getAssets^(^).list^(assetPath^);
echo             if ^(sousFichiers != null ^&^& sousFichiers.length ^> 0^) {
echo                 copierDossierAssets^(assetPath, destPath^);
echo             } else {
echo                 copierAsset^(assetPath, destPath^);
echo             }
echo         }
echo     }
echo.
echo     @Override
echo     public void onBackPressed^(^) {
echo         if ^(webView.canGoBack^(^)^) {
echo             webView.goBack^(^);
echo         } else {
echo             super.onBackPressed^(^);
echo         }
echo     }
echo.
echo     @Override
echo     protected void onDestroy^(^) {
echo         super.onDestroy^(^);
echo         if ^(phpProcess != null^) {
echo             phpProcess.destroy^(^);
echo         }
echo     }
echo }
) > "app\src\main\java\%PACKAGE_PATH%\MainActivity.java"

echo       ✓ MainActivity.java créé

REM ============================================================
REM [4/9] Création de PHPBridge.java
REM ============================================================
echo [4/9] Création de PHPBridge.java...

(
echo package %PACKAGE%;
echo.
echo import android.app.AlertDialog;
echo import android.content.Context;
echo import android.os.Vibrator;
echo import android.widget.Toast;
echo import android.app.Notification;
echo import android.app.NotificationChannel;
echo import android.app.NotificationManager;
echo import android.os.Build;
echo import android.content.ClipboardManager;
echo import android.content.ClipData;
echo import android.os.BatteryManager;
echo import android.content.Intent;
echo import android.content.IntentFilter;
echo import android.net.ConnectivityManager;
echo import android.net.NetworkInfo;
echo import android.net.wifi.WifiManager;
echo import android.net.wifi.WifiInfo;
echo import android.provider.Settings;
echo import android.media.MediaPlayer;
echo import android.media.MediaRecorder;
echo import android.hardware.Sensor;
echo import android.hardware.SensorManager;
echo import android.hardware.SensorEvent;
echo import android.hardware.SensorEventListener;
echo import android.location.Location;
echo import android.location.LocationListener;
echo import android.location.LocationManager;
echo import android.hardware.camera2.CameraManager;
echo import android.hardware.camera2.CameraAccessException;
echo import android.hardware.camera2.CameraDevice;
echo import android.hardware.camera2.CameraCaptureSession;
echo import android.hardware.camera2.CaptureRequest;
echo import android.os.Handler;
echo import android.os.HandlerThread;
echo import android.util.Log;
echo import java.io.File;
echo import java.io.FileOutputStream;
echo import java.io.InputStream;
echo import java.io.IOException;
echo import java.net.InetAddress;
echo.
echo public class PHPBridge {
echo.
echo     private Context context;
echo     private MediaPlayer mediaPlayer;
echo     private MediaRecorder mediaRecorder;
echo.
echo     public PHPBridge(Context ctx) {
echo         this.context = ctx;
echo     }
echo.
echo     // ================= TOAST & DIALOG =================
echo     public void showToast(String msg) {
echo         Toast.makeText(context, msg, Toast.LENGTH_SHORT).show();
echo     }
echo     public void showDialog(String title, String msg) {
echo         new AlertDialog.Builder(context).setTitle(title).setMessage(msg).setPositiveButton("OK", null).show();
echo     }
echo.
echo     // ================= VIBRATE =================
echo     public void vibrate(long ms) {
echo         Vibrator v = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
echo         if(v != null) v.vibrate(ms);
echo     }
echo.
echo     // ================= NOTIFICATION =================
echo     public void notify(String title, String msg, int id) {
echo         NotificationManager nm = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
echo         String channelId = "phpbridge_channel";
echo         if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
echo             NotificationChannel ch = new NotificationChannel(channelId, "PHPBridge Notifications", NotificationManager.IMPORTANCE_DEFAULT);
echo             nm.createNotificationChannel(ch);
echo         }
echo         Notification.Builder b = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ?
echo                 new Notification.Builder(context, channelId) :
echo                 new Notification.Builder(context);
echo         b.setContentTitle(title).setContentText(msg).setSmallIcon(android.R.drawable.ic_dialog_info);
echo         nm.notify(id, b.build());
echo     }
echo.
echo     // ================= BATTERY =================
echo     public int getBatteryLevel() {
echo         IntentFilter ifilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
echo         Intent batteryStatus = context.registerReceiver(null, ifilter);
echo         int level = batteryStatus != null ? batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) : -1;
echo         int scale = batteryStatus != null ? batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1) : -1;
echo         return (int)((level / (float)scale) * 100);
echo     }
echo.
echo     // ================= NETWORK =================
echo     public boolean isNetworkConnected() {
echo         ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
echo         NetworkInfo ni = cm.getActiveNetworkInfo();
echo         return ni != null && ni.isConnected();
echo     }
echo     public String getWifiInfo() {
echo         WifiManager wm = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
echo         WifiInfo info = wm.getConnectionInfo();
echo         return info.getSSID() + " | " + info.getIpAddress();
echo     }
echo     public boolean ping(String host) {
echo         try { return InetAddress.getByName(host).isReachable(3000); } catch(Exception e){ return false; }
echo     }
echo.
echo     // ================= CLIPBOARD =================
echo     public void copyToClipboard(String label, String text) {
echo         ClipboardManager cm = (ClipboardManager) context.getSystemService(Context.CLIPBOARD_SERVICE);
echo         cm.setPrimaryClip(ClipData.newPlainText(label, text));
echo     }
echo.
echo     // ================= MEDIA =================
echo     public void playSound(int resId) {
echo         stopSound();
echo         mediaPlayer = MediaPlayer.create(context, resId);
echo         mediaPlayer.start();
echo     }
echo     public void stopSound() {
echo         if(mediaPlayer != null) { mediaPlayer.stop(); mediaPlayer.release(); mediaPlayer = null; }
echo     }
echo.
echo     public void startRecording(String path) {
echo         stopRecording();
echo         mediaRecorder = new MediaRecorder();
echo         mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
echo         mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
echo         mediaRecorder.setOutputFile(path);
echo         mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
echo         try{ mediaRecorder.prepare(); mediaRecorder.start(); }catch(Exception e){ e.printStackTrace(); }
echo     }
echo     public void stopRecording() {
echo         if(mediaRecorder != null) { try{ mediaRecorder.stop(); }catch(Exception e){} mediaRecorder.release(); mediaRecorder = null; }
echo     }
echo.
echo     // ================= SENSORS =================
echo     public void listenAccelerometer(SensorEventListener listener) {
echo         SensorManager sm = (SensorManager) context.getSystemService(Context.SENSOR_SERVICE);
echo         Sensor sensor = sm.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
echo         sm.registerListener(listener, sensor, SensorManager.SENSOR_DELAY_NORMAL);
echo     }
echo.
echo     // ================= GPS =================
echo     public void listenGPS(LocationListener listener) {
echo         LocationManager lm = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
echo         try{ lm.requestLocationUpdates(LocationManager.GPS_PROVIDER, 1000, 1, listener); }catch(SecurityException e){ e.printStackTrace(); }
echo     }
echo.
echo     // ================= FLASH =================
echo     public void toggleFlash(boolean on) {
echo         CameraManager cm = (CameraManager) context.getSystemService(Context.CAMERA_SERVICE);
echo         try { cm.setTorchMode(cm.getCameraIdList()[0], on); } catch(CameraAccessException e){ e.printStackTrace(); }
echo     }
echo.
echo     // ================= CAMERA =================
echo     public void capturePhotoFrontBack(String path, boolean front) {
echo         CameraManager cm = (CameraManager) context.getSystemService(Context.CAMERA_SERVICE);
echo         try {
echo             String camId = cm.getCameraIdList()[front ? 1 : 0]; // 0=back, 1=front
echo             HandlerThread ht = new HandlerThread("CameraThread"); ht.start();
echo             Handler h = new Handler(ht.getLooper());
echo             cm.openCamera(camId, new CameraDevice.StateCallback() {
echo                 @Override public void onOpened(CameraDevice c) {
echo                     try {
echo                         CaptureRequest.Builder b = c.createCaptureRequest(CameraDevice.TEMPLATE_STILL_CAPTURE);
echo                         c.createCaptureSession(java.util.Collections.emptyList(), new CameraCaptureSession.StateCallback() {
echo                             @Override public void onConfigured(CameraCaptureSession session) {}
echo                             @Override public void onConfigureFailed(CameraCaptureSession session) {}
echo                         }, h);
echo                     } catch(Exception e){ e.printStackTrace(); }
echo                 }
echo                 @Override public void onDisconnected(CameraDevice c){ c.close(); }
echo                 @Override public void onError(CameraDevice c, int e){ c.close(); }
echo             }, h);
echo         } catch(CameraAccessException e){ e.printStackTrace(); }
echo     }
echo.
echo     // ================= SCREEN BRIGHTNESS =================
echo     public int getScreenBrightness() {
echo         try { return Settings.System.getInt(context.getContentResolver(), Settings.System.SCREEN_BRIGHTNESS); } catch(Exception e){ return -1; }
echo     }
echo     public void setScreenBrightness(int value) {
echo         try { Settings.System.putInt(context.getContentResolver(), Settings.System.SCREEN_BRIGHTNESS, value); } catch(Exception e){}
echo     }
echo.
echo     // ================= FILE / STORAGE =================
echo     public void copyAssetToFile(String assetName, String destPath) {
echo         try(InputStream in = context.getAssets().open(assetName);
echo             FileOutputStream out = new FileOutputStream(new File(destPath))) {
echo             byte[] buf = new byte[1024]; int len;
echo             while((len=in.read(buf))>0) out.write(buf,0,len);
echo         } catch(IOException e){ e.printStackTrace(); }
echo     }
echo.
echo }
) > "app\src\main\java\%PACKAGE_PATH%\PHPBridge.java"

echo       ✓ PHPBridge.java VERSION ULTIME créé avec succès

REM ============================================================
REM [4/9] activity_main.xml
REM ============================================================
echo [4/9] Création de activity_main.xml...

(
echo ^<?xml version="1.0" encoding="utf-8"?^>
echo ^<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
echo     android:layout_width="match_parent"
echo     android:layout_height="match_parent"^>
echo.
echo     ^<WebView
echo         android:id="@+id/webview"
echo         android:layout_width="match_parent"
echo         android:layout_height="match_parent" /^>
echo.
echo ^</RelativeLayout^>
) > "app\src\main\res\layout\activity_main.xml"

echo       ✓ activity_main.xml créé

REM ============================================================
REM [5/9] AndroidManifest.xml
REM ============================================================
echo [5/9] Création de AndroidManifest.xml...

(
echo ^<?xml version="1.0" encoding="utf-8"?^>
echo ^<manifest xmlns:android="http://schemas.android.com/apk/res/android"
echo     package="%PACKAGE%"^>
echo.
echo     ^<uses-permission android:name="android.permission.INTERNET" /^>
echo     ^<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" /^>
echo     ^<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" /^>
echo     ^<uses-permission android:name="android.permission.CAMERA" /^>
echo.
echo     ^<application
echo         android:allowBackup="true"
echo         android:icon="@mipmap/ic_launcher"
echo         android:label="%PROJECT_NAME%"
echo         android:theme="@style/Theme.AppCompat.Light.NoActionBar"
echo         android:usesCleartextTraffic="true"^>
echo.        
echo         ^<activity
echo             android:name=".MainActivity"
echo             android:exported="true"^>
echo             ^<intent-filter^>
echo                 ^<action android:name="android.intent.action.MAIN" /^>
echo                 ^<category android:name="android.intent.category.LAUNCHER" /^>
echo             ^</intent-filter^>
echo         ^</activity^>
echo     ^</application^>
echo.
echo ^</manifest^>
) > "app\src\main\AndroidManifest.xml"

echo       ✓ AndroidManifest.xml créé

REM ============================================================
REM [6/9] build.gradle (app)
REM ============================================================
echo [6/9] Création de build.gradle (app^)...

(
echo plugins {
echo     id 'com.android.application'
echo }
echo.
echo android {
echo     namespace '%PACKAGE%'
echo     compileSdk 34
echo.
echo     defaultConfig {
echo         applicationId "%PACKAGE%"
echo         minSdk 24
echo         targetSdk 34
echo         versionCode 1
echo         versionName "1.0"
echo     }
echo.
echo     buildTypes {
echo         release {
echo             minifyEnabled false
echo             proguardFiles getDefaultProguardFile^('proguard-android-optimize.txt'^), 'proguard-rules.pro'
echo         }
echo     }
echo.
echo     compileOptions {
echo         sourceCompatibility JavaVersion.VERSION_1_8
echo         targetCompatibility JavaVersion.VERSION_1_8
echo     }
echo }
echo.
echo dependencies {
echo     implementation 'androidx.appcompat:appcompat:1.6.1'
echo     implementation 'com.google.android.material:material:1.11.0'
echo }
) > "app\build.gradle"

echo       ✓ build.gradle (app^) créé

REM ============================================================
REM [7/9] build.gradle (root)
REM ============================================================
echo [7/9] Création de build.gradle (root^)...

(
echo buildscript {
echo     repositories {
echo         google^(^)
echo         mavenCentral^(^)
echo     }
echo     dependencies {
echo         classpath 'com.android.tools.build:gradle:8.2.0'
echo     }
echo }
echo.
echo allprojects {
echo     repositories {
echo         google^(^)
echo         mavenCentral^(^)
echo     }
echo }
echo.
echo task clean^(type: Delete^) {
echo     delete rootProject.buildDir
echo }
) > "build.gradle"

echo       ✓ build.gradle (root^) créé

REM ============================================================
REM [8/9] settings.gradle et gradle.properties
REM ============================================================
echo [8/9] Création des fichiers Gradle...

(
echo rootProject.name = '%PROJECT_NAME%'
echo include ':app'
) > "settings.gradle"

(
echo org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
echo android.useAndroidX=true
echo android.enableJetifier=true
) > "gradle.properties"

echo       ✓ Fichiers Gradle créés

REM ============================================================
REM [9/9] index.php
REM ============================================================
echo [9/9] Création de l'application PHP...

(
echo ^<?php
echo session_start^(^);
echo $page = $_GET['page'] ?? 'accueil';
echo $theme = $_GET['theme'] ?? 'material'; 
echo ?^>
echo ^<!DOCTYPE html^>
echo ^<html lang="fr"^>
echo ^<head^>
echo ^<meta charset="UTF-8"^>
echo ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^>
echo ^<title^>Mon Application PHP^</title^>
echo ^<?php if\(\$theme == 'material'\)\:?^>
echo     ^<link rel="stylesheet" href="assets/material/material.min.css"^>
echo     ^<script src="assets/material/material.min.js"^>^</script^>
echo ^<?php else : ^>
echo     ^<link rel="stylesheet" href="assets/cupertino/cupertino.min.css"^>
echo ^<?php endif; ^>
echo ^</head^>
echo     ^<meta charset="UTF-8"^>
echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^>
echo     ^<title^>Mon Application PHP^</title^>
echo     ^<style^>
echo         * { margin: 0; padding: 0; box-sizing: border-box; }
echo         body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f0f4f8; }
echo         .header { background: linear-gradient^(135deg, #667eea 0%%, #764ba2 100%%^); color: white; padding: 20px; text-align: center; box-shadow: 0 2px 10px rgba^(0,0,0,0.1^); }
echo         .container { padding: 20px; max-width: 800px; margin: 0 auto; }
echo         .card { background: white; border-radius: 15px; padding: 20px; margin-bottom: 20px; box-shadow: 0 2px 10px rgba^(0,0,0,0.05^); }
echo         .card h2 { color: #667eea; margin-bottom: 15px; }
echo         .btn { background: #667eea; color: white; border: none; padding: 12px 25px; border-radius: 8px; width: 100%%; margin-top: 10px; text-decoration: none; display: block; text-align: center; cursor: pointer; font-size: 16px; }
echo         .btn:active { background: #5568d3; }
echo         input, textarea { width: 100%%; padding: 12px; border: 2px solid #e2e8f0; border-radius: 8px; margin-bottom: 15px; font-size: 16px; }
echo         input:focus, textarea:focus { outline: none; border-color: #667eea; }
echo         .info { background: #edf2f7; padding: 15px; border-radius: 10px; margin-bottom: 10px; display: flex; justify-content: space-between; }
echo         .label { font-weight: 600; color: #4a5568; }
echo         .value { color: #667eea; font-family: monospace; }
echo         .nav { display: grid; grid-template-columns: repeat^(3, 1fr^); gap: 10px; margin-bottom: 20px; }
echo         .nav a { background: white; color: #667eea; padding: 15px; text-align: center; border-radius: 10px; text-decoration: none; font-weight: 600; box-shadow: 0 2px 5px rgba^(0,0,0,0.05^); }
echo         .nav a.active { background: #667eea; color: white; }
echo         .success { background: #48bb78; color: white; padding: 15px; border-radius: 10px; margin-bottom: 20px; text-align: center; }
echo     ^</style^>
echo ^</head^>
echo ^<body^>
echo     ^<div class="header"^>
echo         ^<h1^>📱 Mon Application PHP^</h1^>
echo         ^<p^>Application PHP embarquée dans Android^</p^>
echo     ^</div^>
echo     ^<div class="container"^>
echo         ^<div class="nav"^>
echo             ^<a href="?page=accueil" class="^<?= $page == 'accueil' ? 'active' : '' ?^>^"^>🏠 Accueil^</a^>
echo             ^<a href="?page=formulaire" class="^<?= $page == 'formulaire' ? 'active' : '' ?^>^"^>📝 Formulaire^</a^>
echo             ^<a href="?page=infos" class="^<?= $page == 'infos' ? 'active' : '' ?^>^"^>ℹ️ Infos^</a^>
echo         ^</div^>
echo         ^<?php
echo         switch^($page^) {
echo             case 'accueil':
echo                 echo '^<div class="card"^>^<h2^>🎉 Bienvenue !^</h2^>^<p style="color: #666; margin-bottom: 20px;"^>Votre application fonctionne parfaitement !^</p^>';
echo                 echo '^<div class="info"^>^<span class="label"^>Heure:^</span^>^<span class="value"^>' . date^('H:i:s'^) . '^</span^>^</div^>';
echo                 echo '^<div class="info"^>^<span class="label"^>Date:^</span^>^<span class="value"^>' . date^('d/m/Y'^) . '^</span^>^</div^>^</div^>';
echo                 break;
echo             case 'formulaire':
echo                 if ^($_SERVER['REQUEST_METHOD'] === 'POST'^) {
echo                     $_SESSION['nom'] = $_POST['nom'] ?? '';
echo                     echo '^<div class="success"^>✓ Message de ' . htmlspecialchars^($_SESSION['nom']^) . ' envoyé !^</div^>';
echo                 }
echo                 echo '^<div class="card"^>^<h2^>📝 Formulaire de contact^</h2^>';
echo                 echo '^<form method="POST"^>^<input type="text" name="nom" placeholder="Votre nom" required^>';
echo                 echo '^<textarea name="message" rows="4" placeholder="Votre message" required^>^</textarea^>';
echo                 echo '^<button type="submit" class="btn"^>Envoyer^</button^>^</form^>^</div^>';
echo                 break;
echo             case 'infos':
echo                 echo '^<div class="card"^>^<h2^>ℹ️ Informations système^</h2^>';
echo                 echo '^<div class="info"^>^<span class="label"^>Version PHP:^</span^>^<span class="value"^>' . phpversion^(^) . '^</span^>^</div^>';
echo                 echo '^<div class="info"^>^<span class="label"^>Système:^</span^>^<span class="value"^>' . PHP_OS . '^</span^>^</div^>';
echo                 echo '^<div class="info"^>^<span class="label"^>Memory Limit:^</span^>^<span class="value"^>' . ini_get^('memory_limit'^) . '^</span^>^</div^>^</div^>';
echo                 break;
echo         }
echo         ?^>
echo     ^</div^>
echo.
echo     ^<?php
echo         if ^(isset^($_SESSION['last_photo']^)^) {
echo             echo "^<img src='photos/{$_SESSION['last_photo']}' style='width:100%%;margin-top:15px;'^>";
echo         } 
echo     ?^>
echo.
echo     ^<button class="btn" onclick="getLocation()"^>📍 Ma position^</button^>
echo     ^<h2^>📷 Caméra^</h2^>
echo     ^<form method="POST" action="save_photo.php" enctype="multipart/form-data"^>
echo         ^<input type="file" name="photo" accept="image/*" capture="environment" required^>
echo         ^<button class="btn" type="submit"^>📸 Prendre la photo^</button^>
echo     ^</form^>
echo.
echo ^<script^>
echo function getLocation() {
echo     if (navigator.geolocation) {
echo         navigator.geolocation.getCurrentPosition(
echo             function(pos) {
echo                 alert(
echo                     "Latitude: " + pos.coords.latitude +
echo                     "\nLongitude: " + pos.coords.longitude
echo                 );
echo             },
echo             function(err) {
echo                 alert("Erreur GPS : " + err.message);
echo             }
echo         );
echo     } else {
echo         alert("Géolocalisation non supportée");
echo     }
echo }
echo ^</script^>
echo ^</body^>
echo ^</html^>
) > "app\src\main\assets\www\index.php"

REM ============================================================
REM PHP - save_photo.php
REM ============================================================
(
echo ^<?php
echo session_start^(^);
echo.
echo if ^(!isset^($_FILES['photo']^)^) {
echo     die^("Aucune photo reçue"^);
echo }
echo.
echo $dir = __DIR__ . "/photos";
echo if ^(!is_dir^($dir^)^) mkdir^($dir^);
echo.
echo $name = "photo_" . time^(^) . ".jpg";
echo move_uploaded_file^($_FILES['photo']['tmp_name'], "$dir/$name"^);
echo.
echo $_SESSION['last_photo'] = $name;
echo.
echo echo "📸 Photo enregistrée";
echo ?^>
) > "app\src\main\assets\www\save_photo.php"

echo       ✓ Application PHP créée

REM ============================================================
REM README
REM ============================================================
(
echo # Application Android + PHP Embarque
echo.
echo Ce projet a ete genere automatiquement avec PHP7 embarque.
echo.
echo ## Ouvrir dans Android Studio
echo.
echo 1. Ouvrir Android Studio
echo 2. File ^> Open
echo 3. Selectionner le dossier : %PROJECT_NAME%
echo 4. Attendre la synchronisation Gradle
echo 5. Build ^> Make Project
echo 6. Run ^> Run 'app'
echo.
echo ## Structure
echo.
echo app/src/main/
echo   assets/
echo     php7/    ^<-- Binaires PHP (deja copies^)
echo     www/     ^<-- Vos fichiers PHP
echo   java/      ^<-- Code Java
echo   res/       ^<-- Ressources Android
echo.
echo Bon developpement !
) > "README.txt"

REM ============================================================
REM FINALISATION
REM ============================================================
echo.
echo ============================================================
echo    ✓ PROJET CRÉÉ AVEC SUCCÈS !
echo ============================================================
echo.
echo Dossier créé : %CD%
echo.
echo Structure complète :
dir /B app\src\main\assets
echo.
echo ✓ PHP7 déjà copié et prêt
echo ✓ Application PHP créée
echo ✓ Code Java configuré
echo.
echo PROCHAINES ÉTAPES :
echo   1. Ouvrir Android Studio
echo   2. File ^> Open ^> Sélectionner : %CD%
echo   3. Attendre la synchronisation Gradle
echo   4. Build ^> Make Project
echo   5. Run ^> Run 'app'
echo.
echo Votre application PHP sera accessible à :
echo   http://127.0.0.1:8080
echo.
echo Bon développement ! 🚀
echo.

cd ..

pause