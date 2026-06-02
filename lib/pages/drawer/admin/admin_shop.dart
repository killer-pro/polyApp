import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/pages/interclasse/football/create_equipe.dart';
import 'package:new_app/pages/interclasse/football/create_match.dart';
import 'package:new_app/pages/interclasse/football/voir_match_admin.dart';
import 'package:new_app/pages/shop/afficher_commandes.dart';
import 'package:new_app/pages/shop/create_article_shop.dart';
import 'package:new_app/pages/shop/create_collection.dart';
import 'package:new_app/pages/shop/gestion_article.dart';
import 'package:new_app/pages/shop/gestion_categorie_shop.dart';
import 'package:new_app/pages/shop/gestion_collection.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/submited_button.dart';

class AdminShop extends StatefulWidget {
  const AdminShop({super.key});

  @override
  State<AdminShop> createState() => _AdminShopState();
}

class _AdminShopState extends State<AdminShop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop admin'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Column(
            children: [
              SubmittedButton("Créer un article", () {
                changerPage(context, CreateArticleShop());
              }),
              SizedBox(height: 10),
              SubmittedButton("Gérer les articles", () {
                changerPage(context, ArticleListPage());
              }),
              SizedBox(height: 10),
              SubmittedButton("Créer collection", () {
                changerPage(context, CreateCollectionPage());
              }),
              SizedBox(height: 10),
              SubmittedButton("Gestion collection", () {
                changerPage(context, CollectionListPage());
              }),
              SizedBox(height: 10),
              SubmittedButton("Voir les commandes", () {
                changerPage(context, CommandeListPage());
              }),
              SizedBox(height: 10),
              SubmittedButton("Gestion catégorie shop", () {
                changerPage(context, CategorieShopPage());
              }),
            ],
          ),
        ),
      ),
    );
  }
}
