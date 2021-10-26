import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:ecommerce/mart_objects/customer.dart';
import 'package:ecommerce/mart_objects/order_item.dart';
import 'package:ecommerce/providers/favorite_provider.dart';
import 'package:ecommerce/providers/promo_model.dart';
import 'package:ecommerce/screen_models/wallet_model.dart';
import 'package:ecommerce/screens/update_prompt_screen.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


import 'constants.dart';
import 'mart_objects/small_mitem.dart';


void uShowSnackBar({ String text,  BuildContext context,
   Function() onPressed,
   String butLabel=''}){
  final scaffold=Scaffold.of(context);
  scaffold.showSnackBar(SnackBar(content: Text(text),
    backgroundColor: kThemeOrange,
    action: SnackBarAction(label: butLabel, onPressed: onPressed,),));
}

Future<dynamic> uGetSharedPrefValue(String key) async {
  SharedPreferences sp=await SharedPreferences.getInstance();
  await sp.reload();
  return sp.get(key).toString();
}

Future<bool> uCheck4Updates(BuildContext context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  try {
    String result = await uGetSharedPrefValue(kUpdate);

    DateFormat df = DateFormat('yy:MM:dd');
    String date = df.format(DateTime.now());
    String savedDate = await uGetSharedPrefValue(kUpdateTime);

    if (date != savedDate && (await uCheckInternet())) {
      print('updating from online');
      result = await AzSingle().getAppUpdate();
      await uSetPrefsValue(kUpdate, result);
      await uSetPrefsValue(kUpdateTime, date);
    }
    print('update result: $result');
    if (!result.contains('<')) return false;
    List<String> updateData = result.split('<');
    String upVers = updateData[0];
    print('version: $version, message-version: $upVers');
    if (version != upVers) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => UpdatePage()));
      return true;
    }
  }catch(e,t){
    print('error: $e, trace: $t');
  }
  return false;
}

Future<Customer> uGetUserCustomer() async {
 Customer c = Customer()
 ..i = await uGetSharedPrefValue(kIdKey)
 ..e = await uGetSharedPrefValue(kMailKey)
 ..p =  await uGetSharedPrefValue(kPhoneKey)
 ..s =  await uGetSharedPrefValue(kStateKey)
 ..l = await uGetSharedPrefValue(kLnameKey)
 ..f = await uGetSharedPrefValue(kFnameKey)
 ..w = await uGetSharedPrefValue(kWalletKey)
 ..a = await uGetSharedPrefValue(kAdressKey)
 ..t = await uGetSharedPrefValue(kShopInfo)
 ..f = await uGetSharedPrefValue(kShopItemsDownloaded)
 ..cid = await uGetSharedPrefValue(kCartItemsId);
 return c;
}

void uShowNoInternetDialog(BuildContext context){
  uShowCustomDialog(context:context, icon: CupertinoIcons.cloud_bolt_rain, iconColor: Colors.grey,text:'No iternet connection. 😕', buttonList: [[]]);
}

void uShowLogSignDialog(BuildContext context){
  uShowCustomDialog(context: context,
      icon: CupertinoIcons.person_add,
      iconColor: Colors.indigo,
      text: 'Sorry: it appears you are not logged in.',
      buttonList: [
        ['Login', kThemeOrange, () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/login');
        }
        ],
        ['Sign-Up', kLightBlue, () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/signup');
        }
        ],

      ]);
}

Future<bool> uCheckInternet() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

Future<void> uSetPrefsValue(String key, var value) async {
  SharedPreferences sp=await SharedPreferences.getInstance();
  //FORMER
//  Set<String> keys=sp.getKeys();
//  Map<String, dynamic> valMap={};
//  for(String s in keys){
//    valMap[s]= sp.get(s);
//  }
//  sp.clear();
//  sp.reload();
//  valMap[key]=value;
//  for(var v in valMap.entries ){
//    await sp.setString(v.key, v.value.toString());
//  }
//  await sp.setString(key, value.toString());
    if(sp.containsKey(key)){
      await sp.remove(key);
    }
    await sp.reload();
    await sp.setString(key, value.toString());
    await sp.commit();
}

bool uIsItemExpired(String psplit) {
  List<String> splitDates=psplit.split(':');
  if(splitDates.length!=3)return false;

  int month=int.parse(splitDates[1]);
  int day=int.tryParse(splitDates[2])??1;
  int year=(int.tryParse(splitDates[0])??0)+2000;

  DateTime dt= DateTime(year,month,day);
  DateTime today=DateTime.now();
  return today.isAfter(dt);
}

