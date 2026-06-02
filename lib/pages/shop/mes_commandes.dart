import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/commande.dart';
import 'package:new_app/models/article_shop.dart';
import 'package:new_app/models/utilisateur.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserCommandeListPage extends StatelessWidget {
  final CollectionReference _commandeCollection =
      FirebaseFirestore.instance.collection('COMMANDE');
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('USER');
  final CollectionReference _articleCollection =
      FirebaseFirestore.instance.collection('ARTICLE');
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  Future<Map<String, dynamic>> _getCommandeDetails(Commande commande) async {
    DocumentSnapshot articleSnapshot =
        await _articleCollection.doc(commande.produitId).get();
    ArticleShop article =
        ArticleShop.fromJson(articleSnapshot.data() as Map<String, dynamic>);

    return {
      'commande': commande,
      'prix': article.prix,
      'libelle': article.titre,
    };
  }

  Future<void> _deleteCommande(String commandeId) async {
    await _commandeCollection.doc(commandeId).delete();
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String commandeId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation de suppression'),
          content: Text('Voulez-vous vraiment supprimer cette commande ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Supprimer', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await _deleteCommande(commandeId);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Commande supprimée.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Center(
        child: Text("Aucun utilisateur connecté."),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Mes Commandes"),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _commandeCollection
            .where('userId', isEqualTo: _currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LinearProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Une erreur est survenue."));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Aucune commande trouvée."));
          }

          List<DocumentSnapshot> commandesDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: commandesDocs.length,
            itemBuilder: (context, index) {
              Commande commande = Commande.fromJson(
                  commandesDocs[index].data() as Map<String, dynamic>);

              return FutureBuilder<Map<String, dynamic>>(
                future: _getCommandeDetails(commande),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text("Chargement des détails..."),
                      subtitle: LinearProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return ListTile(
                      title: Text("Erreur de chargement des détails"),
                    );
                  }

                  var commandeData = snapshot.data!;
                  int prix = commandeData['prix'];
                  int prixTotal = prix * commande.nombre;
                  String libelle = commandeData['libelle'];

                  return ListTile(
                    title: Text("Commande de $libelle"),
                    subtitle: Text(
                        "Quantité: ${commande.nombre}\nPrix: $prixTotal FCFA\nDate: ${simpleDateformat(commande.date)}"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, commande.id);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
