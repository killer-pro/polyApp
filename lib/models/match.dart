import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_app/models/commentaires.dart';
import 'package:new_app/models/enums/sport_type.dart';
import 'package:new_app/models/equipe.dart';
import 'package:new_app/models/utilisateur.dart';

class Matches {
  String id = "";
  DateTime date = DateTime.now();
  DateTime dateCreation = DateTime.now();
  Equipe equipeA = Equipe(id: "", nom: "", logo: "", joueurs: []);
  Equipe equipeB = Equipe(id: "", nom: "", logo: "", joueurs: []);
  int scoreEquipeA = 0;
  int scoreEquipeB = 0;
  SportType sport = SportType.FOOTBALL;
  List<Commentaire>? comments = [];
  List<Utilisateur?>? likers = [];
  List<Utilisateur?>? dislikers = [];
  String? partageLien = "";
  String? description = "";
  String? photo = "";

  Matches(
      {required this.id,
      required this.date,
      required this.dateCreation,
      required this.equipeA,
      required this.equipeB,
      required this.scoreEquipeA,
      required this.scoreEquipeB,
      required this.sport,
      required this.comments,
      this.likers,
      this.dislikers,
      this.partageLien,
      this.description,
      this.photo});

  // Factory method to create a Match object from JSON
  Matches.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        dateCreation = (json['dateCreation'] as Timestamp).toDate(),
        date = (json['date'] as Timestamp).toDate(),
        equipeA = Equipe.fromJson(json['equipeA'] as Map<String, dynamic>),
        equipeB = Equipe.fromJson(json['equipeB'] as Map<String, dynamic>),
        scoreEquipeA = json['scoreEquipeA'] as int,
        scoreEquipeB = json['scoreEquipeB'] as int,
        comments = (json['comments'] as List<dynamic>)
            .map((item) => Commentaire.fromJson(item))
            .toList(),
        likers = (json['likers'] as List<dynamic>)
            .map((item) => Utilisateur.fromJson(item))
            .toList(),
        dislikers = (json['dislikers'] as List<dynamic>)
            .map((item) => Utilisateur.fromJson(item))
            .toList(),
        sport = SportType.values.firstWhere(
          (e) => e.toString().split('.').last == json['sport'],
          // Valeur par défaut si la conversion échoue
        ),
        partageLien = json['partageLien'] as String,
        description = json['description'] as String,
        photo = json['photo'] as String;

  // Method to convert a Match object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateCreation': dateCreation,
      'date': date, // Convert DateTime to ISO 8601 string
      'equipeA': equipeA.toJson(),
      'equipeB': equipeB.toJson(),
      'scoreEquipeA': scoreEquipeA,
      'scoreEquipeB': scoreEquipeB,
      'description': description,
      'partageLien': partageLien,
      'photo': photo,
      'sport': sport.toString().split('.').last, // Convert enum to string
      'comments': comments!.map((comment) => comment.toJson()).toList(),
      'likers': likers!.map((liker) => liker!.toJson()).toList(),
      'dislikers': dislikers!.map((disliker) => disliker!.toJson()).toList(),
    };
  }
}
