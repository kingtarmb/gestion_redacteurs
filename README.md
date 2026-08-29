# Gestion Rédacteurs — Magazine Infos

Application Flutter complète de gestion des rédacteurs.

## Fonctionnalités

- Authentification Firebase Email/Mot de passe
- Tableau de bord
- Ajout d’un rédacteur
- Modification d’un rédacteur
- Suppression avec confirmation
- Recherche et filtres
- SQLite pour le stockage local
- Synchronisation Firestore
- Architecture MVC
- Interface Material 3
- Mode local si Firebase n’est pas encore configuré

## Architecture

```text
lib/
├── main.dart
├── models/
│   └── redacteur.dart
├── controllers/
│   └── redacteur_controller.dart
├── services/
│   ├── auth_service.dart
│   ├── database_service.dart
│   └── sync_service.dart
└── views/
    ├── login_page.dart
    ├── dashboard_page.dart
    └── redacteur_form_page.dart
```

## Firebase Android

Le projet attend :

```text
android/app/google-services.json
```

Le fichier `google-services.json` est spécifique à TON projet Firebase et ne peut pas être inventé.

Dans Firebase :

1. Créer le projet.
2. Ajouter une application Android avec l’ID :
   `com.example.gestion_redacteurs`
3. Télécharger `google-services.json`.
4. Le placer dans `android/app/`.
5. Activer Authentication > Email/Password.
6. Créer Firestore Database.
7. Créer la collection `redacteurs`.

Les champs principaux sont :

- nom
- prenom
- email
- specialite
- telephone
- actif
- updatedAt

## Installation

Dans le dossier du projet :

```powershell
flutter pub get
flutter analyze
flutter test
```

Puis :

```powershell
flutter run
```

## APK debug

```powershell
flutter build apk --debug
```

Le fichier est généré dans :

```text
build\app\outputs\flutter-apk\app-debug.apk
```

## APK release signé

La signature définitive nécessite une clé personnelle. Générer une clé une seule fois :

```powershell
keytool -genkeypair -v `
  -keystore android\app\upload-keystore.jks `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias upload
```

Ne jamais publier le fichier `.jks` ni ses mots de passe.

Ensuite configurer `key.properties` et le `signingConfigs.release` de ton projet Android, puis :

```powershell
flutter build apk --release
```

## Important pour ton PC

La machine utilisée pour ce projet dispose de très peu de RAM disponible pendant les builds. Le fichier `android/gradle.properties` doit rester raisonnable, par exemple :

```properties
org.gradle.jvmargs=-Xmx2G -XX:MaxMetaspaceSize=512m -XX:ReservedCodeCacheSize=256m -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.newDsl=false
android.builtInKotlin=false
```

Fermer Chrome/Android Studio/VS Code inutilement lourds avant un build Android peut éviter un nouveau crash JVM.
"# gestion_redacteurs" 
