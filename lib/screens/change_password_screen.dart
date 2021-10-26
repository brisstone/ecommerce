import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecommerce/NotificationHelper.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/main.dart';
import 'package:ecommerce/mart_objects/customer.dart';
import 'package:ecommerce/screens/decision_page.dart';
import 'package:ecommerce/screens/home_screen.dart';
import 'package:ecommerce/screens/login_screen.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:minimize_app/minimize_app.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> with SingleTickerProviderStateMixin{

  bool showPassword=false;
  bool showPassword2=false;
  double marginVal=16;
  Color textFillColor=kLightBlue.withAlpha(50);//Color(0x22000000);
  AnimationController _controller;
  CurvedAnimation slideInLeftAnim;
  String password='';
  String password2='';
  String email='';
  bool showProgress=false;
  bool progress=false;
  FocusNode emailFocus= FocusNode();
  FocusNode paswordFocus= FocusNode();
  FocusNode paswordFocus2= FocusNode();

  var hintColor=Colors.grey;
  var hintSelectedColor=Colors.grey;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: progress,
        color: Colors.black.withOpacity(0.4),
        child: Container(
          color: Colors.white,
          height: double.maxFinite,
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                SizedBox(height: 100,),
                Text('Retrieve Account', style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.bold, fontSize: 20),),
                SizedBox(height: 20,),
                Hero(
                    tag: 'mainLogo',
                    child: Image.asset('images/logo.png', color: kThemeBlue, height: _controller.value*150,)),
                SizedBox(height: 25,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: _controller.value*marginVal),
              child: TextField(
                onChanged: (string){email=string.toString();},
                focusNode: emailFocus,
                decoration: InputDecoration(
                    filled: true,
                    prefixIcon: Icon(CupertinoIcons.mail, color: kThemeBlue,),
                    labelText: 'Enter email',
                    labelStyle: TextStyle(
                        color:emailFocus.hasFocus?hintColor:hintSelectedColor
                    ),
                    fillColor: textFillColor
                ),
                textInputAction: TextInputAction.next,
                style: TextStyle(color: kThemeBlue),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
                SizedBox(height: 10,),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: _controller.value*marginVal),
                  child: TextField(
                    onChanged: (string){password=string.toString();},
                    focusNode: paswordFocus,
                    decoration: InputDecoration(
                        filled: true,
                        prefixIcon: Icon(CupertinoIcons.lock, color: kThemeBlue,),
                        suffixIcon: IconButton(icon: Icon(showPassword?Icons.visibility_off:Icons.visibility, color: Colors.grey,), onPressed: toggleIconVisibility,),
                        labelText: 'Enter password',
                        labelStyle: TextStyle(
                            color:paswordFocus.hasFocus?hintColor:hintSelectedColor
                        ),
                        fillColor: textFillColor
                    ),
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: kThemeBlue),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: showPassword?false:true,
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: _controller.value*marginVal),
                  child: TextField(
                    onChanged: (string){password2=string.toString();},
                    focusNode: paswordFocus2,
                    decoration: InputDecoration(
                        filled: true,
                        prefixIcon: Icon(CupertinoIcons.lock, color: kThemeBlue,),
                        suffixIcon: IconButton(icon: Icon(showPassword2?Icons.visibility_off:Icons.visibility, color: Colors.grey,), onPressed: toggleIconVisibility2,),
                        labelText: 'Confirm password',
                        labelStyle: TextStyle(
                            color:paswordFocus2.hasFocus?hintColor:hintSelectedColor
                        ),
                        fillColor: textFillColor
                    ),
                    textInputAction: TextInputAction.done,
                    style: TextStyle(color: kThemeBlue),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: showPassword2?false:true,
                  ),
                ),
                SizedBox(height: 15,),
                Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                  color: kLightBlue,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: FlatButton(onPressed: (){
                  retrieve();
                },
                child: Text('Change password', style: kNavTextStyle,),
                splashColor: Colors.white,)),
                // Container(
                //   width: double.maxFinite,
                //   alignment: Alignment.center,
                //   padding: EdgeInsets.only(left: 20),
                //   child: TextButton(
                //       onPressed: (){
                //         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                //           return LoginScreen();
                //         }));
                //       },
                //       child: Text('Retry login', style: TextStyle(color: kLightBlue, fontWeight: FontWeight.bold, fontSize: 10))),
                // ),
                // SizedBox(height: 25,),

              ],
            ),
          ),
        ),
      ),
    );
  }

  toggleIconVisibility(){
    showPassword=!showPassword;
    setState(() {

    });
  }
  toggleIconVisibility2(){
    showPassword2=!showPassword2;
    setState(() {

    });
  }

  Future<void> retrieve() async {
    setProgress(true);

    email=email.trim();
    if(email==null || email.isEmpty ){
      setProgress(false);
      uShowErrorDialog(this.context,'email cannot be empty');
      return;
    }else if(!email.contains('@')|| !email.contains('.com')|| email.contains(' ')){
      setProgress(false);
      uShowErrorDialog(this.context,'Invalid email');
      return;
    }
    String email2get= await uGetSharedPrefValue(kMail2Retrieve);
    if(email2get!=email.trim()){
      setProgress(false);
      uShowErrorDialog(context, 'It seems this email is wrong \nOR\nthis link is expired');
      return;
    }
    if (password.isEmpty || password.length<6 ) {
      uShowErrorDialog(this.context,'An error occured: Invalid password.\nPassword cannot not be less than 6 characters.');
      return;
    }

    if ( password!=password2 ) {
      uShowErrorDialog(this.context,'Passwords do not match.');
      return;
    }

    if(!(await uCheckInternet())){
      setProgress(false);
      uShowNoInternetDialog(this.context);
      return;
    }
    loginAndChangePassword();
  }

  Future<void> loginAndChangePassword() async {
    try {
      String id = await AzSingle().getUserId(email);
      Customer customer = await AzSingle().getOnlineCustomer(id);
      // uShowOkNotification(customer.toString());
      if (customer == null) {
        uShowCustomDialog(context: this.context,
            icon: Icons.warning,
            iconColor: Colors.red,
            text: 'Sorry: it appears there is an error your account data.\nPlease sign up with another email.',
            buttonList: [
              ['Sign-Up', kLightBlue, () {
                Navigator.pushNamed(context, '/signup');
              }
              ]
            ]);
        return;
      }
      customer.q = password.trim();
      await AzSingle().uploadCustomer2Azure(customer, changePass: false);
      String mail2Ret = await uGetSharedPrefValue(kMail2Retrieve);
      String failedEmails = await uGetSharedPrefValue(kFailedMailKey) ?? '';
      String newmail = failedEmails.replaceAll(mail2Ret, "");
      await uSetPrefsValue(kMail2Retrieve, '');
      await uSetPrefsValue(kFailedMailKey, newmail);
      print('after send Mail ${await uGetSharedPrefValue(kFailedMailKey)}, mail2Ret: $mail2Ret');

      showNotification(flutterLocalNotificationsPlugin,tittle:'Password reset successful.',message: ' You may now exit the app and retry login.');
      await Timer(Duration(seconds: 3), () {
        setProgress(false);
        Navigator.pop(context);
        if(Platform.isIOS)MinimizeApp.minimizeApp();
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      });
    }catch(e,t){
      setProgress(false);
      uShowErrorDialog(context,'An error occured. Please check inputs and try again.');
      print('error: $e, trace: $t');
    }
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
    //   return LoginScreen();
    // }));
  }

  void setProgress(bool b){
    setState(() {
      progress=b;
    });
  }

}
