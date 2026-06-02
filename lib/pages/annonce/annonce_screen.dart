import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/annonce.dart';
import 'package:new_app/pages/annonce/hot_topics.dart';
import 'package:new_app/pages/annonce/p_info_nouveaute.dart';
import 'package:new_app/services/annonce_service.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/widgets/ept_button.dart';
import 'package:new_app/pages/drawer/drawer.dart';
import 'package:new_app/pages/home/navbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_text_formatter/whatsapp_text_formatter.dart';

class AnnonceScreen extends StatefulWidget {
  AnnonceScreen({super.key});

  @override
  State<AnnonceScreen> createState() => _AnnonceScreenState();
}

class _AnnonceScreenState extends State<AnnonceScreen> {
  AnnonceService _annonceService = AnnonceService();
  bool annonceAvailable = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          leading: Builder(builder: (context) {
            return IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(
                Icons.menu,
                size: 35,
              ),
            );
          }),
          title: Text('Polytech Info'),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      drawer: EptDrawer(),
      bottomNavigationBar: navbar(pageIndex: 1),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          FutureBuilder<Annonce?>(
            future: _annonceService.getNextAG(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return AppLoader();
              } else if (snapshot.hasError) {
                return Text('Erreur lors du chargement des annonces');
              } else if (!snapshot.hasData || snapshot.data == null) {
                // Si aucune annonce n'est retournée, afficher un widget vide
                return SizedBox.shrink();
              } else {
                // Si une annonce est retournée, afficher le widgetAG
                Annonce annonce = snapshot.data!;
                return widgetAG(
                  simpleDateformat(annonce.date),
                  getHour(annonce.date),
                  annonce.lieu,
                  annonce.description,
                  communiqueUrl: annonce.communiqueUrl,
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 20),
            child: Column(
              children: [
                PInfoNouveaute(),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: 250,
                  height: 3,
                  color: Colors.black,
                ),
                const SizedBox(
                  height: 20,
                ),
                HotTopics(),
              ],
            ),
          ),
        ],
      )),
    );
  }
}

Widget widgetAG(String date, String heure, String lieu, String sujet,
    {String? communiqueUrl}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        // Image de fond avec les personnes et le tableau
        Container(
          margin: EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0), color: jauneClair),
          height: 140,
        ),
        Positioned(
          right: -20,
          bottom: -10,
          child: SizedBox(
            height: 180,
            child: Image.asset(
              'assets/images/polytech-Info/schedule.png', // Chemin vers l'image de l'horloge
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 0, 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Assemblée Générale",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        date,
                        style:
                            TextStyle(fontSize: 11, fontFamily: 'InterRegular'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        heure,
                        style:
                            TextStyle(fontSize: 11, fontFamily: 'InterRegular'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        lieu,
                        style:
                            TextStyle(fontSize: 11, fontFamily: 'InterRegular'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.record_voice_over,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      SizedBox(
                        width: 200,
                        child: WhatsAppTextFormatter(
                          text: sujet,
                          style: TextStyle(
                              fontSize: 11, fontFamily: 'InterRegular'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (communiqueUrl != null)
                    ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(communiqueUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(Icons.picture_as_pdf,
                          color: Colors.white, size: 14),
                      label: Text(
                        "Voir communiqué",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                ],
              ),
              // Image de l'horloge à droite
            ],
          ),
        ),
      ],
    ),
  );
}