void uShowErrorDialog(BuildContext context, String errorText){
  uShowCustomDialog(context: context, icon:Icons.warning, iconColor: Colors.red, text: errorText, buttonList: [[]] );
}

String uGetUniqueIdWPath(String path) {
  List unis=path.split('/');
  return unis[unis.length-1].replaceAll('.jpg','');
}

String uGetConnString(){
  return kAzstoreConnectionString;
}

String uGetSearchKey() {
  return kSearchApiKey;
}

void uShowCustomDialog({ BuildContext context,  IconData icon,
   Color iconColor,  String text,  List buttonList  = const []}){
  List<Widget> butList=[];
  if(buttonList!=null && buttonList.length>0){
    for(var arr in buttonList){
      butList.add(Expanded(
        child: GestureDetector(
          onTap: arr[2],
          child: Container(
            margin: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
                color: arr[1],
                borderRadius: BorderRadius.circular(20)
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(2),
              child: Text(arr[0], style: kNavTextStyle,),
            ),
          ),
        ),
      ));
    }
  }
  Dialog errorDialog= Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    backgroundColor: kDialogLight,
    child: Container(
      height: 350,
      child: Column(
        children: [
          Expanded(child: Icon(icon, color: iconColor, size: 200,)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          ),
          SizedBox(height: 20,),
          Container(
            height: butList!=null?50:2,
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: buttonList!=null?butList:[],
            ),
          )
        ],
      ),
    ),
  );
  showGeneralDialog(context: context,
      barrierLabel: text,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 500),
      transitionBuilder: (_, anim, __, child){
        return SlideTransition(position: Tween(begin: Offset(-1,0), end: Offset(0,0)).animate(anim), child: child,);
      },
      pageBuilder: (BuildContext context, _, __)=>(errorDialog)
  );
}

Future<String> uGetPicUrl(String element) async {
  String url;
  element=element.replaceAll(kPicLink, '');
  element=element.replaceAll(kUrlStart, '');
  //CONDITIONS: PIC REFERENCE WAS REPLACED WITH kUrlStart or kPicLink or PICS'S ID WAS STORED DIRECTLY
  if(element.length>=28){//check id length
    if(element.startsWith('L%2F'))url='$kUrlStart$element';
    else url='$kPicLink$element';
  }else{
    url=await FirebaseStorage.instance.ref().child('L').child(element).getDownloadURL();
  }
  return url;
}


Future<void> uToggleFavoriteStatus({ BuildContext context,  SmallMitem smitem}) async {
  if(Provider.of<FavoriteProvider>(context, listen:false).isItemFavorite(smitem)){
    await Provider.of<FavoriteProvider>(context, listen:false).removeItemFromFavorite(smitem.I);
  }else{
    Provider.of<FavoriteProvider>(context, listen:false).addItemToMap(smitem);
  }
}

 uShowCustomDialogWithImage({ BuildContext context,
    String icon,  Color iconColor =  Colors.black,  String text, List buttonList  = const []}){
  List<Widget> butList=[];
  if(buttonList!=null && buttonList.length>0){
    for(var arr in buttonList){
      butList.add(Expanded(
        child: Container(
          margin: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
              color: arr[1],
              borderRadius: BorderRadius.circular(20)
          ),
          child: GestureDetector(onTap: arr[2],
            child: Padding(
              padding: EdgeInsets.all(2),
              child: Text(arr[0], style: kNavTextStyle,),
            ),),
        ),
      ));
    }
  }
  Dialog errorDialog= Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    backgroundColor: kDialogLight,
    child: Container(
      height: 350,
      child: Column(
        children: [
          SizedBox(height: 20,),
          Expanded(child: Image.asset(icon, color: iconColor, height: 200,)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          ),
          SizedBox(height: 20,),
          Container(
            height: butList!=null?50:2,
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: buttonList!=null?butList:[],
            ),
          )
        ],
      ),
    ),
  );
  showGeneralDialog(context: context,
      barrierLabel: text,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 500),
      transitionBuilder: (_, anim, __, child){
        return SlideTransition(position: Tween(begin: Offset(-1,0), end: Offset(0,0)).animate(anim), child: child,);
      },
      pageBuilder: (BuildContext context, _, __)=>(errorDialog)
  );
}

