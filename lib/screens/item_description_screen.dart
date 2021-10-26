import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/custom_widgets/confirm_price_pge.dart';
import 'package:ecommerce/custom_widgets/mart_grid_item.dart';
import 'package:ecommerce/custom_widgets/my_button.dart';
import 'package:ecommerce/custom_widgets/nav_button.dart';
import 'package:ecommerce/custom_widgets/rating_widget.dart';
import 'package:ecommerce/custom_widgets/seller_contact_items.dart';
import 'package:ecommerce/custom_widgets/variant_list_item.dart';
import 'package:ecommerce/databases/customer_orders_db.dart';
import 'package:ecommerce/databases/mart_item_db.dart';
import 'package:ecommerce/databases/order_mitems_db.dart';
import 'package:ecommerce/mart_objects/cart_item.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/mart_objects/order_item.dart';
import 'package:ecommerce/mart_objects/small_mitem.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/providers/favorite_provider.dart';
import 'package:ecommerce/screen_models/item_description_model.dart';
import 'package:ecommerce/screens/cart_screen.dart';
import 'package:ecommerce/screens/order_create_screen.dart';
import 'package:ecommerce/screens/order_details_screen.dart';
import 'package:ecommerce/screens/profile_screen.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:http/http.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../utility_functions.dart';
import 'login_screen.dart';

class ItemDescriptionScreen extends StatefulWidget {

  ItemDescriptionScreen({this.heroTag='itemImage',
    this.image='images/img.jpg', this.martItem, this.smallMitem});
  double price=0.0;
  String heroTag;
  String image;
  MartItem martItem;
  SmallMitem smallMitem;

   void changePrice(var v){
    price=double.tryParse(v);
  }

  @override
  ItemDescriptionScreenState createState() => ItemDescriptionScreenState();
}

class ItemDescriptionScreenState extends State<ItemDescriptionScreen> {

  String sellerPNum='';
  String sellerEmail='';
  String image='';
  String itemId='';
  String title='Sample title';
  String description='This is an sample test description This is an sample test description. '
      'This is an sample test  descriptionThis is an sample test description This is an sample test description This is an sample test description This is an sample test description\n';
  String sellerName='Gmart Seller';
  String shopTitle='Contact Seller';
  String variantName='';
  String numOfOrder='0';
  String deliveryAmount2Pay='';
  double price=0;
  MartItem martItem;
  List<Widget> variantsList=[];
  List<Widget> othersList=[];
  List<Widget> picList=[];
  List<String> imPaths=[];
  List<RatingData> ratData= [];

  ItemDescriptionModel _itemDescriptionModel= ItemDescriptionModel();

  bool numProgress=false;
  bool showProgress=false;
  bool hitMax=false;

  double avgRating=0;

  @override
  void initState() {
    martItem=widget.martItem;
    price=widget.price;
    if(martItem!=null){
      widget.smallMitem=SmallMitem.fromMartItem(widget.martItem);
      setupScreenFromLarge();
    }else if(widget.smallMitem!=null){
      setupScreenFromSmall();
    }
    setItemReview();
    // setupItemsBySeller();
    // PaystackPlugin.initialize(
    //     publicKey: kPaystackPubKey);
  }

