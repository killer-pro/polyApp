import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/pages/drawer/propos/membre.dart';

class AProposPage extends StatelessWidget {
  const AProposPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('A propos'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Couleur du texte et des icônes
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                "En tant qu'élèves ingénieurs/ingénieurs passionnés par l'informatique, nous avons développé cette application intuitive, exprimant notre gratitude envers l’école. Elle centralise l'ensemble des activités sociales orchestrées par le BDE, facilitant ainsi la participation et l'engagement de la communauté polytechnicienne VIVA EPT.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'InterMedium',
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                height: 1,
                width: 250,
                color: Colors.black,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    "L'équipe",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            itemCount: 7, // 9 membres au total
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 colonnes
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemBuilder: (context, index) {
              // Exemple de membres de l'équipe avec image et nom
              List<Map<String, String>> equipe = [
                {
                  "imagePath": "assets/images/equipe/Elimane.jpg",
                  "name": "Elimane SALL",
                  "role": "Backend Developer",
                  "description":
                      "Durant ce projet, nous étions chargés d'intégrer les API.",
                  "contact": "77 209 95 38",
                  "message":
                      "En tant qu'élève ingenieur, nous avons une obligation d'etre au service de notre nation. Toujours au service de notre nation.",
                  "linkedin": "https://www.linkedin.com/in/elimane-sall/",
                  "github": "https://github.com/ElimaneSall",
                },
                {
                  "imagePath": "assets/images/equipe/ibou.jpg",
                  "name": "Ibrahima DIA",
                  "role": "Full Stack Developer",
                  "description":
                      "Chargé d'intégrer l'ensemble des interfaces visuelles de l'application et que d'assurer la bonne communication entre ces dernières et la base de donnée.",
                  "contact": "77 474 88 97",
                  "message":
                      "En tant que passionné d'IT et amateur de développement mobile c'était un réel plaisir de participer à ce projet. Nous espèrons vraiment que cette application perdurera et nous comptons sur les générations futures pour continuer à la maintenir et y apporter des améliorations.",
                  "linkedin":
                      "https://www.linkedin.com/in/ibrahima-dia-1b6992294/",
                  "github": "https://github.com/ibou-dia",
                },
                {
                  "imagePath": "assets/images/equipe/Diouf.jpg",
                  "name": "Mouhamadou Diouf CISSE",
                  "role": "Project Manager / Developer_full_stack",
                  "description":
                      "Le rôle central du projet manager dans le domaine informatique est celui d'un véritable chef d'orchestre, coordonnant avec brio le déroulement des projets depuis leur conception jusqu'à leur réalisation finale.",
                  "contact": "70 653 07 76",
                  "message":
                      "Nous ne pouvons pas prédire où nous conduira la Révolution Informatique. Tout ce que nous savons avec certitude, c’est que, quand on y sera enfin, on n’aura pas assez de RAM.",
                  "linkedin":
                      "https://www.linkedin.com/in/mouhamadou-diouf-ciss%C3%A9-9303a12aa/",
                  "github": "https://github.com/killer-pro ",
                },
                {
                  "imagePath": "assets/images/equipe/Sembene.jpg",
                  "name": "Mohamed El Amine SEMBENE",
                  "role": "UI/UX designer",
                  "description":
                      "Chargé de la concetption du prototype figma et du fonctionnement de certaines fonctionnalités",
                  "contact": "77 301 07 16",
                  "message": "...",
                  "linkedin": "null",
                  "github": "null",
                },
                {
                  "imagePath": "assets/images/equipe/codiallo.jpg",
                  "name": "Cheikh Oumar DIALLO",
                  "role": "Frontend Developer",
                  "description":
                      "Durant ce projet, nous étions chargé de coder les interfaces qu'a faites le designer",
                  "contact": "77 418 94 39",
                  "message":
                      "Cette application a été créée par des élèves ingénieurs comme vous. N'hésitez pas à apporter également votre contribution à l'édifice de l'école polytechnique de Thiès.",
                  "linkedin":
                      "https://www.linkedin.com/in/cheikh-oumar-diallo-470a50268/",
                  "github": "https://github.com/cheikhouma",
                },
                {
                  "imagePath": "assets/images/equipe/Amath.jpg",
                  "name": "Amath THIAM",
                  "role": "Backend Developer",
                  "description":
                      "Durant ce projet, nous étions chargés d'intégrer les API et gérer la base de données",
                  "contact": "76 130 97 97",
                  "message": "Simple is better than complex.",
                  "linkedin": "404 Not Found",
                  "github": "https://github.com/xoss7",
                },
                {
                  "imagePath": "assets/images/equipe/aminou.jpg",
                  "name": "Mohamed Aminou NIANG",
                  "role": " Project manager ",
                  "description":
                      "Le project manager  est un leader visionnaire, orchestrant avec brio la collaboration entre les équipes techniques et les parties prenantes.En somme, il est le pilier sur lequel repose la réussite du projet, alliant stratégie et adaptabilité.",
                  "contact": "77 258 42 81",
                  "message":
                      "Osez innover, l'élève ingénieur doit se donner des defis et les relever ! Travail-Discipline-Solidarité notre credo. Dédicace à la 51e promotion et à la famille polytechnicienne.",
                  "linkedin":
                      "https://www.linkedin.com/in/mohamed-aminou-niang-5865592b0/",
                  "github": "https://github.com/aminouniang",
                },
              ];

              return equipeMembre(
                equipe[index]["imagePath"]!,
                equipe[index]["name"]!,
                equipe[index]["role"]!,
                equipe[index]["description"]!,
                equipe[index]["contact"]!,
                equipe[index]["message"]!,
                equipe[index]["linkedin"]!,
                equipe[index]["github"]!,
              );
            },
          ),
        ),
      ]),
    );
  }
}

Widget equipeMembre(image, nom, String role, String description, String contact,
    String message, String linkedin, String github) {
  return Builder(builder: (context) {
    return InkWell(
      onTap: () {
        changerPage(
            context,
            MembreEquipe(nom, image, role, description, contact, message,
                linkedin, github));
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: ResizeImage(
              AssetImage(image),
              width: 210,
            ),
            radius: 35,
            backgroundColor: Colors.grey[300], // Couleur de l'avatar
          ),
          SizedBox(height: 5),
          Text(
            nom,
            maxLines: 2,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  });
}
