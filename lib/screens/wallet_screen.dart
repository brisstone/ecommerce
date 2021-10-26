
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
// import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/custom_widgets/nav_button.dart';
import 'package:ecommerce/screen_models/wallet_model.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import '../utility_functions.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin{

  String _email='email@example.com';
  String _name='Name';
  var walletModel;
  AnimationController _controller;
  List<Widget> payOptions=[];
  Animation slideInLeftAnim;
  bool progress=false;

  void showProgress(bool b){
    progress=b;
    setState(() {});
  }

 @override
  void initState() {
   // PaystackPlugin.initialize(
   //     publicKey: kPaystackPubKey);

    _controller=AnimationController(
      duration: Duration(milliseconds:1500 ),
      vsync: this,
    );
    slideInLeftAnim=CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _controller.addListener(() {
      setState(() {});
      print(_controller.value);
    });
 }


  @override
  void didChangeDependencies() {
    walletModel=Provider.of<WalletModel>(context, listen: false);
    walletModel.setWalletBalance();
    payOptions=walletModel.getPayChildren(this.context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('My Wallet',
        style: TextStyle(
           color: Colors.white,
          ),
        ),
    iconTheme: IconThemeData(color: Colors.white),
    elevation: 0,
    backgroundColor: kThemeBlue),
      body: Builder(builder: (BuildContext context){
        WalletModel.walletContext=context;// to show Snackbar
        return ModalProgressHUD(
          inAsyncCall: Provider.of<WalletModel>(context).getProgress(),
          color: Colors.black.withOpacity(0.5),
          child: Stack(
            children: [
              Container(
                height: (_controller.value*250)+50,
                decoration: BoxDecoration(
                    color: kThemeBlue,
                    borderRadius: BorderRadius.circular(35)
                ),
              ),
              Container(
                height: (_controller.value*250),
                color: kThemeBlue,
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Account balance',
                      style: TextStyle(color: kLightBlue),),
                    SizedBox(height: 30,),
                    Text('\u20a6 ${Provider.of<WalletModel>(context).getBallance()}',
                        style: TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.w900),),
                    SizedBox(height: 30,),
                    Text('Select payment option',
                      style: TextStyle(color: kLightBlue, fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 250),
                child: AnimatedList(
                  initialItemCount: payOptions.length,
                  padding: EdgeInsets.only(bottom: 40),
                  itemBuilder: (context, index, animation){
                    return(payOptions[index]);
                  },
                ),
              )
            ],
          ),
        );
      },
      )
    );
  }

}
