
import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/custom_widgets/my_button.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/providers/promo_model.dart';
import 'package:ecommerce/screen_models/home_screen_model.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class PromoteOptionsScreen extends StatefulWidget {
  String itemName;
  String itemId;
  MartItem mitem;
  BuildContext backContext;

  PromoteOptionsScreen({this.mitem, this.itemId, this.itemName, this.backContext});

  @override
  _PromoteOptionsScreenState createState() => _PromoteOptionsScreenState();
}

class _PromoteOptionsScreenState extends State<PromoteOptionsScreen> {
  bool progress=false;
  int PROMO1=8683;
  int PROMOM=6809;
  String category;
  int selectedPromo=0;
  int selectedCategory=null;
  var singlePromoPrice;
  var multiPromoPrice;

  @override
  void initState() {
  }

  @override
  void didChangeDependencies() {
    setupPrices();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: progress,
        child: Material(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Container(
                  height:  MediaQuery.of(context).size.height*0.23,
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Hero(
                        tag: widget.mitem.l,
                          child: Image.file(File(widget.mitem.q.split(',').firstWhere((element) => element.isNotEmpty)??''), width: double.maxFinite, height:double.maxFinite,)),
                      Container(
                        decoration:BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors:[
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(0.7)
                            ],
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            Container(
                                padding: EdgeInsets.all(10),
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                    onPressed: (){
                                      Navigator.pop(context);
                                    },
                                    child: Icon(Icons.clear, color: Colors.white, size: 25,))),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(widget.mitem.t, textAlign: TextAlign.start, style: kNavTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),),
                            )
                          ]
                        ),
                      )

                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(12.0),
                    child:  RichText(
                        textAlign: TextAlign.center,
                        text:TextSpan(
                            style:TextStyle(color: kThemeBlue, fontWeight: FontWeight.w900),
                            children:[
                              TextSpan(text:'Select promo search category for ',),
                              TextSpan(text:'${widget.itemName}',style:TextStyle(color: kThemeOrange, fontWeight: FontWeight.bold)),
                            ]
                        )
//              Text('Select promo search category for $itemName', style: TextStyle(color:kThemeBlue, fontSize: 20, fontWeight: FontWeight.bold),textAlign: TextAlign.center, ),
                    )),
                if(selectedCategory!=null)Padding(
                    padding: const EdgeInsets.all(12.0),
                    child:  RichText(
                        textAlign: TextAlign.center,
                        text:TextSpan(
                            style:TextStyle(color: kThemeBlue, fontWeight: FontWeight.w900),
                            children:[
                              TextSpan(text:'Category: ',),
                              TextSpan(text:'${kCarItems[selectedCategory]}',style:TextStyle(color: kLightBlue, fontWeight: FontWeight.bold)),
                            ]
                        )
                    )),
                SizedBox(height: 12,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CarouselSlider(
                      items: getPromoCarSliderItems(context, widget.itemId),
                      options: CarouselOptions(height: 150,
                          enlargeCenterPage: true,
                          viewportFraction: 0.4,
                          aspectRatio: 39/9
                      )),
                ) ,
                SizedBox(height: 5,),
                Padding(
                    padding: const EdgeInsets.all(12.0),
                    child:  RichText(
                        textAlign: TextAlign.center,
                        text:TextSpan(
                            style:TextStyle(color: kThemeBlue, fontWeight: FontWeight.w900),
                            children:[
                              TextSpan(text:'Select promo subscription.',),
                              // TextSpan(text:'${widget.itemName}',style:TextStyle(color: kThemeOrange, fontWeight: FontWeight.bold)),
                            ]
                        )
//              Text('Select promo search category for $itemName', style: TextStyle(color:kThemeBlue, fontSize: 20, fontWeight: FontWeight.bold),textAlign: TextAlign.center, ),
                    )),

                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        elevation: selectedPromo==PROMO1?18:0,
                          borderRadius: BorderRadius.circular(15),
                          color: selectedPromo==PROMO1?kLightBlue:kThemeBlue,
                          child: GestureDetector(
                            onTap: (){
                              selectedPromo=PROMO1;
                              setState(() {

                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom:selectedPromo==PROMO1?16:0, ),
                              padding:  EdgeInsets.all( 12.0),
                              child: Column(
                                children: [
                                  Text('Promote for 1 day', textAlign: TextAlign.center,
                                    style: TextStyle( color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),),
                                  SizedBox(height: 20,),
                                  Text('\u20a6 $singlePromoPrice', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                                  SizedBox(height: 20,),
                                  Text('Begins 00:00 tomorrow', textAlign: TextAlign.center
                                      , style: TextStyle( color: Colors.white, fontSize: 10, )),
                                ],
                              ),
                            ),
                          )
                      ),
                      SizedBox(width: 20,),
                      Material(
                        elevation: selectedPromo==PROMOM?18:0,
                          borderRadius: BorderRadius.circular(15),
                          color: selectedPromo==PROMOM?kLightBlue:kThemeBlue,
                          child: GestureDetector(
                          onTap: (){
                            selectedPromo=PROMOM;
                            setState(() {

                            });
                          },
                          child: Container(
                            padding:  EdgeInsets.all(12.0),
                            margin: EdgeInsets.only(bottom:selectedPromo==PROMOM?16:0, ),
                            child: Column(
                              children: [
                                Text('Promote for 4 days', textAlign: TextAlign.center,
                                  style: TextStyle( color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),),
                                SizedBox(height: 20,),
                                Text('\u20a6 $multiPromoPrice', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                                SizedBox(height: 20,),
                                Text('Begins 00:00 tomorrow', textAlign: TextAlign.center
                                    , style: TextStyle( color: Colors.white, fontSize: 10, )),
                              ],
                            ),
                          ),
                        )
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15,),
                MyButton(text: 'proceed', onPressed: startPromoSequence,),
                SizedBox(height: 15,),
              ],
            ),
          ),    ),
      ),
    );
  }

  List<Widget> getPromoCarSliderItems(BuildContext context, String itemId) {
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
    int numDex=0;
    for(CarouselItem item in carItems){
      result.add(
          Container(
            width: 180,
            height: 120,
            padding: EdgeInsets.all(5),
            child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(item.image,
                      alignment: Alignment.center,
                      height: double.infinity,
                      fit: BoxFit.fill,
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
                  FlatButton(
                    onPressed: (){
//                      promoteItem(kCarItems.indexOf(item.label), itemId, context);
                      setState(() {
                        selectedCategory=kCarItems.indexOf(item.label);
                      });
                    },
                    splashColor: Colors.white,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(item.label,
                        textAlign: TextAlign.center,
                        style: kNavTextStyle,),
                    ),
                  ),

                ]
            ),
          ));
      numDex++;
    }
    return result;
  }

  void showProgress(bool b){
    setState(() {
      progress=b;
    });
  }

  startPromoSequence() async {
    if(! (await uCheckInternet() )){
      uShowNoInternetDialog(context);
      return;
    }
    if(selectedCategory==null){
      uShowErrorDialog(context, 'No category selected yet !');
      return;
    }
    if(selectedPromo==0){
      uShowErrorDialog(context, 'You need to select a pricing plan!');
      return;
    }
    promoteItem(selectedCategory, widget.itemId, context,duration: selectedPromo==PROMOM?4:1);
  }

  void promoteItem(int indexOf, String itemId, BuildContext context,{int duration=1}) async{
    showProgress(true);
    try {
      String googleDate= await uGetGoogleDate();
      int dayDex = extractDay(googleDate); //GET TODAY'S DAY AND UPLOAD INDEX.
      String expirationDate=extractExpiration(googleDate,duration);
      print('gotten date dex :$dayDex');
      double uploadPrice = await getPromoUploadPrice(
          duration); // GET-UPLOAD PRICE
      print('gotten  upload price :$uploadPrice');

      bool debitUserSuccess = await uDebitUser(uploadPrice, context: context, prompt4Funds: true); //DEBIT USER.
      print('gotten  to debit user :$debitUserSuccess');
      if (debitUserSuccess) { //UPLOAD ITEM ID WITH CATEGORY.
        for (int i = dayDex + 1; i < (dayDex + 1 + duration); i++) {
          print('gotten  to debit inner loop dex :$i');
//          await kDbref.child('d$i').child(itemId).set( '$indexOf');
         await AzSingle().setCloudPromoStatus(indexOf, itemId, expirationDate,duration );
        }
        await savePromotedItem(itemId: itemId, itemExpiration: expirationDate);
        showProgress(false);
        uShowOkNotification('${widget.itemName} promoted');
        Timer(Duration(seconds: 2),(){
          Navigator.pop(context);
        });
        // uShowCustomDialog(context: widget.backContext,
        //     icon: Icons.done,
        //     iconColor: Colors.green,
        //     text: '${widget.itemName} promoted');
      }else{// if debit fails
        showProgress(false);
      }
    }catch(e){
      showProgress(false);
      uShowErrorDialog(context, 'Something went wrong.');
      print('error: $e');
    }
  }

  Future<double> getPromoUploadPrice(int duration) async {
    DataSnapshot priceShot;
    if(duration==1)
      priceShot=await FirebaseDatabase.instance.reference().child('PR').once();
    else
      priceShot=await FirebaseDatabase.instance.reference().child('PM').once();
    print('gotten  priceshot: ${priceShot.value}');
    double uploadPrice=double.tryParse(priceShot.value.toString())??(duration==1?30.toString():100.toString());
    if(duration==1){
      await uSetPrefsValue(kPromo1Key, uploadPrice.toString());
    }else{
      await uSetPrefsValue(kPromoMultiKey, uploadPrice.toString());
    }
    return uploadPrice;
  }

  int extractDay(String dateBase) {
    List<String> days=['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    List<String> dBase=dateBase.split(' ');
    String day=dBase[0].toLowerCase();
    for(int i=0;i<days.length;i++){
      if(day.contains(days[i])){
        return i;
      }
    }
    return 0;
  }

  Future<void> setupPrices() async {
    singlePromoPrice= (await uGetSharedPrefValue(kPromo1Key)).toString();
    if(singlePromoPrice=='null')singlePromoPrice='30';
    multiPromoPrice= (await uGetSharedPrefValue(kPromoMultiKey))??'100';
    if(multiPromoPrice=='null')multiPromoPrice='100';
    setState(() { });
  }

  String extractExpiration(String dateBase, int duration) {
    List<String> months=['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul','aug', 'sep', 'oct', 'nov', 'dec'];
    List<String> dBase=dateBase.split(' ');
    int month=(months.indexOf(dBase[2].toLowerCase())+1);
    int day=int.tryParse(dBase[1]);
    int year=int.tryParse(dBase[3]);
    DateTime dt= DateTime(year,month,day);
    dt=dt.add(Duration(days: duration));
    DateFormat df=DateFormat('yy:MM:dd');
    return df.format(dt).toString();
  }

  savePromotedItem({String itemId, String itemExpiration}) async {
    String formerPromos;
    formerPromos=(await uGetSharedPrefValue(kPromotedItems1)).toString()??'';
    formerPromos+='<$itemId,$itemExpiration';
    await uSetPrefsValue(kPromotedItems1, formerPromos);
    await Provider.of<PromoModel>(context, listen: false).setWidgetLists(widget.backContext);
  }
}
