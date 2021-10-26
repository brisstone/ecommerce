import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/screens/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intro_slider/scrollbar_behavior_enum.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:intro_slider/intro_slider.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with SingleTickerProviderStateMixin{

  bool progress=false;
  AnimationController _controller;
  CurvedAnimation slideInLeftAnim;

  List<Slide> slides=[];

    var titleStyle= GoogleFonts.cantarell(fontSize: 19, color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic);//TextStyle(color: kThemeBlue, fontSize: 17, fontWeight: FontWeight.bold );
  var descStyle= GoogleFonts.courgette(fontSize: 15, color: Colors.white);//TextStyle(color: kThemeBlue, fontSize: 14, );
  Color backColor=kThemeBlue;
  var slideTitleMargin=EdgeInsets.symmetric(vertical: 100);

  @override
  void initState() {
    _controller=AnimationController(
      duration: Duration(milliseconds:1700, ),
      vsync: this,
    );

    slideInLeftAnim=CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _controller.addListener(() {
      setState(() {

      });
    });
    _initSlides();
  }

  @override
  Widget build(BuildContext context) {
     // titleStyle=TextStyle(color: kThemeBlue, fontSize: 17, fontWeight: FontWeight.bold );
     // descStyle=TextStyle(color: kThemeBlue, fontSize: 11, );
    return new IntroSlider(
      // List slides
      slides: this.slides,

      // Skip button
      renderSkipBtn: this.renderSkipBtn(),
      colorSkipBtn: Color(0x33000000),
      highlightColorSkipBtn: Color(0xff000000),

      // Next button
      renderNextBtn: this.renderNextBtn(),

      // Done button
      renderDoneBtn: this.renderDoneBtn(),
      onDonePress: this.onDonePress,
      colorDoneBtn: Color(0x33000000),
      highlightColorDoneBtn: Color(0xff000000),

      // Dot indicator
      colorDot: Colors.white.withAlpha(100), //Color(0x33D02090),
      colorActiveDot: Colors.white,// Color(0xffD02090),
      sizeDot: 13.0,

      // Show or hide status bar
      hideStatusBar: true,
      backgroundColorAllSlides: Colors.white,

      // Scrollbar
      verticalScrollbarBehavior: scrollbarBehavior.SHOW_ALWAYS,
    );
  }


  void onDonePress() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Widget renderNextBtn() {
    return Icon(
      Icons.navigate_next,
      color: kLightBlue,// Color(0xffD02090),
      size: 35.0,
    );
  }

  Widget renderDoneBtn() {
    return Icon(
      Icons.done,
      color: kThemeOrange// Color(0xffD02090),
    );
  }

  Widget renderSkipBtn() {
    return Icon(
      Icons.skip_next,
        color: kLightBlue// Color(0xffD02090),
    );
  }
  Widget _oldBuild(){
    return ModalProgressHUD(
      inAsyncCall: progress,
      color: Colors.black.withOpacity(0.9),
      child: Material(
        child: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          // decoration: BoxDecoration(
          //     image: DecorationImage(image: AssetImage('images/coola.jpg',), fit: BoxFit.cover)
          // ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                    tag: 'mainLogo',
                    child: Image.asset('images/logo.png', height: _controller.value*150,)),
                SizedBox(height: 30,),
                Text('Your market', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.white),),
                InkWell(
                  child: Container(
                    margin: EdgeInsets.all( 5, ),
                    padding: EdgeInsets.all( 10, ),
                    decoration: BoxDecoration(
                        color: kLightBlue.withAlpha(150),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: TextButton(onPressed: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                    },
                      child: Text('Login', style: kNavTextStyle,),
                    ),
                  ),
                ),
                SizedBox(height: 5,),
                InkWell(
                  child: Container(
                    margin: EdgeInsets.all( 10),
                    padding: EdgeInsets.all( 10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                      // border: Border.all(color: kLightBlue)
                    ),
                    child: TextButton(onPressed: (){
                      Navigator.popAndPushNamed(context, '/signup');
                    },
                      child: Text('Sign up', style: kNavTextStyle,),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  void _initSlides() {
    slides.add(
      new Slide(
        title: "BUY IT ALL",
        description: "Find any item you desire and buy with money back guarantee.",
        pathImage: "images/buynow.png",
          backgroundColor: backColor,
        marginTitle: slideTitleMargin,
        styleDescription: descStyle,
          styleTitle: titleStyle
        // colorBegin: kThemeOrange,
        // colorEnd: kThemeBlue,
        // directionColorBegin: Alignment.topRight,
        // directionColorEnd: Alignment.bottomLeft,
      ),
    );

    slides.add(
      new Slide(
        title: "SET UP SHOP",
        description: "Become a seller.\nUpload items.\nPromote items.\nShare item links on social media.\nManage orders with a user friendly interface.",
        pathImage: "images/mobileshop.png",
          backgroundColor: backColor,
        marginTitle: slideTitleMargin,
        styleDescription: descStyle,
          styleTitle: titleStyle
        // colorBegin: kThemeOrange,
        // colorEnd: kThemeBlue,
        // directionColorBegin: Alignment.topRight,
        // directionColorEnd: Alignment.bottomLeft,
      ),
    );

    slides.add(
      new Slide(
        title: "DIRECT COMMUNICATION",
        description: "Communicate directly with buyers and sellers.",
        pathImage: "images/messaging.png",
          backgroundColor: backColor,
        marginTitle: slideTitleMargin,
        styleDescription: descStyle,
        styleTitle: titleStyle

        // colorBegin: kThemeOrange,
        // colorEnd: kThemeBlue,
        // directionColorBegin: Alignment.topRight,
        // directionColorEnd: Alignment.bottomLeft,
      ),
    );
    slides.add(
      new Slide(
        title: "START NOW",
        description: "Get the market in your pocket.",
        pathImage: "images/enrollment.png",
        backgroundColor: backColor,
        marginTitle: slideTitleMargin,
          styleDescription: descStyle,
          styleTitle: titleStyle

        // colorBegin: kThemeOrange,
        // colorEnd: kThemeBlue,
        // directionColorBegin: Alignment.topRight,
        // directionColorEnd: Alignment.bottomLeft,
      ),
    );
  }
}
