
import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/screens/promote_options_screen.dart';
import '../providers/promo_model.dart';
import 'package:ecommerce/custom_widgets/seller_list_item.dart';
import 'package:ecommerce/custom_widgets/promo_list_item.dart';
import 'package:ecommerce/databases/seller_items_db.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/screen_models/home_screen_model.dart';
import 'package:ecommerce/screens/edit_item_screen.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class SellerPortalMainPageModel{

  int PROMO1=778;
  int PROMOM=7688;
  int selectedPromo=0;

  List<Widget> getDummyPromoItems(int i, BuildContext context){
    List<Widget> res=[];
    for(int k=0; k<i; k++){
      res.add(PromoListItem(title: 'Test title $k',));
    }
    return res;
  }

  List<Widget> getDummyItems(int i, BuildContext context){
    List<Widget> promoList=getDummyPromoItems(5,context);
    List<Widget> res=[
      Container(
        margin: EdgeInsets.all(4),
        height: promoList.length>0?130:0,
        child: ListView(
          children: promoList,
          scrollDirection: Axis.horizontal,
        ),
      ),
      Container(
        width: double.maxFinite,
        margin: EdgeInsets.all( 10),
        decoration: BoxDecoration(
            color: kThemeOrange,
            borderRadius: BorderRadius.circular(10)
        ),
        child: FlatButton(onPressed: (){
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context){
                return EditItemScrren(context);
              }));
        },
          child: Text('Add new item', style: kNavTextStyle,),

          splashColor: Colors.white,),
      ),
    ];

    for(int k=0; k<i; k++){
      res.add(ListItem(title: 'Test title $k',));
    }
    return res;
  }

  Future<void> showPromoteItemDialog(BuildContext context, String id, String itemName) async {
    String promo1ID=(await uGetSharedPrefValue(kPromo1Key))??30;
    String promo2ID=(await uGetSharedPrefValue(kPromoMultiKey))??100;
    Dialog promoteDialog= Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: kDialogLight,
      child:PromoteOptionsScreen(itemId: id, itemName:itemName, backContext: context,)
    );
    showGeneralDialog(context: context,
        barrierLabel: 'nune',
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 500),
        transitionBuilder: (_, anim, __, child){
          return SlideTransition(position: Tween(begin: Offset(0,1), end: Offset(0,0)).animate(anim), child: child,);
        },
        pageBuilder: (BuildContext context, _, __)=>(promoteDialog));
  }

  Future<void> getSellerItems( BuildContext context) async {
    List<Widget> promoItems=[];
    try {
      String itemStat = await uGetSharedPrefValue(kShopItemsDownloaded);
      String id = await uGetSharedPrefValue(kIdKey);
      print('itemStat: $itemStat');
      print('sellerId: $id');
      if (itemStat.contains('f')) {
        if (!(await uCheckInternet())) {
          uShowNoInternetDialog(context);
          return [];
        }
        await downloadSellerItems();
      }
      await Provider.of<PromoModel>(context).setWidgetLists(context);
    }catch(e){
      print('download items exception');
      return null;
    }
  }

  Future<void> downloadSellerisFromAzure() async {
    String sellerId= await uGetSharedPrefValue(kIdKey);
    Response response= await get('https://gmart-search.search.windows.net/indexes/gmart-dex/docs?api-version=2020-06-30&searchFields=i&search=$sellerId',
        headers:
        {'Content-Type':'application/json',
          'api-key':kSearchApiKey});
    if(response==null || response.body==null)return;
    var reses= jsonDecode(response.body);
    List<MartItem> martList=[];

    for (var v in reses['value']) {
      MartItem martItem= MartItem.fromAzureList(value: v);
      martList.add(martItem);
    }

    SellerLargeItemsDb sDb = SellerLargeItemsDb();

    for(MartItem martItem in martList){
      List<String> picList=martItem.k.split(',');
      for(String element in picList){
        if(!element.isEmpty){
          try{
            martItem.q+=','+(await downloadPic(element));
          }catch(e){
            print('download pic error: $e');
          }
        }
      }
      print('inserting: ${martItem}');
      await sDb.insertItem(martItem);
    }
    await uSetPrefsValue(kShopItemsDownloaded, 'true');

  }

   Future<void> downloadSellerItems() async {
     String sellerId= await uGetSharedPrefValue(kIdKey);
     DataSnapshot smallItemsRef=await kDbref.child('S').orderByChild('s').equalTo(sellerId).once();
     print('small-item-ref: ${smallItemsRef.toString()}');
     List<MartItem> martList=[];
     for (var v in smallItemsRef.value.entries) {
       MartItem martItem= MartItem();
       martItem.l=v.key.toString();
       martItem.k=v.value['p'];
       martItem.t=v.value['n'];
       martItem.m=v.value['m'];
       martItem.i=v.value['s'];
       martItem.s=v.value['t'];
       martItem.h=v.value['e'];
       martList.add(martItem);
     }
     SellerLargeItemsDb sDb = SellerLargeItemsDb();
     for(MartItem martItem in martList){
       Map tempItem=(await kDbref.child('R').child(martItem.l).once()).value;
       if(tempItem!=null){
         martItem.k+=','+tempItem['k'].toString().replaceAll(martItem.k, '');
         martItem.b=tempItem['b'];
         martItem.d=tempItem['d'];
         martItem.n=tempItem['n'];
         martItem.m=tempItem['m'];
       }
       martItem.q='';
       List<String> picList=martItem.k.split(',');
       for(String element in picList){
         if(!element.isEmpty){
           try{
              martItem.q+=','+(await downloadPic(element));
           }catch(e){
             print('download pic error: $e');
           }
         }
       }
       print('inserting: ${martItem}');
       await sDb.insertItem(martItem);
     }
     await uSetPrefsValue(kShopItemsDownloaded, 'true');
   }

    Future<String> downloadAzurePic(String picId) async {
      String url;
      String fileId=getUniqueId();

      url=picId.contains(kAzureImageStart)?picId: (kAzureImageStart+picId);

      //CONDITIONS: PIC REFERENCE WAS REPLACED WITH kUrlStart or kPicLink or PICS'S ID WAS STORED DIRECTLY
      final directory= await getApplicationDocumentsDirectory();
      String path= directory.path+'/GmartPics';
      if(!Directory(path).existsSync()) await Directory(path).create();
      path+='/$fileId.jpg';
      File newFile=File(path);
      await newFile.create();

      Response response=await get(url);
      await newFile.writeAsBytes(response.bodyBytes);
      return path;
    }

    Future<String> downloadPic(String element) async {
      String url;
      String fileId=getUniqueId();
      element=element.replaceAll(kPicLink, '');
      element=element.replaceAll(kUrlStart, '');
      if(element.length>=28){//check id length
        if(element.startsWith('L%2F'))url='$kUrlStart$element';
        else url='$kPicLink$element';
      }else{
        url=await FirebaseStorage.instance.ref().child('L').child(element).getDownloadURL();
        fileId=element;
      }
      final directory= await getApplicationDocumentsDirectory();
      String path= directory.path+'/GmartPics';
      if(!Directory(path).existsSync()) await Directory(path).create();
      path+='/$fileId.jpg';
      File newFile=File(path);
      await newFile.create();

      Response response=await get(url);
      await newFile.writeAsBytes(response.bodyBytes);
      return path;
    }

    String getUniqueId() {
      List<String> idSrc=FirebaseDatabase.instance.reference().push().key.toString().split('/');
      String id=idSrc[idSrc.length-1];
      return(id.replaceAll('.', '').replaceAll('#', '').replaceAll('[', '').replaceAll(']', '').replaceAll('*', ''));
    }

    bool isPromoActive(String psplit) {
      List<String> splitDates=psplit.split(':');
      if(splitDates.length!=3)return false;

      int month=int.parse(splitDates[1]);
      int day=int.tryParse(splitDates[2])??1;
      int year=(int.tryParse(splitDates[0])??0)+2000;

      DateTime dt= DateTime(year,month,day);
      DateTime today=DateTime.now();
      return today.isBefore(dt)||today.isAtSameMomentAs(dt);
    }

}