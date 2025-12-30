# PHPMobile – Android Microframework and Very early IOS

PHPMobile is a lightweight, ultra-powerful microframework that allows you to develop Android apps entirely with PHP and JavaScript, while accessing native device features via a simple PHP-Java bridge.

## 🚀 Features

### Native Device Access from PHP/JS
- Toasts, dialogs, and local notifications  
- Vibrations and haptic feedback  
- Front/back camera capture & gallery access  
- Microphone recording & audio playback  
- GPS, accelerometer, battery, screen brightness  
- Network info, Wi-Fi info, ping, network speed  
- File system read/write, storage management, clipboard  

### Bidirectional Bridge
- Call Android functions directly from PHP  
- Return results back to PHP  
- WebView JavaScript can also interact with PHPBridgeUltimate  

### Flexible UI
- Material Design or iOS/Cupertino styles  
- Switch themes dynamically via PHP  

### Embedded PHP Runtime
- No external server needed  
- Full PHP capabilities: sessions, file I/O, networking  

### Extensible
- Add new native functions or modules easily  
- Ideal for sensors, multimedia, device controls  

## 🛠 Installation

1. Make sure `php7` folder with binaries exists alongside `generate-project.bat`.  
2. Run `generate-project.bat`.  
3. Follow prompts for project name and package.  
4. Open the generated project in Android Studio.  
5. Wait for Gradle sync, then **Build & Run**.  

## 📂 Project Structure
app/src/main/
├── assets/
│ ├── php7/ <-- Embedded PHP binaries
│ └── www/ <-- Your PHP + HTML + JS code
├── java/ <-- Java code including PHPBridgeUltimate
└── res/ <-- Android resources (layouts, drawables, etc.)