void uShowCustomOrderDialog({ BuildContext context,  List buttonList ,
   OrderItem orderItem}){
  List<Widget> butList=[];
  if(buttonList!=null && buttonList.length>0){
    for(var arr in buttonList){
      butList.add(Expanded(
        child: Container(
          margin: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
              color: arr[1],
              borderRadius: BorderRadius.circular(20)
          ),
          child: FlatButton(onPressed: arr[2],
            child: Padding(
              padding: EdgeInsets.all(2),
              child: Text(arr[0], style: kNavTextStyle,),
            ),
            splashColor: Colors.white,),
        ),
      ));
    }
  }
  Dialog errorDialog= Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    backgroundColor: kDialogLight,
    child: Container(
      height: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(height: 20,),
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            padding:  EdgeInsets.all(8.0),
            child: Text('Confirm Details.', style: TextStyle(color: kThemeBlue, fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          ),
          SizedBox(height: 20,),
          Padding(
            padding: EdgeInsets.all(2.0),
            child: Text('Ordered item(s).', style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.w100), textAlign: TextAlign.center,),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(orderItem.n, style: TextStyle(color: kThemeBlue, fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          ),
          Padding(
            padding: EdgeInsets.all(2.0),
            child: Text('Amount paid.', style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.w100), textAlign: TextAlign.center,),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("\u20a6 ${orderItem.p}", style: TextStyle(color: kThemeBlue, fontSize: 15, fontWeight: FontWeight.w300), textAlign: TextAlign.center,),
          ),
          Padding(
            padding: EdgeInsets.all(2.0),
            child: Text('Units ordered.', style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.w100), textAlign: TextAlign.center,),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Units: ${orderItem.u}", style: TextStyle(color: kThemeBlue, fontSize: 14, fontWeight: FontWeight.w300), textAlign: TextAlign.center,),
          ),
          Padding(
            padding: EdgeInsets.all(2.0),
            child: Text('Delivery location.', style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.w100), textAlign: TextAlign.center,),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(orderItem.z, style: TextStyle(color: kThemeBlue,fontSize: 13, fontWeight: FontWeight.w300), textAlign: TextAlign.center,),
          ),

          SizedBox(height: 20,),
          Container(
            height: butList!=null?50:2,
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: buttonList!=null?butList:[],
            ),
          )
        ],
      ),
    ),
  );
  showGeneralDialog(context: context,
      barrierLabel: 'randomxxx',
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 500),
      transitionBuilder: (_, anim, __, child){
        return SlideTransition(position: Tween(begin: Offset(-1,0), end: Offset(0,0)).animate(anim), child: child,);
      },
      pageBuilder: (BuildContext context, _, __)=>(errorDialog)
  );
}

void uShowCustomDialogWithFile({ BuildContext context,  String path,
   Color iconColor  = Colors.black,  String text, List buttonList = const []}){
  List<Widget> butList=[];
  if(buttonList!=null && buttonList.length>0){
    for(var arr in buttonList){
      butList.add(Expanded(
        child: Container(
          margin: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
              color: arr[1],
              borderRadius: BorderRadius.circular(20)
          ),
          child: FlatButton(onPressed: arr[2],
            child: Padding(
              padding: EdgeInsets.all(2),
              child: Text(arr[0], style: kNavTextStyle,),
            ),
            splashColor: Colors.white,),
        ),
      ));
    }
  }
  Dialog errorDialog= Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    backgroundColor: kDialogLight,
    child: Container(
      height: 350,
      child: Column(
        children: [
          SizedBox(height: 20,),
          Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(File(path), height: 200,fit: BoxFit.fill,))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          ),
          SizedBox(height: 20,),
          Container(
            height: butList!=null?50:2,
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: buttonList!=null?butList:[],
            ),
          )
        ],
      ),
    ),
  );
  showGeneralDialog(context: context,
      barrierLabel: text,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 500),
      transitionBuilder: (_, anim, __, child){
        return SlideTransition(position: Tween(begin: Offset(-1,0), end: Offset(0,0)).animate(anim), child: child,);
      },
      pageBuilder: (BuildContext context, _, __)=>(errorDialog)
  );
}

void uShowCreditDialog({double amount =0,  BuildContext context}) {
  Dialog creditDialog= Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    backgroundColor: Color(0xFFEEEEFF),
    child: Container(
      height: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20,),
          Expanded(child: Container(
              alignment: Alignment.center,
              child: Text('You have been credited with', style: TextStyle(color:kThemeBlue, fontWeight: FontWeight.bold
             ),textAlign: TextAlign.center, ))),
          Expanded(
            child: Text('\u20a6 $amount', style: TextStyle(color: kThemeOrange , fontWeight: FontWeight.bold, fontSize: 50), textAlign: TextAlign.center,),
          ),
          Expanded(
            child: Text('👍', style: TextStyle(color: kThemeOrange , fontWeight: FontWeight.bold, fontSize: 30), textAlign: TextAlign.center,),
          ),
        ],
      ),
    ),
  );
  showGeneralDialog(context: context,
      barrierLabel: amount.toString(),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 500),
      transitionBuilder: (_, anim, __, child){
        return SlideTransition(position: Tween(begin: Offset(0,1), end: Offset(0,0)).animate(anim), child: child,);
      },
      pageBuilder: (BuildContext context, _, __)=>(creditDialog));
}

