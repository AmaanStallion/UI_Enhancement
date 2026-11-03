import 'package:flutter/material.dart';

class FloatTextInputField extends StatefulWidget {
  final String? initialValue;
  final String? lblHeadingText;
  final String? lblText;
  final FocusNode? focusOnTextField;
  final FocusNode? focusOnNextTextField;
  final FormFieldValidator? validator;
  final FormFieldSetter? onSaved;
  final bool? obscureText;
  final InkWell? suffix;
  final bool? enabled;
  final Key? key;
  final TextInputType? keyboardType;

  const FloatTextInputField({@required this.lblText, this.lblHeadingText,
    this.focusOnTextField, this.focusOnNextTextField, this.validator,
    this.onSaved, this.obscureText, this.suffix, this.initialValue, this.enabled,
    this.key, this.keyboardType
  });

  @override
  _FloatTextInputFieldState createState() => _FloatTextInputFieldState();
}

class _FloatTextInputFieldState extends State<FloatTextInputField> {

  bool checkFocus = false;

  void _requestFocus(){
    setState(() {
      FocusScope.of(context).requestFocus(widget.focusOnTextField);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Focus(
        onFocusChange: (hasFocus){
          setState(() {
            checkFocus = true;
          });
        },
        child: TextFormField(
          key: widget.key,
          initialValue: widget.initialValue,
          obscureText: widget.obscureText!,
          onSaved: widget.onSaved,
          validator: widget.validator,
          onTap: _requestFocus,
          autofocus: false,
          focusNode: widget.focusOnTextField,
          enabled: widget.enabled,
          textInputAction: TextInputAction.next,
          style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.normal,
          ),
          cursorColor: Colors.black,
          keyboardType: widget.keyboardType,
          onFieldSubmitted: (term) {
            setState(() {
              checkFocus = false;
            });
            widget.focusOnTextField?.unfocus();
            FocusScope.of(context).requestFocus(widget.focusOnNextTextField);
          },
          decoration:  InputDecoration(
            suffix: widget.suffix,
            labelText: widget.lblHeadingText,
            hintText: checkFocus ? widget.lblText : widget.lblHeadingText,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide:
              BorderSide(color: Colors.grey, width: 0.8),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide:
              BorderSide(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
          ),
        ),
      ),
    );
  }
}
