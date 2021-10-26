import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:azstore/azstore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:ecommerce/custom_widgets/variant_edit_item.dart';
import 'package:ecommerce/databases/seller_items_db.dart';
import 'package:ecommerce/fragmented_screens/sellerportal_mainpage.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/mart_objects/small_mitem.dart';
import 'package:ecommerce/providers/promo_model.dart';
import 'package:ecommerce/screens/preview_screen.dart';
import 'package:ecommerce/screens/seller_portal_screen.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class EditItemScrren extends StatefulWidget {
  MartItem martItem;
  BuildContext oldContext;

  EditItemScrren(this.oldContext,{this.martItem}){
//    if(martItem==null)martItem= MartItem.empty();
  }
  EditItemScrren.empty() {}

  @override
  _EditItemScrrenState createState() => _EditItemScrrenState();

}

class _EditItemScrrenState extends State<EditItemScrren> {
  TextStyle largeBlueTextStyle= TextStyle(color: kThemeBlue, fontWeight: FontWeight.w900, fontSize: 18);
  var largeOrangeTextStyle=  TextStyle(color: kThemeOrange, fontWeight: FontWeight.w900, fontSize: 18);
  bool progress=false;

  double sBoxHeight=30;
  String _prices='0';
  String email='';
  String fname='';
  String sname='';
  String phoneNum='';
  String itemId='';//Item id
  String tittle='';//tittle
  String description='';
  String state='';//state
  String sellerId='';//seller Id
  String sellerProfile='';//seller profile
  String pictures='';//pictures
  String allowPayment='';//allow payment(bool)
  String subTime='';//subscription expiration time
  String price='';//price (m)
  String numLeft='';//number left

  Map<String,Widget> variantsList={};
  Map<String,String> variantValues={};
  Map<String,String> variantPrices={};
  List<Widget> variantsWidgetsList=[];
  List<Widget> sellerDetailsList=[];

  final picker= ImagePicker();
  List filePaths=[];
  List<String> imageUrls=[];
  List<Widget> imageWidgets=[];

  int tittleLength=24;
  int descLength=100;
  int numLeftLength=3;
  int priceLength=5;
  bool allowPay=true;
  String paymentMessage='Payment allowed';

  String shopName='';

  @override
  void initState() {
    setupLayout();
  }

