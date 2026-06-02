import 'package:cloud_firestore/cloud_firestore.dart';

class Avis {
  final String id;
  final String userId; // email de l'auteur
  final String prenom;
  final String nom;
  final String? photo;
  final int note; // 1 à 5
  final String commentaire;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Avis({
    required this.id,
    required this.userId,
    required this.prenom,
    required this.nom,
    this.photo,
    required this.note,
    required this.commentaire,
    required this.createdAt,
    this.updatedAt,
  });

  factory Avis.fromJson(Map<String, dynamic> json) {
    return Avis(
      id: json['id'] as String,
      userId: json['userId'] as String,
      prenom: json['prenom'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      photo: json['photo'] as String?,
      note: (json['note'] as num?)?.toInt() ?? 0,
      commentaire: json['commentaire'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'prenom': prenom,
      'nom': nom,
      'photo': photo,
      'note': note,
      'commentaire': commentaire,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
