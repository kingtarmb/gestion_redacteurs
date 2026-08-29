import 'dart:async';


import '../models/redacteur.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';

class RedacteurController {
  RedacteurController({
    DatabaseService? database,
    SyncService? sync,
  })  : _database = database ?? DatabaseService.instance,
        _sync = sync ?? SyncService();

  final DatabaseService _database;
  final SyncService _sync;

  Stream<List<Redacteur>> localStream() async* {
    yield* Stream.periodic(const Duration(milliseconds: 500))
        .asyncMap((_) => _database.getAll());
  }

  Future<List<Redacteur>> getLocal() => _database.getAll();

  Future<void> ajouterRedacteur({
    required String nom,
    required String prenom,
    required String email,
    required String specialite,
    required String telephone,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final r = Redacteur(
      id: id,
      nom: nom.trim(),
      prenom: prenom.trim(),
      email: email.trim(),
      specialite: specialite.trim(),
      telephone: telephone.trim(),
      updatedAt: DateTime.now(),
    );
    await _database.upsert(r);
    try {
      await _sync.push(r);
    } catch (_) {
      // Mode hors ligne : la donnée reste dans SQLite.
    }
  }

  Future<void> modifierRedacteur(Redacteur r) async {
    final updated = r.copyWith(updatedAt: DateTime.now());
    await _database.upsert(updated);
    try {
      await _sync.push(updated);
    } catch (_) {}
  }

  Future<void> supprimerRedacteur(String id) async {
    await _database.delete(id);
    try {
      await _sync.deleteRemote(id);
    } catch (_) {}
  }

  Future<int> synchroniser() async {
    final count = await _sync.pullToLocal();
    return count;
  }
}