Future<void> uShowLoginDialog({ BuildContext context}) async {
  String fname=await uGetSharedPrefValue(kFnameKey);
  String sname=await uGetSharedPrefValue(kLnameKey);
  Dialog creditDialog= Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    backgroundColor: kDialogLight,
    child: Container(
      height: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical:20.0),
              child:Icon(Icons.auto_awesome, color: kThemeOrange, size: 200,)          ),
          SizedBox(height: 30,),
          Expanded(child: Text('Welcome back ${fname} $sname ! We did miss you 😊.', style: TextStyle(color:kThemeBlue, fontSize: 20, fontWeight: FontWeight.bold),textAlign: TextAlign.center, )),
          SizedBox(height: 12,),
        ],
      ),
    ),
  );
  showGeneralDialog(context: context,
      barrierLabel: 'cjns',
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 500),
      transitionBuilder: (_, anim, __, child){
        return SlideTransition(position: Tween(begin: Offset(0,1), end: Offset(0,0)).animate(anim), child: child,);
      },
      pageBuilder: (BuildContext context, _, __)=>(creditDialog));
}

Future<String> uGetGoogleDate() async {
  var url='https://google.com/';
  var response=await http.get(url);
  String dateBase = response.headers['date'];
  return dateBase;
}

bool uIsStringValid(String value){
  return !(value ==null||value.toLowerCase().trim().isEmpty||value.toLowerCase().trim()=='null');
}

String uGetSplitPaymentAccID(){
  return kFwSplitPaymentAccID;
}

String uGetAzurePicUrl(String pic){
  List<String> picList = pic.split(',');
  String res='';
  for(String p in picList){
    if(p.trim().length>1){
      res=p;
      break;
    }
  }
  print(' Picture:  $kAzureImageStart${res}.jpg');
  return '$kAzureImageStart${res}.jpg';
}

Future<bool> uDebitUser(double price,{ BuildContext context,bool prompt4Funds = false}) async{
  String walletAmount=(await uGetSharedPrefValue(kWalletKey)).toString();
  double wallet= double.tryParse(walletAmount)??0;
  print('wallet $walletAmount');
  if(wallet<price){
    print('gotten to if');
    if(prompt4Funds)uShowFundWalletDialog(context,price);
    return false;
  }
  print('gotten b4 minus');
  wallet-=price;
  String id=await uGetSharedPrefValue(kIdKey);
  await kDbref.child('cad').child(id).child('w').set(wallet.toString());
  await uSetPrefsValue(kWalletKey, wallet.toString());
  await Provider.of<PromoModel>(context, listen: false).setWalletValue();
  return true;
}

Future<bool> canUserPay(double price)async{
  String walletAmount=(await uGetSharedPrefValue(kWalletKey)).toString();
  double wallet= double.tryParse(walletAmount)??0;
  if(wallet<price){
    print('gotten to if');
    return false;
  }
  return true;
}

Future<String> uGetPicDownloadUrl(String element) async {
  String url=null;
  element=element.replaceAll(kPicLink, '');
  element=element.replaceAll(kUrlStart, '');
  //CONDITIONS: PIC REFERENCE WAS REPLACED WITH kUrlStart or kPicLink or PICS'S ID WAS STORED DIRECTLY
  if(element.length>=28){//check id length
    if(element.startsWith('L%2F'))url='$kUrlStart$element';
    else url='$kPicLink$element';
  }else{
    url=await FirebaseStorage.instance.ref().child('L').child(element).getDownloadURL();
  }
  return url;
}

String uGetUniqueId() {
  List<String> idSrc=FirebaseDatabase.instance.reference().push().key.toString().split('/');
  String id=idSrc[idSrc.length-1];
  return(id.replaceAll('.', '').replaceAll('#', '').replaceAll('[', '').replaceAll(']', '').replaceAll('*', '').replaceAll('+', '').replaceAll('-', '').replaceAll('?', '').replaceAll('{', '').replaceAll('}', '').replaceAll('(', '').replaceAll(')', '').replaceAll('!', '').replaceAll('&', '').replaceAll('^', '').replaceAll('"', '').replaceAll('~', '').replaceAll(':', '').replaceAll('\\', ''));
}

