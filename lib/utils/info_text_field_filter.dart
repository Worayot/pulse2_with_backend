import 'package:flutter/material.dart';

class InfoTextField extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final Color boxColor;
  final bool fillSpace;
  final String? hintText;
  final void Function(String)? onChanged;

  const InfoTextField({super.key, required this.title, required this.controller, required this.boxColor, required this.fillSpace, this.hintText, this.onChanged});

  @override
  State<InfoTextField> createState() => _InfoTextFieldState();
}

class _InfoTextFieldState extends State<InfoTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(alignment: Alignment.centerLeft, child: Text(widget.title, textAlign: TextAlign.left, style: const TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(height: 5),
        Container(
          width: widget.fillSpace ? double.infinity : MediaQuery.of(context).size.width / 3,
          height: 40,
          decoration: BoxDecoration(color: widget.boxColor, borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 0, left: 12, right: 12),
            child: TextFormField(
              controller: widget.controller,
              maxLines: 1,
              onChanged: widget.onChanged,
              style: const TextStyle(color: Colors.black, fontSize: 14),
              decoration: InputDecoration(border: InputBorder.none, isCollapsed: true, hintText: widget.hintText, hintStyle: const TextStyle(color: Colors.grey, fontSize: 14)),
            ),
          ),
        ),
      ],
    );
  }
}
