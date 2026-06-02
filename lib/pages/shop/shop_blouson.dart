// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:new_app/models/article_shop.dart';
import 'dart:async';

import 'package:new_app/models/collection.dart';
import 'package:new_app/services/shop_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/alerte_message.dart';

class blousonPage extends StatefulWidget {
  Collection collection;
  blousonPage(this.collection, {super.key});

  @override
  _Blouson_PageState createState() => _Blouson_PageState(collection);
}

class _Blouson_PageState extends State<blousonPage> {
  Collection _collection;
  _Blouson_PageState(this._collection);
  final ShopService _shopService = ShopService();
  List<String> carouselImages = [];
  Future<void> _loadCarouselImages() async {
    Collection? collection = await _shopService.getNewCollection();
    // debugPrint(collection as String?);
    if (collection != null) {
      setState(() {
        carouselImages =
            collection.articleShops.map((article) => article.image).toList();
      });
    }
  }

  int _currentPage = 0;
  late Timer _timer;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _loadCarouselImages();
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPage < carouselImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _nextImage() {
    _currentPage = (_currentPage + 1) % carouselImages.length;
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousImage() {
    _currentPage =
        (_currentPage - 1 + carouselImages.length) % carouselImages.length;
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showProductDetails(ArticleShop articleShop, Collection collection) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(carouselImages[_currentPage], height: 200),
              SizedBox(height: 10),
              Text(articleShop.titre,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Catégorie: ${articleShop.categorie.libelle}'),
              Text('Prix: ${articleShop.prix} CFA'),
              SizedBox(height: 10),
              Text('Description: ${articleShop.description}'),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Commander'),
                onPressed: () async {
                  String code = await _shopService.postCommande(articleShop, 1);
                  if (code == "OK") {
                    Navigator.of(context).pop();
                    alerteMessageWidget(
                        context,
                        "Votre commande a été bien prise en compte.",
                        AppColors.success);
                  } else {
                    alerteMessageWidget(
                        context, "Echec lors de la commande.", AppColors.echec);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: Stack(
          children: [
            // Carousel
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: carouselImages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    carouselImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
            ),
            // Left Arrow
            Positioned(
              left: 10,
              top: MediaQuery.of(context).size.height * 0.5 - 20,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
                onPressed: _previousImage,
              ),
            ),
            // Right Arrow
            Positioned(
              right: 10,
              top: MediaQuery.of(context).size.height * 0.5 - 20,
              child: IconButton(
                icon: Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 30),
                onPressed: _nextImage,
              ),
            ),
            // Back Button
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            // Product Information and Order Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.collection.nom,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cursive',
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Classe Polytechnicienne",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Récupérer l'article correspondant à l'image affichée
                        _showProductDetails(
                            widget.collection.articleShops.firstWhere(
                              (article) =>
                                  article.image == carouselImages[_currentPage],
                            ),
                            widget.collection);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Commander',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.shopping_cart, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )));
  }
}
