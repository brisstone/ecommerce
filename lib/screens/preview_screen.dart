import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:ecommerce/custom_widgets/seller_contact_items.dart';
import 'package:ecommerce/custom_widgets/variant_list_item.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/screens/edit_item_screen.dart';
import 'package:ecommerce/screens/seller_portal_screen.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:http/http.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:share/share.dart';

import '../constants.dart';

class PreviewScreen extends StatefulWidget {
  MartItem martItem;
  bool justUped;

  PreviewScreen({this.martItem, this.justUped=false});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen>{
  String title='Sample title';
  String description='This is an sample test description This is an sample test description This is an sample test  descriptionThis is an sample test description This is an sample test description This is an sample test description This is an sample test description\n';
  String sellerName='';
  String shopTitle='Gmart.ng';
  bool progress=false;
  List<Widget> variantsList=[];
  List<Widget> picList=[];
  String itemId='';
  String price='';
  int endTime=0;
  Widget countDownWidget=Container(height: 40,);
  EdgeInsets contactsPadding=EdgeInsets.all(8);
  TextStyle indStyle=TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w300);
  String numsLeft='';
  int year=0, monthi=0, day=0;
  bool numProgress=false;

  @override
  void initState() {
  }

  @override
  void didChangeDependencies() {
    showProgress(true);
    if(widget.justUped && this.mounted  ) {
      widget.justUped=false;
      showItemUploadedDialog();
    }
    setDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child:ModalProgressHUD(
            inAsyncCall: progress,
            child: Stack(
              alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: EdgeInsets.all(18.0),
                    child: ListView(
                      children: [
                        SizedBox(height: 50,),
                        Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children:[
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children:
                                [
                                  Text(title, textAlign: TextAlign.start, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.w900, fontSize: 18),),
                                  FlatButton(
                                      splashColor: kThemeOrange,
                                      onPressed: (){
                                        shareItem();
                                      },
                                      child: Icon(Icons.share, size: 20, color: kThemeBlue,))
                                ]

                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text('\u20a6 ${price}', textAlign: TextAlign.start,
                                  style: TextStyle(color: kThemeOrange, fontWeight: FontWeight.w900, fontSize: 15),),
                              ),
                              CarouselSlider(
                              items: picList
                              , options: CarouselOptions(height: 400,
                              enlargeCenterPage: true,
                              viewportFraction: 1.0,
                            )),
                              SizedBox(height: 10,),
                              Container(
                                height: 30,
                                width: 400,
                                child: ModalProgressHUD(
                                  inAsyncCall: numProgress,
                                  opacity: 0,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 18),
                                      height: 30,
                                      width: double.maxFinite,
                                      child: Text('$numsLeft', textAlign: TextAlign.start, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500,fontSize: 15),)),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(18.0),
                                child: Text(description, textAlign: TextAlign.start, style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500,fontSize: 18),),
                              ),
                            ]
                          ),
                        )
                        ,
                        Card(
                          child: Column(
                            children: [
                              SizedBox(height: 10,),
                              Text(shopTitle, textAlign: TextAlign.start, style:
                              TextStyle(color: Colors.black,
                                  fontFamily: 'Pacifico',
                                  fontWeight: FontWeight.w200, fontSize: 17),),
                              SizedBox(height: 10,),
                              Text('sold by: $sellerName', textAlign: TextAlign.start, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12),),
                              SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      padding: contactsPadding,
                                      decoration: BoxDecoration(
                                      color: Colors.black, shape: BoxShape.circle
                                  ), child: Icon(CupertinoIcons.phone,color: Colors.white)),
                                  SizedBox(width: 16,),
                                  Container(
                                      padding: contactsPadding,
                                      decoration: BoxDecoration(
                                      color: Colors.blueAccent,  shape: BoxShape.circle
                                  ), child: Icon(CupertinoIcons.chat_bubble_text,color: Colors.white)),
                                  SizedBox(width: 16,),
                                  Container(
                                      padding: contactsPadding,
                                      decoration: BoxDecoration(
                                      color: Colors.red,   shape: BoxShape.circle
                                  ), child: Icon(CupertinoIcons.mail, color: Colors.white,)),
                                  SizedBox(width: 16,),
                                  CircleAvatar(
                                    radius: 16,
                                    child: GestureDetector(
                                        onTap: (){
                                        },
                                        child: Image.asset('images/whatsapp.png', height: 26,)),backgroundColor: Colors.green,),
                                ],
                              ),
                              SizedBox(height: 10,),
                            ],
                          ),
                        ),
