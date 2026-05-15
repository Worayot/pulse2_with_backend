import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InfoTextField extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final Color boxColor;
  final double minWidth;
  final double fontSize;
  final EdgeInsets padding;
  final Color textColor;
  final bool? numberOnly;
  final bool blockEditing;
  final String? hintText;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  final bool obscure;
  final bool showToggle;
  final IconData? toggleIcon;

  final Function(String)? onChanged;

  const InfoTextField({
    super.key,
    required this.title,
    required this.controller,
    required this.boxColor,
    required this.minWidth,
    required this.fontSize,
    this.padding = const EdgeInsets.all(8.0),
    this.textColor = Colors.black,
    this.numberOnly,
    this.focusNode,
    this.blockEditing = false,
    this.hintText,
    this.validator,
    this.obscure = false,
    this.showToggle = false,
    this.toggleIcon,
    this.onChanged, // 👈 NEW
  });

  @override
  State<InfoTextField> createState() => _InfoTextFieldState();
}

class _InfoTextFieldState extends State<InfoTextField> {
  late bool isObscured;

  @override
  void initState() {
    super.initState();
    isObscured = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = !widget.blockEditing;

    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),

          Container(
            constraints: BoxConstraints(maxWidth: double.infinity, minWidth: widget.minWidth),
            height: 40,
            decoration: BoxDecoration(color: widget.boxColor, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextFormField(
                      focusNode: widget.focusNode,
                      controller: widget.controller,
                      keyboardType: widget.numberOnly == true ? TextInputType.number : TextInputType.text,
                      inputFormatters: widget.numberOnly == true ? [FilteringTextInputFormatter.digitsOnly] : [],
                      obscureText: isObscured,
                      maxLines: 1,
                      style: TextStyle(color: widget.textColor, fontSize: widget.fontSize),
                      enabled: isEnabled,
                      validator: widget.validator,
                      autovalidateMode: AutovalidateMode.onUserInteraction,

                      onChanged: widget.onChanged,

                      decoration: InputDecoration(border: InputBorder.none, isCollapsed: true, hintText: widget.hintText),
                    ),
                  ),
                ),

                if (widget.showToggle)
                  IconButton(
                    padding: const EdgeInsets.only(right: 8),
                    icon: Icon(isObscured ? (widget.toggleIcon ?? Icons.visibility_off) : (widget.toggleIcon ?? Icons.visibility), size: 20),
                    onPressed: () {
                      setState(() {
                        isObscured = !isObscured;
                      });
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
