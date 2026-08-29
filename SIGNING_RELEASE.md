# Signature APK release

La signature finale est volontairement laissée avec une clé locale personnelle.

1. Générer la clé :

```powershell
keytool -genkeypair -v `
  -keystore android\app\upload-keystore.jks `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias upload
```

2. Créer `android/key.properties` :

```properties
storePassword=TON_MOT_DE_PASSE
keyPassword=TON_MOT_DE_PASSE
keyAlias=upload
storeFile=upload-keystore.jks
```

3. Ajouter `key.properties` et le `.jks` à `.gitignore`.

4. Configurer `signingConfigs.release` dans `android/app/build.gradle.kts`.

5. Construire :

```powershell
flutter clean
flutter pub get
flutter build apk --release
```

Le fichier final sera :

```text
build\app\outputs\flutter-apk\app-release.apk
```

Pour Google Play, préférer un Android App Bundle :

```powershell
flutter build appbundle --release
```
