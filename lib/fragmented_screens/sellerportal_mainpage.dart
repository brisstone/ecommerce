import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/databases/seller_items_db.dart';
import 'package:ecommerce/fragment_models/seller_portal_mainpage_model.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/providers/promo_model.dart';
import 'package:ecommerce/providers/seller_orders_provider.dart';
import 'package:ecommerce/screens/edit_item_screen.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:http/http.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class SellerPortalMainPage extends StatefulWidget {
  @override
  _SellerPortalMainPageState createState() => _SellerPortalMainPageState();
}

class _SellerPortalMainPageState extends State<SellerPortalMainPage> {
  String walletBallance='0.0';
  String singleUploadPrice='30';
  String multiPromoUploadPrice='100';
  String singlePromoUploadPrice='30';
  String singleVariantUploadPrice='35';
  double orderAmount=0.0;
  bool progress=false;
  bool itemsSet=false;
  SellerPortalMainPageModel _smPageModel;

  List<Widget> widList=[];
  List<Widget> promoList=[];
  List<Widget> sellerItemsWIdgets = [];

  TextStyle promoTitleStyle=TextStyle( color: Colors.white, fontSize: 8, fontWeight: FontWeight.w500);
  TextStyle promoPriceStyle=  TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold);
  TextStyle promoDetailsStyle=TextStyle( color: Colors.white, fontSize: 8);


  @override
  void initState() {
//    promoList=_smPageModel.getDummyPromoItems(5, context);
    super.initState();
    _smPageModel=SellerPortalMainPageModel();
  }

  @override
  void didChangeDependencies() {
//    itemsSet=true;
    if(!itemsSet) setSellerItems();// if(itemsSet)setSellerItems();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state==AppLifecycleState.resumed){
      setSellerItems();// if(itemsSet)setSellerItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: progress,
      color: kThemeBlue,
      child: Container(
        color: kThemeBlue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:
          [
           Container(
              alignment: Alignment.bottomRight,
              margin: EdgeInsets.all(6),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: kLightBlue, borderRadius: BorderRadius.circular(10)),
                child: Text('Acc. balance: \u20a6${Provider.of<PromoModel>(context).walletValue}',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              ),
            ),
           Container(
             padding: const EdgeInsets.all(8.0),
             color: kThemeBlue,
              alignment: Alignment.center,
             child: Row(
                   children: [
                 Expanded(
                   child: Column(
                     children: [
                        Text('Single item upload', textAlign: TextAlign.center,
                          style: promoTitleStyle),
                       SizedBox(height: 20,),
                       Text('\u20a6 $singleUploadPrice', style:promoPriceStyle),
                       SizedBox(height: 20,),
                       Text('Upload a single item to your store',textAlign: TextAlign.center,
                         style: promoDetailsStyle),
                     ],
                   ),
                 ),
                 Container(
                   width: 1,
                   height:100,
                   margin: EdgeInsets.all(10),
                   color: kLightBlue,
                 ),
                 Expanded(
                   child: Column(
                     children: [
                        Text('Variant item upload', textAlign: TextAlign.center,
                          style: promoTitleStyle,),
                       SizedBox(height: 20,),
                       Text('\u20a6 $singleVariantUploadPrice', style:promoPriceStyle,),
                       SizedBox(height: 20,),
                       Text('Upload an item with color, size or other variations', textAlign: TextAlign.center
                           , style:promoDetailsStyle),
                     ],
                   ),
                 ),
                 Container(
                   width: 1,
                    height: 100,
                   margin: EdgeInsets.all(10),
                   color: kLightBlue,
                 ),
                 Expanded(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                        Text('Promote item', maxLines: 2, textAlign: TextAlign.center, style: promoTitleStyle),
                       SizedBox(height: 20,),
                       Text('\u20a6 $singlePromoUploadPrice', style: promoPriceStyle,),
                       SizedBox(height: 20,),
                       Text('Put an item on Gmart home screen for 24 hours', textAlign: TextAlign.center,
                         style:promoDetailsStyle,),
                     ],
                   ),
                 ),
                 Container(
                   width: 1,
                    height: 100,
                   margin: EdgeInsets.all(10),
                   color: kLightBlue,
                 ),
                 Expanded(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                        Text('Promote item (premium)', textAlign: TextAlign.center, style:promoTitleStyle),
                       SizedBox(height: 20,),
                       Text('\u20a6 $multiPromoUploadPrice', style: promoPriceStyle),
                       SizedBox(height: 20,),
                       Text('Put an item on Gmart home screen for 4 days', maxLines: 4, textAlign: TextAlign.center,
                         style:promoDetailsStyle,),
                     ],
                   ),
                 )
               ],
             ),
           ),
           Expanded(
             child: Stack(
               children: [
                 Container(
                   color: Colors.white,
                   height: double.maxFinite,
                   margin: EdgeInsets.only(top: 170),
                 ),
                 Container(
                  decoration:BoxDecoration(
                  borderRadius:BorderRadius.circular(30),
                  color: Color(0xAAAAAAFF),
                  ),
                child: ListView(
                    children:[
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FlatButton(
                            splashColor: Colors.white,
                            onPressed: (){
//                              showSubExpiredNotification();
                              },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                color:kThemeBlue,
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(CupertinoIcons.doc_chart_fill, color: Colors.white,),
                              ),
                            ),
                          ),
                            Text('Earnings \u20a6${Provider.of<SellerOrderProvider>(context).amount}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),)
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 5, right: 5, top: 15, bottom: 300),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: (promoList.length>0||(Provider.of<PromoModel>(context).promoList!=null&&Provider.of<PromoModel>(context).promoList.length>0))?30:0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.star_lefthalf_fill, color: kThemeOrange,
                                      size: promoList.length>0||(Provider.of<PromoModel>(context).promoList!=null&&Provider.of<PromoModel>(context).promoList.length>0)?25:0,),
                                    Text('Promoted items', style: TextStyle(color:kThemeOrange, fontWeight: FontWeight.bold),)
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(4),
                                height: (promoList.length>0||(Provider.of<PromoModel>(context).promoList!=null&&Provider.of<PromoModel>(context).promoList.length>0))?160:0,
                                child: ListView(
                                  children: Provider.of<PromoModel>(context).promoList??promoList,
                                  scrollDirection: Axis.horizontal,
                                ),
                              ),
                              Container(
                                width: double.maxFinite,
                                margin: EdgeInsets.all( 10),
                                decoration: BoxDecoration(
                                    color: kThemeOrange,
                                    borderRadius: BorderRadius.circular(25)
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
                              Column(
                                children: Provider.of<PromoModel>(context).martList??sellerItemsWIdgets,
                              )
                            ],
                          ),
                        ),
                      ),
                    ]
                  ),
                )],
             ),
           )
          ],
        ),
      ),
    );
  }
  void showSubExpiredNotification(){
    showSimpleNotification(
        Text("Gmart item subscriptions expired !!! Re-subscribe now.", style: kNavTextStyle,),
        leading:Icon(Icons.warning, color:Colors.white),
        background: Colors.red);
  }

  void testSellerItemsDownload(){
    setProgress(true);
    _smPageModel.downloadSellerItems();
    setProgress(false);
  }

  void setProgress(bool b){
    progress=b;
    setState(() {

    });
  }

  Future<void> setSellerItems() async {
    setProgress(true);
    walletBallance=await uGetSharedPrefValue(kWalletKey);
    if(walletBallance=='null') walletBallance='0';
   await getSellerItems(context);
   singleUploadPrice=await uGetSharedPrefValue(kItemUploadPriceKey)??'30';
   if(singleUploadPrice=='null') singleUploadPrice='30';
   singleVariantUploadPrice=await uGetSharedPrefValue(kVariantUploadPriceKey)??'35';
   if(singleVariantUploadPrice=='null') singleVariantUploadPrice='35';
   singlePromoUploadPrice=await uGetSharedPrefValue(kPromo1Key)??'30';
   if(singlePromoUploadPrice=='null')singlePromoUploadPrice='30';
   multiPromoUploadPrice=await uGetSharedPrefValue(kPromoMultiKey)??'100';
   if(multiPromoUploadPrice=='null')multiPromoUploadPrice='100';
   String itemStat= await uGetSharedPrefValue(kShopItemsDownloaded);
   print('itemstat: $itemStat');
   if(Provider.of<PromoModel>(context, listen: false).martList==null && (itemStat.toLowerCase().contains('f')||itemStat.toLowerCase().contains('null'))){
     sellerItemsWIdgets=[];
      setProgress(false);
      uShowErrorDialog(context, 'Can\'t download items');
      return;
   }
   itemsSet=true;
    setProgress(false);
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
      await Provider.of<PromoModel>(context, listen: false).setWidgetLists(context);
    }catch(e){
      print('download items exception $e');
      return null;
    }
  }
  Future<void> downloadSellerItems() async {
    String sellerId= await uGetSharedPrefValue(kIdKey);
    List<MartItem> martList=await  AzSingle().fetchFullSellerItems(sellerId);
    SellerLargeItemsDb sDb = SellerLargeItemsDb();
    for(MartItem martItem in martList){
      print ('mart-item: $martItem');
      martItem.q='';
      List<String> picList=martItem.k.split(',');
      for(String element in picList){
        if(element.trim().isNotEmpty){
          // DOWNLOAD PICTURE.
          try{
            martItem.q+=','+(await AzSingle().downloadAzurePic(element));
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

//  Future<String> downloadAzurePic(String picId) async {
//    String url;
//    String fileId=uGetUniqueId();
//
//    url=picId.contains(kAzureImageStart)?picId: (kAzureImageStart+picId);
//
//    //CONDITIONS: PIC REFERENCE WAS REPLACED WITH kUrlStart or kPicLink or PICS'S ID WAS STORED DIRECTLY
//    final directory= await getApplicationDocumentsDirectory();
//    String path= directory.path+'/GmartPics';
//    if(!Directory(path).existsSync()) await Directory(path).create();
//    path+='/$fileId.jpg';
//    File newFile=File(path);
//    await newFile.create();
//
//    Response response=await get(url);
//    await newFile.writeAsBytes(response.bodyBytes);
//    return path;
//  }

}

//Container(
//decoration:BoxDecoration(
//borderRadius:BorderRadius.circular(10),
//color: Color(0xAAAAAAFF),
//),
//padding:EdgeInsets.all(8),
//child: Column(
//children:[
//Container(
//height: 60,
//alignment: Alignment.center,
//padding: EdgeInsets.all(16),
//decoration: BoxDecoration(
//borderRadius: BorderRadius.circular(10),
//color: kLightBlue
//),
//child: Row(
//mainAxisAlignment: MainAxisAlignment.spaceBetween,
//children: [
//Container(
//alignment: Alignment.center,
//decoration:BoxDecoration(
//shape: BoxShape.circle,
//color: kThemeBlue
//),
//padding: EdgeInsets.all(8),
//child: Icon(CupertinoIcons.doc_chart_fill, color: Colors.white,)),
//Text('Earnings \u20a6$orderAmount', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),)
//],
//),
//),
//Container(
//margin: EdgeInsets.only(top: 45),
//padding: EdgeInsets.all(8),
//decoration:BoxDecoration(
//shape: BoxShape.circle,
//color: Colors.white
//),
//child: SingleChildScrollView(
//child: Container(
//child: Column(
//children: [
//ListView(
//shrinkWrap: true,
//children: _smPageModel.getDummyPromoItems(5),
//),
//ListView(
//shrinkWrap: true,
//children: _smPageModel.getDummyItems(5),
//),
//],
//),
//),
//),
//)
//]
//),
//)
//
