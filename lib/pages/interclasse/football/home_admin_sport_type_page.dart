import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_app/pages/annonce/add_categorie.dart';
import 'package:new_app/pages/drawer/admin/admin_shop.dart';
import 'package:new_app/pages/drawer/admin/admin_sport.dart';
import 'package:new_app/pages/interclasse/football/create_equipe.dart';
import 'package:new_app/pages/interclasse/football/voir_match_admin.dart';
import 'package:new_app/pages/shop/afficher_commandes.dart';
import 'package:new_app/pages/shop/create_collection.dart';
import 'package:new_app/pages/shop/gestion_article.dart';
import 'package:new_app/pages/shop/gestion_categorie_shop.dart';
import 'package:new_app/pages/shop/gestion_collection.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/models/collection.dart';
import 'package:new_app/models/match.dart';
import 'package:new_app/pages/interclasse/football/create_match.dart';
import 'package:new_app/pages/interclasse/create_commission.dart';
import 'package:new_app/pages/shop/create_article_shop.dart';
import 'package:new_app/services/shop_service.dart';
import 'package:new_app/services/sport_service.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/widgets/submited_button.dart';
import 'package:new_app/widgets/match_card.dart';

import '../../../fonctions.dart';
import 'administrate_one_match.dart';

class HomeAdminSportTypePage extends StatelessWidget {
  final String typeSport;
  HomeAdminSportTypePage(this.typeSport, {super.key});

  final ShopService _shopService = ShopService();
  final SportService _sportService = SportService();
  final UserService _userService = UserService();
  final TextEditingController _nomCollectionController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userService
          .getUserByEmail(FirebaseAuth.instance.currentUser!.email!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: AppLoader());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur de chargement de l\'utilisateur'));
        } else {
          final user = snapshot.data;
          final userRole = user?.role.toString().split(".").last;

          // Vérifie le rôle de l'utilisateur
          if (userRole == "ADMIN_MB") {
            return _buildAdminMBPage(context); // Page complète pour ADMIN_MB
          } else if (userRole == "ADMIN_FOOTBALL" ||
              userRole == "ADMIN_BASKETBALL" ||
              userRole == "ADMIN_VOLLEYBALL" ||
              userRole == "ADMIN_JEUX_ESPRIT") {
            return _buildAdminFootballPage(
                context); // Page limitée pour ADMIN_FOOTBALL
          } else {
            return _buildAccessDeniedPage(); // Page vierge avec message d'accès refusé
          }
        }
      },
    );
  }

  // Page pour ADMIN_MB (accès à tout)
  Widget _buildAdminMBPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestion $typeSport"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SubmittedButton("Admin SHOP", () {
                  changerPage(context, AdminShop());
                }),
                SizedBox(height: 10),
                SubmittedButton("Admin SPORT", () {
                  changerPage(context, AdminSport());
                }),
                SizedBox(height: 10),
                SubmittedButton("Gestion catégories info", () {
                  changerPage(context, AddCategoriePage());
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Page pour ADMIN_FOOTBALL (accès aux matchs seulement)
  Widget _buildAdminFootballPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestion des matchs $typeSport"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SubmittedButton("Créer un match", () {
                changerPage(context, CreateMatch(typeSport));
              }),
              SizedBox(height: 10),
              Text("Liste des matchs à administrer"),
              SizedBox(
                height: 10,
              ),
              _buildMatchList(typeSport),
            ],
          ),
        ),
      ),
    );
  }

  // Page vierge avec message d'accès refusé
  Widget _buildAccessDeniedPage() {
    return Scaffold(
      body: Center(
        child: Text("Vous n'avez pas le droit d'accéder à cette page."),
      ),
    );
  }

/*  void _showCreateCollectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Nom de la collection"),
          content: TextField(
            controller: _nomCollectionController,
            decoration:
                InputDecoration(hintText: "Entrer le nom de la collection"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                _shopService.postCollection(Collection(
                  id: DateTime.now().toString(),
                  nom: _nomCollectionController.text,
                  articleShops: [],
                  date: DateTime.now(),
                ));
                Navigator.pop(context);
              },
              child: Text("Confirmer"),
            ),
          ],
        );
      },
    );
  }*/

  Widget _buildMatchList(String typeSport) {
    return FutureBuilder<List<Matches>>(
      future: (typeSport != 'MB')
          ? _sportService.getListMatchFootball(typeSport)
          : _sportService.getAllMatch(), // Vérifiez bien cette méthode
      builder: (context, snapshot) {
        // Si en attente de la réponse
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppLoader();
        } else if (snapshot.hasError) {
          return Text('Erreur lors du chargement des matchs');
        } else {
          List<Matches> matches = snapshot.data ?? [];

          if (matches.isNotEmpty) {
            return Column(
              children: matches.map((match) {
                return Column(
                  children: [
                    Text(match.sport.name),
                    buildMatchCard(
                      context,
                      match.id,
                      dateCustomformat(match.date),
                      match.equipeA.nom,
                      match.equipeB.nom,
                      match.scoreEquipeA,
                      match.scoreEquipeB,
                      match.equipeA.logo,
                      match.equipeB.logo,
                      AdministrateOneFootball(match.id, match.sport.name),
                    ),
                    SizedBox(
                      height: 5,
                    )
                  ],
                );
              }).toList(),
            );
          } else {
            return Text("Aucun match à administrer");
          }
        }
      },
    );
  }
}
