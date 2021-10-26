import 'package:flutter/material.dart';

import '../constants.dart';

class SellerContactWidget extends StatelessWidget {

  SellerContactWidget({this.icon, this.label, this.color, this.function});

  IconData icon;
  String label;
  Color color;
  Function function;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color
        ),
        padding: EdgeInsets.all(8),
      child: Icon(
        icon,
        color: Colors.white,
        size: 16,)
      )
    );
  }
}
