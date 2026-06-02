import 'package:new_app/models/joueur_jeu.dart';
import 'package:uuid/uuid.dart';

class SessionJeu {
  final DateTime date;
  final String lieu;
  final String id; // ID de la session
  final List<JoueurJeu> joueurs;
  final String creatorId; // ID de l'utilisateur qui a créé la session

  SessionJeu({
    required this.date,
    required this.lieu,
    required this.id,
    required this.joueurs,
    required this.creatorId,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'lieu': lieu,
      'id': id,
      'joueurs': joueurs.map((j) => j.toJson()).toList(),
      'creatorId': creatorId, // Inclure l'ID du créateur
    };
  }

  // Ajoute un fromJson pour récupérer les données
  factory SessionJeu.fromJson(Map<String, dynamic> json) {
    return SessionJeu(
      date: DateTime.parse(json['date']),
      lieu: json['lieu'],
      id: json['id'],
      joueurs:
          (json['joueurs'] as List).map((j) => JoueurJeu.fromJson(j)).toList(),
      creatorId: json['creatorId'], // Récupérer l'ID du créateur
    );
  }
}
