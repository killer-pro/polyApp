import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/article_shop.dart';
import 'package:new_app/models/categorie_shop.dart';
import 'package:new_app/models/collection.dart';
import 'package:new_app/models/enums/role_type.dart';
import 'package:new_app/pages/drawer/drawer.dart';
import 'package:new_app/pages/home/navbar.dart';
import 'package:new_app/pages/shop/admin_commandes_page.dart';
import 'package:new_app/pages/shop/cart_page.dart';
import 'package:new_app/pages/shop/shopCaroussel.dart';
import 'package:new_app/services/cart_service.dart';
import 'package:new_app/services/shop_service.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/alerte_message.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'dart:async';

import 'package:photo_view/photo_view.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ShopService _shopService = ShopService();
  final UserService _userService = UserService();
  final CartService _cart = CartService.instance;

  List<String> carouselImages = [];
  Collection? _collection;
  String searchQuery = '';
  CategorieShop selectedCategory = CategorieShop(id: "", libelle: "Tous");
  List<CategorieShop> categories = [
    CategorieShop(id: "", libelle: "Tous"),
  ];
  bool _isAdminMb = false;

  @override
  void initState() {
    super.initState();
    _loadCarouselImages();
    _loadCategories();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    final user = await _userService.getUserByEmail(email);
    if (mounted) {
      setState(() {
        _isAdminMb = user?.role == RoleType.ADMIN_MB ||
            user?.role == RoleType.ADMIN;
      });
    }
  }

  Future<void> _loadCarouselImages() async {
    Collection? collection = await _shopService.getNewCollection();
    if (collection != null) {
      setState(() {
        _collection = collection;
        carouselImages =
            collection.articleShops.map((article) => article.image).toList();
      });
    }
  }

  Future<void> _loadCategories() async {
    List<CategorieShop>? loadedCategories =
        await _shopService.getAllCategorieShop();
    setState(() {
      categories.addAll(loadedCategories);
    });
  }

  Future<List<ArticleShop>> getFilteredProducts() async {
    List<ArticleShop> products = await _shopService.getAllArticle();
    List<ArticleShop> filteredProducts = List.from(products);

    filteredProducts.sort((a, b) {
      if (a.commandes == b.commandes) return 0;
      if (a.commandes.isEmpty) return -1;
      return 1;
    });

    return filteredProducts.where((product) {
      bool categoryMatch = selectedCategory.libelle == 'Tous' ||
          product.categorie.id == selectedCategory.id;
      bool searchMatch =
          product.titre.toLowerCase().contains(searchQuery.toLowerCase());
      return categoryMatch && searchMatch;
    }).toList();
  }

  void _showProductDetails(ArticleShop product) {
    int quantity = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(),
                  GestureDetector(
                    onTap: () {
                      if (product.image.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: PhotoView(
                              imageProvider:
                                  CachedNetworkImageProvider(product.image),
                              minScale: PhotoViewComputedScale.covered * 0.8,
                            ),
                          ),
                        );
                      }
                    },
                    child: Image(
                        image: ResizeImage(
                      CachedNetworkImageProvider(product.image),
                      height: 300,
                    )),
                  ),
                  const SizedBox(height: 10),
                  Text(product.titre,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Catégorie: ${product.categorie.libelle}'),
                  Text('Prix: ${product.prix} CFA'),
                  const SizedBox(height: 10),
                  Text(product.description),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: quantity > 1
                            ? () => setState(() => quantity--)
                            : null,
                        icon: const Icon(Icons.remove),
                        color: quantity > 1 ? Colors.black : Colors.grey,
                      ),
                      Text('$quantity',
                          style: const TextStyle(fontSize: 18)),
                      IconButton(
                        onPressed: () => setState(() => quantity++),
                        icon: const Icon(Icons.add),
                        color: Colors.black,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart_outlined,
                        color: Colors.white, size: 18),
                    label: const Text('Ajouter au panier',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      _cart.ajouter(product, quantity);
                      Navigator.of(context).pop();
                      alerteMessageWidget(
                          context,
                          '${product.titre} ajouté au panier.',
                          AppColors.success);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        centerTitle: true,
        forceMaterialTransparency: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu, color: Colors.black, size: 35),
            );
          },
        ),
        actions: [
          if (_isAdminMb)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined,
                  color: Colors.black, size: 26),
              tooltip: 'Gestion commandes',
              onPressed: () =>
                  changerPage(context, const AdminCommandesPage()),
            ),
          ValueListenableBuilder<Map<String, CartItem>>(
            valueListenable: _cart.items,
            builder: (context, items, _) {
              final count = items.values
                  .fold(0, (sum, item) => sum + item.quantite);
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart,
                        size: 30, color: Colors.black),
                    onPressed: () =>
                        changerPage(context, const CartPage()),
                  ),
                  if (count > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: orange,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            count > 9 ? '9+' : '$count',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: navbar(pageIndex: 4),
      drawer: EptDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_collection != null)
              ShopCarousel(
                imagePaths: carouselImages,
                collection: _collection!,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: screenWidth * 0.4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xffd9d9d9),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 10, right: 5),
                              child: Icon(Icons.search,
                                  color: Color(0xff777777), size: 20),
                            ),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Chercher',
                                  hintStyle: TextStyle(
                                      fontSize: 15, color: Color(0xff777777)),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 10),
                                ),
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.black),
                                onChanged: (value) {
                                  setState(() => searchQuery = value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<CategorieShop>(
                        onSelected: (CategorieShop value) {
                          setState(() => selectedCategory = value);
                        },
                        itemBuilder: (BuildContext context) {
                          return categories.map((CategorieShop choice) {
                            return PopupMenuItem<CategorieShop>(
                              value: choice,
                              child: Text(choice.libelle),
                            );
                          }).toList();
                        },
                        child: Row(
                          children: [
                            const Text(
                              'Catégories',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 35,
                              height: 35,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/categorie.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    selectedCategory.libelle,
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Nouveautés',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            FutureBuilder<List<ArticleShop>>(
              future: getFilteredProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoader();
                } else if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Aucun produit trouvé');
                }

                List<ArticleShop> products = snapshot.data!;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 5,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final produit = products[index];
                    return _buildProductItem(produit);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(ArticleShop produit) {
    return GestureDetector(
      onTap: () => _showProductDetails(produit),
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: ResizeImage(CachedNetworkImageProvider(produit.image),
                    width: 200),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            produit.titre,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${produit.prix} FCFA',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
