import 'package:ecommerce/constants.dart';
import 'package:ecommerce/custom_widgets/seller_signup_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utility_functions.dart';

class HomeScreenModel{

  List<Widget> getCarSliderItems(Function(String) onCarItemPressed) {
    List carItems= [
    CarouselItem(label:"Bag", image:'images/bagpic.jpg'),
    CarouselItem(label:"Belt", image:'images/beltpic.jpg'),
    CarouselItem(label:"Blouse", image:'images/blousepic.jpg'),
    CarouselItem(label:"Cloth",image:'images/clothpic.jpg'),
    CarouselItem(label:"Cosmetics", image: 'images/cosmeticspic.jpg'),
    CarouselItem(label: "Crypto currency", image:'images/crptopic.jpg'),
    CarouselItem(label:"Dress", image:'images/dresspic.jpg'),
    CarouselItem(label: "Food", image:'images/foodpic.png'),
    CarouselItem(label:"Glasses", image:'images/glassespic.jpg'),
    CarouselItem(label: "Hat", image:'images/hats.jpg'),
    CarouselItem(label:"Jacket", image:'images/jacketpic.jpg'),
    CarouselItem(label:"Jewelry", image:'images/jewelpic.jpg'),
    CarouselItem(label:"Laptop", image:'images/codepic.jpg'),
    CarouselItem(label:"Pant", image:'images/pantspic.jpg'),
    CarouselItem(label:"Purse", image:'images/pursepic.jpg'),
    CarouselItem(label:"Phone", image:'images/phonepic.jpg'),
    CarouselItem(label:"Shirt", image:'images/shirtpic.jpg'),
    CarouselItem(label:"Shoe",image:'images/shoepic.jpg'),
    CarouselItem(label:"Suit", image:'images/suitpic.jpg'),
    CarouselItem(label:"Tie", image:'images/tiepic.jpg'),
    CarouselItem(label:"Trouser",image:'images/pantspic.jpg'),
    CarouselItem(label:"Utensil", image:'images/utensilpic.jpg'),
    CarouselItem(label:"Watch",image: 'images/watchpic.jpg')];

    List<Widget> result=[];
    for(var item in carItems){
      result.add(
          GestureDetector(
            onTap: (){
              onCarItemPressed(item.label);
            },
            child: Container(
              width: 180,
              height: 180,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(item.image,
                      alignment: Alignment.center,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    width: double.infinity,),
                  ),

                  Container(
                    alignment: Alignment.center,
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Color(0xAA222222),
                        borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(item.label,
                      textAlign: TextAlign.center,
                    style: kNavTextStyle,),
                  ),

                ]
        ),
            ),
          ));
    }
    return result;
  }

  Future<void> openProfile(BuildContext context) async {
    SharedPreferences sp= await SharedPreferences.getInstance();
    String email=sp.getString(kMailKey);
    if(email==null || email.isEmpty){
      uShowLogSignDialog(context);
    }else
    Navigator.pushNamed(context, '/profile');
  }

  Future<void> openWallet(BuildContext context) async {
    SharedPreferences sp= await SharedPreferences.getInstance();
    String email=sp.getString(kMailKey);
    if(email==null || email.isEmpty){
      uShowLogSignDialog(context);
    }else
    Navigator.pushNamed(context, '/wallet');
  }

  Future<void> showSetupSellerDialog(BuildContext context) async {

    Dialog errorDialog= Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      backgroundColor: Colors.white,//Color(0xFFDDDDFF),
      child: SellerSignUp(),
    );
    showGeneralDialog(context: context,
        barrierLabel: 'btxt',
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 500),
        transitionBuilder: (_, anim, __, child){
          return SlideTransition(position: Tween(begin: Offset(0,-1), end: Offset(0,0)).animate(anim), child: child,);
        },
        pageBuilder: (BuildContext context, _, __)=>(errorDialog)
    );
  }

  Future<void> openSellerPortal(BuildContext context) async {
    SharedPreferences sp= await SharedPreferences.getInstance();
    if(!sp.containsKey(kMailKey)) {
      print('prob1');
      uShowLogSignDialog(context);
      return;
    }
    if(await sp.getString(kMailKey).length==0 || await sp.getString(kMailKey).toString()=='null'){
      print('prob2 ${sp.getString(kMailKey)}');
      uShowLogSignDialog(context);
      return;
    }

    if(sp.containsKey(kShopInfo)&&sp.getString(kShopInfo).length>0 && !sp.getString(kShopInfo).toString().startsWith('null') &&  sp.getString(kShopInfo).toString()!='c'){
      String itemStat= await uGetSharedPrefValue(kShopItemsDownloaded);
      if((itemStat.contains('f')||itemStat.toString().trim().startsWith('null')) && !(await uCheckInternet())){
        uShowNoInternetDialog(context);
        return;
      }
      Navigator.pushNamed(context, '/sellerPortal');
      return;
    }
    String shopIt=await sp.getString(kShopInfo);
    String shopId=await sp.getString(kIdKey);
    print('shop info: $shopIt, shop Id:$shopId');
    showSetupSellerDialog(context);

//    Navigator.pushNamed(context, '/sellerPortal');
  }

}

class CarouselItem{
  CarouselItem({this.image,this.label});
  String image = '';
  String label = '';
}