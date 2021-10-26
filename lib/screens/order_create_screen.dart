import 'dart:io';

import 'package:ecommerce/custom_widgets/confirm_price_pge.dart';
import 'package:ecommerce/providers/delivery_charge_provider.dart';
import 'package:ecommerce/screens/pay_for_item_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/custom_widgets/my_button.dart';
import 'package:ecommerce/custom_widgets/seller_contact_items.dart';
import 'package:ecommerce/custom_widgets/variant_list_item.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/mart_objects/order_item.dart';
import 'package:ecommerce/mart_objects/user_info_object.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderCreateScreen extends StatefulWidget {
  OrderItem orderItem;
  MartItem martItem;

  OrderCreateScreen({this.orderItem,this.martItem});

  @override
  _OrderCreateScreenState createState() => _OrderCreateScreenState();
}

class _OrderCreateScreenState extends State<OrderCreateScreen> {
  String sellerPNum='';
  String sellerEmail='';
  String image='';
  String itemId='';
  String title='Sample title';
  String description='This is an sample test description This is an sample test description. This is an sample test  descriptionThis is an sample test description This is an sample test description This is an sample test description This is an sample test description\n';
  String sellerName='Gmart Seller';
  String shopTitle='Contact Seller';
  String variantName='';
  String numOfOrder='0';
  String deliveryAmount2Pay='';
  String _chosenPic='';
  String shipping='';
  String phoneNum;
  String email;
  String fName;
  String sName;
  String state;
  String sAddress;
  String name='';
  bool profileInEditMode=false;
  double price=0;
  MartItem martItem;
  TextEditingController shippingPriceController;
  List<Widget> userInfoWidgets=[];
  List<Widget> variantsList=[];
  List<Widget> othersList=[];
  List<Widget> picList=[];
  List<String> imPaths=[];

  bool numProgress=false;
  bool showProgress=false;
  bool hitMax=false;
  int pageCount=0;

  PageController pageViewController=PageController(
      initialPage: 0
  );

  ValueNotifier currentPageNotifier=ValueNotifier<int>(0);

  @override
  void initState() {
    setDetails();
    _initDeliveryService();
  }

