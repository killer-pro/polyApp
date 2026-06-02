// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

void changerPage(BuildContext context, Widget destination) {
  Navigator.push(
    context,
    PageTransition(
      type: PageTransitionType.fade,
      child: destination,
      duration: const Duration(milliseconds: 150),
    ),
  );
}

String formatDateTime(DateTime dateTime) {
  // Créer un format pour le jour de la semaine, jour, mois, année et l'heure
  final DateFormat dayFormat =
      DateFormat.EEEE('fr'); // Format pour le jour de la semaine en français
  final DateFormat dateFormat =
      DateFormat('d MMMM yyyy', 'fr'); // Format pour le jour, mois et année
  final DateFormat timeFormat = DateFormat('HH:mm'); // Format pour l'heure

  // Obtenir les parties du format
  String dayOfWeek = dayFormat.format(dateTime).capitalize();
  String date = dateFormat.format(dateTime);
  String time = timeFormat.format(dateTime);

  return "$dayOfWeek $date à $time";
}

// Extension pour capitaliser la première lettre
extension StringCasingExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

String timeAgoCustom(DateTime d) {
  // <-- Custom method Time Show  (Display Example  ==> 'Today 7:00 PM')     // WhatsApp Time Show Status Shimila
  Duration diff = DateTime.now().difference(d);
  if (diff.inDays > 365)
    return "Il y'a " +
        "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "année" : "années"}";
  if (diff.inDays > 30)
    return "Il y'a " +
        "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "mois" : "mois"}";
  if (diff.inDays > 7)
    return "Il y'a " +
        "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "semaine" : "semaines"}";
  if (diff.inDays > 0)
    return "Il y'a " + "${diff.inDays} ${diff.inDays == 1 ? "jour" : "jours"}";
  //"${DateFormat.E().add_jm().format(d)}";
  if (diff.inHours > 0)
    return "Il y'a " +
        "${diff.inHours} ${diff.inHours == 1 ? "heure" : "heures"}";
  //return "Today ${DateFormat('jm').format(d)}";
  if (diff.inMinutes > 0)
    return "Il y'a " +
        "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"}";
  return "Maintenant";
}

String dateCustomformat(DateTime d) {
  final newFormatter = DateFormat("EEEE dd MMMM yyyy à HH:mm", "fr");
  final newFormatString = newFormatter.format(d);

  final result =
      newFormatString[0].toUpperCase() + newFormatString.substring(1);
  return result;
}

String simpleDateformat(DateTime d) {
  final newFormatter = DateFormat("EEEE dd MMMM", "fr");
  final newFormatString = newFormatter.format(d);

  final result =
      newFormatString[0].toUpperCase() + newFormatString.substring(1);
  return result;
}

String getHour(DateTime d) {
  final newFormatter = DateFormat("HH:mm", "fr");
  final newFormatString = newFormatter.format(d);

  final result =
      newFormatString[0].toUpperCase() + newFormatString.substring(1);
  return result;
}

void ouvrirLien(BuildContext context, String url) async {
  final Uri uri = Uri.parse(Uri.encodeFull(url)); // Encode l'URL
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Impossible d\'ouvrir le lien')),
    );
  }
}