//                      Card(
//                        child: Container(
//                          decoration: BoxDecoration(
//                              borderRadius: BorderRadius.circular(20)
//                          ),
//                          margin: EdgeInsets.all(8),
//                          padding: EdgeInsets.all(8),
//                          child: Row(
//                            children: [
//                              Expanded(
//                                flex: 2,
//                                child: Column(
//                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                  crossAxisAlignment: CrossAxisAlignment.start,
//                                  children: [
//                                    Text(sellerName, textAlign: TextAlign.start, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 30),),
//                                    SizedBox(height: 50,),
//                                    Text(shopTitle, textAlign: TextAlign.start, style: TextStyle(color: Colors.white,
//                                        fontFamily: 'Pacifico',
//                                        fontWeight: FontWeight.w200, fontSize: 15),),
//                                  ],
//                                ),
//                              ),
//                              Expanded(
//                                  flex: 3,
//                                  child: Column(
//                                    children: [
//                                      SizedBox(height: 50,),
//                                      SellerContactWidget(color: kLightBlue, label: 'Call', icon: CupertinoIcons.phone,),
//                                      SizedBox(height: 6,),
//                                      SellerContactWidget(color: kLightBlue, label: 'Text', icon: CupertinoIcons.chat_bubble_text,),
//                                      SizedBox(height: 6,),
//                                      SellerContactWidget(color: kLightBlue, label: 'Email', icon: CupertinoIcons.mail,),
//                                      SizedBox(height: 6,),
//                                      SellerContactWidget(color: kLightBlue, label: 'Whatsapp', icon: CupertinoIcons.text_quote,),
//                                    ],
//                                  ))
//                            ],
//                          ),
//                        ),
//                      ),

                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8.0),
                                child: Text('\u20a6 ${price}', textAlign: TextAlign.start,
                                  style: TextStyle(color: kThemeOrange, fontWeight: FontWeight.w900, fontSize: 25),),
                              ),
                              Container(
                                height: variantsList.length>0? 50: 0,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children:variantsList,
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                ),
                              ),
                              SizedBox(height: 20,),
                              FlatButton(onPressed: (){},
                                  splashColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                                  child: Container(
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    decoration: BoxDecoration(
                                        color: kThemeOrange,
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Text('Buy', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                                  )),
                              SizedBox(height: 20,),
                            ],
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),
                   Container(
                      constraints: BoxConstraints(
                        maxHeight: 100
                      ),
                      decoration: BoxDecoration(
                      gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black,
                        Colors.transparent
                      ]
                    )
                    ),
                    child: Row(
                      children:[
                        FlatButton(
                          splashColor: kThemeBlue,
                          onPressed: (){
                            List<String> timeDivs=widget.martItem.h.split(':');
                            if(timeDivs.length!=3)
                              Navigator.pop(context);
                            else
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SellerPortalScreen()));
                          },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle
                          ),
                            padding: EdgeInsets.all(16),
                            child: Icon(CupertinoIcons.arrow_left, color: kThemeBlue,)),
                        ),
                        countDownWidget,
                        Container(
                            decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle
                          ),
                            child: IconButton(
                              icon: Icon(Icons.edit, color:kThemeBlue),
                              splashColor: Colors.white,
                              onPressed: (){
                               showEditItemDialog();
                              },
                            )
                          )
                        ]
                        ),
                      )
                ]
            ),
          ),
        ),
      ),
    );
  }

  void showProgress(bool b){
    progress=b;
    setState(() {});
  }

  void showNumProgress(bool b){
    numProgress=b;
    setState(() {});
  }

  Future<void> updateCloudStatus(String h) async {
    print('updating cloud');
    List<String> timeDivs=h.split(':');
    showProgress(false);
    if(timeDivs.length!=3)return;
    if(!(await uCheckInternet())) return;
    showNumProgress(true);
    numsLeft= await AzSingle().getItemNumleft(itemId);
    numsLeft='Items left: $numsLeft';
    print('updating cloud : $numsLeft');
    showNumProgress(false);
  }

  void showItemUploadedDialog() {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        uShowCustomDialog(context: context,
            icon: Icons.done,
            iconColor: Colors.green,
            text: 'Your item has been uploaded',
            buttonList: [['Ok', Colors.green, (){
              Navigator.pop(context);
            }]]);
      });
