import 'package:flutter/material.dart';
import 'package:new_app/models/article_shop.dart';

class ShopBlouson extends StatelessWidget {
  final ArticleShop product;
  final VoidCallback onTap;

  ShopBlouson({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          children: [
            Image.network(
              product.image,
              fit: BoxFit.cover,
              height: 120,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.titre,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${product.prix} CFA',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
