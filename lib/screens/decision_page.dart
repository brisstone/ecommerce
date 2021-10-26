import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/screens/home_screen.dart';
import 'package:ecommerce/screens/start_page.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'change_password_screen.dart';

class DecisionPage extends StatefulWidget {
  @override
  _DecisionPageState createState() => _DecisionPageState();
}

class _DecisionPageState extends State<DecisionPage> {
  bool progress=false;

  @override
  void initState() {
    initDynamicLinksAndUpdateCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ModalProgressHUD(
        inAsyncCall: progress,
        color: Colors.white,
        opacity: 1,
        child: Container(
          color: Colors.white,
          child: Center(
              child: Image.asset('images/logo.png', height: 150,)),
        ),
      ),
    );
  }

  void openHomeIfLoggedIn() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    print('id ${(await sp.getString('id'))}');

    if(sp.containsKey('id')&& (await sp.getString('id')).isNotEmpty&& (await sp.getString('id')).length>5) {
      // Navigator.pop(context);
      bool is2Update= false;// await uCheck4Updates(context);
      if(is2Update)return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
    }
    else{
      // Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>StartPage()));
    }
    // this.dispose();
  }
  void initDynamicLinksAndUpdateCheck() async {
    print('initing dynamic links');
    try {
      setDlinksProgress(true);

      final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance
          .getInitialLink();
      final Uri deepLink = data?.link;
      String linkDetails = deepLink.toString();
      String mail2Ret=await uGetSharedPrefValue(kMail2Retrieve);
      // Remove notification. Replace with print
      print('link details: ${linkDetails}, mail2ret: ${mail2Ret}');
      if (!linkDetails.startsWith('null') && !mail2Ret.startsWith('null')&& linkDetails.contains(mail2Ret)&& linkDetails.contains('gmartpass.pageret.link')) {
        String id = await uGetSharedPrefValue(kIdKey);
        String email2get = await uGetSharedPrefValue(kMail2Retrieve);
        if ((id != null && id != 'null' && id.length > 5)||(email2get == null) ||(email2get != null && email2get != 'null' && email2get.trim()
            .isEmpty)){

        }else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChangePasswordScreen()));
          return;
        }
      }
    }catch(e,t){
      print('dynamic links. error:$e, stack trace: $t');
    }
    await openHomeIfLoggedIn();
  }

  setDlinksProgress(bool b){
    setState(() {
      progress=b;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
