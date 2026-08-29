import 'package:cloud_firestore/cloud_firestore.dart';

class Redacteur {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String specialite;
  final String telephone;
  final bool actif;
  final DateTime? updatedAt;

  const Redacteur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.specialite,
    required this.telephone,
    this.actif = true,
    this.updatedAt,
  });

  String get nomComplet => '$prenom $nom'.trim();

  factory Redacteur.fromMap(Map<String, dynamic> map) {
    DateTime? date;
    final raw = map['updatedAt'];
    if (raw is int) {
      date = DateTime.fromMillisecondsSinceEpoch(raw);
    } else if (raw is String) {
      date = DateTime.tryParse(raw);
    } else if (raw is Timestamp) {
      date = raw.toDate();
    }
    return Redacteur(
      id: (map['id'] ?? '').toString(),
      nom: (map['nom'] ?? '').toString(),
      prenom: (map['prenom'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      specialite: (map['specialite'] ?? '').toString(),
      telephone: (map['telephone'] ?? '').toString(),
      actif: map['actif'] is bool ? map['actif'] as bool : true,
      updatedAt: date,
    );
  }

  factory Redacteur.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Redacteur.fromMap({
      ...data,
      'id': doc.id,
    });
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'specialite': specialite,
        'telephone': telephone,
        'actif': actif,
        'updatedAt': (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
      };

  Map<String, dynamic> toFirestoreMap() => {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'specialite': specialite,
        'telephone': telephone,
        'actif': actif,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Redacteur copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? email,
    String? specialite,
    String? telephone,
    bool? actif,
    DateTime? updatedAt,
  }) {
    return Redacteur(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      specialite: specialite ?? this.specialite,
      telephone: telephone ?? this.telephone,
      actif: actif ?? this.actif,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
