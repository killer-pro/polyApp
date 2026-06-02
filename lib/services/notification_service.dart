import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
class LocalNotificationService {
  LocalNotificationService();

  final localNotificationService = FlutterLocalNotificationsPlugin();

  Future<void> initialize(BuildContext context) async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true);

    final InitializationSettings settings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: darwinInitializationSettings);

    await localNotificationService.initialize(settings);
  }

  Future<NotificationDetails> notificationDetails() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel_id', 'channel_name',
            channelDescription: 'Description',
            importance: Importance.max,
            priority: Priority.max,
            icon: 'launch_background',
            styleInformation: BigTextStyleInformation(''),
            playSound: true);

    const DarwinNotificationDetails ioSNotificationDetails =
        DarwinNotificationDetails();

    return const NotificationDetails(
        android: androidNotificationDetails, iOS: ioSNotificationDetails);
  }

  Future<void> showNotification(
      {required int id, required String title, required String body}) async {
    final details = await notificationDetails();
    await localNotificationService.show(id, title, body, details);
  }

  /// Envoie une notification à tous les appareils actifs via Cloud Function
  /// et persiste la notification dans Firestore pour l'historique.
  Future<void> sendAllNotification(String title, String body) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('sendNotification');
      await callable.call({'title': title, 'body': body});
    } catch (e) {
      debugPrint('Erreur envoi notification : $e');
    }
    try {
      final doc = FirebaseFirestore.instance.collection('NOTIFICATION').doc();
      await doc.set({
        'id': doc.id,
        'titre': title,
        'corps': body,
        'date': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Erreur sauvegarde historique notification : $e');
    }
  }

  String? mtoken;
  bool userauth = false;
}
