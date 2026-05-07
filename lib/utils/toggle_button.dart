import 'package:flutter/material.dart';

class ToggleButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color activeColor;
  final Color inactiveColor;
  final bool isActive;
  final ValueChanged<bool>? onToggle;

  const ToggleButton({super.key, required this.text, required this.icon, required this.activeColor, required this.inactiveColor, required this.isActive, this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle?.call(!isActive),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
        decoration: BoxDecoration(
          color: inactiveColor,
          border: Border.all(color: isActive ? activeColor : inactiveColor, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive ? [BoxShadow(color: activeColor.withOpacity(0.6), offset: const Offset(0, 3), blurRadius: 4)] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(text, style: TextStyle(color: activeColor, fontWeight: FontWeight.bold)), const SizedBox(width: 4), Icon(icon, color: activeColor)],
        ),
      ),
    );
  }
}
