import 'package:new_app/models/joueur.dart';

class Equipe {
  final String id;
  final String nom; // Team name
  final String logo;
  final List<Joueur> joueurs; // List of players

  Equipe(
      {required this.id,
      required this.nom,
      required this.joueurs,
      required this.logo});

  // Factory method to create an Equipe object from JSON
  factory Equipe.fromJson(Map<String, dynamic> json) {
    // Parse the 'joueurs' list from JSON and map it to a list of Joueur objects
    var joueursFromJson = json['joueurs'] as List<dynamic>;
    List<Joueur> joueursList =
        joueursFromJson.map((item) => Joueur.fromJson(item)).toList();

    return Equipe(
      id: json['id'] as String,
      nom: json['nom'] as String,
      logo: json['logo'] as String,
      joueurs: joueursList,
    );
  }

  // Method to convert an Equipe object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'logo': logo,
      'joueurs': joueurs
          .map((joueur) => joueur.toJson())
          .toList(), // Convert list of Joueur objects to JSON
    };
  }
}
