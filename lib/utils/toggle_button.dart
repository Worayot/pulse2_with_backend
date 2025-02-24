import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToggleButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<bool>? onToggle; // Callback for the toggle state
  final String preferenceKey; // Key to save and load state

  const ToggleButton({
    super.key,
    required this.text,
    required this.icon,
    required this.activeColor,
    required this.inactiveColor,
    this.onToggle,
    required this.preferenceKey, // Pass the preference key for saving/loading state
  });

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  bool isActive = false;

  @override
  void initState() {
    super.initState();
    _loadState(); // Load the state when the widget is initialized
  }

  // Load the saved toggle state from SharedPreferences
  void _loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isActive = prefs.getBool(widget.preferenceKey) ??
          false; // Default to false if no saved state
    });
  }

  // Save the toggle state to SharedPreferences
  void _saveState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(widget.preferenceKey, isActive);
  }

  // Toggle the state and notify the parent if needed
  void toggleButton() {
    setState(() {
      isActive = !isActive;
      _saveState(); // Save the updated state
      if (widget.onToggle != null) {
        widget.onToggle!(isActive); // Notify parent of the toggle state
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleButton,
      child: AnimatedContainer(
        duration: const Duration(
            milliseconds: 200), // Adjust duration for smoother animation
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
        decoration: BoxDecoration(
          color: widget.inactiveColor,
          border: Border.all(
            color: isActive ? widget.activeColor : widget.inactiveColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          // Adding shadow conditionally based on isActive
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: widget.activeColor.withOpacity(0.9), // Shadow color
                    offset: const Offset(0, 4), // Shadow offset
                    blurRadius: 3, // Blur radius of the shadow
                  ),
                ]
              : [], // No shadow when inactive
        ),
        width: MediaQuery.of(context).size.width / 3,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.text,
              style: TextStyle(
                color: widget.activeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              widget.icon,
              color: widget.activeColor,
            ),
          ],
        ),
      ),
    );
  }
}
