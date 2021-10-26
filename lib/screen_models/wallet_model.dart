
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/custom_widgets/my_button.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterwave/core/flutterwave.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:flutterwave/utils/flutterwave_constants.dart';

import '../mart_objects/customer.dart';
import '../utility_functions.dart';

class WalletModel extends ChangeNotifier {
  static String amount2Pay = '';

  WalletModel({ this.context});

  static BuildContext walletContext;
  static String couponCode = '';
  BuildContext context;
  static double ballance = 0.0;
  static bool progress = false;

  bool getProgress()=>progress;
  double getBallance()=>ballance;

  beginPayment( String amount) async {
    String name= await uGetSharedPrefValue(kFnameKey);
    name+=' '+await uGetSharedPrefValue(kLnameKey);
    String email= await uGetSharedPrefValue(kMailKey);
    String phoneNum=await uGetSharedPrefValue(kPhoneKey);
    String txRef = FirebaseDatabase.instance.reference().push().toString();
    List<String> refBase=txRef.split('/');
    txRef=refBase[refBase.length-1];
    txRef=txRef.replaceAll("\-", "")
        .replaceAll("\#", "")
        .replaceAll("\.", "")
        .replaceAll("\$", "")
        .replaceAll("\[", "")
        .replaceAll("-", "")
        .replaceAll("#", "")
        .replaceAll("]", "")
        .replaceAll("]", "");

    final Flutterwave flutterwave = Flutterwave.forUIPayment(
    context: this.context,
    encryptionKey: kFwTeseEncyptionKey,
    currency: 'NGN',
    publicKey: kFwPublicKey,
    amount: amount,
    email: email,
    fullName: name,
    txRef: txRef,
    isDebugMode: true,
    phoneNumber: phoneNum,
    acceptCardPayment: true,
    acceptUSSDPayment: false,
    acceptAccountPayment: false);


    try {
      final ChargeResponse response = await flutterwave.initializeForUiPayments();
      if (response == null) {
      // user didn't complete the transaction. Payment wasn't successful.
      } else {
        final isSuccessful = checkPaymentIsSuccessful(response,amount,txRef);
        if (isSuccessful) {
        // provide value to customer
        } else {
          // check message
          print(response.message);

          // check status
          print(response.status);

          // check processor error
          print(response.data.processorResponse);
        }
      }
    } catch (error, stacktrace) {
      setProgress(false);
      uShowErrorDialog(context, 'An error occured');
    }
  }

  bool checkPaymentIsSuccessful( var response, String amount, String txRef) {
    return response.data.status == FlutterwaveConstants.SUCCESSFUL &&
      response.data.currency == 'NGN'&&
      response.data.amount == amount &&
      response.data.txRef == txRef;
  }

  Future<dynamic> loadCoupon(String coupon, BuildContext context) async {
    setProgress(true);
    String snapshot=(await AzSingle().retrieveCouponValue(coupon)).toString();
    print('coupon val : ${snapshot}');
    if (snapshot != null && snapshot != null) {
      double d = double.tryParse(snapshot.trim().toString())??0; //parse value to double
      if (d == null){
        setProgress(false);
        uShowErrorDialog(context, 'Sorry! An error occured');
        return d;
      }// return null if value is null
      double walm = double.tryParse((await uGetSharedPrefValue(kWalletKey)).toString()) ?? 0; // retrieve saved wallet value
      walm += d; // add coupon to saved value
      bool b=await AzSingle().updateCloudWallet(walm); // upload saved value to cloud user account and signup user if not already signed up
      if(!b){
        setProgress(false);
        uShowErrorDialog(context, 'An error occured. Please ensure information on your profile is in order!');
        return null;
      }
      await uSetPrefsValue(kWalletKey, walm.toString()); //save value to shared preferences
      setProgress(false);
      uShowCreditDialog(amount:d, context: context);
      setWalletBalance();
      return d;
    } else {
      setProgress(false);
      uShowErrorDialog(context, 'An error occured !');
    }
    return null;
  }


  bool retrieveProgress() {
    return progress;
  }

  void setProgress(bool b) {
    print('listeners notified');
    progress = b;
    notifyListeners();
  }

