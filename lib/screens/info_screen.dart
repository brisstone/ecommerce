
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class InfoScreen extends StatefulWidget {
  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> with SingleTickerProviderStateMixin{

  AnimationController _controller;


  @override
  void initState() {
    _controller=AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _controller.forward();
    _controller.addListener(() {
      setState(() { });
      print(_controller.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
            tag: 'infoIcon',
            child: Icon(CupertinoIcons.info, size: 30,)),
        backgroundColor: kThemeBlue.withOpacity(_controller.value),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        color: kThemeBlue.withOpacity(_controller.value),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(height: 1, width: 200, margin: EdgeInsets.symmetric(vertical: 15),),
            Padding(
              padding: const EdgeInsets.only(left:8.0),
              child: Text('Developer: Algure', style: TextStyle(color: Colors.white),),
            ),
            Container(height: 1, width: 200, margin: EdgeInsets.symmetric(vertical: 15),),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text('UI/UX: Teekay',  style: TextStyle(color: Colors.white)),
            ),
            Container(height: 1, width: 200,  margin: EdgeInsets.symmetric(vertical: 15),),
            Padding(
              padding: EdgeInsets.only(left:8.0),
              child: Text('UI/UX: PDS',  style: TextStyle(color: Colors.white) ,),
            ),
              Container(height: 1, width: 200,  margin: EdgeInsets.symmetric(vertical: 15),),
            Padding(
              padding: EdgeInsets.only(left:8.0),
              child: Text('Pics: Canva.com',  style: TextStyle(color: Colors.white) ,),
            ),  Container(height: 1, width: 200,  margin: EdgeInsets.symmetric(vertical: 15),),
            FlatButton(

              splashColor: Colors.white,
              onPressed: (){},
              child: Center(child: Text('View our terms of service ', textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blue, textBaseline: TextBaseline.alphabetic, fontWeight: FontWeight.w500, fontSize: 16) ,)),
            ),

            Expanded(
                child: Container(
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsets.only(right: 10, bottom: 30),
                    child: Image.asset('images/logo.png', height: 150, width: 150, fit: BoxFit.contain,)
                )
            ),
          ],
        ),
      ),
    );
  }
}
