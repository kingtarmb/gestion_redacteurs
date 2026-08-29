import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/redacteur.dart';
import 'database_service.dart';

class SyncService {
  SyncService({
    FirebaseFirestore? firestore,
    DatabaseService? database,
  })  : _firestore = firestore ?? _getFirestore(),
        _database = database ?? DatabaseService.instance;

  final FirebaseFirestore? _firestore;
  final DatabaseService _database;

  static FirebaseFirestore? _getFirestore() {
    try {
      // Vérifie d'abord si Firebase est initialisé.
      Firebase.app();
      return FirebaseFirestore.instance;
    } catch (_) {
      // Firebase n'est pas disponible.
      // L'application continue en mode SQLite local.
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? get _collection =>
      _firestore?.collection('redacteurs');

  /// Récupère les rédacteurs depuis Firebase.
  ///
  /// Si Firebase n'est pas disponible, retourne simplement
  /// un flux vide. SQLite reste indépendant.
  Stream<List<Redacteur>> watchRemote() {
    final collection = _collection;

    if (collection == null) {
      return Stream.value(<Redacteur>[]);
    }

    return collection.snapshots().map(
          (snapshot) =>
              snapshot.docs.map(Redacteur.fromFirestore).toList(),
        );
  }

  /// Envoie un rédacteur vers Firebase puis met à jour SQLite.
  Future<void> push(Redacteur redacteur) async {
    final collection = _collection;

    if (collection != null) {
      await collection.doc(redacteur.id).set(
            redacteur.toFirestoreMap(),
            SetOptions(merge: true),
          );
    }

    // SQLite reste toujours mis à jour.
    await _database.upsert(
      redacteur.copyWith(
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Supprime un rédacteur de Firebase puis de SQLite.
  Future<void> deleteRemote(String id) async {
    final collection = _collection;

    if (collection != null) {
      await collection.doc(id).delete();
    }

    await _database.delete(id);
  }

  /// Télécharge les rédacteurs Firebase vers SQLite.
  ///
  /// Si Firebase n'est pas disponible, retourne 0.
  Future<int> pullToLocal() async {
    final collection = _collection;

    if (collection == null) {
      return 0;
    }

    final snapshot = await collection.get();

    for (final doc in snapshot.docs) {
      final redacteur = Redacteur.fromFirestore(doc);

      await _database.upsert(
        redacteur.copyWith(
          updatedAt: DateTime.now(),
        ),
      );
    }

    return snapshot.docs.length;
  }
}