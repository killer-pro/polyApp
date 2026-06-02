import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_app/widgets/app_loader.dart';

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des utilisateurs'),
      ),
      body: UserList(),
    );
  }
}

class UserList extends StatelessWidget {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('USER'); // Accès à la collection "User"

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: users.snapshots(), // Écouter les changements en temps réel
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Erreur : ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppLoader();
        }

        // Récupérer et afficher uniquement le champ "nom"
        final userDocs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: userDocs.length,
          itemBuilder: (context, index) {
            // On récupère le champ "nom"
            final nom = userDocs[index]['nom'];

            return ListTile(
              title: Text(nom), // Affiche le nom de l'utilisateur
            );
          },
        );
      },
    );
  }
}
