import 'package:flutter/material.dart';
import 'package:new_app/utils/app_colors.dart';

class EptButton extends StatelessWidget {
  final String title;
  final double width;
  final double height;
  Color fontColor;
  double fontsize;
  double borderRadius;
  Color color;
  Image? icon;
  GestureTapCallback? onTap;
  EptButton(
      {super.key,
      required this.title,
      required this.width,
      required this.height,
      this.borderRadius = 0,
      this.color = orange,
      this.fontsize = 14,
      this.fontColor = Colors.white,
      this.onTap,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(borderRadius)),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: "Inter",
                  fontWeight: FontWeight.bold,
                  fontSize: fontsize,
                  color: fontColor,
                ),
              ),
              if (icon != null) ...[
                SizedBox(
                  width: 10,
                ),
                icon!
              ]
            ],
          ),
        ),
      ),
    );
  }
}