  @override
  Widget build(BuildContext context) {
    double nCount=1;
    double price = this.price * (double.tryParse(numOfOrder) ?? 0.0) +
        (double.tryParse(deliveryAmount2Pay)??0.0);
    nCount= double.tryParse(numOfOrder)??1;
    // price*=nCount;
    print('nCount: $nCount, price $price, main price: ${this.price}, pagecount: $pageCount, main price: ${(widget.martItem.m.split('<')[0])} ');
    if(pageCount==0)setVariantsList(widget.martItem!=null &&widget.martItem.m!=null?widget.martItem.m:'');
    return Scaffold(
    appBar: AppBar(
      title: Text('Create order'),
      elevation: 0,
    ),
    body: ModalProgressHUD(
      inAsyncCall: showProgress,
      child: SingleChildScrollView(
        child: Column(
            children:[
              Container(
                height: profileInEditMode?0:130,
                child: Row(
                    children:[ ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: Image.network(image, fit: BoxFit.cover, height: 100, width: 100,),
                    ),
                     SizedBox(width: 10,),
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         SizedBox(height: 20,),
                         Text(title??'', textAlign: TextAlign.start, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.w900, fontSize: 18),),
                         SizedBox(height: 10,),
                         if(variantName!=null&& variantName.trim().isNotEmpty) Text('Variant: $variantName', textAlign: TextAlign.start, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.w500, fontSize: 15),),
                         SizedBox(height: 10,),
                         Text('Units: $numOfOrder', textAlign: TextAlign.start, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.w500, fontSize: 15),),
                         SizedBox(height: 10,),
                         Text('Bill: \u20a6 ${this.price * (double.tryParse(numOfOrder) ?? 0.0) + (double.tryParse(
                            Provider.of<DeliveryChargeProvider>(context).deliveryAmount
                         )??0.0)}', textAlign: TextAlign.start, style: TextStyle(color: kThemeOrange, fontWeight: FontWeight.w900, fontSize: 15),),
                       ],
                     ),
                    ]
                    ),
              ),
              SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CirclePageIndicator(currentPageNotifier: currentPageNotifier,dotColor: Colors.grey.shade300 ,selectedDotColor: kThemeBlue, itemCount: 4),
              ),
              SizedBox(height: 10,),
              if(pageCount==0)Text('Order Amount', textAlign: TextAlign.center, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.w900, fontSize: 18),),
              if(pageCount==1)
                _getDeliveryTitle(),
              if(pageCount==2)
                Text('Shipping Price.', textAlign: TextAlign.center, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.w900, fontSize: 18),),
              SizedBox(height: 10,),
              Container(
                height: MediaQuery.of(context).size.height*(profileInEditMode?0.7:0.5),
                child: Container(
                  // controller: pageViewController,
                  // onPageChanged: (n){
                  //   pageCount=n;
                  // },
                  // physics: NeverScrollableScrollPhysics(),
                child: _getCurrentPage()
                ),
              ),
            ]
          ),
      ),
    ),
    floatingActionButton: Padding(
      padding: const EdgeInsets.only(left:28.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // if(pageCount>0)
            FloatingActionButton(
            backgroundColor: kThemeBlue,
            child: Icon(Icons.arrow_back, color: Colors.white,),
            onPressed: (){
              print('moving back');
              moveBack();
            },
          ),
          // SizedBox(width: MediaQuery.of(context).size.width*0.7,),
          FloatingActionButton(
            backgroundColor: kThemeBlue,
            child: Icon(Icons.arrow_forward, color: Colors.white,),
            onPressed: (){
              moveForward();
            },
          ),]
      ),
    ),
    );
  }

  void setVariantsList(String pricesAndVariants) {
    print('pricesAndVariants: $pricesAndVariants');
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
            price:variantDetails[1], selected: variantName!=null&&variantName.isNotEmpty?variantDetails[0].toString().contains(variantName):false,
            onPressedFunc: (){
              changeVariant(amount: variantDetails[1], vName: variantDetails[0]);
            },));
    }
    this.variantsList= variantsList;
  }

  void changeVariant({String amount, String vName}){
    price=double.parse(amount);
    price=double.parse(amount);
    variantName=vName;
    print('vName: $vName, vAmount: $amount');
    if(this.mounted)
      setState(() {
      });
  }

  void callSeller(){
    launch("tel:$sellerPNum");
  }

  void smsSeller(){
    launch("sms:$sellerPNum");
  }

  void whatsappSeller(){

    // String phoneNum2Use=sellerPNum!=null&&sellerPNum.trim().isNotEmpty?sellerPNum:'08065023649';
    String phoneNum2Use=sellerPNum!=null&&sellerPNum.trim().isNotEmpty?sellerPNum:'';
    if(!phoneNum2Use.startsWith('+234')){
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

  Future<void> addItem() async {
    setNumProgress(true);
    if(hitMax){
      setNumProgress(false);
      uShowErrorNotification('No more units available!');
      return;
    }
    String snap=await getUnitsLeft();

    double d= double.tryParse(snap);
    if(d==null){
      uShowErrorNotification('Sorry! An error occured!');
      setNumProgress(false);
      return;
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
  }

  Future<void> minusItem() async {
    setNumProgress(true);
    double currentNum= double.tryParse(numOfOrder)??0;
    if(currentNum-1>=0){
      hitMax=false;
      numOfOrder=(currentNum-1).toString();
    }else{
      uShowErrorNotification('Order cannot be any less !');
    }
    setNumProgress(false);
  }

  void setNumProgress(bool b){
    setState(() {
      numProgress=b;
    });
  }

  void setProgress(bool b){
    setState(() {
      showProgress=b;
    });
  }

  Future<String> getUnitsLeft() async {
    String nres= await AzSingle().getItemNumleft(itemId);
    return nres;
  }

  handleBill(String amount) {
    this.deliveryAmount2Pay=amount;
    shipping=amount;
    Provider.of<DeliveryChargeProvider>(context,listen: false).setDeliveryNotifier(amount);
  }

  Future<List<Widget>> getUserDetailsWidgets() async {
    SharedPreferences sp=await SharedPreferences.getInstance();
    List payMethodList=[
      UserInfoObjects(CupertinoIcons.person, fName??'', 'First name'),
      UserInfoObjects(CupertinoIcons.person, sName??'', 'Last name'),
      UserInfoObjects(CupertinoIcons.mail, email??'', 'Email'),
      UserInfoObjects(CupertinoIcons.phone, phoneNum??'', 'Phone number'),
      UserInfoObjects(CupertinoIcons.location, state??'', 'State'),
    ];
    if(sp.containsKey(kAdressKey) && sp.getString(kAdressKey).length>0) {
      payMethodList.add(UserInfoObjects(CupertinoIcons.location_solid, sAddress ?? '', 'Address'));
    }
    List<Widget> res=[];
    int i= payMethodList.length-1;

    for(UserInfoObjects item in payMethodList){
      res.add(TextButton(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          child: Column(
              children: [
                ListTile(
                  leading: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kLightBlue,
                      ),
                      child: Icon(item.iconData, color: Colors.white,)),
                  title: Text(item.tittle, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.bold),),
                  subtitle: Text(item.info, style: TextStyle(color: kLightBlue, fontSize: 10),),
                  tileColor: Colors.white,
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: i!=0?kLightBlue: Colors.transparent,
                  margin: EdgeInsets.symmetric(horizontal: 25, vertical: 3),
                )
              ]
          ),
        ),
      ));
      i--;
    }
    // res.insert(0, TextButton(onPressed: enableEdit,
    //     child: Icon(Icons.edit, color: kThemeBlue,)));
    return res;
  }

  Future<void> setDetails() async {
    setProgress(true);
    try {
      print('entering item: ${widget.martItem}');
      print('entering order item: ${widget.orderItem}');
      martItem = widget.martItem;
      description = '';
      sellerName = '';
      itemId = widget.martItem.l;
      title = widget.martItem.t;
      price = double.tryParse(widget.martItem.m.split('<')[0]);
      image = uGetAzurePicUrl(
          widget.martItem.k.split(',').firstWhere((element) => element !=
              null && element
              .trim()
              .isNotEmpty));
      await setProfileFromSp();
      userInfoWidgets = await getUserDetailsWidgets();
    }catch(e){
      print('goto pay error: $e');
      uShowErrorDialog(context, 'An unexpected error occured.');
    }
    setProgress(false);
  }

  enableEdit() {
    setState(() {
      profileInEditMode=true;
    });
  }

  disableEdit() async {
    await setProfileFromSp();
    setState(() {
      profileInEditMode=false;
    });
  }

  keepProfile() async {
    setProgress(true);
    userInfoWidgets=await getUserDetailsWidgets();
    setState(() {
      showProgress=false;
      profileInEditMode=false;
    });
  }
  handleAddressChange(String p1) {
      sAddress = p1;
  }

  handleFnameChange(String p1) {
    fName=p1;
  }

  handleSnameChange(String p1) {
    sName=p1;
  }

  handlePhoneNumChange(String p1) {
    phoneNum=p1;
  }

  handleStateChange(int dex) {
    setState(() {
      state = kStateList[dex].value.toString();
    });
  }

  setProfileFromSp() async {
     email= await uGetSharedPrefValue(kMailKey);
     fName=await uGetSharedPrefValue(kFnameKey);
     sName=await uGetSharedPrefValue(kLnameKey);
     state=await uGetSharedPrefValue(kStateKey);
     sAddress=await uGetSharedPrefValue(kAdressKey);
     phoneNum=await uGetSharedPrefValue(kPhoneKey);
     name='';
  }

  Future<void> initiateOrderSequence() async {
    Navigator.pop(context);
    setProgress(true);
    try {
      String address = await uGetSharedPrefValue(kAdressKey);
      OrderItem mOrder = OrderItem();
      mOrder.i = uGetUniqueId()+(await uGetSharedPrefValue(kIdKey)); //Order ID
      mOrder.t =  martItem.l; //Item ID
      mOrder.n = title + ' $variantName'; //Item name
      mOrder.u = numOfOrder; //Item units
      mOrder.p = (price * (double.tryParse(numOfOrder) ?? 1) + double.tryParse(deliveryAmount2Pay)??0).toString(); //Order price
      mOrder.s = martItem.i; //Seller ID
      mOrder.c = await uGetSharedPrefValue(kIdKey); //Customer ID
      mOrder.d = await getTodaysDate(); //Order date
      mOrder.k = '1<${mOrder.d}'; //Order status
      mOrder.y = martItem.p; //Seller details
      mOrder.z = (await uGetSharedPrefValue(kAdressKey))+ '<'+(await uGetSharedPrefValue(kPhoneKey)); //Customer details
      OrderItem largeUpload = mOrder.getLargeUpload();

      String itemId = largeUpload.i;
      largeUpload.i = '';

      // await debitUser(mOrder.p);// DEBIT USER WITH PAYSTACK

      //UPLOAD ITEM
//      await FirebaseDatabase.instance.reference().child(kLargeOrdersPath).child(
//          itemId).set(largeUpload.toMap());
//      //UPLOAD COMPRESSED ITEM with KEY as ORDER-ID and value as SELLER-ID
//      await FirebaseDatabase.instance.reference().child(kSmallOrdersPath).child(itemId).set(mOrder.s);
//       await AzSingle().uploadOrder(mOrder);
//
//       //SAVE ITEM
//       CustomerOrdersDb cdb = CustomerOrdersDb();
//       await cdb.insertItem(mOrder);
//
//       // DOWNLOAD PICTURE AND SAVE ORDER ITEM TO DB
//       String picPath = await AzSingle().downloadAzurePic(imPaths[0]);
//       MartItem saveItem = martItem;
//       saveItem.k = picPath;
//       OrderItemsDb odb = OrderItemsDb();
//       await odb.insertItem(saveItem);
//
//       //TODO: UPDATE USER ADDRESS
//       await kDbref.child('cad').child(mOrder.c).child('a').set(address);
//
//       // REDUCE ONLINE ORDER AMOUNT
// //      DatabaseReference dbRef= FirebaseDatabase.instance.reference().child('R').child(widget.smallMitem.I).child('n');
// //      DataSnapshot snap= await dbRef.once();
// //      double d= double.tryParse(snap.value.toString())??0;
// //      d-=double.tryParse(numOfOrder)??1;
//       String snap = await AzSingle().getItemNumleft(widget.smallMitem.I);
//       double d= double.tryParse(snap)??0;
//       d-=double.tryParse(numOfOrder)??1;
//       await AzSingle().setNumLeft(widget.smallMitem.I, d.toString());
//
//       setProgress(false);
//       openOrderDisplayPage(mOrder);

    }catch(e){
      setProgress(false);
      uShowErrorNotification('Sorry! an error occured. Please try again later');
      print('initiate upload exception ${e.toString()}');
    }
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

  Future<void> moveForward() async {
    if(pageCount+1>=3) {
      launchOrderPayment();
      return;
    }

    if(pageCount+1==1){// Moving from units/variant selection
      double units= double.tryParse(numOfOrder)??0;
      if(this.price==null || this.price==0||units==0){
        String message= 'Invalid bill detected.\nPlease ensure that a valid number of units was selected. ';
        uShowErrorDialog(context,message);
        return;
      }
      // if(variantsList.length>=1 && (variantName==null||variantName.trim().isEmpty||variantName.trim()=='null')){
      //   uShowErrorDialog(context,'No variant selected.\nPlease select a variant.');
      //   return;
      // }
    }
    if(pageCount+1==2){///Moving from profile screen
      if(sName==null || sName.trim().isEmpty|| sName.toString().trim().toLowerCase()=='null'){
        uShowErrorDialog(context, 'Invalid last name detected.');
        return;
      }
      if(fName==null || fName.trim().isEmpty|| fName.toString().trim().toLowerCase()=='null'){
        uShowErrorDialog(context, 'Invalid first name detected.');
        return;
      }
      if(sAddress==null || sAddress.trim().isEmpty|| sAddress.toString().trim()=='null' ){
        uShowErrorDialog(context, 'Invalid address detected.');
        return;
      }
      if(phoneNum==null || phoneNum.trim().isEmpty|| phoneNum.toString().trim()=='null' ){
        uShowErrorDialog(context, 'No phone number detected.');
        return;
      }
      if(profileInEditMode){
        // ('Delivery details not saved');
        setState(() {
          profileInEditMode=false;
        });
      }
    }
    pageCount+=1;
    currentPageNotifier.value=pageCount;
    currentPageNotifier.notifyListeners();
    // pageViewController.jumpToPage(pageCount);
    // pageViewController.animateToPage(pageCount, duration: Duration(milliseconds: 100), curve: Curves.easeIn);
    setProgress(false);
  }

  Future<void> moveBack() async {

    if(profileInEditMode){
      uShowErrorNotification('Delivery details not saved');
      setState(() {
      profileInEditMode=false;
    });
    }
    pageCount-=1;
    currentPageNotifier.value=pageCount;
    currentPageNotifier.notifyListeners();
    // pageViewController.jumpToPage(pageCount);
    // pageViewController.animateToPage(pageCount, duration: Duration(milliseconds: 100), curve: Curves.easeIn);
    setProgress(false);
  }

  Future<void> launchOrderPayment() async {
    double units= double.tryParse(numOfOrder)??0;
    if(this.price==null || this.price==0||units==0){
      String message= 'Invalid bill detected. Please ensure that a valid number of units was selected. ';
      if(variantsList.length>=1)message+='Also ensure that a variant was selected';
      uShowErrorDialog(context,message);
      return;
    }
    if(sAddress==null || sAddress.trim().isEmpty|| sAddress.toString().trim()=='null' ){
      uShowErrorDialog(context, 'Invalid address detected.');
      return;
    }
    if(phoneNum==null || phoneNum.trim().isEmpty|| phoneNum.toString().trim()=='null' ){
      uShowErrorDialog(context, 'No phone number detected.');
      return;
    }
    setProgress(true);
    OrderItem mOrder = OrderItem();
    mOrder.i = uGetUniqueId()+(await uGetSharedPrefValue(kIdKey)); //Order ID
    mOrder.t =  widget.martItem.l; //Item ID
    mOrder.n = title + ' $variantName'; //Item name
    mOrder.u = numOfOrder; //Item units
    mOrder.p = (price * (double.tryParse(numOfOrder) ?? 1) +(double.tryParse(deliveryAmount2Pay)??0))
        .toString(); //order price
    mOrder.s = martItem.i; //Seller ID
    mOrder.c = await uGetSharedPrefValue(kIdKey); //Customer ID
    mOrder.d = await getTodaysDate(); //Order date
    mOrder.k = '1'; //Order status
    mOrder.y = martItem.p; //Seller details
    mOrder.z = '$fName $sName<$phoneNum<'+sAddress;//await uGetSharedPrefValue(kAdressKey); //Cust
    setProgress(false);
    Navigator.push(context, MaterialPageRoute(builder: (context) =>
          PayForItemScreen(martItem: martItem, orderItem: mOrder,phoneNum: phoneNum, sAddress: sAddress,)));
  }

  Widget _getDeliveryTitle() {
    if(profileInEditMode) {
     return Container(
       height: 40,
       child: Row(
         children: [
           Expanded(
               child: MyButton(text: 'cancel', onPressed:disableEdit, buttonColor: Colors.black, )),
           Text('Edit Delivery Details', textAlign: TextAlign.center,
            style: TextStyle(
                color: kThemeBlue, fontWeight: FontWeight.w900, fontSize: 18),),
           Expanded(child: MyButton(text: 'save', onPressed:keepProfile, buttonColor: kLightBlue, ))]),
     );
    }
    return Container(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(),
            Text('Edit Delivery Details', textAlign: TextAlign.center,
              style: TextStyle(
                  color: kThemeBlue, fontWeight: FontWeight.w900, fontSize: 18),),
            TextButton(child: Icon(Icons.edit, color: kThemeBlue,),onPressed: enableEdit,)])
    );

  }

  _getCurrentPage() {
   // if(pageCount==0) return ConfirmPricePage(
   //    numOfOrder: numOfOrder,
   //    addItemFunction: (){addItem();},
   //    minusItemFunction: (){minusItem();},
   //    numProgress: numProgress,
   //    variantsList: variantsList,
   //  );
   if(pageCount==1) return AddressPage(
    phoneNum: phoneNum,
    email: email,
    fName: fName,
    sName: sName,
    state: state,
    sAddress: sAddress,
    name: name,
    inEditMode: profileInEditMode,
    userInfoWidgets: userInfoWidgets,
    enableEdit: enableEdit,
    disableEdit: disableEdit,
    keepProfile: keepProfile,
    handleAddressChange: handleAddressChange,
    handleFnameChange: handleFnameChange,
    handleSnameChange: handleSnameChange,
    handlePhoneNumChange: handlePhoneNumChange,
    handleStateChange: handleStateChange);
   if(pageCount==2) return  ShippingPricePage(
    sellerName: sellerName,
    shopTitle: shopTitle,
    shipping: deliveryAmount2Pay,
    shippingPriceController: this.shippingPriceController,
    handleBill: handleBill,
    callSeller: (){callSeller();},
    whatsappSeller: (){whatsappSeller();},
    emailSeller: (){emailSeller();},
    smsSeller: (){smsSeller();},
    );
  }

  void _initDeliveryService() {
    shippingPriceController= TextEditingController(text: deliveryAmount2Pay);
    Provider.of<DeliveryChargeProvider>(context,listen: false).setDeliveryNotifier('');
  }

}


