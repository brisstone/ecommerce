import 'package:azstore/azstore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/databases/cart_items_db.dart';
import 'package:ecommerce/databases/customer_orders_db.dart';
import 'package:ecommerce/databases/favorite_item_db.dart';
import 'package:ecommerce/databases/mart_item_db.dart';
import 'package:ecommerce/databases/order_mitems_db.dart';
import 'package:ecommerce/mart_objects/customer.dart';
import 'package:ecommerce/mart_objects/order_item.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/providers/customer_orders_provider.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utility_functions.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {

  bool passReset;

  LoginScreen({this.passReset=false});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin{

  bool showPassword=false;
  double marginVal=16;
  Color textFillColor=Color(0x22FFFFFF);
  AnimationController _controller;
  CurvedAnimation slideInLeftAnim;
  String password;
  String email;
  bool showProgress=false;

  FocusNode emailFocus= FocusNode();
  FocusNode paswordFocus= FocusNode();

  var hintColor=Colors.grey;
  var hintSelectedColor=Colors.grey;

 @override
  void initState() {
    _controller=AnimationController(
      duration: Duration(milliseconds:1700, ),
      vsync: this,
    );

    slideInLeftAnim=CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _controller.addListener(() {
      setState(() {

      });
    });
    resolvePassReset();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showProgress,
      color: Colors.black.withOpacity(0.9),
      child: Container(
        child: Scaffold(
          backgroundColor: kThemeBlue,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                  tag: 'mainLogo',
                  child: Image.asset('images/logo.png', height: _controller.value*150,)),
              SizedBox(height: 30,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: _controller.value*marginVal),
                child: TextField(
                  onChanged: (string){email=string.toString();},
                  focusNode: emailFocus,
                  decoration: InputDecoration(
                      filled: true,
                      prefixIcon: Icon(CupertinoIcons.mail, color: Colors.white,),
                      labelText: 'Enter email',
                      labelStyle: TextStyle(
                          color:emailFocus.hasFocus?hintColor:hintSelectedColor
                      ),
                    fillColor: textFillColor
                  ),
                  textInputAction: TextInputAction.next,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              SizedBox(height: 10,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: _controller.value*marginVal),
                child: TextField(
                  onChanged: (string){password=string.toString();},
                  focusNode: paswordFocus,
                  decoration: InputDecoration(
                      filled: true,
                      prefixIcon: Icon(CupertinoIcons.lock, color: Colors.white,),
                      suffixIcon: IconButton(icon: Icon(showPassword?Icons.visibility_off:Icons.visibility, color: Colors.grey,), onPressed: toggleIconVisibility,),
                      labelText: 'Enter password',
                      labelStyle: TextStyle(
                          color:paswordFocus.hasFocus?hintColor:hintSelectedColor
                      ),
                    fillColor: textFillColor
                  ),
                  textInputAction: TextInputAction.done,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: showPassword?false:true,
                ),
              ),
              SizedBox(height: 20,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: _controller.value*marginVal),
                height: 45,
                child: Row(
                  children: [
                    Expanded(
                        child:  Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              color: kThemeOrange,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: FlatButton(onPressed: (){
                            checkDetails();
                          },
                            child: Text('Login', style: kNavTextStyle,),
                            splashColor: Colors.white,),
                        )
                    ),
                    SizedBox(width: 5,),
                    Expanded(
                        child:  Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              color: kLightBlue,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: FlatButton(onPressed: (){
                            Navigator.pushNamed(context, '/signup');
                          },
                            child: Text('Sign up', style: kNavTextStyle,),
                            splashColor: Colors.white,),
                        )
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                color: Colors.transparent,
                child: FlatButton(onPressed: (){
                  Navigator.pushNamed(context, '/retrieve');
                },
                  child: Text('Forgot password', textAlign: TextAlign.center, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400 ),),
                  splashColor: Colors.white,),
              )
            ],
          ),
        ),
      ),
    );
  }

  setSpinner(bool b){
    showProgress=b;
    setState(() { });
  }

  toggleIconVisibility(){
    showPassword=!showPassword;
    setState(() {

    });
  }

  Future<void> checkDetails () async {
    try {
      bool cancel = false;
      // Check for a valid password, if the user entered one.
      if (password.isEmpty || password.length<6) {
        uShowErrorDialog(this.context,'An error occured: Invalid password.\nPassword cannot not be less than 6 characters.');
        cancel = true;
        return;
      }
      // Check for a valid email address.
      if (email.isEmpty) {
        cancel = true;
        uShowErrorDialog(this.context,'An error occured: Invalid email address');
        return;
      } else if (!email.contains('@')||!email.contains('.com')|| email.length<6) {
        uShowErrorDialog(this.context,'An error occured: Invalid email address');
        cancel = true;
        return;
      }
      if (cancel) {
        uShowErrorDialog(this.context,'An error occured\nInvalid credentials.');
        return;
      }else if(!(await uCheckInternet())){
        uShowNoInternetDialog(this.context);
      }
      else {
        setSpinner(true);
        attemptLogin();
      }
    }catch ( e){
      print(e);
      setSpinner(false);
      uShowErrorDialog(this.context,'An error occured');
    }
  }

  int logFail=0;
  Future<void> attemptLogin() async {
    setSpinner(true);
    // SharedPreferences sp = await SharedPreferences.getInstance();
    String falseEmail = await uGetSharedPrefValue(kFailedMailKey) ?? '';
    String mail2Ret=await uGetSharedPrefValue(kMail2Retrieve);

    try {
      // Remove notification
      print('failed Mails:$falseEmail, mail2Ret: $mail2Ret');
      if(mail2Ret.contains(email)){
        setSpinner(false);
        uShowErrorDialog(context,'You have not reset your password');
        return;
      }
      if (falseEmail.contains(email)) {
        setSpinner(false);
        uShowCustomDialog(context: this.context,
            icon: Icons.error,
            iconColor: Colors.red,
            text: 'Login attempts exhausted. Please retrieve password.',
            buttonList: [
              ['Retrieve password', Colors.red, () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pushNamed(context, '/retrieve');
              }
              ]
            ]);        return;
      }
      // DataSnapshot snapshot = await kDbref.reference().child("cus").child(
      //     email.replaceAll('.', '')).once();
      bool isMailRegistered= await AzSingle().checkUserMail(email);
      print('email safe: $isMailRegistered');
      if (!isMailRegistered) {
        setSpinner(false);
        uShowCustomDialog(context: this.context,
            icon: CupertinoIcons.person_add,
            iconColor: Colors.blueGrey,
            text: 'Sorry: it appears we may not have your account.\nPlease confirm input or quickly follow the sign-up process.',
            buttonList: [
              ['Sign-Up', kLightBlue, () {
                  Navigator.pushNamed(context, '/signup');
                }
              ]
            ]);
        return;
      }
      bool error=false;
      print('gotten to sign IN');
      String id= await AzSingle().getUserId(email);

      if (id == null) {
        setSpinner(false);
        uShowCustomDialog(context: this.context,
            icon: Icons.warning,
            iconColor: Colors.red,
            text: 'Sorry: it appears there is an error your account data.\nPlease sign up with another email.',
            buttonList: [
              ['Sign-Up', kLightBlue, () {
                Navigator.pushNamed(context, '/signup');
              }
              ]
            ]);
        return;
      }
      print('userId: $id');
       Customer customer= await AzSingle().getOnlineCustomer(id.trim());
      print (customer.toString());
      if(customer==null){
        setSpinner(false);
        uShowCustomDialog(context: this.context,
            icon: Icons.warning,
            iconColor: Colors.red,
            text: 'Sorry: an error occured.\nPlease try again later.',
            // buttonList: [
            //   ['Sign-Up', kLightBlue, () {
            //     Navigator.pushNamed(context, '/signup');
            //   }
            //   ]
            // ]
        );
        return;
      }
      print('online pass:${customer.q} entered pass: ${password} ');
      CartItemsDb cdb = CartItemsDb();
      CustomerOrdersDb cusdb = CustomerOrdersDb();
      FavoriteItemsDb fdb = FavoriteItemsDb();
      OrderItemsDb odb = OrderItemsDb();
      LargeMartItemsDb ldb = LargeMartItemsDb();
      await cdb.clearAllItems();
      await cusdb.clearAllItems();
      await fdb.clearAllItems();
      await odb.clearAllItems();
      await ldb.clearAllItems();
      await Provider.of<CartProvider>(context, listen:false).fillUpCartMapFromDb();
      await Provider.of<CustomerOrderProvider>(context, listen:false).retrieveCustomerOrders();
      // if(customer.q.trim()=='null')throw 'An error occured';
      if(customer.q.trim()!=password.trim())throw Exception('wrong-password');
      // await uSetPrefsValue(kIdKey, id);
      await uSetPrefsValue(kIdKey, id);
      await uSetPrefsValue(kStateKey, customer.s);
      await uSetPrefsValue(kLnameKey, customer.l);
      await uSetPrefsValue(kFnameKey, customer.f);
      await uSetPrefsValue(kWalletKey, customer.w);
      await uSetPrefsValue(kAdressKey, customer.a);
      await uSetPrefsValue(kPhoneKey, customer.p);
      await uSetPrefsValue(kMailKey, customer.e);
      // await uSetPrefsValue(kPasswordKey, customer.q);
      await uSetPrefsValue(kShopInfo, customer.t);
      await uSetPrefsValue(kCartItemsId, customer.cid);
      await uSetPrefsValue(kShopItemsDownloaded,'f');
      await downloadAndSaveCartItems();
      await downloadCustomerOrders();
      setSpinner(false);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
        return MyHomePage(justLoggedIn: true,);
      }));
    }catch(e){

      if(e.toString().contains('wrong-password')){
        print(e);
        logFail++;
        if(logFail==3) {
          falseEmail = await uGetSharedPrefValue(kFailedMailKey) ?? '';
          falseEmail += ',$email';
          await uSetPrefsValue(kFailedMailKey, falseEmail);
          print(await uGetSharedPrefValue(kFailedMailKey));
        }
        print('logFail: $logFail');
        setSpinner(false);
        showRetrievePasswordDialog();
        return;
      }
      setSpinner(false);
      uShowErrorDialog(context, 'An error occured ! Please try again later.');
      print('sign in error: ${e.toString()}');
    }
  }

  void showRetrievePasswordDialog([String s='Login attempt error. Password and email do not match.']){
    uShowCustomDialog(context: this.context,
        icon: Icons.warning,
        iconColor: Colors.brown,
        text: s,
        buttonList: [
          ['Retrieve password', Colors.red, () {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pushNamed(context, '/retrieve');
          }
          ]
        ]);
  }

  downloadShopItems(String userId) async {
    CustomerOrdersDb cdb= CustomerOrdersDb();
    DataSnapshot snap = await FirebaseDatabase.instance.reference().child(kLargeOrdersPath).orderByChild('c') .equalTo(
        userId).once();
    try {
      if (snap == null || snap.value == null) return;
      print('orders value: ${snap.value.toString()}');
      Map<dynamic, dynamic> maps = Map.from(snap.value);
      for (var k in maps.entries) {
        print('kValue: ${k.value.toString()}');
        OrderItem order = OrderItem.fromMap(k.value);
        order.i = k.key.toString();
        await cdb.insertItem(order);
      }
    }catch(e){
      print('order download exception: ${e.toString()}');
    }
  }

  void resolvePassReset() {
   if(widget.passReset){
     WidgetsBinding.instance.addPostFrameCallback((_) {
       uShowCustomDialog(context: this.context,
         icon: CupertinoIcons.mail_solid,
         iconColor: Colors.blueGrey,
         text: 'Recovery email has been sent to your email address. Please check your mail and reset password before attempting login again.',
       );
     });
   }
  }

  Future<void> downloadAndSaveCartItems() async {
    await Provider.of<CartProvider>(context, listen: false).downloadAndSetUserCartItems();
  }

  Future<void> downloadCustomerOrders() async {
    await Provider.of<CustomerOrderProvider>(context, listen: false).quickFetchForOrders();
  }


}
