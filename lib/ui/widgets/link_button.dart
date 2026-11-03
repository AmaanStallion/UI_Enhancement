import 'package:flutter/material.dart';

class LinkButton extends StatefulWidget {

  final Function onTap;
  final String lblText;

  const LinkButton({required this.lblText, required this.onTap});

  @override
  _LinkButtonState createState() => _LinkButtonState();
}

class _LinkButtonState extends State<LinkButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        widget.onTap();
      },
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(top:4.0),
          child: Text(
            widget.lblText,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
            ),
          ),
        ),
      ),
    );
  }
}
