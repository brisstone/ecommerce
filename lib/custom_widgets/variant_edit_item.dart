import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';

class VariantEditItem extends StatelessWidget {
  VariantEditItem({
    @required this.onPricedChanged,
    @required this.s,
    @required this.onValueChanged,
    @required this.onDelete,
    this.price='',
    this.label='variant'
  });

  final String s;
  String price;
  String label;
  Function(String s) onPricedChanged;
  Function(String s) onValueChanged;
  Function onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        children: [
          GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.clear, color: kThemeBlue,size: 20,)),
          Expanded(
            child: TextField(
              controller: TextEditingController(text:label),
              onChanged: onValueChanged,
              decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter variant',
                  hintStyle: TextStyle(color: Colors.grey.shade300),
                  fillColor: Colors.transparent
              ),
              maxLength: 10,
              inputFormatters: [LengthLimitingTextInputFormatter(10)],
              textInputAction: TextInputAction.next,
              style: TextStyle(color: kThemeBlue),
              keyboardType: TextInputType.text,
            ),
          ),
          SizedBox(width: 5,),
          Expanded(
            child: TextField(
              controller: TextEditingController(text:price),
              onChanged: onPricedChanged,
              decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter price(\u20a6)',
                  hintStyle: TextStyle(color: Colors.grey.shade300),
                  fillColor: Colors.transparent
              ),
              maxLength: 7,
              inputFormatters: [LengthLimitingTextInputFormatter(7)],
              textInputAction: TextInputAction.next,
              style: TextStyle(color: kThemeBlue),
              keyboardType: TextInputType.number,
            ),
          )
        ],
      ),
    );
  }
}
