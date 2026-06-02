import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/login/login.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/models/enums/role_type.dart';
import 'package:new_app/models/utilisateur.dart';
import 'package:new_app/pages/object_perdus/objets_perdus.dart';
import 'package:new_app/pages/drawer/compte/compte.dart';
import 'package:new_app/pages/drawer/famille/famille.dart';
import 'package:new_app/pages/drawer/avis/avis_page.dart';
import 'package:new_app/pages/drawer/propos/a_propos.dart';
import 'package:new_app/pages/interclasse/football/home_admin_sport_type_page.dart';
import 'package:new_app/pages/drawer/xoss/xoss_screen.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart'; // Import du package url_launcher

class EptDrawer extends StatefulWidget {
  const EptDrawer({super.key});

  @override
  State<EptDrawer> createState() => _EptDrawerState();
}

class _EptDrawerState extends State<EptDrawer> {
  final UserService _userService = UserService();

  // Fonction pour ouvrir un lien dans le navigateur
  void _ouvrirLien(String url) async {
    final Uri uri = Uri.parse(Uri.encodeFull(url)); // Encode l'URL
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d\'ouvrir le lien')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double size = 100;
    return Drawer(
        backgroundColor: eptLighterOrange,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 30),
                children: [
                  const SizedBox(height: 30),
                  FutureBuilder(
                    future: _userService.getUserByEmail(
                        FirebaseAuth.instance.currentUser!.email!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: AppLoader());
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text(
                                'Erreur lors de la récupération des données'));
                      } else {
                        final user = snapshot.data;
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    changerPage(context, CompteScreen());
                                  },
                                  child: Container(
                                    width: size,
                                    height: size,
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(200),
                                      color: eptOrange,
                                    ),
                                    child: Container(
                                      width: size,
                                      height: size,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: user?.photo != ""
                                          ? Image(
                                              image: ResizeImage(
                                                CachedNetworkImageProvider(
                                                    "${user?.photo}"),
                                                height: 250,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : Container(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Column(
                              children: [
                                Text(
                                  '${user?.prenom} ${user?.nom.toUpperCase()}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  user?.role.toString().split(".").last ?? '',
                                  style: TextStyle(
                                    fontFamily: "InterRegular",
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Divider(thickness: 1, color: Colors.black),
                  const SizedBox(height: 20),

                  drawerItem("assets/images/top-left-menu/compte.png", "Compte",
                      () {
                    changerPage(context, CompteScreen());
                  }),
                  drawerItem("assets/images/top-left-menu/famille.png",
                      "Famille Polytechnicienne", () {
                    changerPage(context, FamillePolytechnicienneScreen());
                  }),
                  drawerItem(
                      "assets/images/top-left-menu/xoss.png", "Cahier Xoss",
                      () {
                    changerPage(context, XossScreen());
                  }),
                  drawerItem(
                      "assets/images/top-left-menu/a_propos.png", "A propos",
                      () {
                    changerPage(context, AProposPage());
                  }),
                  drawerItem("assets/images/top-left-menu/a_propos.png", "Avis",
                      () {
                    changerPage(context, const AvisPage());
                  }),
                  FutureBuilder(
                    future: _userService.getUserByEmail(
                        FirebaseAuth.instance.currentUser!.email!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LinearProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Center(
                          child: const Text('Erreur de chargement'),
                        );
                      } else {
                        final user = snapshot.data;
                        if ([
                          RoleType.ADMIN.toString(),
                          RoleType.ADMIN_MB.toString(),
                          RoleType.ADMIN_FOOTBALL.toString(),
                          RoleType.ADMIN_BASKETBALL.toString(),
                          RoleType.ADMIN_VOLLEYBALL.toString(),
                          RoleType.ADMIN_JEUX_ESPRIT.toString()
                        ].contains(user?.role.toString())) {
                          return drawerItem(
                            "assets/images/top-left-menu/paramètres.png",
                            'Administration ${user?.role.toString().split("_").last.toLowerCase()}',
                            () {
                              changerPage(
                                context,
                                HomeAdminSportTypePage(
                                    user!.role.toString().split("_").last),
                              );
                            },
                          );
                        } else {
                          return SizedBox();
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 5),
                  Divider(thickness: 1, color: Colors.black),
                  const SizedBox(height: 20),
                  // Icônes des réseaux sociaux avec liens
                  drawerItem(
                    "assets/images/top-left-menu/facebook.png",
                    "@bde_ept",
                    () {
                      _ouvrirLien(
                          "https://www.facebook.com/profile.php?id=100075396502307");
                    },
                    isLink: true,
                  ),
                  drawerItem(
                    "assets/images/top-left-menu/instagram.png",
                    "@bde_ept",
                    () {
                      _ouvrirLien(
                          "https://www.instagram.com/bde_ept?igsh=MWdxamV4dGhjNWE3aA==");
                    },
                    isLink: true,
                  ),
                  drawerItem(
                    "assets/images/top-left-menu/x.png",
                    "@bde_ept",
                    () {
                      _ouvrirLien("https://x.com/bde_ept?s=21");
                    },
                    isLink: true,
                  ),
                  drawerItem(
                    "assets/images/top-left-menu/linkedin.png",
                    "Bureau Des Elèves EPT",
                    () {
                      _ouvrirLien(
                          "https://www.linkedin.com/company/bureau-des-el%C3%A8ves-ept/");
                    },
                    isLink: true,
                  ),
                  const SizedBox(height: 20),
                  // Bouton Déconnexion
                  InkWell(
                    onTap: () {
                      _userService.signOut();
                      changerPage(context, LoginScreen());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      width: 150,
                      height: 40,
                      decoration: BoxDecoration(
                        color: eptOrange,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/images/top-left-menu/sortie.png",
                            scale: 4,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Déconnexion",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const Text(
              "PolyApp version 1.0.0",
              style: TextStyle(
                fontSize: 10,
                color: eptDarkGrey,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 5,
              color: eptOrange,
            ),
          ],
        ));
  }
}

// Fonction widget pour les éléments du drawer
Widget drawerItem(
    final String imagePath, final String title, VoidCallback ontap,
    {bool isLink = false}) {
  return Column(
    children: [
      InkWell(
        onTap: ontap,
        child: Container(
          padding: const EdgeInsets.all(5),
          color: Colors.white,
          width: 250,
          height: 40,
          child: Row(
            children: [
              Image.asset(
                imagePath,
                scale: 4,
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: "InterRegular",
                  fontSize: 12,
                ),
              ),
              if (isLink) ...[
                Spacer(),
                Image.asset(
                  "assets/images/top-left-menu/external_link.png",
                  scale: 1,
                ),
              ]
            ],
          ),
        ),
      ),
      SizedBox(
        height: 15,
      )
    ],
  );
}
