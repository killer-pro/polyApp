import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/annonce.dart';
import 'package:new_app/models/categorie.dart';
import 'package:new_app/models/utilisateur.dart';
import 'package:new_app/pages/annonce/create_annonce.dart';
import 'package:new_app/pages/annonce/infocard.dart';
import 'package:new_app/pages/annonce/p_info_section_selector.dart';
import 'package:new_app/pages/annonce/restauration.dart';
import 'package:new_app/services/annonce_service.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/app_loader.dart';

class PInfoNouveaute extends StatefulWidget {
  PInfoNouveaute({super.key});

  @override
  State<PInfoNouveaute> createState() => _PInfoNouveauteState();
}

class _PInfoNouveauteState extends State<PInfoNouveaute> {
  final UserService _userService = UserService();
  final AnnonceService _annonceService = AnnonceService();
  int groupValue = 0;
  bool isAdmin = false; // Initialement, l'utilisateur n'est pas admin
  String? userId; // Stocker l'ID de l'utilisateur connecté

  @override
  void initState() {
    super.initState();
    _checkUserRole(); // Appel pour vérifier le rôle de l'utilisateur
  }

  Future<void> _checkUserRole() async {
    try {
      // Récupérer l'utilisateur connecté via FirebaseAuth
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userId = user.email;

        // Récupérer le rôle de l'utilisateur à partir du service utilisateur
        String? role = await _userService.getUserRole(userId!);

        // Vérifier si l'utilisateur est admin
        if (role == 'ADMIN_MB') {
          setState(() {
            isAdmin = true; // Met à jour l'état pour afficher le bouton "+"
          });
        }
      }
    } catch (e) {
      debugPrint("Erreur lors de la vérification du rôle : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              "Nouveautés",
              style: TextStyle(
                  fontFamily: "Inter",
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            if (isAdmin) // Afficher le bouton "+" uniquement si l'utilisateur est admin
              ...[
              const SizedBox(width: 5),
              InkWell(
                onTap: () {
                  changerPage(context, CreateAnnonce());
                },
                child: Image.asset(
                  "assets/images/polytech-Info/plus.png",
                  scale: 5,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FutureBuilder<List<Categorie>>(
                  future: _annonceService.getAllCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return AppLoader();
                    } else if (snapshot.hasError) {
                      return Text('Erreur lors du chargement');
                    } else {
                      List<Categorie> categories = snapshot.data ?? [];

                      // Ajout de l'option "All"
                      categories.insert(
                          0,
                          Categorie(
                              id: '0',
                              logo:
                                  'https://firebasestorage.googleapis.com/v0/b/ept-app-46930.appspot.com/o/assets%2Fpolytech-info%2Fbde_ept.jpg?alt=media&token=12c1e41f-0d06-4068-8ac6-50e35c146140',
                              libelle: 'All'));

                      return Row(
                        children: [
                          for (var category in categories)
                            PInfoSectionSelector(
                              value: int.parse(category.id),
                              groupValue: groupValue,
                              onChanged: (value) {
                                setState(() {
                                  groupValue = value!;
                                });

                                // Gestion de la sélection de "All"
                              },
                              image: Image.network(
                                category.logo,
                                scale: 3,
                              ),
                            ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        FutureBuilder<List<Annonce>>(
          future: groupValue == 0
              ? _annonceService
                  .getAllAnnonces() // Récupère toutes les annonces si "All" est sélectionné
              : _annonceService.getAnnoncesByCategorie(Categorie(
                  id: groupValue.toString(),
                  libelle: "",
                  logo: "")), // Récupère les annonces filtrées par catégorie
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AppLoader();
            } else if (snapshot.hasError) {
              return Text('Erreur lors du chargement des annonces');
            } else {
              List<Annonce> annonces = snapshot.data ?? [];
              annonces.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
              return CategorySelection(
                items: annonces,
                value: groupValue,
              );
            }
          },
        )
      ],
    );
  }
}

class CategorySelection extends StatelessWidget {
  final List<Annonce> items;
  final int value;

  CategorySelection({
    super.key,
    required this.items,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items
              .map((Annonce annonce) => InfoCard(
                        annonce: annonce,
                        width: width,
                        height: height,
                      )
                  // Container(
                  //   padding: const EdgeInsets.all(5),
                  //   width: 170,
                  //   height: MediaQuery.sizeOf(context).height * 0.3,
                  //   decoration: BoxDecoration(
                  //       color: AppColors.primary,
                  //       borderRadius: BorderRadius.circular(15)),
                  //   child: Container(
                  //     decoration:
                  //         BoxDecoration(borderRadius: BorderRadius.circular(15)),
                  //     clipBehavior: Clip.hardEdge,
                  //     child: Image.network(
                  //       annonce.image,
                  //       fit: BoxFit.cover,
                  //     ),
                  //   ),
                  // ),
                  )
              .toList(),
        ),
      ),
    );
  }
}

double width = 200;
double height = 300;
