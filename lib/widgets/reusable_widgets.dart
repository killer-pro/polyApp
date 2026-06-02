import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_app/utils/app_colors.dart';

Widget reusableTextFormField(String label, TextEditingController controller,
    FormFieldValidator function) {
  return TextFormField(
    controller: controller,
    validator: function,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  );
}

Widget buildMatchCard(String title, String logoteam1, String score1,
    String logoteam2, String score2) {
  return Column(
    children: [
      Container(
        decoration: BoxDecoration(
            color: grisClair, borderRadius: BorderRadius.circular(6)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: grisClair,
                        backgroundImage: CachedNetworkImageProvider(logoteam1),
                      ),
                      Text(
                        score1,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(score2),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: grisClair,
                        backgroundImage: CachedNetworkImageProvider(logoteam2),
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
  );
}
