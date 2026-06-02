import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:new_app/pages/annonce/hot_topics.dart';
import 'package:new_app/models/hot_topic.dart';
import 'package:new_app/services/notification_service.dart';

class HotTopicService {
  LocalNotificationService _local_notification = LocalNotificationService();
  final CollectionReference hotTopicsCollection =
      FirebaseFirestore.instance.collection('HOTTOPICS');

  Future<void> createHotTopic(HotTopic hotTopic) async {
    try {
      CollectionReference hotTopicsRef =
          FirebaseFirestore.instance.collection('HOTTOPICS');

      await hotTopicsRef.doc(hotTopic.id).set({
        'id': hotTopic.id,
        'title': hotTopic.title,
        'content': hotTopic.content,
        'category': hotTopic.category,
        'fileUrl': hotTopic.fileUrl,
        'dateCreation': Timestamp.fromDate(hotTopic.dateCreation),
      });

      await _local_notification.sendAllNotification(
          "${hotTopic.title} (${hotTopic.category})", "${hotTopic.content}");
    } catch (e) {
      throw e;
    }
  }

  Future<List<HotTopic>> getHotTopics() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('HOTTOPICS').get();
      return querySnapshot.docs.map((doc) {
        return HotTopic.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateHotTopic(HotTopic hotTopic) async {
    await FirebaseFirestore.instance
        .collection('HOTTOPICS')
        .doc(hotTopic.id)
        .update(hotTopic.toJson());
  }

  Future<void> deleteHotTopic(String id) async {
    try {
      CollectionReference hotTopicsRef =
          FirebaseFirestore.instance.collection('HOTTOPICS');
      await hotTopicsRef.doc(id).delete();

    } catch (e) {
      throw e;
    }
  }

  Future<List<HotTopic>> getHotTopicsByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('HOTTOPICS')
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs.map((doc) {
        return HotTopic.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw e;
    }
  }
}
