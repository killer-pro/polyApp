import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/models/annonce.dart';
import 'package:new_app/pages/annonce/afficher_annonce.dart';
import 'package:new_app/utils/app_colors.dart';

class InfoCard extends StatelessWidget {
  final Annonce annonce;
  final double width;
  final double height;

  const InfoCard({
    super.key,
    required this.annonce,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return InkWell(
        onTap: () {
          changerPage(context, AfficherAnononceScreen(annonce: annonce));
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
          padding: const EdgeInsets.all(3),
          width: width,
          height: height,
          decoration: BoxDecoration(
              color: eptOrange, borderRadius: BorderRadius.circular(20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: Image(
                image: ResizeImage(
                  CachedNetworkImageProvider(annonce.image),
                  height: 340,
                ),
                height: height,
              ),
            ),
          ),
        ),
      );
    });
  }
}
