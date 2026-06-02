import 'package:flutter/material.dart';

Widget ReusableDescriptionInput(String label, TextEditingController controller,
    FormFieldValidator function) {
  return TextFormField(
    controller: controller,
    validator: function,
    keyboardType: TextInputType.text,
    maxLines: 4,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 14,
      ),
      alignLabelWithHint: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
