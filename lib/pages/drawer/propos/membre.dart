import 'package:flutter/material.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/fonctions.dart';

class MembreEquipe extends StatelessWidget {
  String nom;
  String image;
  String role;
  String description;
  String contact;
  String message;
  String linkedin;
  String github;
  MembreEquipe(this.nom, this.image, this.role, this.description, this.contact,
      this.message, this.linkedin, this.github,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 70,
            ),
            Column(
              children: [
                Text(
                  nom,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Forme en cercle
                    border: Border.all(
                      color: orange, // Couleur de la bordure
                      width: 4.0, // Largeur de la bordure
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage: ResizeImage(
                      AssetImage(image),
                      height: 600,
                    ),
                    backgroundColor: grisClair,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                        color: eptLighterOrange,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Text(
                          role,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          description,
                          style: TextStyle(
                            fontFamily: 'InterMedium',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )),
              ],
            ),
            // Contacts
            SizedBox(height: 20),
            Text(
              'Contacts',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Icon(Icons.phone),
                SizedBox(
                  width: 5,
                ),
                Text(
                  contact,
                  style: TextStyle(fontFamily: 'InterMedium'),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Image.asset(
                  'assets/images/top-left-menu/linkedin.png',
                  width: 25,
                ),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                  onTap: () {
                    ouvrirLien(context, linkedin);
                  },
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width - 100,
                    child: Text(
                      linkedin,
                      style: TextStyle(fontFamily: 'InterMedium'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Image.asset(
                  'assets/images/top-left-menu/github.png',
                  width: 25,
                ),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                  onTap: () {
                    ouvrirLien(context, github);
                  },
                  child: Text(
                    github,
                    style: TextStyle(fontFamily: 'InterMedium'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Message
            Text(
              'Message',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                  color: eptLighterOrange,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                message,
                style: TextStyle(fontFamily: 'InterMedium'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
