import 'package:flutter/material.dart';

class SimpleButton extends StatefulWidget {

  final Function onTap;
  final String lblText;
  final Color color;

  const SimpleButton({required this.lblText, required this.color, required this.onTap});

  @override
  _SimpleButtonState createState() => _SimpleButtonState();
}

class _SimpleButtonState extends State<SimpleButton> {
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
        ),
        child: Text(
          widget.lblText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17.0,
          ),
        ),
      ),
    );
  }
}