class ShippingPricePage extends StatelessWidget {


  ShippingPricePage({@required this.sellerName,@required this.shopTitle,
    @required this.handleBill,@required this.callSeller,@required this.whatsappSeller,
    @required this.emailSeller, @required this.smsSeller, @required this.shipping,
    @required this.shippingPriceController,});
  TextEditingController shippingPriceController;
  String sellerName;
  String shopTitle;
  String shipping='';
  Function callSeller;
  Function smsSeller;
  Function emailSeller;
  Function whatsappSeller;
  Function(String) handleBill;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Container()// Image.asset('images/delivery.png', color: kLightBlue, height: 70, width: 70,),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: shippingPriceController,
                textAlign: TextAlign.center,
                onChanged:handleBill,
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
                style: TextStyle(color: kThemeBlue,fontWeight: FontWeight.w500, fontSize: 15),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 10,),
            Text(sellerName??'', textAlign: TextAlign.start, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18),),
            Text( shopTitle, textAlign: TextAlign.start, style: TextStyle(color: Colors.black,
                fontFamily: 'Pacifico',
                fontWeight: FontWeight.w200, fontSize: 12),),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 16,),
                SellerContactWidget(color: Colors.black, label: 'Call', icon: CupertinoIcons.phone,
                  function:callSeller,
                ),
                SizedBox(width: 16,),
                SellerContactWidget(color: Colors.blueAccent, label: 'Text', icon: CupertinoIcons.chat_bubble_text,
                  function: smsSeller,),
                SizedBox(width: 16,),
                SellerContactWidget(color: Colors.red, label: 'Email', icon: CupertinoIcons.mail, function: emailSeller, ),
                SizedBox(width: 16,),
                CircleAvatar(
                  radius: 16,
                  child: GestureDetector(
                      onTap: whatsappSeller,
                      child: Image.asset('images/whatsapp.png', height: 26,)),backgroundColor: Colors.green,),
                SizedBox(width: 16,),
              ],
            ),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }
}

