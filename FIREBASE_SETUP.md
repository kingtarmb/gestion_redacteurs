# Configuration Firebase

Ce projet contient le code Firebase, mais pas le fichier `google-services.json`, car ce fichier appartient à ton projet Firebase.

## 1. Identifiant Android

Utiliser :

`com.example.gestion_redacteurs`

## 2. Firebase Authentication

Firebase Console > Authentication > Sign-in method > Email/Password > Enable.

## 3. Firestore

Créer une base Firestore.

Collection :

`redacteurs`

Exemple :

```text
redacteurs/
  ABC123
    nom: "Doe"
    prenom: "John"
    email: "john@example.com"
    specialite: "Sport"
    telephone: "+235..."
    actif: true
    updatedAt: timestamp
```

## 4. Google Services

Télécharger `google-services.json` puis :

```text
android/app/google-services.json
```

Le projet Android existant doit conserver le plugin :

```kotlin
id("com.google.gms.google-services")
```

dans `android/app/build.gradle.kts`.

## 5. Synchronisation

La couche `SyncService` centralise Firestore.

La couche `DatabaseService` centralise SQLite.

La vue ne parle jamais directement à Firestore : elle passe par `RedacteurController`.
