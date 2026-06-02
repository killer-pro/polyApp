import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/commande.dart';
import 'package:new_app/models/article_shop.dart';
import 'package:new_app/models/utilisateur.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/app_loader.dart';

class CommandeListPage extends StatefulWidget {
  @override
  State<CommandeListPage> createState() => _CommandeListPageState();
}

class _CommandeListPageState extends State<CommandeListPage> {
  final CollectionReference _commandeCollection =
      FirebaseFirestore.instance.collection('COMMANDE');

  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('USER');

  final CollectionReference _articleCollection =
      FirebaseFirestore.instance.collection('ARTICLE');

  // Récupère l'utilisateur et l'article associés à chaque commande
  Future<Map<String, dynamic>> _getCommandeDetails(Commande commande) async {
    // Récupérer l'utilisateur (nom et prénom)
    DocumentSnapshot userSnapshot =
        await _userCollection.doc(commande.userId).get();
    Utilisateur utilisateur =
        Utilisateur.fromJson(userSnapshot.data() as Map<String, dynamic>);

    // Récupérer l'article (libelle)
    DocumentSnapshot articleSnapshot =
        await _articleCollection.doc(commande.produitId).get();
    ArticleShop article =
        ArticleShop.fromJson(articleSnapshot.data() as Map<String, dynamic>);

    return {
      'commande': commande,
      'prenom': utilisateur.prenom,
      'nom': utilisateur.nom,
      'libelle': article.titre,
      'prix': article.prix,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des Commandes"),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _commandeCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: AppLoader());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Une erreur est survenue."));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Aucune commande trouvée."));
          }

          List<DocumentSnapshot> commandesDocs =
              snapshot.data!.docs.reversed.toList();

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
                  String prenom = commandeData['prenom'];
                  String nom = commandeData['nom'];
                  String libelle = commandeData['libelle'];
                  int prixTotal = commandeData['prix'] * commande.nombre;

                  return ListTile(
                    title: Text("Commande de $prenom $nom"),
                    subtitle: Text(
                        "Article: $libelle\nQuantité: ${commande.nombre}\nPrix: $prixTotal FCFA\nDate: ${simpleDateformat(commande.date)}"),
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
