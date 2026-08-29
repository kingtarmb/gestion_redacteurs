import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/redacteur.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'gestion_redacteurs.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE redacteurs(
            id TEXT PRIMARY KEY,
            nom TEXT NOT NULL,
            prenom TEXT NOT NULL,
            email TEXT NOT NULL,
            specialite TEXT NOT NULL,
            telephone TEXT NOT NULL,
            actif INTEGER NOT NULL DEFAULT 1,
            updatedAt INTEGER
          )
        ''');
      },
    );
    return _db!;
  }

  Future<List<Redacteur>> getAll() async {
    final db = await database;
    final rows = await db.query('redacteurs', orderBy: 'nom ASC, prenom ASC');
    return rows.map(Redacteur.fromMap).toList();
  }

  Future<void> upsert(Redacteur r) async {
    final db = await database;
    await db.insert(
      'redacteurs',
      r.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    final db = await database;
    await db.delete('redacteurs', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete('redacteurs');
  }
}
