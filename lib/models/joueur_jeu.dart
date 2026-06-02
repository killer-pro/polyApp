import 'package:new_app/models/utilisateur.dart';
import 'package:uuid/uuid.dart';

class JoueurJeu extends Utilisateur {
  final String id;
  final bool waiting;

  JoueurJeu(
      {required this.id,
      required this.waiting,
      required email,
      required prenom,
      required nom})
      : super(email: email, prenom: prenom, nom: nom);

  // Factory method to create a JoueurJeu object from JSON
  factory JoueurJeu.fromJson(Map<String, dynamic> json) {
    return JoueurJeu(
      id: json['id'] as String,
      nom: json['nom'] as String,
      waiting: json['waiting'] as bool,
      email: json['email'] as String,
      prenom: json['prenom'] as String,
    );
  }

  // Method to convert a Joueur object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'waiting': waiting,
    };
  }
}
