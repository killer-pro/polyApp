import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_app/models/buteur.dart';
import 'package:new_app/models/commentaires.dart';
import 'package:new_app/models/enums/sport_type.dart';
import 'package:new_app/models/equipe.dart';
import 'package:new_app/models/joueur.dart';
import 'package:new_app/models/match.dart';
import 'package:new_app/models/utilisateur.dart';

class Volleyball extends Matches {
  final List<But>? buteursA;
  final List<But>? buteursB;
  final Map<String, int> statistiques;

  Volleyball(
      {this.buteursA,
      this.buteursB,
      required this.statistiques,
      required String id,
      required DateTime date,
      dateCreation,
      description,
      photo,
      required Equipe equipeA,
      required Equipe equipeB,
      required int scoreEquipeA,
      required int scoreEquipeB,
      required SportType sport,
      required List<Commentaire> comments,
      required List<Utilisateur> likers,
      required List<Utilisateur> dislikers,
      required String partageLien})
      : super(
            id: id,
            date: date,
            dateCreation: dateCreation,
            equipeA: equipeA,
            equipeB: equipeB,
            scoreEquipeA: scoreEquipeA,
            scoreEquipeB: scoreEquipeB,
            sport: sport,
            comments: comments,
            likers: likers,
            dislikers: dislikers,
            partageLien: partageLien,
            description: description,
            photo: photo);

  Volleyball.fromJson(Map<String, dynamic> json)
      : buteursA = (json['buteursA'] as List<dynamic>?)
            ?.map((item) => But.fromJson(item))
            .toList(),
        buteursB = (json['buteursB'] as List<dynamic>?)
            ?.map((item) => But.fromJson(item))
            .toList(),
        statistiques = Map<String, int>.from(json['statistiques']),
        super.fromJson(json);

  Map<String, dynamic> toJson() {
    final data = super.toJson(); // Appelle le toJson() de Matches
    data['buteursA'] = buteursA?.map((buteur) => buteur.toJson()).toList();
    data['buteursB'] = buteursB?.map((buteur) => buteur.toJson()).toList();
    data['statistiques'] = statistiques;
    return data;
  }
}
