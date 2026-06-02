import 'package:flutter/material.dart';
import 'package:new_app/utils/app_colors.dart';

Widget SubmittedButton(String label, Function() _onSubmited) {
  return ElevatedButton(
    onPressed: _onSubmited,
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 16, color: Colors.black),
    ),
  );
}
