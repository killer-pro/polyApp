import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages

class HotTopic {
  final String id;
  final String title;
  final String content;
  final String category;
  final String? fileUrl;
  final DateTime dateCreation;
  final String? userId; // Auteur du hot topic

  HotTopic({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.fileUrl,
    required this.dateCreation,
    this.userId,
  });

  factory HotTopic.fromJson(Map<String, dynamic> json) {
    return HotTopic(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      fileUrl: json['fileUrl'],
      dateCreation: (json['dateCreation'] as Timestamp).toDate(),
      userId: json['userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'fileUrl': fileUrl,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'userId': userId,
    };
  }
}
