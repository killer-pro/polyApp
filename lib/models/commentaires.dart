import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_app/models/utilisateur.dart';

class Commentaire {
  String id;
  String content;
  DateTime date;
  Utilisateur user;
  int likes;
  int dislikes;

  Commentaire(
      {required this.id,
      required this.content,
      required this.date,
      required this.user,
      required this.likes,
      required this.dislikes});

  factory Commentaire.fromJson(Map<String, dynamic> json) {
    return Commentaire(
        id: json['id'] as String,
        content: json['content'] as String,
        date: (json['date'] as Timestamp).toDate(),
        user: Utilisateur.fromJson(json['user']),
        likes: json['likes'] as int,
        dislikes: json['dislikes'] as int);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'date': date,
      'user': user.toJson(),
      'likes': likes,
      'dislikes': dislikes
    };
  }
}
