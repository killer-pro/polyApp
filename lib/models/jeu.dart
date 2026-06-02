import 'package:new_app/models/enums/jeu_type.dart';
import 'package:uuid/uuid.dart';
import 'session_jeu.dart'; // Import SessionJeu class

class Jeu {
  final String id;
  final String nom;
  final String logo;
  final String regle;
  final JeuType jeuType;
  final List<SessionJeu> sessions;

  Jeu(
      {required this.id,
      required this.nom,
      required this.logo,
      required this.jeuType,
      required this.sessions,
      required this.regle});

  // Factory method to create a Jeu object from JSON
  factory Jeu.fromJson(Map<String, dynamic> json) {
    var sessionsFromJson = json['sessions'] as List<dynamic>;
    List<SessionJeu> sessionList =
        sessionsFromJson.map((item) => SessionJeu.fromJson(item)).toList();

    return Jeu(
        id: json['id'] as String,
        nom: json['nom'] as String,
        logo: json['logo'] as String,
        jeuType: JeuType.values
            .firstWhere((e) => e.toString() == 'JeuType.${json['jeuType']}'),
        sessions: sessionList,
        regle: json['regle'] as String);
  }

  // Method to convert a Jeu object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'logo': logo,
      "regle": regle,
      "jeuType": jeuType.toString().split('.').last,
      'sessions': sessions
          .map((session) => session.toJson())
          .toList(), // Convert list of SessionJeu objects to JSON
    };
  }
}
