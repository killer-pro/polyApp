// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Importer intl pour le formatage des dates
import 'package:new_app/models/objet_perdu_model.dart';
import 'package:new_app/models/utilisateur.dart';
import 'package:new_app/pages/drawer/drawer.dart';
import 'package:new_app/services/user_service.dart';
import 'package:new_app/utils/app_colors.dart'; // Assurez-vous que cette classe existe
import 'package:new_app/services/lost_found_service.dart';
import 'package:new_app/widgets/app_loader.dart';
import 'package:new_app/widgets/empty_state_widget.dart';

import '../home/navbar.dart';

class ObjetsPerdus extends StatefulWidget {
  const ObjetsPerdus({super.key});

  @override
  _ObjetsPerdusState createState() => _ObjetsPerdusState();
}

class _ObjetsPerdusState extends State<ObjetsPerdus> {
  final ObjetPerduService _service = ObjetPerduService();
  final currentUser = FirebaseAuth.instance.currentUser;

  TextEditingController dateController = TextEditingController();
  TextEditingController lieuController = TextEditingController();
  TextEditingController objetController = TextEditingController();
  TextEditingController infoSuppController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker(); // Instance de ImagePicker

  // Search Lost Objects
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Fonction pour sélectionner une image depuis la galerie ou prendre une photo
  Future<void> _choisirImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galerie'),
                onTap: () async {
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Caméra'),
                onTap: () async {
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Fonction pour choisir la date
  Future<void> _choisirDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text =
            DateFormat('dd-MM-yyyy').format(pickedDate); // Format de date
      });
    }
  }

  // submit the form
  Future<void> _submitForm() async {
    String? photoURL;
    if (_image != null) {
      photoURL = await _service.uploadImage(_image!);
    }

    ObjetPerdu objet = ObjetPerdu(
      description: objetController.text,
      details: infoSuppController.text,
      photoURL: photoURL,
      lieu: lieuController.text,
      date: dateController.text,
      estTrouve: 0,
      idUser: currentUser?.email,
    );

    // clear the form
    objetController.clear();
    lieuController.clear();
    dateController.clear();
    infoSuppController.clear();

    await _service.addLostObject(objet);

    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: EptDrawer(),
      appBar: AppBar(
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: Icon(
              Icons.menu,
              size: 35,
            ),
          );
        }),
        title: Text('Objets Perdus'),
        centerTitle: true,
      ),
      bottomNavigationBar: navbar(pageIndex: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Formulaire
              Text(
                'Signaler un objet perdu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "Qu'avez vous perdu ?",
                style: TextStyle(fontFamily: 'InterRegular'),
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 35,
                child: TextField(
                  controller: objetController,
                  decoration: InputDecoration(
                    fillColor: grisClair,
                    filled: true,
                    labelText: "Objet",
                    labelStyle:
                        TextStyle(fontFamily: 'InterMedium', fontSize: 13),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Où avez vous perdu cet objet ?",
                style: TextStyle(fontFamily: 'InterRegular'),
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 35,
                child: TextField(
                  controller: lieuController,
                  decoration: InputDecoration(
                    fillColor: grisClair,
                    filled: true,
                    labelText: "Lieu",
                    labelStyle:
                        TextStyle(fontFamily: 'InterMedium', fontSize: 13),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Quand l'avez vous perdu ?",
                style: TextStyle(fontFamily: 'InterRegular'),
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 35,
                child: TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    fillColor: grisClair,
                    filled: true,
                    labelText: "Date",
                    labelStyle:
                        TextStyle(fontFamily: 'InterMedium', fontSize: 13),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: _choisirDate, // Ouvre le calendrier
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Informations supplémentaires ?",
                style: TextStyle(fontFamily: 'InterRegular'),
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                controller: infoSuppController,
                maxLines: 3,
                decoration: InputDecoration(
                  fillColor: grisClair,
                  filled: true,
                  labelText: "Informations supplémentaires",
                  labelStyle: TextStyle(
                    fontFamily: 'InterMedium',
                    fontSize: 13,
                  ),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 16),
              TextButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                      grisClair), // Couleur personnalisée
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Bordure personnalisée
                    ),
                  ),
                ),
                onPressed:
                    _choisirImage, // Appel de la fonction pour choisir l'image
                icon: Icon(
                  Icons.camera_alt,
                  color: Colors.black,
                ),
                label: Text(
                  "Attacher une photo",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16),
              _image != null
                  ? Image.file(
                      _image!,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.image_not_supported, size: 50),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (objetController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Donnez un nom à l'objet svp",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    if (lieuController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Indiquez le lieu de perte svp",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    if (dateController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Indiquez la date de perte svp",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    try {
                      await _submitForm();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Objet signalé avec succès !",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Erreur lors du signalement.",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                        const Color.fromRGBO(244, 171, 90, 1)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Bordure personnalisée
                      ),
                    ),
                  ),
                  child: Text(
                    "Signaler",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Chercher un objet perdu
              SizedBox(height: 32),
              Text(
                'Liste des objets perdus',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 50,
                width: 200,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    fillColor: grisClair,
                    filled: true,
                    labelText: "Chercher",
                    labelStyle:
                        TextStyle(fontFamily: 'InterMedium', fontSize: 13),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30)),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),

              // Liste des objets perdus
              SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: _service.getLostObjects(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: AppLoader(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        children: [
                          const Text('Erreur de chargement'),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {});
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color.fromRGBO(244, 171, 90, 1)),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Bordure personnalisée
                                ),
                              ),
                            ),
                            child: Text(
                              "Réessayer",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData) {
                    return EmptyStateWidget(
                      message: "Aucun objet perdu n'est encore signalé",
                      icon: Icons.search_off_outlined,
                    );
                  } else {
                    final lostObjects = snapshot.data!.docs;

                    // Search filtering based on a potential search query
                    final filteredObjects = lostObjects.where((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      var description = data['description']?.toLowerCase();
                      return description.contains(_searchQuery);
                    }).toList();

                    if (filteredObjects.isEmpty) {
                      return EmptyStateWidget(
                        message: 'Aucun objet trouvé.',
                        icon: Icons.search_off_outlined,
                      );
                    }

                    return SizedBox(
                      height: 500,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: filteredObjects.length,
                        itemBuilder: (context, index) {
                          var lostObject = filteredObjects[index].data()
                              as Map<String, dynamic>;
                          String description = lostObject['description'];
                          String details = lostObject['details'] ?? '';
                          String lieu =
                              lostObject['lieu'] ?? 'Unknown location';
                          String date = lostObject['date'] ?? 'Unknown date';
                          String? photoUrl = lostObject[
                              'photoURL']; // Nullable: May not have a photo
                          bool estTrouve = lostObject['etat'] != 0;

                          return Card(
                            color: eptLightOrange,
                            elevation: 3,
                            margin: EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(description),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  details != ''
                                                      ? details
                                                      : "Pas d'infos supplémentaires",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(
                                                    height:
                                                        20), // Add some space before the separator
                                                Divider(
                                                    thickness:
                                                        1.0), // Visual separator (line)

                                                // Full name of the person who reported the lost object
                                                SizedBox(height: 10),
                                                FutureBuilder(
                                                  future:
                                                      _service.getUserByEmail(
                                                          lostObject['idUser']),
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return LinearProgressIndicator();
                                                    } else {
                                                      Map<String, dynamic>?
                                                          signalant =
                                                          snapshot.data;
                                                      return Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          (signalant == null
                                                              ? 'Inconnu'
                                                              : '${signalant["prenom"]} ${signalant["nom"]} ${signalant["promo"]}'), // Full name of the reporter
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                            color: Colors
                                                                .blueAccent, // You can customize the color and style here
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                )
                                              ],
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStateProperty.all<
                                                              Color>(
                                                          const Color.fromRGBO(
                                                              244, 171, 90, 1)),
                                                  shape: WidgetStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  'Fermer',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Colors.white),
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: photoUrl != null
                                        ? Image.network(
                                            photoUrl,
                                            height: 120,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            height:
                                                120, // Ajustement de la hauteur
                                            color: eptLightOrange,
                                            child: Center(
                                              child: Icon(
                                                  Icons.image_not_supported,
                                                  size: 50),
                                            ),
                                          ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    description,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    maxLines:
                                        1, // Limite de ligne pour éviter trop de texte
                                    overflow: TextOverflow
                                        .ellipsis, // Texte trop long coupé avec '...'
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.place,
                                        size: 15,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        lieu == '' ? 'unknown' : lieu,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'InterRegular',
                                        ),
                                        maxLines: 1, // Limite de ligne
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        size: 15,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        date == '' ? 'unknown' : date,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'InterRegular',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          estTrouve
                                              ? Text(
                                                  'Trouvé',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 10,
                                                  ),
                                                )
                                              : Text(
                                                  'Non Trouvé',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                        ],
                                      ),
                                      currentUser != null &&
                                              currentUser!.email ==
                                                  lostObject['idUser']
                                          ? SizedBox(
                                              height: 10,
                                              width: 40,
                                              child: Transform.scale(
                                                scale: 0.5,
                                                child: Switch(
                                                  activeThumbColor:
                                                      Colors.green,
                                                  value:
                                                      1 == lostObject['etat'],
                                                  onChanged: (value) async {
                                                    await _service
                                                        .toggleFoundStatus(
                                                      lostObjects[index].id,
                                                      value ? 1 : 0,
                                                    );
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          value
                                                              ? 'Objet marqué comme trouvé!'
                                                              : 'Objet marqué comme perdu!',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        backgroundColor:
                                                            Colors.green,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
