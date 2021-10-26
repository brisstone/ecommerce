import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
// import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutterwave/flutterwave.dart';
import 'package:flutterwave/models/requests/charge_card/charge_card_request.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/databases/customer_orders_db.dart';
import 'package:ecommerce/databases/order_mitems_db.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/mart_objects/order_item.dart';
import 'package:ecommerce/screens/order_details_screen.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:http/http.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class PayForItemScreen extends StatefulWidget {
  PayForItemScreen({@required this.martItem,@required this.orderItem,@required  this.phoneNum,@required  this.state, @required this.sAddress});

  OrderItem orderItem;
  MartItem martItem;
  String phoneNum;
  String state;
  String sAddress;

  @override
  _PayForItemScreenState createState() => _PayForItemScreenState();
}

class _PayForItemScreenState extends State<PayForItemScreen> {
  bool showProgress=false;
  String title='';
  String customerAddress='';
  String sellerPNum='';
  String sellerEmail='';
  String image='';
  String itemId='';
  String description='';
  String sellerName='';
  String shopTitle='Contact Seller';
  String variantName='';
  String numOfOrder='';
  String price='';
  String orderStat='';
  String deliveryAddr='';
  String dateC='';
  String unitsO='';
  String recepient='';
  String phoneNum='';

  MartItem orderMartItem;


