import 'package:flutter/material.dart';

Widget reusableCommentInput(String label, TextEditingController controller,
    FormFieldValidator function, Function saveCommen) {
  return TextFormField(
    controller: controller,
    validator: function,
    decoration: InputDecoration(
      suffixIcon: IconButton(
        icon: Icon(Icons.send),
        onPressed: () {
          saveCommen();
        },
      ),
      labelText: label,
      labelStyle: TextStyle(fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  );
}
