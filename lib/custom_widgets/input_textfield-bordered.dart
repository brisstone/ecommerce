

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class InputTextFieldBordered extends StatelessWidget {

  InputTextFieldBordered({this.onChangedFunc});

  final onChangedFunc;

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(color: kThemeBlue),
      textAlign: TextAlign.center,
      decoration: kStrokedTextFieldDecoration,
      onChanged: onChangedFunc,
    );
  }
}
