import 'package:flutter/material.dart';

Widget deleteConfirmedDialog(BuildContext context, String message) {
  return AlertDialog(
    title: Text("Confirmer la suppression"),
    content: Text(message),
    actions: [
      TextButton(
        child: Text("Annuler"),
        onPressed: () {
          Navigator.of(context).pop(false); // Ne pas supprimer
        },
      ),
      TextButton(
        child: Text("Supprimer"),
        onPressed: () {
          Navigator.of(context).pop(true); // Confirmer la suppression
        },
      ),
    ],
  );
}