  @override
  void initState() {
    setOtherDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme:IconThemeData(color: kThemeBlue),
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: showProgress,
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  Card(
                    child: Stack(
                        alignment: Alignment.topRight,
                        children:[
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children:[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Order Created: $dateC', textAlign: TextAlign.end,
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 15),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('$title',style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.w300, fontSize: 13),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Bill \u20a6 $price', textAlign: TextAlign.start,
                                    style: TextStyle(color: kThemeOrange, fontWeight: FontWeight.w900, fontSize: 15),),
                                ),
                                Padding(
                                  padding:  EdgeInsets.all(1.0),
                                  child:
                                  image!=null && image.trim().isNotEmpty? Image.network(
                                    image,fit: BoxFit.contain,height: 250,width: double.infinity,):
                                  Icon(Icons.shopping_cart, color: kThemeOrange, size: 300,),
                                ),
                                Row(
                                  children:[
                                    Padding(
                                      padding: EdgeInsets.only(left:8.0),
                                      child: Text('Units:', style: kHintStyle.copyWith(color: kLightBlue),),
                                    ),
                                    Container(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text('$unitsO ', textAlign: TextAlign.start, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.w900,           fontSize: 15),),
                                  ),]
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left:8.0),
                                      child: Text('Recepient:', style: kHintStyle.copyWith(color: kLightBlue),),
                                    ),
                                    Container(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text('$recepient', textAlign: TextAlign.start, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.w900, fontSize: 15),),
                                  ),]
                                ),

                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left:8.0),
                                      child: Text('Contact:', style: kHintStyle.copyWith(color: kLightBlue),),
                                    ),
                                    Container(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text('$phoneNum', textAlign: TextAlign.start, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.w900, fontSize: 15),),
                                  ),]
                                ),

                                Row(
                                  children:[    Padding(
                                    padding: EdgeInsets.only(left:8.0),
                                    child: Text('Delivery Address:', style: kHintStyle.copyWith(color: kLightBlue),),
                                  ),
                                    Container(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(' $deliveryAddr', textAlign: TextAlign.start, style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.w900, fontSize: 15),),
                                  ),]
                                ),
                                TextButton(
                                    onPressed: (){
                                      initiateOrderSequence();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                      decoration: BoxDecoration(
                                          color: kThemeOrange,
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Text('Pay Now', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                                    )),
                              ]
                          ),
                        ]
                    ),
                  ),
                ],
              ),
            ),
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
    orderMartItem = widget.martItem;
    print('order details: ${widget.orderItem}');
    print('item details: ${orderMartItem}');
    price = widget.orderItem.p;
    orderStat = widget.orderItem.k;
    title = widget.orderItem.n;

    dateC = deduceDate(widget.orderItem.d);
    unitsO = widget.orderItem.u;
    if (orderMartItem != null) {
      description = orderMartItem.d;
      if(orderMartItem.k.startsWith(',')&& orderMartItem.k.length>1) orderMartItem.k=orderMartItem.k.substring(1);
      image = uGetAzurePicUrl( orderMartItem.k.split(',').firstWhere((element) => element!=null && element.trim().isNotEmpty&&element.trim()!='null'));
    }
    setupCustomerContact(widget.orderItem.z);
    setProgress(false);
  }

  String deduceDate(String d) {
    List<String> dsplits=d.split(':');
    return('${dsplits[0]}/${dsplits[1]}/20${dsplits[2]}');
  }

  void setupCustomerContact(String buyerProf) {
    if(!buyerProf.contains('<'))return;
    int splitDex= buyerProf.indexOf('<');
    recepient=buyerProf.substring(0,splitDex);
    deliveryAddr=buyerProf.substring(splitDex+1);

    splitDex=deliveryAddr.indexOf('<');
    phoneNum=deliveryAddr.substring(0,splitDex);
    deliveryAddr=deliveryAddr.substring(splitDex+1);
  }

  Future<void> initiateOrderSequence() async {
    setProgress(true);
    try {
      // await debitUser(widget.orderItem.p);// DEBIT USER WITH PAYSTACK
      // //UPLOAD ITEM
      await AzSingle().uploadOrder(widget.orderItem);
      //SAVE ITEM
      CustomerOrdersDb cdb = CustomerOrdersDb();
      await cdb.insertItem(widget.orderItem);

      // DOWNLOAD PICTURE AND SAVE ORDER ITEM TO DB
      String picPath = await AzSingle().downloadAzurePic(widget.martItem.k.split(',').firstWhere((element) => element!=null&&element.trim().isNotEmpty));
      MartItem saveItem = widget.martItem;
      saveItem.q = picPath;
      OrderItemsDb odb = OrderItemsDb();
      await odb.insertItem(saveItem);
      print('After insert');

      //TODO: UPDATE USER ADDRESS
      // await kDbref.child('cad').child(mOrder.c).child('a').set(address);
      await AzSingle().updateUser(state: widget.state, address: widget.sAddress, phoneNum: widget.phoneNum);
      // REDUCE ONLINE ORDER AMOUNT
      String snap = await AzSingle().getItemNumleft(widget.martItem.l);
      double d= double.tryParse(snap)??0;
      d-=double.tryParse(numOfOrder)??1;
      await AzSingle().setNumLeft(widget.martItem.l, d.toString());
      print('After num set');

      setProgress(false);
      Navigator.pop(context);
      Navigator.pop(context);
      openOrderDisplayPage(widget.orderItem);
    }catch(e, stackTrace){
      setProgress(false);
      uShowErrorNotification('Sorry! an error occured. Please try again later');
      print('initiate upload exception ${e.toString()}, stackTrace: $stackTrace');
    }
  }

  void openOrderDisplayPage(OrderItem mOrder) {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderDetailsScreen(mOrder, isNew:true)));
  }

  Future<String> _getReference(String uMail, String uBill) async {
    Response response = await get('https://gmartpaystackgateway.azurewebsites.net/api/initiate_kuda_split_transaction?email=${uMail}&amount=${uBill}');
    var data= jsonDecode(response.body.toString());
    print('json response ${response.body.toString()}');
    return data['data']['reference'];
  }

  Future<void> debitUser(String price) async {
    String orderId = widget.orderItem.i;
    final Flutterwave flutterwave = Flutterwave.forUIPayment(
        context: this.context,
        encryptionKey: kFwEncryptionKey,
        currency: 'NGN',
        publicKey: kFwPublicKey,
        amount: widget.orderItem.p,
        email: await uGetSharedPrefValue(kMailKey),
        fullName: recepient,
        txRef: orderId,
        isDebugMode: false,
        phoneNumber:  await uGetSharedPrefValue(kPhoneKey),
        acceptCardPayment: true,
        acceptUSSDPayment: false,
        acceptAccountPayment: false,
        // subaccounts: [SubAccount(uGetSplitPaymentAccID())]
    );
    // try {
      final ChargeResponse response = await flutterwave.initializeForUiPayments();
      if (response == null) {
        // user didn't complete the transaction. Payment wasn't successful.
      } else {
        final isSuccessful = checkPaymentIsSuccessful(response,widget.martItem.p,orderId);
        if (isSuccessful) {
          // provide value to customer
          return;
        } else {
          // check message
          print(response.message);
          // check status
          print(response.status);
          // check processor error
          print(response.data.processorResponse);
        }
      }
      throw Exception('Payment error');
    // } catch (error, stacktrace) {
    //   setProgress(false);
    //   // print()
    //   uShowErrorDialog(context, 'An error occured');
    // }
  }

  bool checkPaymentIsSuccessful( var response, String amount, String txRef) {
    return response.data.status == FlutterwaveConstants.SUCCESSFUL &&
        response.data.currency == 'NGN'&&
        response.data.amount == amount &&
        response.data.txRef == txRef;
  }

  Future<String> _getAccessCodeFrmInitialization(String uMail, String uBill) async {
    Response response = await get('https://gmartpaystackgateway.azurewebsites.net/api/initiate_kuda_split_transaction?email=${uMail}&amount=${uBill}');
    var data= jsonDecode(response.body.toString());
    print('json response ${response.body.toString()}');
    return data['data']['access_code'];
  }
}