  Future<double> getWalletBalance() async {
    setProgress(true);
    String b = (await uGetSharedPrefValue(kWalletKey)).toString();
    print('wallet value $b');
    ballance = double.parse(b ?? '0');
    setProgress(false);
    return ballance;
  }

  Future<void> setWalletBalance() async {
    try {
      setProgress(true);
      String b = (await uGetSharedPrefValue(kWalletKey)).toString();
      print('wallet value $b');
      ballance = double.parse(b ?? '0');
    }catch(e){
      print('ERROR: $e');
    }
    finally{
      setProgress(false);
    }
  }

  List<Widget> getPayChildren(BuildContext context) {
    List payMethodList = [
      PaymentDataObjects(CupertinoIcons.creditcard, 'ATM card payment', '100% credit (No fees)'),
      PaymentDataObjects(Icons.account_balance, 'Bank transfer', '100% credit (No fees)'),
      PaymentDataObjects(CupertinoIcons.phone_arrow_up_right, 'USSD payment', '100% credit (No fees)'),
      PaymentDataObjects(Icons.card_giftcard_outlined, 'Coupon payment', '100% credit (No fees)')
    ];
    List<Widget> res = [];
    for (PaymentDataObjects item in payMethodList) {
      Function() pressFunction=(){};
      if(item.tittle == 'Coupon payment' ){
        pressFunction=(){onCouponTilePressed(context);};
      }else if(item.tittle=='Bank transfer'){
        pressFunction=(){showOpenPaymentDialog(context, PaymentOption.BANKPAY);};
      }else if(item.tittle=='USSD payment'){
        pressFunction=(){showOpenPaymentDialog(context, PaymentOption.USSDPAY);};
      }else if(item.tittle=='ATM card payment'){
        pressFunction=(){showOpenPaymentDialog(context, PaymentOption.CARDPAY);};
      }
        res.add(
            GestureDetector(
        onTap: () {  },
        child: Container(
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  spreadRadius: 0, blurRadius: 5, color: Colors.black54,)
              ]
          ),
          child: FlatButton(
            splashColor: kLightBlue,
            onPressed: pressFunction,
            child: ListTile(
              leading: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kLightBlue,
                  ),
                  child: Icon(item.iconData, color: Colors.white,)),
              title: Text(item.tittle, style: TextStyle(
                  color: kThemeBlue, fontWeight: FontWeight.bold),),
              subtitle: Text(item.info, style: TextStyle(color: kLightBlue),),
              tileColor: Colors.transparent,
            ),
          ),
        ),
      ));
    }
    return res;
  }

  onCouponTilePressed(BuildContext context) {
    uShowCouponDialog(context: context,
        icon: Icons.card_giftcard,
        iconColor: kThemeOrange,
        text: 'Load',
        onPressedFun: () async {
          if (WalletModel.couponCode == null ||
              WalletModel.couponCode.isEmpty) {
              uShowSnackBar(text: 'Invalid coupon code !!!',
                context: walletContext,
                butLabel: 'OK', onPressed: () {  });
          } else if (!(await uCheckInternet())) {
            Navigator.pop(context);
            uShowNoInternetDialog(context);
          } else {
            Navigator.of(context).pop();
            attemptCouponLoad(context);
          }
        });
  }

  void showOpenPaymentDialog(BuildContext context,PaymentOption payop){
    Dialog errorDialog= Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Colors.white,//Color(0xFFDDDDFF),
      child: Container(
        height: 350,
        child: Column(
          children: [
            Expanded(child: Icon(Icons.account_balance, color: kThemeBlue, size: 200,)),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                textAlign: TextAlign.center,
                onChanged: (string){WalletModel.amount2Pay=string;},
                decoration: InputDecoration(
                    filled: false,
                    hintText: 'Enter amount (min: \u20a650)',
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
                      startPaySequence(amount2Pay, payop, context);
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

  startPaySequence(String tamount, PaymentOption payop, BuildContext context) async {
    double amount=double.tryParse(tamount)??0;
    if(amount==null){
      uShowErrorNotification('invalid amount');
      return;
    }else if(amount<50){
      uShowErrorNotification('amount cannot be less than \u20a650');
      return;
    }
    if(!(await uCheckInternet())){
      uShowErrorNotification('Error: No internet.');
      return;
    }
    Navigator.pop(context);
    setProgress(true);
    String name= await uGetSharedPrefValue(kFnameKey);
    name+=' '+await uGetSharedPrefValue(kLnameKey);
    String email= await uGetSharedPrefValue(kMailKey);
    String phoneNum=await uGetSharedPrefValue(kPhoneKey);
    String txRef = FirebaseDatabase.instance.reference().push().toString();
    List<String> refBase=txRef.split('/');
    txRef=refBase[refBase.length-1];
    txRef=txRef.replaceAll("\-", "")
        .replaceAll("\#", "")
        .replaceAll("\.", "")
        .replaceAll("\$", "")
        .replaceAll("\[", "")
        .replaceAll("-", "")
        .replaceAll("#", "")
        .replaceAll("]", "")
        .replaceAll("]", "");

       final Flutterwave flutterwave = Flutterwave.forUIPayment(
       context: context,
       encryptionKey: kFwEncryptionKey,
       publicKey: kFwPublicKey,
       currency: 'NGN',
       amount: amount.toString(),
       email: email,
       fullName: name,
       txRef: txRef,
       isDebugMode: false,
       phoneNumber: phoneNum,
       acceptCardPayment: payop==PaymentOption.CARDPAY,
       acceptUSSDPayment: payop==PaymentOption.USSDPAY,
       acceptAccountPayment: payop==PaymentOption.BANKPAY);
   try {
     final ChargeResponse response = await flutterwave.initializeForUiPayments();
     if (response == null) {
       // user didn't complete the transaction. Payment wasn't successful.
       setProgress(false);
       uShowErrorDialog(context, 'Transaction not completed !');
     } else {
       final isSuccessful = checkPaymentIsSuccessful(response,amount.toString(),txRef);
       if (isSuccessful) {
         // provide value to customer
         String wallVal= await uGetSharedPrefValue(kWalletKey);
         double waval=double.tryParse(wallVal)??0;
         if(waval!=null)amount+=waval;
         bool b=await AzSingle().updateCloudWallet(amount); // upload saved value to cloud user account and signup user if not already signed up
         setWalletBalance();
         // double walm = double.tryParse((await uGetSharedPrefValue(kWalletKey)).toString()) ?? 0; // retrieve saved wallet value
         // walm += d; // add coupon to saved value
         // bool b=await AzSingle().updateCloudWallet(walm); // upload saved value to cloud user account and signup user if not already signed up
         // setWalletBalance();

         setProgress(false);
         uShowCreditDialog(context: context, amount:waval==null?amount:amount-waval);
       } else {
         // check message
         setProgress(false);
         uShowErrorDialog(context, 'Transaction error! Please ensure that funds are available at your source account/card.');
         print(response.message);
         // check status
         print(response.status);
         // check processor error
         print(response.data.processorResponse);
       }
     }
   } catch (error, stacktrace) {
     setProgress(false);
     uShowErrorDialog(context, 'An error occured');
     print('error $error');
   }
  }

  void attemptCouponLoad(BuildContext context) async {
    setProgress(true);
    print('coupon loaded block');
    if (WalletModel.couponCode == null || WalletModel.couponCode.isEmpty) {
      setProgress(false);
      uShowSnackBar(text: 'Invalid coupon code !!!',
          context: this.context,
          butLabel: 'OK', onPressed: () {  });
    } else if (!(await uCheckInternet())) {
      setProgress(false);
      uShowSnackBar(
          text: 'No internet !!!', context: this.context, butLabel: 'OK', onPressed: () {  });
    } else if (!(await uCheckInternet())) {
      setProgress(false);
      uShowNoInternetDialog(context);
    } else {
      setProgress(false);
      print('coupon loading');
      loadCoupon(WalletModel.couponCode, context);
    }
  }
}

class PaymentDataObjects{
  PaymentDataObjects(this.iconData, this.tittle, this.info);
  IconData iconData;
  String tittle;
  String info;
}

enum PaymentOption{
  CARDPAY, BANKPAY, USSDPAY
}