Future<String> uGetUniquePicId() async {
  List<String> idSrc=FirebaseDatabase.instance.reference().push().key.toString().split('/');
  String id=idSrc[idSrc.length-1];
  String userId= await uGetSharedPrefValue(kIdKey);
  return(userId+'_'+id.replaceAll('.', '').replaceAll('#', '').replaceAll('[', '').replaceAll(']', '').replaceAll('*', '').replaceAll('+', '').replaceAll('-', ''));
}

void uShowFundWalletDialog(BuildContext context,double price){
  uShowCustomDialog(context: context, text: 'Insufficient funds! Purchase costs \u20a6$price', icon: Icons.account_balance_wallet, iconColor: Colors.brown, buttonList: [['Fund wallet',kLightBlue,(){
    Navigator.pop(context);
    Navigator.pushNamed(context, '/wallet');
  }]]);
}

Future<void> uShowSignupDialog({ BuildContext context}) async {
  String fname=await uGetSharedPrefValue(kFnameKey);
  String sname=await uGetSharedPrefValue(kLnameKey);
  Dialog creditDialog= Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    backgroundColor: kDialogLight,
    child: Container(
      height: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical:20.0),
              child:Icon(Icons.auto_awesome, color: kThemeOrange, size: 200,)          ),
          SizedBox(height: 30,),
          Expanded(child: Text('Welcome ${fname} $sname ! 😊.', style: TextStyle(color:kThemeBlue, fontSize: 20, fontWeight: FontWeight.bold),textAlign: TextAlign.center, )),
          SizedBox(height: 12,),
        ],
      ),
    ),
  );
  showGeneralDialog(context: context,
      barrierLabel: sname,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 500),
      transitionBuilder: (_, anim, __, child){
        return SlideTransition(position: Tween(begin: Offset(0,1), end: Offset(0,0)).animate(anim), child: child,);
      },
      pageBuilder: (BuildContext context, _, __)=>(creditDialog));
}

void uShowErrorNotification(String text){
  showSimpleNotification(
      Text(text, style: kNavTextStyle,),
      leading:Icon(Icons.warning, color:Colors.white),
      background: Colors.red);
}

void uShowOkNotification(String text){
  showSimpleNotification(
      Text(text, style: kNavTextStyle,),
      // leading:Icon(Icons.ok, color:Colors.white),
      background: Colors.green);
}

String uExtractDate4rmGoogle(String dateBase) {
  List<String> months=['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul','aug', 'sep', 'oct', 'nov', 'dec'];
  List<String> dBase=dateBase.split(' ');
  int month=(months.indexOf(dBase[2].toLowerCase())+1);
  int day=int.tryParse(dBase[1])??0;
  int year=int.tryParse(dBase[3])??0;

  DateTime dt= DateTime(year,month,day);
  dt=dt.add(Duration(days: 30));
  DateFormat df=DateFormat('yy:MM:dd');
  return df.format(dt).toString();
}

void uShowCouponDialog({ BuildContext context,  IconData icon,  Color iconColor, String text,
  Function() onPressedFun}){
  List<Widget> butList=[
    Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
        decoration: BoxDecoration(
            color: kThemeBlue,
            borderRadius: BorderRadius.circular(10)
        ),
        child: FlatButton(onPressed:onPressedFun,
          child: Text('Load', style: kNavTextStyle,),
          splashColor: Colors.white,),
      ),
    )
  ];
  Dialog errorDialog= Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    backgroundColor: Colors.white,//Color(0xFFDDDDFF),
    child: Container(
      height: 350,
      child: Column(
        children: [
          Expanded(child: Icon(icon, color: iconColor, size: 200,)),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              textAlign: TextAlign.center,
              onChanged: (string){WalletModel.couponCode=string;},
              decoration: InputDecoration(
                  filled: false,
                  hintText: 'Enter coupon code',
                  hintStyle: TextStyle(
                      color: Colors.grey
                  ),
                  fillColor: Colors.transparent,
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: kThemeOrange, width: 5, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(16)
                )
              ),
              textInputAction: TextInputAction.next,
              style: TextStyle(color: kThemeBlue),
              keyboardType: TextInputType.text,
            ),
          ),
          SizedBox(height: 30,),
          Container(
            height: butList!=null?60:2,
            child: Row(
              children: butList,
            ),
          )
        ],
      ),
    ),
  );
  showGeneralDialog(context: context,
      barrierLabel: text,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 500),
      transitionBuilder: (_, anim, __, child){
        return SlideTransition(position: Tween(begin: Offset(0,-1), end: Offset(0,0)).animate(anim), child: child,);
      },
      pageBuilder: (BuildContext context, _, __)=>(errorDialog)
  );
}
