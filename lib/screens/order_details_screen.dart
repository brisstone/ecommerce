import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/custom_widgets/my_button.dart';
import 'package:ecommerce/custom_widgets/seller_contact_items.dart';
import 'package:ecommerce/databases/order_mitems_db.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/mart_objects/order_item.dart';
import 'package:ecommerce/mart_objects/small_mitem.dart';
import 'package:ecommerce/providers/customer_orders_provider.dart';
import 'package:ecommerce/providers/favorite_provider.dart';
import 'package:ecommerce/providers/promo_model.dart';
import 'package:ecommerce/providers/seller_orders_provider.dart';
import 'package:ecommerce/screens/collect_payment_data_screen.dart';
import 'package:ecommerce/screens/confirm_order_delivery_screen.dart';
import 'package:ecommerce/screens/item_description_screen.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';

class OrderDetailsScreen extends StatefulWidget {

  OrderDetailsScreen(this.mOrder,{this.isNew=false, this.isSeller=false});

  OrderItem mOrder;
  bool isNew;
  bool isSeller;

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {

  MartItem orderMartItem;
  String sellerPNum='';
  String sellerEmail='';
  String image='';
  String itemId='';
  String title='Sample title';
  String description='';
  String sellerName='';
  String shopTitle='Contact Seller';
  String variantName='';
  String numOfOrder='';
  String price='';
  String orderStat='';
  String dateC='';
  String unitsO='';

  bool showProgress=false;
  List<Widget> variantsList=[];
  List<Widget> othersList=[];
  List<Widget> picList=[];

  @override
  void initState() {
    setOtherDetails();
  }

  @override
  Widget build(BuildContext context) {
//    image=orderMitem.;
    print('order image: ${image}');

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child: Icon(CupertinoIcons.left_chevron, color: kThemeBlue,size: 20,),
        ),
        title: Text('Order-${widget.mOrder.n}', style: kNavTextStyle.copyWith(color: kThemeBlue, fontWeight: FontWeight.bold, fontSize: 17),),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showProgress,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                Card(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children:[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Order Created: $dateC', textAlign: TextAlign.end,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 15),),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('ID: $itemId', textAlign: TextAlign.start, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.w300, fontSize: 13),),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Bill \u20a6 ${price}', textAlign: TextAlign.start,
                          style: TextStyle(color: kThemeOrange, fontWeight: FontWeight.w900, fontSize: 15),),
                      ),
                      Padding(
                        padding:  EdgeInsets.all(1.0),
                        child:
                        image!=null && image.isNotEmpty? Image.file(
                          File(image??''),fit: BoxFit.fill,height: 400,width: double.infinity,):
                        Icon(Icons.shopping_cart, color: kThemeOrange, size: 300,),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.all(16),
                        child: TextButton(
                            onPressed: gotoItem,
                            child: Text('View item', textAlign: TextAlign.end, style: kHintStyle.copyWith(color: Colors.blue, fontWeight: FontWeight.bold),)),
                      ),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        child: Text('UNITS ORDERED: $unitsO \nDELIVERY DETAILS: $description', textAlign: TextAlign.start, style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w900,           fontSize: 15),),
                      ),
                    ]
                ),

                ),
                Card(
                child: Column
                  (
                children: [
                SizedBox(height: 20,),
                Text(widget.isSeller?'Contact Buyer':'Contact Us', textAlign: TextAlign.start, style: TextStyle(color: Colors.black,
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
                    },
                  ),
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
                ),
                Card(
                child: Column(
                children:[
                  SizedBox(height: 20,),
                 Text('ORDER ACTIONS', textAlign: TextAlign.start,
                     style: TextStyle(color: kThemeOrange, fontWeight: FontWeight.w900, fontSize: 18),),
                  SizedBox(height: 20,),
                     getActionButton()
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

  void setProgress(bool b){
    setState(() {
      showProgress=b;
    });
  }

  Future<void> setOtherDetails() async {
    setProgress(true);
    print('setting OTHER DETAILS');
    OrderItemsDb odb = OrderItemsDb();
    itemId=widget.mOrder.i;
    orderMartItem = await odb.getItem(widget.mOrder.t);
    if (widget.isNew) showNewOrderDialog();
    print('item details: ${widget.mOrder}');
    print('item details: ${orderMartItem}');
    price = widget.mOrder.p;
    orderStat = widget.mOrder.k;
    dateC = deduceDate(widget.mOrder.d);
    unitsO = widget.mOrder.u;
    if (orderMartItem != null) {
      title = orderMartItem.i;
      description = orderMartItem.d;
      if(orderMartItem.q.startsWith(',')&& orderMartItem.q.length>1) orderMartItem.q=orderMartItem.q.substring(1);
      image = orderMartItem.q.split(',')[0];
    }
    if (widget.isSeller) {
      if (orderMartItem != null) setupSellerContacts(orderMartItem.p);
    }
    else {
      setupCustomerContact(widget.mOrder.z);
    }
    setProgress(false);
  }

  Future<void> setImageList(String itemImages) async {
    if(itemImages.startsWith(','))
      itemImages=itemImages.substring(1);
    List<String> filePaths=itemImages.split(',');
    for(String imPath in filePaths){
      String pic= await uGetPicDownloadUrl(imPath);
      picList.add(
          InteractiveViewer(child: Image.network(pic, fit: BoxFit.cover,))
      );
    }
  }

  void setupSellerContacts(String sellerProf){
    if(!sellerProf.contains('<'))return;
    List<String> sList= sellerProf.split('<');
    if(sList.length<2) return;
    sellerEmail=sList[0];
    sellerPNum=sList[1];
  }

  void callSeller(){
    launch("tel:$sellerPNum");
  }

  void smsSeller(){
    launch("sms:$sellerPNum");
  }

  void whatsappSeller(){
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

  void showNewOrderDialog() {
    uShowCustomDialog(context: context,
      icon: CupertinoIcons.checkmark_alt,
      iconColor: Colors.green,
      text: 'Your order is completed. You can monitor order status from your profile page.',);
  }

  void setupCustomerContact(String buyerProf) {
    print('buyer profile');
    if(!buyerProf.contains('<'))return;
    int splitDex= buyerProf.indexOf('<');
    if(splitDex <= 0 ) return;
    sellerName=buyerProf.substring(0,splitDex);
    description=buyerProf.substring(splitDex+1);
    splitDex=description.indexOf('<');
    if(splitDex <= 0 ) return;
    sellerPNum=description.substring(0,splitDex);
    description='Delivery address: '+description.substring(splitDex+1);
  }

  Widget getActionButton() {
    String text='';
    Color acColor=Colors.white;
    Color textColor=Colors.white;
    Function onClick;
    orderStat=widget.mOrder.k;
    if(orderStat.startsWith('1')) {
      if(widget.isSeller){
        text='Paid-Pending';
        Colors.transparent;
        textColor=Colors.green;
      }else{
        text='Request Refund';
        acColor=Colors.red;
        // CREATE INITIATE REFUND FUNCTION
        onClick=showInitiateRefundDialog;
      }
    }else if(orderStat.startsWith('2')){
      if(widget.isSeller) {
        text = 'Collect Payment';
        acColor=Colors.blueAccent;
        textColor=Colors.white;
        onClick=showCloseOrderDialog;// CREATE COLLECT PAYMENT FUNCTION
      }else{
        text='Order Completed';
        acColor=Colors.transparent;
        textColor=Colors.blue;
      }
    }else if(orderStat.startsWith('3')){
      if(widget.isSeller){
        text='Approve Refund';
        acColor=Colors.brown;
        textColor=Colors.white;
        // APPROVE REFUND FUNCTION
        // onClick=approveRefund;
        onClick=showApproveRefundDialog;
      }else{
        text='Refund Approval Pending';
        acColor=Colors.transparent;
        textColor=Colors.brown;
      }
    }else if(orderStat.startsWith('4')){
      if(widget.isSeller) {
        text = 'Refund Approved';
        acColor = Colors.transparent;
        textColor=Colors.brown;
      }else{
        text='Collect Refund';
        acColor=Colors.blueAccent;
        textColor=Colors.white;
        onClick= showRequestRefundDialog;// CREATE COLLECT REFUND FUNCTION
      }
    }else if(orderStat.startsWith('5')){
      text = 'Order Settled';
      acColor = Colors.transparent;
      textColor=Colors.black;
    }else if(orderStat.startsWith('6')){
      text = 'Order Settled';
      acColor = Colors.transparent;
      textColor=Colors.black;
    }
    if(orderStat.startsWith('1') && !widget.isSeller){
      return Row(
        children: [
          Expanded(
            child: MyButton(text: 'Confirm Delivery', onPressed: (){
              // IMPLEMENT CONFIRM ITEM DELIVERY
              showOnConfirmDeliveryDialog();
               }, buttonColor: Colors.blueAccent , textColor: Colors.white, ),
          ),
          Expanded(child: MyButton(text: text, onPressed: (){ onClick.call();}, buttonColor: acColor , textColor: textColor, )),
        ],
      );
    }
    return MyButton(text: text, onPressed:(){ onClick.call();}, buttonColor: acColor , textColor: textColor, );
  }

  showInitiateRefundDialog(){
    uShowCustomDialogWithImage(context: context, icon: 'images/refund.png',
        text: 'Confirm. By proceeding, you request that the seller grants you a refund. ',
        buttonList: [['Proceed',Colors.black,initiateRefund]]);
  }

  showApproveRefundDialog(){
    uShowCustomDialogWithImage(context: context, icon: 'images/refund.png',
        text: 'Approve buyer refund',
        buttonList: [['Proceed',Colors.black,approveRefund]]);
  }

  Future<void> showOnConfirmDeliveryDialog() async{
    setProgress(true);
    if(!(await uCheckInternet())){
      uShowNoInternetDialog(context);
      return;
    }
    Dialog dialog= Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: kDialogLight,
         child: ConfirmOrderDelivery(onConfirmPressed: confirmOrderDelivery, order: widget.mOrder )
    );
    showGeneralDialog(context: context,
    barrierLabel: 'text',
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 500),
    transitionBuilder: (_, anim, __, child){
     return SlideTransition(position: Tween(begin: Offset(-1,0), end: Offset(0,0)).animate(anim), child: child,);
    },
    pageBuilder: (BuildContext context, _, __)=>(dialog)
    );
    setProgress(false);
  }

  Future<void> approveRefund() async {
    setProgress(true);
    String orderId=widget.mOrder.i;
    String userId= await uGetSharedPrefValue(kIdKey);
    String url='https://gmartfunctions.azurewebsites.net/api/approve-order-refund?oid=$orderId&uid=$userId';
    http.Response response=await http.get(url);
    if(response.statusCode>=200 && response.statusCode<300) {
      widget.mOrder.k="4";
      await saveStatusToDatabase();
    }else{
      uShowErrorDialog(context, 'Operation error.');
    }
    setProgress(false);
  }


  Future<void> initiateRefund() async {
    setProgress(true);
    String orderId=widget.mOrder.i;
    String userId= await uGetSharedPrefValue(kIdKey);
    String url='https://gmartfunctions.azurewebsites.net/api/init-order-refund?oid=$orderId&uid=$userId';
    http.Response response=await http.get(url);
    if(response.statusCode>=200 && response.statusCode<300) {
      widget.mOrder.k="3";
      await saveStatusToDatabase();
    }else{
      uShowErrorDialog(context, 'Operation error.');
    }
    setProgress(false);
  }

  Future<void> confirmOrderDelivery() async {
    Navigator.pop(context);
    setProgress(true);
    String orderId=widget.mOrder.i;
    String userId= await uGetSharedPrefValue(kIdKey);
    String url='https://gmartfunctions.azurewebsites.net/api/confirm-order-delivery?oid=$orderId&uid=$userId';
    http.Response response=await http.get(url);
    if(response.statusCode>=200 && response.statusCode<300) {
      widget.mOrder.k="2";
      await saveStatusToDatabase();
    }else{
      uShowErrorDialog(context, 'Operation error.');
    }
    setProgress(false);
  }

  showCloseOrderDialog() async {
    setProgress(true);
    if(!(await uCheckInternet())){
      uShowNoInternetDialog(context);
      return;
    }
    Dialog dialog= Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: kDialogLight,
        child: CollectPaymentDataScreen(onPaymentComplete: requestOrderPayment, order: widget.mOrder , isSeller: true,)
    );
    showGeneralDialog(context: context,
        barrierLabel: 'text',
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 500),
        transitionBuilder: (_, anim, __, child){
          return SlideTransition(position: Tween(begin: Offset(-1,0), end: Offset(0,0)).animate(anim), child: child,);
        },
        pageBuilder: (BuildContext context, _, __)=>(dialog)
    );
    setProgress(false);
  }

  Future<void> requestOrderPayment(String accNum, String bankCode, String accName) async {
    //
    Navigator.pop(context);
    setProgress(true);
    String userId= await uGetSharedPrefValue(kIdKey);
    String orderId= widget.mOrder.i;
    String url="https://gmartfunctions.azurewebsites.net/api/request-order-payout?acc=$accNum&bcode=$bankCode&uid=$userId&oid=$orderId&name=$accName";
    setProgress(true);
    http.Response response=await http.get(url);
    if(response.statusCode>=200 && response.statusCode<300){
      await Provider.of<SellerOrderProvider>(context, listen: false).quickFetchForOrders();
      widget.mOrder.k='5';
    }else{
      uShowErrorNotification('An error occured.');
    }
    setProgress(false);
  }

  showRequestRefundDialog() async {
    setProgress(true);
    if(!(await uCheckInternet())){
      uShowNoInternetDialog(context);
      return;
    }
    Dialog dialog= Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: kDialogLight,
      child: CollectPaymentDataScreen(onPaymentComplete: requestRefundPayout, order: widget.mOrder ,)
    );
    showGeneralDialog(context: context,
        barrierLabel: 'text',
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 500),
        transitionBuilder: (_, anim, __, child){
          return SlideTransition(position: Tween(begin: Offset(-1,0), end: Offset(0,0)).animate(anim), child: child,);
        },
        pageBuilder: (BuildContext context, _, __)=>(dialog)
    );
    setProgress(false);
  }

  Future<void> requestRefundPayout(String accNum, String bankCode, String accName) async {
    //
    Navigator.pop(context);
    setProgress(true);
    String userId= await uGetSharedPrefValue(kIdKey);
    String orderId= widget.mOrder.i;
    String url="https://gmartfunctions.azurewebsites.net/api/request-refund-payout?acc=$accNum&bcode=$bankCode&uid=$userId&oid=$orderId&name=$accName";
    setProgress(true);
    http.Response response=await http.get(url);
    if(response.statusCode>=200 && response.statusCode<300){
      await Provider.of<CustomerOrderProvider>(context, listen: false).quickFetchForOrders();
      widget.mOrder.k='6';
    }else{
      uShowErrorNotification('An error occured.');
    }
    setProgress(false);
  }

  String deduceDate(String d) {
    List<String> dsplits=d.split(':');
    return('${dsplits[2]}/${dsplits[1]}/20${dsplits[0]}');
  }

  saveStatusToDatabase() async {
    if(widget.isSeller){
      await Provider.of<SellerOrderProvider>(context, listen: false).quickFetchForOrders();
    }else {
      await Provider.of<CustomerOrderProvider>(context, listen: false).quickFetchForOrders();
    }
  }

  Future<void> gotoItem() async {
    setProgress(true);
    try {
      MartItem mitem= await AzSingle().getLargeItem(widget.mOrder.t);
      print('item:  $mitem');
      setProgress(false);
      if(mitem!=null&& mitem.l.toString()!='null'&&mitem.k.toString()!='null'&&mitem.t.toString()!='null')Navigator.push(context, MaterialPageRoute(builder: (context)=>ItemDescriptionScreen(martItem: mitem,)));
      else uShowErrorDialog(context, 'It appears the item is no longer up for sale.');
    }catch(e){
      setProgress(false);
      uShowErrorNotification('An error occured !');
      print('open item exception ${e.toString()}');
    }
  }

}
