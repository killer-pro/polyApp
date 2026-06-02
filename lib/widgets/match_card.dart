import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';
import 'package:new_app/utils/app_colors.dart';

Widget buildMatchCard(
    BuildContext context,
    String id,
    String date,
    String equipe1,
    String equipe2,
    int score1,
    int score2,
    String photo1,
    String photo2,
    Widget destination) {
  return GestureDetector(
      onTap: () => changerPage(context, destination),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: grisClair, borderRadius: BorderRadius.circular(6)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    date,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                              radius: MediaQuery.sizeOf(context).width * 0.08,
                              backgroundImage:ResizeImage(
                                  CachedNetworkImageProvider(photo1),
                                width: 110
                              ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Row(
                            children: [
                              Text(
                                "$equipe1 : ",
                                style: TextStyle(
                                  color: score1 > score2
                                      ? AppColors.success
                                      : score1 == score2
                                          ? AppColors.black
                                          : AppColors.echec,
                                ),
                              ),
                              Text(
                                "$score1",
                                style: TextStyle(
                                  color: score1 > score2
                                      ? AppColors.success
                                      : score1 == score2
                                          ? AppColors.black
                                          : AppColors.echec,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Row(
                            children: [
                              Text(
                                "$score2 : ",
                                style: TextStyle(
                                  color: score1 < score2
                                      ? AppColors.success
                                      : score1 == score2
                                          ? AppColors.black
                                          : AppColors.echec,
                                ),
                              ),
                              Text(
                                equipe2,
                                style: TextStyle(
                                  color: score1 < score2
                                      ? AppColors.success
                                      : score1 == score2
                                          ? AppColors.black
                                          : AppColors.echec,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          CircleAvatar(
                              radius: MediaQuery.sizeOf(context).width * 0.08,
                              backgroundImage: ResizeImage(
                                  CachedNetworkImageProvider(photo2),
                                  width: 110
                              )
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ));
}
