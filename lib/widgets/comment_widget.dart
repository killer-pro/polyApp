import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_app/fonctions.dart';

class CommentWidget extends StatelessWidget {
  final String name;
  final String comment;

  final DateTime timeAgo;
  final String photo;

  const CommentWidget(
      {super.key,
      required this.name,
      required this.comment,
      required this.timeAgo,
      required this.photo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: ResizeImage(
                CachedNetworkImageProvider(photo),
                width: 65,
              )

            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(comment),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Spacer(),
                      Text(
                        timeAgoCustom(timeAgo),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