class AddressPage extends StatelessWidget {

  AddressPage({@required this.phoneNum, @required this.email, @required  this.fName, @required this.sName, @required this.state,@required  this.sAddress, @required this.name, @required this.inEditMode,@required  this.userInfoWidgets, @required  this.enableEdit, @required this.disableEdit, @required  this.handleAddressChange,@required  this.handleFnameChange,@required  this.handleSnameChange,@required  this.handlePhoneNumChange, @required this.handleStateChange, @required this.keepProfile});

  String phoneNum;
  String email;
  String fName;
  String sName;
  String state;
  String sAddress;
  String name='';
  bool inEditMode=false;
  List<Widget> userInfoWidgets=[];
  Function enableEdit;
  Function disableEdit;
  Function keepProfile;
  Function(String) handleFnameChange;
  Function(String) handleSnameChange;
  Function(String) handlePhoneNumChange;
  Function(String) handleAddressChange;
  Function(int) handleStateChange;

  @override
  Widget build(BuildContext context) {
    if(inEditMode) {
      return SingleChildScrollView(
        child: Column(
          children: [
            // SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: TextEditingController(text: fName),
                  style: kInputTextStyle,
                  textAlign: TextAlign.start,
                  maxLength: 10,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10)
                  ],
                  onChanged:handleFnameChange,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    filled: true,
                    prefixIcon: Icon(
                      CupertinoIcons.person, color: kThemeBlue,),
                    fillColor: Colors.white,
                    labelText: 'Input first name',
                    hintStyle: kHintStyle,
                    border: kInputOutlineBorder,
                  )
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: TextEditingController(text: sName),
                  style: kInputTextStyle,
                  textAlign: TextAlign.start,
                  maxLength: 10,
                  maxLengthEnforced: true,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10)
                  ],
                  onChanged:handleSnameChange,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    filled: true,
                    prefixIcon: Icon(
                      CupertinoIcons.person, color: kThemeBlue,),
                    fillColor: Colors.white,
                    labelText: 'Input last/sur name',
                    hintStyle: kHintStyle,
                    border: kInputOutlineBorder,
                  )
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: TextEditingController(text: phoneNum),
                  style: kInputTextStyle,
                  textAlign: TextAlign.start,
                  maxLength: 11,
                  maxLengthEnforced: true,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(11)
                  ],
                  onChanged:handlePhoneNumChange,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    filled: true,
                    prefixIcon: Icon(
                      CupertinoIcons.phone, color: kThemeBlue,),
                    fillColor: Colors.white,
                    labelText: 'Input (whatsapp) phone number ',
                    hintStyle: kHintStyle,
                    border: kInputOutlineBorder,
                  )
              ),
            ),
            Container(
              height: 70,
              width: double.maxFinite,
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: kThemeBlue,
                  ),
                  borderRadius: BorderRadius.circular(8)
              ),
              margin: EdgeInsets.all(8.0),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 10,),
                    Icon(CupertinoIcons.location, color: kThemeBlue,),
                    Expanded(
                      child: Container(
                        child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                                initialItem: kStateStringList.indexOf(
                                    state) >= 0 ? kStateStringList.indexOf(
                                    state) : 0),
                            diameterRatio: 1.5,
                            useMagnifier: true,
                            magnification: 1.2,
                            itemExtent: 30,
                            onSelectedItemChanged: handleStateChange,
                            children: getCupertinoText()
                        ),
                      ),
                    ),
                  ]
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: TextEditingController(text: sAddress),
                  style: kInputTextStyle,
                  textAlign: TextAlign.start,
                  maxLength: 24,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(24)
                  ],
                  onChanged:handleAddressChange,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    filled: true,
                    prefixIcon: Icon(
                      CupertinoIcons.location_solid, color: kThemeBlue,),
                    fillColor: Colors.white,
                    labelText: 'Input specific address',
                    hintStyle: kHintStyle,
                    border: kInputOutlineBorder,
                  )
              ),
            ),
            // SizedBox(height: 50,)
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child:Column(
        children: userInfoWidgets,
      ),
    );
  }

  List<Widget> getCupertinoText(){
    List<Widget> ans=[];
    for(String s in kStateStringList){
      ans.add(  Text(s, style: TextStyle(color: kThemeBlue)));
    }
    return ans;
  }

}

