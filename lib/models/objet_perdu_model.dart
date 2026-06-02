import 'package:uuid/uuid.dart';
import 'utilisateur.dart';
import 'package:new_app/models/enums/statut_objet_perdu.dart';

class ObjetPerdu {
  final String description; // Description of the lost object
  final String details;
  final String? photoURL;
  final String lieu; // Place where the object was lost
  final String date; // Date when the object was lost
  final int estTrouve; // Status of the object (PERDU or RETROUVE)
  final String? idUser; // celui qui a signalé l'objet perdu

  ObjetPerdu({
    required this.description,
    required this.details,
    required this.photoURL,
    required this.lieu,
    required this.date,
    required this.estTrouve,
    required this.idUser
  });

  // Factory method to create an ObjetPerdu object from JSON
  factory ObjetPerdu.fromJson(Map<String, dynamic> json) {
    return ObjetPerdu(
      description: json['description'] as String,
      details: json['details'],
      photoURL: json['photoURL'] as String,
      lieu: json['lieu'] as String,
      date: json['date'],
      estTrouve: json['etat'] as int,
      idUser: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'details': details,
      'photoURL': photoURL,
      'lieu': lieu,
      'date': date,
      'etat': estTrouve,
      'user': idUser,
    };
  }
}