  @override
  Widget build(BuildContext context) {
    setSelectedImages();
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: (){
//            if(subTime!=null&&subTime.contains(':')&&!uIsItemExpired(subTime))
//              goBackToPreview();
//            else
              saveDraftToDb();
            },
          child: Icon(CupertinoIcons.arrow_left, color: Colors.white,),
        ),
        title:RawMaterialButton(
            onPressed: (){
              print('tapped');
              if(subTime!=null&&subTime.contains(':')&&!uIsItemExpired(subTime))
                goBackToPreview();
              else
                saveDraftToDb();
            },
            child: Text(!(subTime!=null&&subTime.contains(':')&&!uIsItemExpired(subTime))?'Save Draft':'Cancel Edit',textAlign: TextAlign.left, style: TextStyle(color: Colors.white, fontSize: 12),)),
        backgroundColor: kThemeBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          FlatButton.icon(
            splashColor: Colors.white,
              onPressed: (){
              showUploadPromptDialog();
             },
              icon: Icon(CupertinoIcons.cloud_upload, color: Colors.white,) ,
            label:  Text('Upload', style: TextStyle(color: Colors.white),
            ),
          ),
          FlatButton.icon(
            splashColor: Colors.white,
              onPressed: (){
               openPreview();
              },
              icon: Icon(CupertinoIcons.arrow_right, color: Colors.white,) ,
              label:  Text('preview', style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: ModalProgressHUD(
        opacity: 0.5,
        color: kThemeBlue,
        inAsyncCall: progress,
        child: Container(
          color: kDialogLight,
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: ListView(
            children: [
              Text('Please fill all required (*) fields', textAlign: TextAlign.center, style: largeBlueTextStyle,),
              SizedBox(height: sBoxHeight,),
              Text('* Add images (max:2)', textAlign: TextAlign.start, style: kInputLabelStyle,),
              Container(
                decoration: BoxDecoration(
//                    border: Border.all(color: kThemeBlue, width: 1.5),
                    color: Colors.white,
                    boxShadow: [BoxShadow(blurRadius: 1)],
                    borderRadius: BorderRadius.circular(8)
                ),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: imageWidgets,
                ),
              ),
              SizedBox(height: sBoxHeight,),
              Text('*Enter item name.', textAlign: TextAlign.start, style: kInputLabelStyle,),
              TextField(
                  controller: TextEditingController(
                    text: tittle
                  ),
                  style: kInputTextStyle,
                  textAlign: TextAlign.start,
                  maxLength: tittleLength,
                  onChanged: (text){tittle=text;},
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'e.g Blouse, Blue T-shirt, Classic watch',
                    hintStyle: kHintStyle,
//                    border: kInputOutlineBorder,
                  )
              ),
              SizedBox(height: sBoxHeight,),
              Text('*Enter item & delivery details.', textAlign: TextAlign.start, style: kInputLabelStyle,),
              TextField(
                  controller: TextEditingController(
                      text: description
                  ),
                  style: kInputTextStyle,
                  textAlign: TextAlign.start,
                  onChanged: (text){description=text;},
                  maxLength: descLength,
                  maxLines:8,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'e.g Blue casual T-shirt. 90% cotton..... 2 days nation wide delivery.....',
                    hintStyle: kHintStyle,
//                    border: kInputOutlineBorder,
                  )
              ),
              SizedBox(height: sBoxHeight,),
              Text('*Enter the price per unit', textAlign: TextAlign.start, style: kInputLabelStyle,),
              TextField(
                  onChanged: (text){price=text;},
                  controller: TextEditingController(
                      text: price
                  ),
                  style: kInputTextStyle,
                  textAlign: TextAlign.start,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number ,
                  maxLength: priceLength,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'e.g 1000',
                    hintStyle: kHintStyle,
//                    border: kInputOutlineBorder,
                  )
              ),
              SizedBox(height: sBoxHeight,),
              Text('*Enter the number of items available', textAlign: TextAlign.start, style: kInputLabelStyle,),
              TextField(
                  onChanged: (text){numLeft=text;},
                  controller: TextEditingController(
                      text: numLeft
                  ),
                  style: kInputTextStyle,
                  textAlign: TextAlign.start,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number ,
                  maxLength: numLeftLength,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'e.g 5',
                    fillColor: Colors.white,
                    hintStyle: kHintStyle,
//                    border: kInputOutlineBorder,
                  )
              ),
              SizedBox(height: sBoxHeight,),
              Text('Allow Gmart payments for this item', textAlign: TextAlign.start, style: kInputLabelStyle,),
              Container(
                decoration: BoxDecoration(
//                    border: Border.all(color: kThemeBlue, width: 1.5),
                    color: Colors.white,
                    boxShadow: [BoxShadow(blurRadius: 1)],
                    borderRadius: BorderRadius.circular(8)
                ),
                padding: EdgeInsets.all(5),
                child: CheckboxListTile(
                    title: Text(paymentMessage, style: TextStyle(color: !allowPay?kThemeBlue:kThemeOrange),),
                    value:allowPay,
                    activeColor: kThemeOrange,
                    checkColor: kThemeBlue,
                    onChanged: (allowPay){
                      setupAllowpay(allowPay);
                    }
                ),
              ),
              SizedBox(height: sBoxHeight,),
              Text('Add variations (optional)', textAlign: TextAlign.start, style: kInputLabelStyle,),
              Container(
                decoration: BoxDecoration(
//                    border: Border.all(color: kThemeBlue, width: 1.5),
                    color: Colors.white,
                    boxShadow: [BoxShadow(blurRadius: 1)],
                    borderRadius: BorderRadius.circular(8)
                ),
                padding: EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: variantsWidgetsList,
                ),
              ),
             SizedBox(height: sBoxHeight,),
              Text('Edit seller details (optional)', textAlign: TextAlign.start, style: kInputLabelStyle,),
              Container(
                decoration: BoxDecoration(
//                    border: Border.all(color: kThemeBlue, width: 1.5),
                    color: Colors.white,
                    boxShadow: [BoxShadow(blurRadius: 1)],
                    borderRadius: BorderRadius.circular(8)
                ),
                padding: EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sellerDetailsList,
                ),
              ),
              SizedBox(height: 50,),
              FlatButton(
                onPressed: (){
                  showDeleteItemDialog();
                },
                splashColor: Colors.white,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.red
                  ),
                  alignment: Alignment.center,
                  child: Text('Delete item', textAlign: TextAlign.center, style: kNavTextStyle,),
                ),
              ),
              SizedBox(height: 100,),
            ],
          ),
        ),
      ),
    );
  }

  void showProgress(bool b){
    progress=b;
    setState(() {});
  }

  selectImage() async {
    try {
      showProgress(true);
      PickedFile tempFile = await picker.getImage(source: ImageSource.gallery);
      print('tempfile ${tempFile.toString()}');
      String compressedPath = tempFile.path;// await compressImage(File(tempFile.path).absolute.path);
      filePaths.add(compressedPath);
      showProgress(false);
      setSelectedImages();
    }catch(e){
      showProgress(false);
      print('error: $e');
    }
  }

  Future<String> compressImage(String imagePath) async {
    final directory= await getApplicationDocumentsDirectory();
    String path= directory.path+'/GmartPics';
    if(!Directory(path).existsSync()) await Directory(path).create();
    String fileId=await uGetUniquePicId();
    path+='/$fileId.jpg';
    File newFile=File(path);
    await newFile.create();
    File compressionFile= await FlutterImageCompress.compressAndGetFile(imagePath, path, quality: 25, rotate: 0);
    return compressionFile.path;
  }

  Future<void> setSellerDetails() async {
    SharedPreferences prefs= await SharedPreferences.getInstance();
     email= prefs.get(kMailKey).toString()??'non';
     fname=prefs.get(kFnameKey).toString()??'non';
     sname=prefs.get(kLnameKey).toString()??'non';
     phoneNum=prefs.get(kPhoneKey).toString()??'non';
    shopName= await uGetSharedPrefValue(kShopInfo);
    TextStyle sellerInfoStyle=TextStyle(color: kThemeBlue, fontWeight: FontWeight.bold);
     sellerDetailsList=[
       Container(
         alignment: Alignment.topRight,
         child: FlatButton(
           onPressed: (){
             showOpenProfileDialog('You can only edit these properties from your profile page');
           },
           splashColor: Colors.white,
           child: Container(
             padding: EdgeInsets.all(6),
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 color: kLightBlue,
               ),
               child: Icon(Icons.edit, color: Colors.white, size: 20,)),
         ),
       ),
       SizedBox(height: 16,),
       Text('$shopName', style: sellerInfoStyle ,),
       SizedBox(height: 16,),
       Text(email, style: sellerInfoStyle ,),
       SizedBox(height: 16,),
       Text(phoneNum, style: sellerInfoStyle ,),
       SizedBox(height: 16,),
     ];
     try{
       setState(() {});
     }catch(e){
       print('error $e');
     }
  }

  String getSellerContact(){
    return '$email<$phoneNum<$shopName';
  }

  void addVariantTab() {
    if (variantsList.length < 6) {
      //Get keys and avoid collisions
      String s = (Random().nextInt(100)).toString();
      while (variantsList.containsKey(s)) s = (Random().nextInt(100)).toString();

      variantsList.remove('button');//remove button b4 inserting new item.
      variantPrices[s] = _prices.isEmpty||_prices=='0'?'':_prices;
      variantValues[s] = '';
      variantsList[s] = VariantEditItem(
          onValueChanged: (string) {
            variantValues[s] = string;
            print('s: $s, label: ${variantValues[s]}, price: ${variantPrices[s]}');
          },
          s: s,
          price:  variantPrices[s],
          label:  variantValues[s],
          onPricedChanged: (string) {
            variantPrices[s] = string;
            print('s: $s, label: ${variantValues[s]}, price: ${variantPrices[s]}');
          },
          onDelete: () {
            deleteVariantItem(s);
          }
      );
      variantsList['button']=Container(//re-add button after inserting new item.
        margin: EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
            color: kLightBlue,
            borderRadius: BorderRadius.circular(10)
        ),
        alignment: Alignment.center,
        child: FlatButton(
          splashColor: Colors.white,
          color: Colors.transparent,
          child: Text('Add variant', style: kNavTextStyle,),
          onPressed: (){
            addVariantTab();
            setState(() {

            });
          },
        ),
      );
      resetVariantWidgets();
    }else{
      uShowErrorDialog(context, 'Variants cannot be more than 5');
    }
  }

 deleteVariantItem(String key){
    print('delete s: $key, label: ${variantValues[key]}, price: ${variantPrices[key]}');
   variantValues.remove(key);
    variantPrices.remove(key);
    variantsList.remove(key);
    resetVariantWidgets();
  }

  void setVariantWidgets(){
    variantsWidgetsList.clear();
    for(var v in variantsList.entries){
      if(v.key=='button') {
        continue;
      }
      String label=variantValues[v.key];
      String price=variantPrices[v.key];
      variantsWidgetsList.add(
          VariantEditItem(
              onValueChanged: (string) {
                variantValues[v.key] = string;
                print('s: ${v.key}, label: ${variantValues[v.key]}, price: ${variantPrices[v.key]}');
              },
              s: v.key,
              price:  price,
              label:  label,
              onPricedChanged: (string) {
                variantPrices[v.key] = string;
                print('s: ${v.key}, label: ${variantValues[v.key]}, price: ${variantPrices[v.key]}');
              },
              onDelete: () {
                deleteVariantItem(v.key);
              }
          ));
    }
    variantsWidgetsList.add(variantsList['button']);
    print("variant list ${variantsWidgetsList.length}");
  }

  void resetVariantWidgets(){
    variantsWidgetsList.clear();
    for(var v in variantsList.entries){
      if(v.key=='button') {
        continue;
      }
      String label=variantValues[v.key];
      String price=variantPrices[v.key];
      variantsWidgetsList.add(
          VariantEditItem(
              onValueChanged: (string) {
                variantValues[v.key] = string;
                print('s: ${v.key}, label: ${variantValues[v.key]}, price: ${variantPrices[v.key]}');
              },
              s: v.key,
              price:  price,
              label:  label,
              onPricedChanged: (string) {
                variantPrices[v.key] = string;
                print('s: ${v.key}, label: ${variantValues[v.key]}, price: ${variantPrices[v.key]}');
              },
              onDelete: () {
                deleteVariantItem(v.key);
              }
          ));
    }
    variantsWidgetsList.add(variantsList['button']);
    setState(() {

    });
  }

  void showOpenProfileDialog(String s) {
    uShowCustomDialog(
      icon: CupertinoIcons.person,
      iconColor: kThemeBlue,
      context: this.context,
      text: s,
      buttonList: [
        ['Go to profile',kLightBlue,(){
          Navigator.pop(context);
          Navigator.pushNamed(context, '/profile');
        },]
      ]
    );
  }

  void setSelectedImages() {
    double aspectRatio=4/5;
    int rem=2-filePaths.length;
    imageWidgets.clear();
    for(String filePath in filePaths){
      if(!filePath.isEmpty) {
        imageWidgets.add(
            Expanded(
              child: Align(
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(File(filePath), height: 350,
                            width: 350 * aspectRatio,
                            fit: BoxFit.cover,),
                        ),
                        Container(
                          alignment: Alignment.topRight,
                          margin: EdgeInsets.all(4),
                          child: FlatButton(
                            onPressed: () {
                             deleteImage(filePath);
                            },
                            splashColor: Colors.white,
                            child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: kLightBlue,
                                ),
                                child: Icon(Icons.clear, color: Colors.white,
                                  size: 20,)),
                          ),
                        ),
                      ]
                  ),
                ),
              ),
            )
        );
        imageWidgets.add(
            SizedBox(width: 10,)
        );
      }else{
        rem++;
      }
    }

    for(int i=0;i<rem; i++){
      imageWidgets.add(
          Expanded(
            child: Align(
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container( color: kLightBlue,  height: 350,
                      width: double.maxFinite,
                      alignment: Alignment.center,
                      child:FlatButton(
                          onPressed: (){
                            selectImage();
                          },
                          splashColor: kLightBlue,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                          [
                            Icon(Icons.image, color: Colors.white, size: 40,),
                            SizedBox(height: 15,),
                            Text('select Image', style: kNavTextStyle),//TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),)
                          ]))
                  ),
                ),
              ),
            ),
          ),
      );
      imageWidgets.add(
          SizedBox(width: 10,)
      );
    }
    setState(() {

    });
  }

  Future<void> deleteImage(filePath) async {
    showProgress(true);
    List<String> pathSrc=filePath.split('/');
    String pathId=pathSrc[pathSrc.length-1].replaceAll('.jpg', '');
    bool isOnline=false;
    String url='';
    AzureStorage azs= AzureStorage.parse(uGetConnString());
    imageUrls.forEach((element) {
      if(element.contains(pathId)){
        isOnline=true;
        url=element;
      }
    });
    if(!isOnline) {
      filePaths.remove(filePath);
      setSelectedImages();
      showProgress(false);
    }else{
      if(!(await uCheckInternet()) ){
        uShowNoInternetDialog(context);
        showProgress(false);
        return;
      }
      await AzSingle().deleteImage(pathId);
//      String delUrl=await uGetPicDownloadUrl(url);
//      if(delUrl!=null)await FirebaseStorage.instance.refFromURL(delUrl).delete();
      if(imageUrls.contains(pathId))imageUrls.remove(pathId);
      filePaths.remove(filePath);
      setSelectedImages();
      showProgress(false);
    }
  }

  Future<void> saveDraftToDb() async {
    if((tittle.toString()=='null' || tittle.trim().isEmpty) && (subTime.toString()=='null' || subTime.isEmpty)){
      showSignOutWarningDialog( context);
      return;
    }
    MartItem mitem=new MartItem();
    mitem.l=await getItemId();//Item id
    mitem.t=tittle;//tittle
    mitem.d=description;//description
    mitem.s=await getState();//state
    mitem.i=await getSellerId();//seller Id
    mitem.b=allowPay?'t':'f';
    mitem.k=getPicsUrl();//pictures
    mitem.h=subTime;//subscription expiration time
    mitem.m=getCompoundPrice();//price (m)
    mitem.n=numLeft;//number left
    mitem.q=getDevicePics();//device pics
    print('inserting item: $mitem');
    if(!(subTime!=null&&subTime.contains(':')&&!uIsItemExpired(subTime)))await saveItemToDb(mitem);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SellerPortalScreen()));
