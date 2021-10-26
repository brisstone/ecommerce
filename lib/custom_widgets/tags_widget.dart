import 'package:flutter/material.dart';

import '../constants.dart';

class TagsWidget extends StatelessWidget{

  TagsWidget({this.data, this.onDelete});

  String data;
  Function onDelete;

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: BoxDecoration(
          color: kLightBlue,
          borderRadius: BorderRadius.circular(20)
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        children: [
          Text(data, style: kNavTextStyleSmall,),
          FlatButton(
            onPressed: onDelete,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.clear, color: Colors.white,),
            ),
          )
        ],
      ),
    );
  }

}
