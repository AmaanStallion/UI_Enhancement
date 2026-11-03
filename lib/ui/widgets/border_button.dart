import 'package:flutter/material.dart';

class BorderButton extends StatefulWidget {

  final Function onTap;
  final String lblText;
  final Color color;

  const BorderButton({required this.lblText, required this.color, required this.onTap});

  @override
  _BorderButtonState createState() => _BorderButtonState();
}

class _BorderButtonState extends State<BorderButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        widget.onTap();
      },
      child: Container(
        width: double.infinity,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.black,
          ),
        ),
        child: Text(
          widget.lblText,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17.0,
          ),
        ),
      ),
    );
  }
}