//    Navigator.push(context, MaterialPageRoute(builder: (context){
//      return SellerPortalScreen();
//    }));
  }

  String getDevicePics(){
    String q='';//device pics
    filePaths.forEach((element) {
      q+=','+element.toString();
    });
    return q;
  }

  String getCompoundPrice(){
    String prices=price;
    for(var v in variantValues.keys){
      variantValues[v]=variantValues[v].trim();
      if(!variantValues[v].trim().isEmpty && variantValues[v].toString()!='null') {
        prices += '<' + variantValues[v].trim(); //+','+variantPrices[v];
        if(variantPrices[v].isEmpty||variantPrices[v]=='0'||variantPrices[v]==null)prices+=','+price;
        else prices+=','+variantPrices[v];
      }
    }
    return prices;
  }

  Future<String> getItemId() async {
    if(itemId.toString()=='null'|| itemId.isEmpty){
//      String temp1=kDbref.push().key.toString();
//      print('push val $temp1');
//      List itemIdSrc=temp1.split('/');
//      itemId=itemIdSrc[itemIdSrc.length-1].toString().replaceAll('#', '').replaceAll('.', '')
//          .replaceAll(',', '').replaceAll('[', '').replaceAll(']', '').replaceAll('.', '');
      bool idIsUsed= true;
      while(idIsUsed){
        itemId=uGetUniqueId();
        idIsUsed= await AzSingle().checkIfIdIsUsed(itemId);
      }
    }
    return itemId;
  }

  Future<void> setItemId() async {
    if(itemId==null){
//      String temp1=uGetUniqueId();
//      print('push val $temp1');
//      List itemIdSrc=temp1.split('/');
//      itemId=itemIdSrc[itemIdSrc.length-1].toString().replaceAll('#', '').replaceAll('.', '')
//          .replaceAll(',', '').replaceAll('[', '').replaceAll(']', '').replaceAll('.', '');
      bool idIsUsed= await AzSingle().checkIfIdIsUsed(itemId);
      while(idIsUsed){
        itemId=uGetUniqueId();
         idIsUsed= await AzSingle().checkIfIdIsUsed(itemId);
      }
    }
    print('item Id $itemId');
  }

  Future<String> getState() async {
    state=(await uGetSharedPrefValue(kStateKey)).toString();
    return state;
  }

  Future<String> getSellerId() async{
    return ((await uGetSharedPrefValue(kIdKey))??'non').toString();
  }

  void showSignOutWarningDialog(BuildContext context) {
    uShowCustomDialog(context: context, icon: Icons.warning, iconColor: Colors.brown,
    text: 'No tittle inputed. Your item would not be saved', buttonList: [
      ['Proceed',kLightBlue,(){
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context){
        return SellerPortalScreen();
      }));
    }],
      ['Wait',kThemeOrange,(){Navigator.pop(context);}],]);
  }

  void showPreviewWarningDialog(BuildContext context) {
    uShowCustomDialog(context: context, icon: Icons.warning, iconColor: Colors.red,
    text: 'Incomplete details. preview cannot be launched.', buttonList: [
      ['Ok',kLightBlue,(){Navigator.pop(context);}],
        ]);
  }

  Future<void> openPreview() async {
    if((tittle.toString()=='null' || tittle.isEmpty) || (price.toString()=='null' || price.isEmpty)){
      showPreviewWarningDialog( context);
      return;
    }
    showProgress(true);
    SellerLargeItemsDb sDb = SellerLargeItemsDb();
    MartItem mitem=new MartItem();
    mitem.l=await getItemId();//Item id
    mitem.t=tittle;//tittle
    mitem.d=description;//description
    mitem.s=await getState();//state
    mitem.i=await getSellerId();//seller Id
    mitem.m=getCompoundPrice();//price (m)
    mitem.n=numLeft;//number left
    mitem.q=getDevicePics();//device pics
    mitem.b=allowPay?'t':'f';
    mitem.k=getPicsUrl();//pictures
    mitem.h=subTime;//subscription expiration time
    print('inserting item: $mitem');
    if(!(subTime!=null&&subTime.contains(':')&&!uIsItemExpired(subTime)))await sDb.insertItem(mitem);
    showProgress(false);
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return PreviewScreen(martItem: mitem,);
    }));
  }

  void setupLayout() {
    setSellerDetails();
    if(widget.martItem==null) {
      for (int i = 0; i < 3; i++) {
        addVariantTab();
      }
      setSelectedImages();
      return;
    }
    print('expiration date: ${widget.martItem.h}');
//    if(widget.martItem.h!=null && widget.martItem.h.isNotEmpty && widget.martItem.h.contains(':')){
//      Navigator.push(context, MaterialPageRoute(builder: (context){
//        return PreviewScreen(martItem: widget.martItem,);
//      }));
//    }
//    print('prices: ${widget.martItem.m}');
    setCompoundPrice(widget.martItem.m);
    setSelectedImagesFromDB(widget.martItem.q);
    setImageUrls(widget.martItem.k);
    tittle=widget.martItem.t;
    description=widget.martItem.d;
    itemId=widget.martItem.l;
    numLeft=widget.martItem.n;
    subTime=widget.martItem.h;
    allowPay= widget.martItem.b.toLowerCase().contains('t')?true:false;
    setupAllowpay(allowPay);
  }

  void setSelectedImagesFromDB(String q) {
    if(q.startsWith(',')) q=q.substring(1);
    if(q.endsWith(','))q=q.substring(0,q.length-1);
    filePaths=q.split(',');
    setSelectedImages();
  }

  void setCompoundPrice(String m) {
    try {
      print('edit price $m');
      m=m.replaceAll('<<', '<');
      List<String> priceList = m.split('<');
      price = priceList[0];
      Random random = Random();
      int nextLen = 3 - priceList.length + 1;
      print('nextLen: $nextLen, price: $m');
      for (int i = 1; i < priceList.length; i++) {
        String key = i.toString();
        List<String> tempList=priceList[i].contains(',')?priceList[i].split(','):priceList[i].split('>');
        if(tempList.length!=2){
          nextLen++;
          continue;
        }
        variantValues[key] = tempList[0];
        variantPrices[key] =tempList[1];
        variantsList[key] = VariantEditItem(
            onValueChanged: (string) {
              variantValues[key] = string;
              print(
                  's: ${key}, label: ${variantValues[key]}, price: ${variantPrices[key]}');
            },
            s: key,
            price: variantPrices[key],
            label: variantValues[key],
            onPricedChanged: (string) {
              variantPrices[key] = string;
              print(
                  's: ${key}, label: ${variantValues[key]}, price: ${variantPrices[key]}');
            },
            onDelete: () {
              deleteVariantItem(key);
            }
        );
      }

      ///ADD EMPTY TAB TO FILL THE REST
      for (int i = 0; i < nextLen; i++) {
        String s = (random.nextInt(100)).toString();
        while (variantsList.containsKey(s))s = (random.nextInt(100)).toString();
        variantsList.remove('button'); //remove button b4 inserting new item.
        variantPrices[s] = '';
        variantValues[s] = '';
        variantsList[s] = VariantEditItem(
            onValueChanged: (string) {
              variantValues[s] = string;
              print(
                  's: $s, label: ${variantValues[s]}, price: ${variantPrices[s]}');
            },
            s: s,
            price: variantPrices[s],
            label: variantValues[s],
            onPricedChanged: (string) {
              variantPrices[s] = string;
              print(
                  's: $s, label: ${variantValues[s]}, price: ${variantPrices[s]}');
            },
            onDelete: () {
              deleteVariantItem(s);
            }
        );
      }
      variantsList['button'] =
          Container( //re-add button after inserting new item.
            margin: EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
                color: kLightBlue,
                borderRadius: BorderRadius.circular(10)
            ),
            alignment: Alignment.center,
            child: FlatButton(
              splashColor: Colors.white,
              color: Colors.transparent,
              child: Text('Add variant', style: kNavTextStyle,),
              onPressed: () {
                addVariantTab();
                setState(() {

                });
              },
            ),
          );
      print('varlist ${variantsList.length}, length: ${nextLen}');
      //SET MAIN WIDGET LIST
      setVariantWidgets();
    }catch(e){
      print('variant error: $e');
    }
  }

  void showUploadPromptDialog(){    //  SHOW UPLOAD PROMPT
    if(!allFieldsOk()){    //  ALL FIELDS OR CANCEL.
      return;
    }
    uShowCustomDialogWithFile(context: context, path:filePaths[0],iconColor: kLightBlue, text:'Confirm upload. We advice that you preview this item before upload.',
        buttonList: [
          ['preview', kLightBlue,(){
          Navigator.pop(context);
          openPreview();
        }],
          ['upload', kThemeBlue,(){
          Navigator.pop(context);
          uploadItem();
        }],
    ]);
  }

  Future<void> uploadItem() async {
    showProgress(true);
    try {
      if (!(await uCheckInternet())) {
        uShowNoInternetDialog(context);
        showProgress(false);
        return;
      }
      if (!(await allFieldsOk())) { //  CHECK USER WALLET OR CANCEL.
        showProgress(false);
        return;
      }
      MartItem mitem = new MartItem();
      mitem.l = await getItemId(); //Item id
      mitem.t = tittle; //tittle
      mitem.d = description; //description
      mitem.s = await getState(); //state
      mitem.i = await getSellerId(); //seller Id
      mitem.k = await uploadPicToAzureGetUrl();// uploadPicsGetUrl(); //pictures
      mitem.b = allowPay ? 't' : 'f';
      mitem.h = await getExpirationTime(); //subscription expiration time
      mitem.m = getCompoundPrice(); //price (m)
      mitem.n = numLeft; //number left
      mitem.q = getDevicePics(); //device pics
      mitem.p = getSellerContact();
      if (mitem.i.length <= 5) {
        showProgress(false);
        uShowErrorDialog(context, 'An error occured');
        return;
      }
      if(!(await isFundsOk(mitem.m))){
        showProgress(false);
        return;
      }
//      MartItem largeItem = mitem.getLargeUpload();
//      SmallMitem smallItem = mitem.getSmallUpload();
//
//      await kDbref.child('S').child(mitem.l).set(smallItem.toMap());
//      await kDbref.child('R').child(mitem.l).set(largeItem.toMap());
      await AzSingle().uploadItemToSearchService(mitem);

      await debitUser(mitem.m); //  DEBIT USER AFTER UPLOAD
      // await AzSingle().setUserAsSeller(); //  SET SELLER STATUS IF NOT SET
      await saveItemToDb(mitem); //  SAVE ITEM AFTER UPLOAD

      showProgress(false);
      restartAfterUpload(mitem);
    }catch(e){
      uShowErrorNotification('An error occurred !');
      showProgress(false);
      print('item upload error: ${e.toString()}');
    }
    //  SET BOOLEAN TO ALLOWPAYMENT OR NOT
  }

  Future<void> testSaveItem2BD() async {
    showProgress(true);
    MartItem mitem=new MartItem();
   try {
     mitem.l = await getItemId(); //Item id
     mitem.t = tittle; //tittle
     mitem.d = description; //description
     mitem.s = await getState(); //state
     mitem.i = await getSellerId(); //seller Id
     mitem.k = await uploadPicsGetUrl(); //pictures
     mitem.b = allowPay ? 't' : 'f';
     mitem.h = await getExpirationTime(); //subscription expiration time
     mitem.m = getCompoundPrice(); //price (m)
     mitem.n = numLeft; //number left
     mitem.q = getDevicePics(); //device pics

     await saveItemToDb(mitem);
   }catch(e){
     print('error $e');
    }
    showProgress(false);
    print('item saved');
  }


  Future<void> testSmallItemUpload() async {
    showProgress(true);
    MartItem mitem = new MartItem();
    try {
      mitem.l = await getItemId(); //Item id
      mitem.t = tittle; //tittle
      mitem.d = description; //description
      mitem.s = await getState(); //state
      mitem.i = await getSellerId(); //seller Id
      mitem.k = await uploadPicsGetUrl(); //pictures
      mitem.b = allowPay ? 't' : 'f'; //allow payment
      mitem.h = await getExpirationTime(); //subscription expiration time
      mitem.m = getCompoundPrice(); //price (m)
      mitem.n = numLeft; //number left
      mitem.q = getDevicePics(); //device pics
    }catch(e){
      print('small error: $e');
    }
    showProgress(false);
    print('main item $mitem');
    print('small item: ${mitem.getSmallUpload()}');
  }

  Future<void> testLargeItemUpload() async {
    showProgress(true);
    MartItem mitem=new MartItem();
    try {
      mitem.l =await getItemId(); //Item id
      mitem.t = tittle; //tittle
      mitem.d = description; //description
      mitem.s = await getState(); //state
      mitem.i = await getSellerId(); //seller Id
      mitem.k = await uploadPicsGetUrl(); //pictures
      mitem.b = allowPay ? 't' : 'f';
      mitem.h = await getExpirationTime(); //subscription expiration time
      mitem.m = getCompoundPrice(); //price (m)
      mitem.n = numLeft; //number left
      mitem.q = getDevicePics(); //device pics
    }catch(e){
      print('large error: ${e.toString()}');
    }
    showProgress(false);
    print('main item $mitem');
    print('large item: ${mitem.getLargeUpload()}');
  }

  bool allFieldsOk(){

    if(filePaths.length==0){
      uShowErrorDialog(context, 'You have not selected any pictures');
      return false;
    }

    if(tittle==null || tittle.isEmpty){
      uShowErrorDialog(context, 'You have not filled in the tittle');
      return false;
    }else if(tittle.length>tittleLength){
      uShowErrorDialog(context, 'Tittle too long');
      return false;
    }

    if(description==null || description.isEmpty){
      uShowErrorDialog(context, 'You have not filled in the description');
      return false;
    }else if(description.length>descLength){
      description=description.replaceAll('\n', ' ').replaceAll('  ', '');
      if(description.length>descLength) {
        uShowErrorDialog(context, 'description is too long');
        return false;
      }
    }

    if(price==null || price.isEmpty){
      uShowErrorDialog(context, 'You have not filled in the price');
      return false;
    }else if(price.length>priceLength){
      uShowErrorDialog(context, 'price is too long');
      return false;
    }

    if(numLeft==null || numLeft.isEmpty){
      uShowErrorDialog(context, 'You have not filled in the number of items available');
      return false;
    }else if(numLeft.length>numLeftLength){
      uShowErrorDialog(context, 'number of items is too long');
      return false;
    }

    return true;
  }

  Future<String> uploadPicToAzureGetUrl() async {
    String downloadUrls='';
    //Optimised get pics to upload pics only if not already online
    print('subtime: $subTime');
//    if(subTime!=null&&subTime.contains(':')&&!uIsItemExpired(subTime)){
//      print ('in 1');
//      if(widget.martItem!=null)return widget.martItem.k;
//      else return '';
//    }
    for(String path in filePaths){
      print ('in 23');
      if(path.isEmpty) {
        continue;
      }
      String picId=await AzSingle().uploadPicToAzureGetID(path);
      setImageUrl(picId);
      downloadUrls+=','+picId;
    }
    return downloadUrls;
  }

  Future<String> uploadPicsGetUrl() async {
    FirebaseStorage storage=FirebaseStorage.instance;
    String downloadUrls='';
    //Optimised get pics to upload pics only if not already online
    if(!(subTime!=null&&subTime.contains(':')&&!uIsItemExpired(subTime))) return widget.martItem.k;
    for(String path in filePaths){
      if(path.isEmpty) {
        continue;
      }
      String picId=getUniqueIdWPath(path);
      Reference ref=storage.ref().child('L').child(picId);
      UploadTask uploadTask=ref.putFile(File(path));

      await uploadTask.then((snapshot) async {
        String downloadUrl=await snapshot.ref.getDownloadURL();
        setImageUrl(downloadUrl);
        downloadUrls+=','+picId;
      });
    }
    return downloadUrls;
  }

  void  setImageUrl(String  url){
    imageUrls.add(url);
  }

  String getUniqueIdWPath(String path) {
    List unis=path.split('/');
    return unis[unis.length-1].replaceAll('.jpg','');
  }

  Future<void> testDate() async {
    showProgress(true);
    try {
      print(await getExpirationTime());
    }catch(e){
      print('error $e');
    }
    showProgress(false);
  }

  Future<String> getExpirationTime() async {
    String dateBase = await uGetGoogleDate();
    String dateExtract=extractDate(dateBase);
    return dateExtract;
  }

  String extractDate(String dateBase) {
    List<String> months=['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul','aug', 'sep', 'oct', 'nov', 'dec'];
    List<String> dBase=dateBase.split(' ');
    int month=(months.indexOf(dBase[2].toLowerCase())+1);
    int day=int.tryParse(dBase[1]);
    int year=int.tryParse(dBase[3]);

    DateTime dt= DateTime(year,month,day);
    dt=dt.add(Duration(days: 30));
    DateFormat df=DateFormat('yy:MM:dd');
    return df.format(dt).toString();
  }

  Future<bool> checkFundsOk(String m)async{
    List<String> mList=m.split('/');
    double price=30;
    if(mList.length>=2){
      DataSnapshot snapshot=await kDbref.child(kVariantUploadPriceAddress).once();
      price=double.tryParse(snapshot.value)??35;
      if(price!=35){
        uSetPrefsValue(kVariantUploadPriceKey, price.toString());
      }
    }else{
      DataSnapshot snapshot=await kDbref.child(kUploadPriceAddress).once();
      price=double.tryParse(snapshot.value)??30;
      if(price!=30){
        uSetPrefsValue(kItemUploadPriceKey, price.toString());
      }
    }
    double wallet= double.tryParse(await uGetSharedPrefValue(kWalletKey))??0;
    if(wallet<price){
      showFundWalletDialog(price);
      return false;
    }
    return true;
  }

  Future<bool> isFundsOk(String m) async{
    List<String> mList=m.split('<');
    double price=30;
    if(mList.length>=2){
      price= double.tryParse(await uGetSharedPrefValue(kVariantUploadPriceKey))??35;
    }else{
    price= double.tryParse(await uGetSharedPrefValue(kItemUploadPriceKey))??30;
    }
    double wallet= double.tryParse(await uGetSharedPrefValue(kWalletKey))??0;
    if(wallet<price){
      showFundWalletDialog(price);
      return false;
    }
    return true;
  }

  Future<void> debitUser(String m) async{
    List<String> mList=m.split('<');
    double price=30;
    if(mList.length>=2){
      price= double.tryParse(await uGetSharedPrefValue(kVariantUploadPriceKey))??35;
    }else{
      price= double.tryParse(await uGetSharedPrefValue(kItemUploadPriceKey))??30;
    }
    double wallet= double.tryParse(await uGetSharedPrefValue(kWalletKey))??0;
    if(wallet<price){
      showFundWalletDialog(price);
      throw Exception('Insufficient funds');
    }
    wallet-=price;
    String id=await uGetSharedPrefValue(kIdKey);
    await kDbref.child('cad').child(id).child('w').set(wallet.toString());
    await uSetPrefsValue(kWalletKey, wallet);
  }

  Future<void> testDebitUser() async {
    String m=getCompoundPrice();
    String wallet= await uGetSharedPrefValue(kWalletKey);
    print('wallet b4: $wallet compound-price: $m');
    showProgress(true);
    await debitUser(m);
    showProgress(false);
    String wallet2= await uGetSharedPrefValue(kWalletKey);
    print('wallet after: $wallet2');
  }

  void showFundWalletDialog(double price){
    uShowCustomDialog(context: context, text: 'Insufficient funds! Upload costs \u20a6$price', icon: Icons.account_balance_wallet, iconColor: Colors.brown, buttonList: [['Fund wallet',kLightBlue,(){
      Navigator.pop(context);
      saveAndGotoWallet();
    }]]);
  }

  Future<void> saveItemToDb(MartItem item) async {
    SellerLargeItemsDb sDb = SellerLargeItemsDb();
    await sDb.insertItem(item);
    await Provider.of<PromoModel>(widget.oldContext, listen: false).setWidgetLists(widget.oldContext);
  }

  Future<void> saveAndGotoWallet() async {
    SellerLargeItemsDb sDb = SellerLargeItemsDb();
    MartItem mitem=new MartItem();
    mitem.l=await getItemId();//Item id
    mitem.t=tittle;//tittle
    mitem.d=description;//description
    mitem.s=await getState();//state
    mitem.i=await getSellerId();//seller Id
    mitem.m=getCompoundPrice();//price (m)
    mitem.n=numLeft;//number left
    mitem.q=getDevicePics();//device pics
    mitem.b=allowPay?'t':'f';
    mitem.k=getPicsUrl();//pictures
    mitem.h=subTime;//subscription expiration time
    print('inserting item: $mitem');
    await sDb.insertItem(mitem);
    Navigator.pushNamed(context, '/wallet');
  }

  String getPicsUrl() {
    String pathUrl='';
    for(String v in imageUrls){
      pathUrl+=',$v';
    }
    return pathUrl;
  }

  void setupAllowpay(bool allowPay) {
    if(allowPay){
      paymentMessage='Payment allowed';
    }else{
      paymentMessage='Payment blocked';
    }
    this.allowPay=allowPay;
    setState(() {

    });
  }

  void setImageUrls(String k) {
    if(k.startsWith(',')){
      k=k.substring(1);
    }
    k.split(',').forEach((element) {
      setImageUrl(element);
    });
  }
  void restartAfterUpload(MartItem mitem){
//    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PreviewScreen(justUped: true, martItem: mitem,)));
  }


  void showDeleteItemDialog(){
    String tite=tittle.length>1?tittle:'this item';
    if(filePaths.length>0)
    uShowCustomDialogWithFile(context: context, path: filePaths[0], text: 'Confirm! you are about to delete $tite from Gmart records',
    buttonList: [['confirm delete', Colors.red,(){
      Navigator.pop(context);
      deleteItem();
    }]]);
    else{
      uShowErrorDialog(context, 'Nothing to delete !');
    }
  }
  Future<void> deleteItem() async {
    if(itemId==null ||itemId.isEmpty) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SellerPortalScreen()));
      dispose();
      return;
    }
    showProgress(true);
    try {
      if (imageUrls.isEmpty) {
        SellerLargeItemsDb sDb = SellerLargeItemsDb();
        await sDb.deleteItem(await getItemId()); // DELETE ITEM FROM DB
        showProgress(false);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SellerPortalScreen()));
        dispose();
        return;
      }
      if (!(await uCheckInternet())) {
        showProgress(false);
        uShowNoInternetDialog(context);
        return;
      }
      for (String url in imageUrls) { // DELETE CLOUD PICS IF ANY.
        if (url != null && !url.isEmpty) {
          try {
            await AzSingle().deleteImage(url);
          }catch(e){
            print('storage error: $e');
          }
        }
      }
      try {
        await deleteFromAzsearch(await getItemId());
      }catch(e){
        print('database error: $e');
      }
      SellerLargeItemsDb sDb = SellerLargeItemsDb();
      await sDb.deleteItem(await getItemId()); // DELETE ITEM FROM DB
      await Provider.of<PromoModel>(widget.oldContext, listen: false).setWidgetLists(widget.oldContext);
      showProgress(false);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SellerPortalScreen()));
//      Navigator.pop(context);
    }catch(e){
      showProgress(false);
      print('error: $e');
    }
  }

  Future<void> testUploadToSearch() async {
    showProgress(true);
    MartItem mit=MartItem();
    mit.l=await uGetUniqueId();
    mit.d='bla bla blaokisdjfop';
    await AzSingle().uploadItemToSearchService(mit);
    showProgress(false);
  }



  void goBackToPreview() {
    print('in preview going');
    MartItem mittt= widget.martItem;
//    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
      return PreviewScreen(martItem: mittt,);
    }));
  }

  deleteFromAzsearch(String id) async {
    await AzSingle().deleteFromSearch(id);
  }
}

//      DataSnapshot snapshot = await kDbref.reference().child(uploadPriceAddress).once();
//      if (snapshot == null || snapshot.value == null) {
//        price = double.tryParse(snapshot.value) ?? 35;
//      }else{
//
//      }


