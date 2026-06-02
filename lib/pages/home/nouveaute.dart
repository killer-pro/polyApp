import 'package:flutter/material.dart';
import 'package:new_app/models/annonce.dart';
import 'package:new_app/models/article_shop.dart';
import 'package:new_app/models/collection.dart';
import 'package:new_app/models/match.dart';
import 'package:new_app/pages/annonce/infocard.dart';
import 'package:new_app/pages/home/section_selector.dart';
import 'package:new_app/services/annonce_service.dart';
import 'package:new_app/services/shop_service.dart';
import 'package:new_app/services/sport_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/app_loader.dart';

class Nouveaute extends StatefulWidget {
  const Nouveaute({super.key});

  @override
  State<Nouveaute> createState() => _NouveauteState();
}

class _NouveauteState extends State<Nouveaute> {
  AnnonceService _annonceService = AnnonceService();
  SportService _sportService = SportService();
  ShopService _shopService = ShopService();
  int _value = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Nouveautés",
              style: TextStyle(
                fontFamily: "Inter",
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Column(
            children: [
              Row(
                children: [
                  SectionSelector(
                    value: 1,
                    groupValue: _value,
                    onChanged: (int? value) {
                      setState(() {
                        _value = value!;
                      });
                    },
                    text: "Polytech-info",
                  ),
                  const SizedBox(width: 30),
                  SectionSelector(
                    value: 2,
                    groupValue: _value,
                    onChanged: (int? value) {
                      setState(() {
                        _value = value!;
                      });
                    },
                    text: "Interclasses",
                  ),
                  const SizedBox(width: 30),
                  SectionSelector(
                    value: 3,
                    groupValue: _value,
                    onChanged: (int? value) {
                      setState(() {
                        _value = value!;
                      });
                    },
                    text: "Commerce",
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_value == 1)
                FutureBuilder<List<Annonce>>(
                  future: _annonceService.getAllAnnonces(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const AppLoader();
                    } else if (snapshot.hasError) {
                      return const Text(
                          'Erreur lors du chargement des annonces');
                    } else {
                      List<Annonce> annonces = snapshot.data ?? [];
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (var annonce in annonces.reversed)
                              annonce.image.isNotEmpty
                                  ? InfoCard(
                                      annonce: annonce,
                                      width: 140,
                                      height: 200,
                                    )
                                  : const SizedBox(height: 0),
                          ],
                        ),
                      );
                    }
                  },
                ),
              if (_value == 2)
                FutureBuilder<List<Matches>>(
                  future: _sportService.getNextMatch(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const AppLoader();
                    } else if (snapshot.hasError) {
                      return const Text(
                          'Erreur lors du chargement des annonces');
                    } else {
                      List<Matches> matches = snapshot.data ?? [];
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (var match in matches)
                              match.photo!.isNotEmpty
                                  ? Container(
                                      padding: const EdgeInsets.all(5),
                                      margin: const EdgeInsets.all(5),
                                      width: 140,
                                      height: 200,
                                      decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        clipBehavior: Clip.hardEdge,
                                        child: Image.network(
                                          match.photo!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : const SizedBox(height: 0),
                          ],
                        ),
                      );
                    }
                  },
                ),
              if (_value == 3)
                FutureBuilder<List<ArticleShop>?>(
                  future: _shopService.getAllArticle(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const AppLoader();
                    } else if (snapshot.hasError) {
                      return const Text(
                          'Erreur lors du chargement des annonces');
                    } else {
                      List<ArticleShop> articles = snapshot.data ?? [];
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (articles != [])
                              for (var articleShop in articles)
                                articleShop.image.isNotEmpty
                                    ? Container(
                                        padding: const EdgeInsets.all(5),
                                        margin: const EdgeInsets.all(5),
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                0.4,
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.25,
                                        decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          clipBehavior: Clip.hardEdge,
                                          child: Image.network(
                                            articleShop.image,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : const SizedBox(height: 0),
                          ],
                        ),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