//      Future.delayed(
//      Duration(seconds: 3),
//      () {
//        uShowCustomDialog(context: context,
//            icon: Icons.done,
//            iconColor: Colors.green,
//            text: 'Your item has been uploaded',
//            buttonList: [['Ok', Colors.green, (){
//              Navigator.pop(context);
//              setDetails();
//            }]]);
//      });
    }catch(e){
      print('dialog error: ${e.toString()}');
    }
  }


  Future<void> shareItem() async {
    if(itemId==null || itemId.isEmpty)return;
    showProgress(true);
    try {
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix:'https://gmart.page.link',// 'https://com.algure.gmartapp',
        link: Uri.parse('https://gmart.page.link/item:${itemId}'),
        androidParameters: AndroidParameters(
          packageName: 'com.algure.gmartapp',
          minimumVersion: 0,
        ),
        iosParameters: IosParameters(
          bundleId: 'com.algure.gmartapp',
          minimumVersion: '1.0.1',
          appStoreId: kIosAppStoreId,
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: '$title',
          imageUrl: Uri.parse(getOnePic()),
          description: ' Check it on Gmart.ng',
        ),
      );
      Uri dynamicUrl = await parameters.buildUrl();
      final ShortDynamicLink shortDynamicLink = await parameters
          .buildShortLink();
      dynamicUrl = shortDynamicLink.shortUrl;
      showProgress(false);
      print('dynamic url: ${dynamicUrl.toString()}');
      Share.share('${dynamicUrl.toString()}',
          subject: 'Check this out on Gmart.ng');
    }catch(e){
      showProgress(false);
      uShowErrorNotification('An error occured !');
      print('share exception ${e.toString()}');
    }
  }

  String getOnePic(){
    List<String> picList = widget.martItem.k.split(',');
    String pic='';
    for(String p in picList){
      if(p.trim().length>1){
        pic=p;
        break;
      }
    }
    print(' Picture:  $kAzureImageStart${pic}.jpg');
    return '$kAzureImageStart${pic}.jpg';
  }

  void setDetails() async {
    title=widget.martItem.t;
    description=widget.martItem.d;
    itemId=widget.martItem.l;
    sellerName=(await uGetSharedPrefValue(kFnameKey)).toString();
    sellerName+=' '+(await uGetSharedPrefValue(kLnameKey)).toString();
    setPricesList(widget.martItem.m);
    setImageList(widget.martItem.q);
    setCountDown(widget.martItem.h);
    await updateCloudStatus(widget.martItem.h);
  }

  void setImageList(String localImages){
    if(localImages.startsWith(','))
      localImages=localImages.substring(1);
    List<String> filePaths=localImages.split(',');
    for(String imPath in filePaths){
      picList.add(
          InteractiveViewer(child: Image.file(File(imPath), fit: BoxFit.cover,))
      );
    }
  }

  void setPricesList(String priceCompound) {
    variantsList=[];
    List<String> prices=priceCompound.split('<');
    price=prices[0];
    if(prices.length<=1){
      return;
    }
    prices=prices.sublist(1);
    for (String variant in prices) {
      List tempList=variant.split(',');
      variantsList.add(
          VariantListItem(title: tempList[0], price: tempList[1] ,
            onPressedFunc: (){
              resetVariants(selName:tempList[0], priceCompound: priceCompound);
            },
          ));
    }
  }

  void resetVariants({String selName, String priceCompound}) {
    variantsList=[];
    List<String> prices=priceCompound.split('<');
    prices=prices.sublist(1);
    for (String variant in prices) {
      List tempList=variant.split(',');
      if(tempList[0]==selName) price=tempList[1];
      variantsList.add(
          VariantListItem(title: tempList[0], price: tempList[1],
              selected: selName==tempList[0]?true:false,
              onPressedFunc: (){
                price=tempList[1];
                resetVariants(selName:tempList[0], priceCompound: priceCompound);
              },
          ));
    }
    setState(() { });
  }


  void setCountDown(String h) {
    List<String> timeDivs=h.split(':');
    if(timeDivs.length!=3){
      countDownWidget=Container(height: 50,);
      return;
    }
    itemId=widget.martItem.l;
     year=int.parse(timeDivs[0]);
     monthi=int.parse(timeDivs[1]);
     day=int.parse(timeDivs[2]);
    DateTime date=DateTime(2000+year, monthi, day);
    TextStyle indStyle=TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w300);

    endTime=date.millisecondsSinceEpoch;
    countDownWidget=Container(
      constraints: BoxConstraints(
        maxHeight: 100,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:[
          Text('Subscription ends in', textAlign: TextAlign.center,style: TextStyle(color: kThemeOrange, fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
          CountdownTimer(
            endTime:endTime,
          widgetBuilder: (_,  time ){
            return RichText(
                text:TextSpan(
                    style:TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                    children:[
                      TextSpan(text:!time.days.toString().contains('null')?time.days.toString():'00'),
                      TextSpan(text:'days:',style:indStyle),
                      TextSpan(text:!time.hours.toString().contains('null')?time.hours.toString():'00'),
                      TextSpan(text:'hrs:',style:indStyle),
                      TextSpan(text:!time.min.toString().contains('null')?time.min.toString():'00'),
                      TextSpan(text:'mins:',style:indStyle),
                      TextSpan(text:!time.sec.toString().contains('null')?time.sec.toString():'00'),
                      TextSpan(text:'secs',style:indStyle),
                    ]
//               '${time.days}days : ${time.hours}hours : ${time.min} mins : ${time.sec} sec']
                )
            );
          },
        ),
        ]
      ),
    );
  }

  void showEditItemDialog() {
    uShowCustomDialog(context: context, icon: Icons.description, iconColor: kLightBlue, text: 'Cuurent edits only take effect after re-uploading item (requires additional subscription fees).',
    buttonList: [['Proceed', kLightBlue,(){
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
        return EditItemScrren(context, martItem:widget.martItem);
      }));
    }],['Cancel', Colors.black,(){
      Navigator.pop(context);
    }],]);
  }
}
