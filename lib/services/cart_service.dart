import 'package:flutter/foundation.dart';
import 'package:new_app/models/article_shop.dart';

class CartItem {
  final ArticleShop article;
  final int quantite;

  const CartItem({required this.article, required this.quantite});

  CartItem copyWith({int? quantite}) =>
      CartItem(article: article, quantite: quantite ?? this.quantite);
}

class CartService {
  static final CartService instance = CartService._internal();
  CartService._internal();

  final ValueNotifier<Map<String, CartItem>> items = ValueNotifier({});

  void ajouter(ArticleShop article, int quantite) {
    final current = Map<String, CartItem>.from(items.value);
    if (current.containsKey(article.id)) {
      current[article.id] =
          current[article.id]!.copyWith(quantite: current[article.id]!.quantite + quantite);
    } else {
      current[article.id] = CartItem(article: article, quantite: quantite);
    }
    items.value = current;
  }

  void retirer(String articleId) {
    final current = Map<String, CartItem>.from(items.value);
    current.remove(articleId);
    items.value = current;
  }

  void changerQuantite(String articleId, int quantite) {
    if (quantite <= 0) {
      retirer(articleId);
      return;
    }
    final current = Map<String, CartItem>.from(items.value);
    if (current.containsKey(articleId)) {
      current[articleId] = current[articleId]!.copyWith(quantite: quantite);
      items.value = current;
    }
  }

  void vider() => items.value = {};

  int get nombreArticles =>
      items.value.values.fold(0, (sum, item) => sum + item.quantite);

  int get total => items.value.values
      .fold(0, (sum, item) => sum + item.article.prix * item.quantite);
}
