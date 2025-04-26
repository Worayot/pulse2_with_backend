import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ToggleIconButton extends StatefulWidget {
  final bool enableButton;
  final VoidCallback addPatientFunc;
  final VoidCallback removePatientFunc;
  final bool buttonState;
  const ToggleIconButton({
    super.key,
    required this.enableButton,
    required this.addPatientFunc,
    required this.removePatientFunc,
    required this.buttonState,
  });

  @override
  _ToggleIconButtonState createState() => _ToggleIconButtonState();
}

class _ToggleIconButtonState extends State<ToggleIconButton> {
  late bool _isPlus;

  @override
  void initState() {
    super.initState();
    _isPlus = widget.buttonState;
    // Initialize _isPlus after the first frame to prevent flickering
    Future.delayed(Duration.zero, () {
      setState(() {
        _isPlus = widget.buttonState;
      });
    });
  }

  @override
  void didUpdateWidget(ToggleIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync _isPlus with buttonState when it changes
    if (widget.buttonState != oldWidget.buttonState) {
      setState(() {
        _isPlus = widget.buttonState;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: ElevatedButton(
        onPressed:
            widget.enableButton
                ? () {
                  if (_isPlus) {
                    widget.addPatientFunc();
                  } else {
                    widget.removePatientFunc();
                  }
                  setState(() {
                    _isPlus = !_isPlus; // Toggle button state
                  });
                }
                : () {},
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.only(left: 2),
          elevation: 0,
        ),
        child: Center(
          child: Icon(
            _isPlus ? FontAwesomeIcons.plus : FontAwesomeIcons.minus,
            size: 25,
            color: _isPlus ? const Color(0xff3362CC) : Colors.red,
          ),
        ),
      ),
    );
  }
}
