import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_app/models/joueur.dart';
import 'package:new_app/models/utilisateur.dart';

class But {
  String id;
  DateTime date;
  Joueur joueur;
  int minute;
  int point;

  But(
      {required this.id,
      required this.date,
      required this.joueur,
      required this.minute,
      required this.point});

  factory But.fromJson(Map<String, dynamic> json) {
    return But(
        id: json['id'] as String,
        date: (json['date'] as Timestamp).toDate(),
        joueur: Joueur.fromJson(json['joueur']),
        minute: json['minute'] as int, // Convertir minute
        point: json['point'] as int);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'joueur': joueur.toJson(),
      'minute': minute, // Ajouter minute à toJson
      'point': point
    };
  }
}
