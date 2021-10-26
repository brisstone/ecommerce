import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/screens/login_screen.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../utility_functions.dart';

class RetrieveAccountScreen extends StatefulWidget {
  @override
  _RetrieveAccountScreenState createState() => _RetrieveAccountScreenState();
}

class _RetrieveAccountScreenState extends State<RetrieveAccountScreen> with SingleTickerProviderStateMixin{
  bool progress=false;
  String _email;
  AnimationController _controller;
  CurvedAnimation slideInLeftAnim;

  @override
  void initState() {
    _controller=AnimationController(
      duration: Duration(milliseconds:1000, ),
      vsync: this,
    );
    slideInLeftAnim=CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _controller.addListener(() {
      setState(() {

      });
    });
    showFailedMails();
  }

  @override
  Widget build(BuildContext context) {
    showFailedMails();
    return ModalProgressHUD(
      inAsyncCall: progress,
      color: Colors.black.withOpacity(0.4),
      child: Material(
        child: Scaffold(
          body: Container(
            color: kThemeBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                    tag: 'mainLogo',
                    child: Image.asset('images/logo.png', height: _controller.value*150,)),
                SizedBox(height: 30,),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: _controller.value*25),
                  child: TextField(
                    onChanged: (string){this._email=string;},
                    decoration: InputDecoration(
                        filled: true,
                        prefixIcon: Icon(CupertinoIcons.mail, color: Colors.white,),
                        hintText: 'Enter registered email address',
                        hintStyle: TextStyle(
                            color: Colors.grey
                        ),
                        fillColor: Colors.white.withOpacity(0.2)
                    ),
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),

                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: FlatButton(onPressed: (){
                    sendRmail();
                  },
                    child: Text('Retrieve password', style: kNavTextStyle,),
                    splashColor: Colors.white,),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showProgress(bool b){
    progress=b;
    setState(() {

    });
  }

  Future<void> showFailedMails([String s='first']) async {

    SharedPreferences sp=await SharedPreferences.getInstance();
    await sp.reload();
    print('$s test failed mails ${sp.getString('failedMail')}');
  }

  void sendRmail() async{
    showProgress(true);
    SharedPreferences sp=await SharedPreferences.getInstance();

    // DataSnapshot snapshot= await kDbref.reference().child("cus").child(_email.replaceAll('.', '')).once();
    bool isMailRegistered= await AzSingle().checkUserMail(_email);
    if(!isMailRegistered) {
      showProgress(false);
      uShowCustomDialog(context: this.context,
          icon: CupertinoIcons.person,
          iconColor: Colors.blueGrey,
          text: 'Sorry. This email is not registered on Gmart.ng!!!',
          buttonList: [
            ['Sign-Up', kLightBlue, () {
              Navigator.pushNamed(context, '/signup');
            }
            ]
          ]
      );
      return;
    }

    _email=_email.trim();
    if(_email==null || _email.isEmpty ){
      showProgress(false);
      uShowErrorDialog(this.context,'email cannot be empty');
      return;
    }else if(!_email.contains('@')|| !_email.contains('.com')|| _email.contains(' ')){
      showProgress(false);
      uShowErrorDialog(this.context,'Invalid email');
      return;
    }

    if(!(await uCheckInternet())){
      showProgress(false);
      uShowNoInternetDialog(this.context);
      return;
    }

    bool error=false;
    FirebaseAuth fbauth=FirebaseAuth.instance;
    await fbauth.sendPasswordResetEmail(email: _email).catchError((onError)=>(){
      if(onError!=null)error=true;
      // print('error stat: $error, onError: $onError');
    }
    );

    if(!error){
      sp.reload();
      await uSetPrefsValue(kMail2Retrieve,_email);
      showProgress(false);
      moveBackAndNotify();
    }else {
      showProgress(false);
      uShowErrorDialog(context, 'Sorry. An error occured !!!');
    }
  }

  void moveBackAndNotify() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen(passReset: true)));
  }
}
