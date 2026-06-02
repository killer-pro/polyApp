import 'package:flutter/material.dart';
import 'package:new_app/utils/app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final bool readOnly;
  final GestureTapCallback? onTap;
  final TextInputAction? textInputAction;
  final int? maxLines;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.textInputAction = TextInputAction.next,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final hPadding = size.width * (isTablet ? 0.03 : 0.04);
    final vPadding = size.height * (isTablet ? 0.015 : 0.018);

    return TextFormField(
      maxLines: maxLines,
      textInputAction: textInputAction,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: isTablet ? 16 : 14,
          ),
      decoration: InputDecoration(
        labelText: hintText,
        labelStyle: TextStyle(fontSize: isTablet ? 16 : 14),
        floatingLabelStyle: TextStyle(
          fontSize: isTablet ? 16 : 14,
          color: AppColors.primary,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        focusColor: AppColors.primary,
        contentPadding:
            EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(width: 1, color: AppColors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(width: 1.5, color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(width: 1, color: AppColors.echec),
        ),
      ),
    );
  }
}
