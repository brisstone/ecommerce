import 'package:flutter/material.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/custom_widgets/my_button.dart';
import 'package:ecommerce/screens/decision_page.dart';
import 'package:ecommerce/screens/home_screen.dart';
import 'package:ecommerce/screens/start_page.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class UpdatePage extends StatefulWidget {
  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  var progress=false;
  double marginVal=16;
  String upVers='';
  String upMessage= '';
  String upLink='';
  bool cancelable=true;


  @override
  void initState() {
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    print('upVers $upVers, upMessage: $upMessage, upLink: $upLink');
    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: progress,
        color: Colors.white,
        child: Material(
          child: Container(
            color: Colors.white,
            height: double.maxFinite,
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  SizedBox(height: 100,),
                  if(cancelable)Padding(
                    padding: EdgeInsets.only(left:20),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: GestureDetector(
                          onTap: () async {
                            SharedPreferences sp = await SharedPreferences.getInstance();
                            print('id ${(await sp.getString('id'))}');
                            if(sp.containsKey('id')&& (await sp.getString('id')).isNotEmpty&& (await sp.getString('id')).length>5) {
                            // Navigator.pop(context);
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
                            }
                            else{
                            // Navigator.pop(context);
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>StartPage()));
                            }                        },
                          child: Icon(Icons.cancel, color: kLightBlue, size: 27,)),),
                  ),
                  SizedBox(height: 20,),
                  Hero(
                      tag: 'mainLogo',
                      child: Image.asset('images/logo.png', color: kThemeBlue, height: 150,)),
                  SizedBox(height: 35,),
                  Text(upMessage, textAlign: TextAlign.center, style: GoogleFonts.mogra(fontSize: 15, color: kThemeBlue),),
                  SizedBox(height: 25,),
                  MyButton(text: 'Proceed', buttonColor: kLightBlue, onPressed: openLink),
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }

  openLink() async {
      try {
        const url = kSellerTermsAndConditionsPage;
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      }catch(e){
        uShowErrorNotification('An error occured');
      }
  }

  Future<void> _initData() async {
    setProgress(true);
    try {
      List<String> updateData = (await uGetSharedPrefValue(kUpdate)).split('<');
      upVers = updateData[0];
      upMessage = updateData[1];
      upLink = updateData[2];
      cancelable = updateData[3].trim().contains('y');
      setProgress(false);
    }catch(e){
      print('update error: $e');
      Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>DecisionPage()));
    }

  }

  void setProgress(bool bool) {
    setState(() {
      progress=bool;
    });
  }
}
