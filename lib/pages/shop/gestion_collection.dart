import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/collection.dart';
import 'package:new_app/pages/shop/edit_collection.dart';
import 'package:new_app/utils/app_colors.dart';
import 'package:new_app/widgets/app_loader.dart';

class CollectionListPage extends StatefulWidget {
  @override
  _CollectionListPageState createState() => _CollectionListPageState();
}

class _CollectionListPageState extends State<CollectionListPage> {
  final CollectionReference _collectionCollection =
      FirebaseFirestore.instance.collection('COLLECTION');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des Collections"),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _collectionCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: AppLoader());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur de chargement des collections"));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Aucune collection trouvée"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot doc = snapshot.data!.docs[index];
                Collection collection =
                    Collection.fromJson(doc.data() as Map<String, dynamic>);

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  decoration: BoxDecoration(
                      color: AppColors.ligthPrimary,
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text(collection.nom),
                    subtitle: Text(
                        "Créée le : ${collection.date.toLocal().toString().split(' ')[0]}"),
                    onTap: () {
                      changerPage(
                          context,
                          EditCollectionPage(
                            collection: collection,
                          ));
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
