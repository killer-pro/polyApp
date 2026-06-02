import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/article_shop.dart';
import 'package:new_app/pages/shop/modifier_article.dart';
import 'package:new_app/services/shop_service.dart';
import 'package:new_app/services/sport_service.dart';
import 'package:new_app/utils/app_colors.dart'; // Modifie pour le service approprié
import 'package:new_app/widgets/app_loader.dart';

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  _ArticleListPageState createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  final ShopService _shopService = ShopService(); // Modifie pour ton service
  late Future<List<ArticleShop>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture = _shopService.getAllArticle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des articles"),
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<List<ArticleShop>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: AppLoader());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun article trouvé'));
          } else {
            List<ArticleShop> articles = snapshot.data!;

            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                ArticleShop article = articles[index];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: GestureDetector(
                    child: ListTile(
                      leading: Image.network(
                        article.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(article.titre),
                      subtitle: Text('${article.prix} FCFA'),
                      onTap: () {
                        changerPage(context, EditArticleShop(article: article));
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
