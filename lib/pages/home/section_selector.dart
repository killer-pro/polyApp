import 'package:flutter/material.dart';
import 'package:new_app/utils/app_colors.dart';

class SectionSelector extends StatefulWidget {
  int value;
  int groupValue;
  void Function(int?)? onChanged;
  String text;
  SectionSelector(
      {super.key,
      required this.value,
      required this.groupValue,
      required this.onChanged,
      required this.text});

  @override
  State<SectionSelector> createState() => _SectionSelectorState();
}

class _SectionSelectorState extends State<SectionSelector> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        bool selected = widget.value != widget.groupValue;
        if (selected) {
          widget.onChanged!(widget.value);
        }
      },
      child: Column(
        children: [
          Text(
            widget.text,
            style: TextStyle(
                fontFamily: "Inter",
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: widget.value == widget.groupValue
                    ? Colors.black
                    : eptDarkGrey),
          ),
          const SizedBox(
            height: 5,
          ),
          Container(
            width: 30,
            height: 5,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: widget.value == widget.groupValue
                    ? Colors.black
                    : Colors.white),
          )
        ],
      ),
    );
  }
}