  @override
  Widget build(BuildContext context) {
    double nCount=1;
    double price = this.price;
    nCount= double.tryParse(numOfOrder)??1;
    price*=nCount;
    print('nCount: $nCount, price $price, ');
    print("seller pic: ${image??widget.smallMitem.P}");
    setVariantsList(martItem!=null && martItem.m!=null?martItem.m:'');
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: FlatButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child: Icon(CupertinoIcons.left_chevron, color: kThemeBlue,size: 20,),
        ),
        title:Text('Gmart $title Details', style: TextStyle(color: kThemeBlue, fontSize: 15, ),) ,
        iconTheme: IconThemeData(color: kThemeOrange, size: 10),
        backgroundColor: Colors.transparent,
      ),
      body: ModalProgressHUD(
        opacity: 0.9,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
        inAsyncCall: showProgress,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
          children: [
                Card(
                child: Stack(
                  alignment: Alignment.topRight,
                  children:[
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(title??'', textAlign: TextAlign.start, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.w900, fontSize: 18),),
                      ),

                      Stack(
                      children: [
                        CarouselSlider(
                            items: picList
                            , options: CarouselOptions(height: 400,
                          enlargeCenterPage: true,
                          viewportFraction: 1.0,
                        )),//                         Hero(
//                      tag: widget.heroTag,
//                        child: Image.network(
//                          image??'',fit: BoxFit.fill,height: 400,width: double.infinity,)),

                        Container(
                          height: 400,
                          alignment: Alignment.bottomRight,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              radius: 0.3,
                              center: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Colors.white,
                                Colors.white,
                                Colors.transparent
                              ]
                            )
                          ),
                          child: TextButton(
                            onPressed: (){
                              toggleFavoriteStatus();
                            },
                              child: Provider.of<FavoriteProvider>(context).isItemIdFavorite(widget.smallMitem.I??'')?
                              Icon(Icons.favorite, color: Colors.redAccent, size: 35, ):
                              Icon(Icons.favorite_border, color: kThemeOrange, size: 35, )
                          ),
                        )
                      ]
                    ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        child: Text(description, textAlign: TextAlign.start, style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w900,           fontSize: 15),),
                      ),
                    ]
                  ),
                    FlatButton(
                        splashColor: kThemeOrange,
                        onPressed: (){
                          shareItem();
                        },
                        child: Icon(Icons.share, size: 20, color: kThemeBlue,))
                  ]
                ),
              ),
                // _getSellerContactInfoWidget(),
                if(ratData.length>0)_getItemReviews(),
                Card(
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:[
                SizedBox(height: 20,),
                // Text('ORDER NOW', textAlign: TextAlign.center,
                //   style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 15),),
                // SizedBox(height: 30,),
                if(this.price>0)Text('\u20a6 ${this.price}', textAlign: TextAlign.center,
                  style: TextStyle(color: kThemeOrange, fontWeight: FontWeight.w900, fontSize: 18),),

                SizedBox(height: 20,),
                if(variantsList.length>0)
                  Text('\t\t\t\ Variants'),
                Container(
                height: variantsList.length>0? 50:0,
                alignment: Alignment.center,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:variantsList,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                ),
              ),
                SizedBox(height: 30,),

                FlatButton(
                    onPressed: (){
                      if(Provider.of<CartProvider>(context, listen:false).isMartItemInCart(itemId))
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>CartScreen()));
                      else
                      showAddToCartDialog();
                    },
                    splashColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                          color: (Provider.of<CartProvider>(context).isMartItemInCart(itemId))? Colors.black: kThemeOrange ,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text((Provider.of<CartProvider>(context).isMartItemInCart(itemId))?'complete order':'Add to Cart', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                    )),
                SizedBox(height: 20,),
              ]
                ),
              ),
                SizedBox(height: 50,),
              ],
            ),
        ),
      ),
    );
  }

  Widget _getItemReviews(){
    return Card(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
    SizedBox(height: 15,),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('Reviews', style: kNavTextStyle.copyWith(color:kThemeBlue, fontWeight: FontWeight.bold, fontSize: 17 ),),
    ),
    if(ratData.length>0)ListTile(
                title: RatingRow(
                  rating: avgRating.toInt(),
                ),
                leading: Text('${avgRating.toString().trim()}', style: kNavTextStyle.copyWith(color:kThemeBlue, fontWeight: FontWeight.bold, fontSize: 30 ),),

                ),
            SizedBox(height: 20,),

            for(RatingData data in ratData)
              Material(
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: ListTile(
                    title: RatingRow(
                      rating: data.rating,
                    ),
                    subtitle: Text(data.message, style: kHintStyle.copyWith(color:kThemeBlue),),
                  ),
                ),
              ),

          ]
      ),
    );
  }

  Future<void> setItemReview() async {
    List<String> revData= (await AzSingle().getItemReviews(widget.smallMitem.I)).split('<');
    int count=0;
    avgRating=0;
    for(String data in revData){
      if(data==null || data.isEmpty)continue;
      List<String> rat= data.split('>');
      if(rat.length!=2)continue;
      RatingData radat=RatingData()
      ..message=rat[1]
      ..rating=int.tryParse(rat[0]);
      if(radat.rating==null || radat.rating==0)continue;
      avgRating+=radat.rating;
      ratData.add(radat);
      count++;
    }
    avgRating/=count;
    setProgress(false);
  }

  Future<void> startOrderSeq() async {
    setProgress(true);
    try {
      // CHECK INTERNET CONNECTION
      if (!(await uCheckInternet())) {
        uShowNoInternetDialog(context);
        setProgress(false);
        return;
      }
      // CHECK IF MARKET IS OPEN
      String marketOpenData= await AzSingle().getMarketStatus();
      print('gotten marketOpenData: $marketOpenData ');
      if (!marketOpenData.contains('yes')) {
        uShowErrorDialog(context,
            'We are very sorry but online transactions are currently unavailable 😥. Please try again soon.');
        setProgress(false);
        return;
      }
      print("passed m-data stage");
      // CHECK IF ITEM IS PAYABLE
      String isItemPayableData= await AzSingle().getItemPayableData(itemId);
      if (!isItemPayableData.toLowerCase().contains('t')) {
        showNoPayDialog();
        setProgress(false);
        return;
      }
      setProgress(false);
      uShowCustomDialogWithImage(context: context,
          icon: 'images/mobileshop.png',
          text: 'We recommend that you contact seller directly for delivery policy confirmation before proceeding with payment.',
              // '\n\nRemember that Gmart guarantees you a refund if your order is not completed.\n\nAlso note that by proceeding, you agree to our terms and conditions as stated in the orders policy section of our website.',
          buttonList: [
            ['Proceed', kThemeBlue, () {
              Navigator.pop(context);
              openOrderCreatePage();
            }
            ],
            // ['View policy', Colors.lightBlueAccent, () {
            //   launchPolicyPage();
            // }
            // ],
            ['Cancel', Colors.black, () {
              Navigator.pop(context);
            },
            ],
          ]);

    }catch(e){
      setProgress(false);
      uShowErrorNotification('Sorry! An unknown error occured.');
      print('pre order errror: ${e.toString()}');
    }
  }

  Future<void> confirmOrderInitiation() async {
    OrderItem mOrder = OrderItem();
    mOrder.i = uGetUniqueId()+(await uGetSharedPrefValue(kIdKey)); //Order ID
    mOrder.t =  martItem.l; //Item ID
    mOrder.n = title;// + ' $variantName'; //Item name
    mOrder.u = numOfOrder; //Item units
    mOrder.p = (widget.price * (double.tryParse(numOfOrder) ?? 1) + double.tryParse(deliveryAmount2Pay)??0)
        .toString(); //order price
    mOrder.s = martItem.i; //Seller ID
    mOrder.c = await uGetSharedPrefValue(kIdKey); //Customer ID
    mOrder.d = await getTodaysDate(); //Order date
    mOrder.k = '1'; //Order status
    mOrder.y = martItem.p; //Seller details
    mOrder.z = await uGetSharedPrefValue(kAdressKey); //Customer details
    uShowCustomOrderDialog(context: context,
        orderItem: mOrder,
        buttonList: [
          ['Proceed', kThemeBlue, () {
            // initiateOrderSequence();
          }
          ],
          ['Cancel', Colors.black, () {
            Navigator.pop(context);
          },
          ],
        ]);
    setProgress(false);
  }

  void showDeliveryChargesDialog(){
    print('price: $price, numOfOrder: $numOfOrder, deliveryAmount2Pay:$deliveryAmount2Pay');
    Dialog errorDialog= Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Colors.white,//Color(0xFFDDDDFF),
      child: Container(
        height: 350,
        width: 200,
        child: Column(
          children: [
            Expanded(child: Image.asset('images/delivery.png', color: kLightBlue, height: 200, width: 200,)),
            Text(
              'Bill: \u20a6 ${price*(double.tryParse(numOfOrder.trim()) ?? 1.0)+ (double.tryParse(deliveryAmount2Pay)??0.0)}',//{price * (double.tryParse(numOfOrder.trim()) ?? 1.0)+ double.tryParse(deliveryAmount2Pay)??0}',//${price * (double.tryParse(numOfOrder) ?? 1.0) + double.tryParse(deliveryAmount2Pay)??0}',
              style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
              textAlign: TextAlign.center,
              onChanged: (string){
              setState(() {
                deliveryAmount2Pay=string.trim();
              });
              },
              decoration: InputDecoration(
                  filled: false,
                  hintText: 'Enter delivery charge (if any).',
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
              keyboardType: TextInputType.number,
                ),
            ),
            SizedBox(height: 30,),
            Container(
              height: 60,
              child: Row(
                children: [
                  Expanded(
                    child: MyButton(text: 'Proceed', buttonColor: kLightBlue, onPressed: (){
                      Navigator.pop(context);
//                      confirmOrderInitiation();
                    },),
                  ),
                  Expanded(
                    child: MyButton(text: 'Cancel', buttonColor: Colors.black, onPressed: (){
                      Navigator.pop(context);
                    }),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
    showGeneralDialog(context: context,
        barrierLabel: 'nongkk',
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 500),
        transitionBuilder: (_, anim, __, child){
          return SlideTransition(position: Tween(begin: Offset(0,-1), end: Offset(0,0)).animate(anim), child: child,);
        },
        pageBuilder: (BuildContext context, _, __)=>(errorDialog)
    );
  }


  // Future<void> debitUser(String price) async {
  //   String uMail= await uGetSharedPrefValue(kMailKey);
  //   double uBill=double.parse(price);
  //   Charge charge = Charge()
  //     ..amount =uBill.toInt()
  //     ..reference = await _getReference(uMail, uBill.toString())
  //   // or ..accessCode = _getAccessCodeFrmInitialization()
  //     ..email =uMail;//'customer@email.com';
  //
  //   CheckoutResponse response = await PaystackPlugin.checkout(
  //     context ,
  //     method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
  //     charge: charge,
  //   );
  //   print('debit user response${response.toString()}');
  // }
  //
  // Future<String> _getReference(String uMail, String uBill) async {
  //   Response response = await get('https://gmartpaystackgateway.azurewebsites.net/api/initiate_kuda_split_transaction?email=${uMail}&amount=${uBill}');
  //   var data= jsonDecode(response.body.toString());
  //   return data['data']['reference'];
  // }

  Future<String> downloadPic(String element) async {
    String url;
    String fileId=getUniqueId();
    element=element.replaceAll(kPicLink, '');
    element=element.replaceAll(kUrlStart, '');
    //CONDITIONS: PIC REFERENCE WAS REPLACED WITH kUrlStart or kPicLink or PICS'S ID WAS STORED DIRECTLY
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

  Future<void> payWithPaystack() async {
//    Charge charge = Charge()
//      ..amount = 10000
//      ..reference = _getReference()
//      ..additionalParameters['split_code']='SPL_pYXBnFif1S'
//    ..email = 'customer@email.com';
//// or ..accessCode = _getAccessCodeFrmInitialization()
//    CheckoutResponse response = await PaystackPlugin.checkout(
//        context,
//        method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
//        charge: charge
//    );
  }

  Future<String> getUnitsLeft() async {
    String nres= await AzSingle().getItemNumleft(itemId);
    return nres;
  }

  Future<String> addItem() async {
    setNumProgress(true);
    if(hitMax){
      setNumProgress(false);
      uShowErrorNotification('No more units available!');
      return numOfOrder;
    }
//   DatabaseReference dbRef= FirebaseDatabase.instance.reference().child('R').child(widget.smallMitem.I).child('n');
//   DataSnapshot snap= await dbRef.once();
    String snap=await getUnitsLeft();

   double d= double.tryParse(snap);
   if(d==null){
     uShowErrorNotification('Sorry! An error occured!');
     setNumProgress(false);
     return numOfOrder;
   }
   double currentNum= double.tryParse(numOfOrder)??0;
   print('snap val ${snap}, d: $d current Num: $currentNum , diff: ${d-currentNum}');
   if(d-currentNum>0){
     numOfOrder=(currentNum+1).toString();
     if(currentNum+1==d)hitMax=true;
   }else{
     hitMax=true;
     uShowErrorNotification('No more units available!');
   }
    setNumProgress(false);
   return numOfOrder;
  }

    Future<String> minusItem() async {
    setNumProgress(true);
   double currentNum= double.tryParse(numOfOrder)??0;
   if(currentNum-1>=0){
     hitMax=false;
     numOfOrder=(currentNum-1).toString();
   }else{
     uShowErrorNotification('Order cannot be any less !');
   }
    setNumProgress(false);
    return numOfOrder;
    }

  Future<String> getTodaysDate() async {
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
    DateFormat df=DateFormat('yy:MM:dd');
    return df.format(dt).toString();
  }

  Future<void> showConfirmOrderDialog(BuildContext context, String id, String itemName) async {

    Dialog promoteDialog= Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: kDialogLight,
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 40,),
            Text('$title $variantName', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            SizedBox(height: 10,),

            SizedBox(height: 40,),
          ],
        )
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

  Future<void> shareItem() async {
    setProgress(true);
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
          title: 'Check this out on Gmart.ng',
          description: 'buy and sell anything!',
          imageUrl: Uri.parse(image)
        ),
      );
      Uri dynamicUrl = await parameters.buildUrl();

      if(await uCheckInternet()) {
        final ShortDynamicLink shortDynamicLink = await parameters
            .buildShortLink();
        dynamicUrl = shortDynamicLink.shortUrl;
      }
      setProgress(false);
      print('dynamic url: ${dynamicUrl.toString()}');
      Share.share('Check out this item on Gmart.ng ${dynamicUrl.toString()}',
          subject: 'Check this out on Gmart.ng');
    }catch(e){
      setProgress(false);
      uShowErrorNotification('An error occured !');
      print('share exception ${e.toString()}');
    }
  }

  void setProgress(bool b){
    setState(() {
      showProgress=b;
    });
  }

  void setNumProgress(bool b){
    setState(() {
      numProgress=b;
    });
  }

  Future<void> setImageList(String itemImages) async {
    if(itemImages.startsWith(',')) itemImages=itemImages.substring(1);
    List<String> filePaths=itemImages.split(',');
    for(String imPath in filePaths){
//      String pic= await uGetPicDownloadUrl(imPath);
      if(imPath.trim().isEmpty)continue;
      String pic= uGetAzurePicUrl(imPath);
      imPaths.add(pic);
      picList.add(
          InteractiveViewer(child: Image.network(pic, fit: BoxFit.cover,))
      );
    }
  }

  Future<void> setupScreenFromLarge() async {
    setProgress(true);
    widget.smallMitem=SmallMitem.fromMartItem(widget.martItem);
    description='';
    sellerName='';
    itemId=widget.smallMitem.I;
    title=widget.smallMitem.N;
    widget.price=double.tryParse(widget.smallMitem.M.split('<')[0]);
    price=double.tryParse(widget.smallMitem.M.split('<')[0]);
    widget.image= uGetAzurePicUrl(widget.smallMitem.P);
    image=  uGetAzurePicUrl(widget.smallMitem.P);
    //kUrlStart+widget.smallMitem.P.replaceAll(kUrlStart, '');
    widget.heroTag=widget.smallMitem.T;
//    widget.image=kUrlStart+widget.martItem.k.split(',')[0].replaceAll(kUrlStart, '');
    print('setting OTHER DETAILS');
    martItem= widget.martItem;

    print('item details: ${martItem}');
    setupItemsBySeller(martItem.i);
    title=martItem.t;

//    ItemDescriptionScreen.price=double.tryParse(widget.martItem.m.split("<")[0]);
    description=martItem.d;
    setupSellerContacts(martItem.p??'');

    await setImageList(martItem.k??'');
    setVariantsList(martItem.m??'');
    print('variant list ${variantsList.length}');
    setProgress(false);
  }

  Future<void> setupScreenFromSmall() async {
//    setProgress(true);
//    description='';
//    sellerName='';
//    itemId=widget.smallMitem.I;
//    title=widget.smallMitem.N;
//    widget.price=double.tryParse(widget.smallMitem.M);
//    widget.image= await uGetPicUrl(widget.smallMitem.P);
//    image= await uGetPicUrl(widget.smallMitem.P);
//    //kUrlStart+widget.smallMitem.P.replaceAll(kUrlStart, '');
//    widget.heroTag=widget.smallMitem.T;
//    setProgress(false);
//    setOtherDetails();

    //AZURE IMPLEMENTATION
    setProgress(true);
    description='';
    sellerName='';
    itemId=widget.smallMitem.I;
    title=widget.smallMitem.N;
    widget.price=double.tryParse(widget.smallMitem.M.split('<')[0]);
    price=double.tryParse(widget.smallMitem.M.split('<')[0]);
    widget.image= uGetAzurePicUrl(widget.smallMitem.P);
    image=  uGetAzurePicUrl(widget.smallMitem.P);
    //kUrlStart+widget.smallMitem.P.replaceAll(kUrlStart, '');
    widget.heroTag=widget.smallMitem.T;
    setProgress(false);
    setOtherDetails();
  }

  Future<void> setOtherDetails() async {
    setProgress(true);
    print('setting OTHER DETAILS');
    martItem= await AzSingle().getLargeItem(widget.smallMitem.I);

    print('item details: ${martItem}');
    setupItemsBySeller(martItem.i);
    title=martItem.t;

//    ItemDescriptionScreen.price=double.tryParse(widget.martItem.m.split("<")[0]);
    description=martItem.d;
    setupSellerContacts(martItem.p??'');

    await setImageList(martItem.k??'');
    setVariantsList(martItem.m??'');
    print('variant list ${variantsList.length}');
    setProgress(false);
  }

  void setVariantsList(String pricesAndVariants) {
    if (!pricesAndVariants.contains("<")) {
      return ;
    }
    List<String> variantsArray = pricesAndVariants.split("<");
    if (variantsArray.length <= 2) {
      return ;
    }
    List<Widget> variantsList = [];
    for (int i = 2; i < variantsArray.length; i++) {
      if(!variantsArray[i].contains('>') && !variantsArray[i].contains(','))continue;
      List variantDetails = variantsArray[i].contains('>')?variantsArray[i].split(">"):variantsArray[i].split(',');
      variantsList.add(
          VariantListItem(title: variantDetails[0],
              price:variantDetails[1],
            selected: variantName!=null&&variantName.isNotEmpty?variantDetails[0].toString().contains(variantName):false,
            onPressedFunc: (){
              changeVariant(amount: variantDetails[1], vName: variantDetails[0]);
            },));
    }
    this.variantsList= variantsList;
  }

  void changeVariant({String amount, String vName}){
    // widget.price=double.parse(amount);
    price=double.parse(amount);
    variantName=vName;
    print('vName: $vName, vAmount: $amount');
    if(this.mounted)
      setState(() {
      });
  }

  void setupSellerContacts(String sellerProf){
    if(!sellerProf.contains('<'))return;
    List<String> sList= sellerProf.split('<');
    if(sList.length<2) return;
    sellerEmail=sList[0];
    sellerPNum=sList[1];
  }

  Future<void> setupItemsBySeller([String sellerId]) async {
    if(sellerId==null)sellerId=widget.smallMitem.I;
    List<MartItem> largeItems= await AzSingle().getSellerItems(sellerId,);
    print('seller items list Length: ${largeItems.length}');
    List<Widget> itemList=[];
    for(MartItem mit in largeItems){
      if(widget.smallMitem!=null&&mit.l==widget.smallMitem.I)continue;
      SmallMitem smit=mit.getSmallUpload();
      smit.I=mit.l;
      othersList.add(MartGridItem(smitem: smit, onPressedFunc: (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
          return ItemDescriptionScreen(heroTag: smit.I, smallMitem: smit,);
        }));
      },));
    }
    setState(() {
      print('seller items widgets Length: ${othersList.length}');
    });
  }

  Future<void> toggleFavoriteStatus() async {
    if(Provider.of<FavoriteProvider>(context, listen:false).isItemIdFavorite(widget.smallMitem.I)){
      Provider.of<FavoriteProvider>(context, listen:false).removeItemFromFavorite(widget.smallMitem.I);
    }else{
       await saveItemToDb();
      Provider.of<FavoriteProvider>(context, listen:false).addItemToMap(widget.smallMitem);
    }
  }

  void callSeller(){
    launch("tel:$sellerPNum");
  }

  void smsSeller(){
    launch("sms:$sellerPNum");
  }

  void whatsappSeller(){
    String phoneNum2Use=sellerPNum!=null&&sellerPNum.trim().isNotEmpty?sellerPNum:'08065023649';
    if(!phoneNum2Use.startsWith('+')){
      phoneNum2Use='+234'+phoneNum2Use.substring(1);
    }
    if(Platform.isAndroid ){
      launch('https://wa.me/$phoneNum2Use');
    }else if(Platform.isIOS){
      launch('https://api.whatsapp.com/send?phone=$phoneNum2Use');
    }
//    launch('https://api.whatsapp.com/send?phone=$sellerPNum');
  }

  Future<void> emailSeller() async{
    final Uri params = Uri(
      scheme: 'mailto',
      path: '$sellerEmail',
    );
    String  url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print( 'Could not launch $url');
      uShowErrorNotification('Sorry! An error occured.');
    }
  }

  void showSetAddressDialog() {
    uShowCustomDialog(context: context,icon: Icons.error, iconColor: Colors.red,
        text: 'You need to set your address.',
        buttonList: [['Set Address', Colors.red,
                (){
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder:(context)=>ProfileScreen()));
          }]
        ]);
  }

  void openOrderDisplayPage(OrderItem mOrder) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderDetailsScreen(mOrder, isNew:true)));
  }

  void showNoPayDialog() {
    uShowCustomDialog(context: context,icon: Icons.remove_shopping_cart, iconColor: Colors.red,
        text: 'Sorry! Seller disabled online purchases for this item',
   );
  }

  saveItemToDb() async {
    LargeMartItemsDb ldb= LargeMartItemsDb();
    List<String> picList=martItem.k.split(',');
    // if(await uCheckInternet()) {
    //   martItem.q='';
    //   for (String element in picList) {
    //     if (element
    //         .trim()
    //         .isNotEmpty) {
    //       // DOWNLOAD PICTURE.
    //       try {
    //         martItem.q += ',' + (await AzSingle().downloadAzurePic(element));
    //       } catch (e) {
    //         print('download pic error: $e');
    //       }
    //     }
    //   }
    //   martItem.k = martItem.q;
    // }
    await ldb.insertItem(martItem);
  }

  Future<void> launchPolicyPage() async {
    await launch(kOnlinePolicyPage);
  }

  Future<void> openOrderCreatePage() async {
    setProgress(true);
    OrderItem mOrder = OrderItem();
    mOrder.i = uGetUniqueId()+(await uGetSharedPrefValue(kIdKey)); //Order ID
    mOrder.t =  martItem.l; //Item ID
    mOrder.n = title + ' $variantName'; //Item name
    mOrder.u = numOfOrder; //Item units
    mOrder.p = widget.price.toString();
        // (widget.price * (double.tryParse(numOfOrder) ?? 1) + double.tryParse(deliveryAmount2Pay)??0)
        // .toString(); //order price
    mOrder.s = martItem.i; //Seller ID
    mOrder.c = await uGetSharedPrefValue(kIdKey); //Customer ID
    mOrder.d = await getTodaysDate(); //Order date
    mOrder.k = '1'; //Order status
    mOrder.y = martItem.p; //Seller details
    mOrder.z = await uGetSharedPrefValue(kAdressKey); //Customer details
    setProgress(false);
    Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderCreateScreen(martItem: this.martItem,orderItem: mOrder,)));

  }

  _getSellerContactInfoWidget() {
    return Card(
      child: Column(
        children: [
          Text(sellerName, textAlign: TextAlign.start, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18),),
          SizedBox(height: 20,),
          Text( shopTitle, textAlign: TextAlign.start, style: TextStyle(color: Colors.black,
              fontFamily: 'Pacifico',
              fontWeight: FontWeight.w200, fontSize: 12),),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 16,),
              SellerContactWidget(color: Colors.black, label: 'Call', icon: CupertinoIcons.phone,
                function:(){
                  callSeller();
                },
              ),
              SizedBox(width: 16,),
              SellerContactWidget(color: Colors.blueAccent, label: 'Text', icon: CupertinoIcons.chat_bubble_text,
                function: (){
                  smsSeller();
                },),
              SizedBox(width: 16,),
              SellerContactWidget(color: Colors.red, label: 'Email', icon: CupertinoIcons.mail, function: (){
                emailSeller();
              }, ),
              SizedBox(width: 16,),
              CircleAvatar(
                radius: 16,
                child: GestureDetector(
                    onTap: (){
                      whatsappSeller();
                    },
                    child: Image.asset('images/whatsapp.png', height: 26,)),backgroundColor: Colors.green,),
              SizedBox(width: 16,),
            ],
          ),
          SizedBox(height: 20,),
        ],
      ),
    );
  }

  void showAddToCartDialog() {
    //Add item to cart
    // Create Dialog with variants if available
     Widget createCartItemPage =  ConfirmPricePage(
      numOfOrder: numOfOrder,
      addItemFunction: addItem,
      minusItemFunction: minusItem,
      numProgress: numProgress,
      variantsData: martItem.m,
      changeVariant: changeVariant,
       price: price,
       uploadToCart:(){
          uploadItemToCart();
       },
    );
     Dialog errorDialog= Dialog(
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
       backgroundColor: kDialogLight,
       child: Container(
         height: 350,
         child: createCartItemPage,
       ),
     );
     showGeneralDialog(context: context,
         barrierLabel: 'randomsxsshjsjhshxxx',
         barrierDismissible: true,
         barrierColor: Colors.black.withOpacity(0.5),
         transitionDuration: Duration(milliseconds: 500),
         transitionBuilder: (_, anim, __, child){
           return SlideTransition(position: Tween(begin: Offset(-1,0), end: Offset(0,0)).animate(anim),
             child: child,);
         },
         pageBuilder: (BuildContext context, _, __)=>(errorDialog)
     );
  }

  Future<void> uploadItemToCart() async {
    print('price:$price, numOfOrder:$numOfOrder');
    if(this.price==null || this.price==0|| ((double.tryParse(numOfOrder)??0)==0)){
      String message= 'Invalid bill detected.\nPlease ensure that a valid number of units was selected. ';
      uShowErrorNotification(message);
      return;
    }

    print('variantName: $variantName');
    if(variantsList.length>=1 && (variantName==null||variantName.trim().isEmpty||variantName.trim()=='null')){
      uShowErrorDialog(context,'No variant selected.\nPlease select a variant.');
      return;
    }
    setProgress(true);
    try {
      String sName = await uGetSharedPrefValue(kLnameKey);
      String fName = await uGetSharedPrefValue(kFnameKey);
      String sAddress = await uGetSharedPrefValue(kAdressKey);
      String phoneNum = await uGetSharedPrefValue(kPhoneKey);
      widget.martItem = martItem;
      CartItem mCart = CartItem();
      mCart.i = uGetUniqueId() + (await uGetSharedPrefValue(kIdKey)); //Order ID
      mCart.t = widget.martItem.l; //Item ID
      mCart.n = title + ' $variantName'; //Item name
      mCart.u = numOfOrder; //Item units
      mCart.p = (price * (double.tryParse(numOfOrder) ?? 1) +
          (double.tryParse(deliveryAmount2Pay) ?? 0))
          .toString(); //order price
      mCart.s = martItem.i; //Seller ID
      mCart.c = await uGetSharedPrefValue(kIdKey); //Customer ID
      mCart.d = await getTodaysDate(); //Order date
      mCart.k = '1'; //Order status
      mCart.y = martItem.p; //Seller details
      mCart.z = '$fName $sName<$phoneNum<' + sAddress;

      await AzSingle().uploadCartItem(mCart);
      await Provider.of<CartProvider>(context, listen: false).addItemToMap(mCart);
      uShowOkNotification('Item added to cart.');
      Navigator.pop(context);
    }catch(e, t){
      uShowErrorNotification('An error occured');
      print ('add cart error: $e, trace: $t');
    }
    setProgress(false);
  }
}

class RatingData {
  int rating;
  String message;
}

