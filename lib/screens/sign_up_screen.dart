import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecommerce/databases/cart_items_db.dart';
import 'package:ecommerce/databases/customer_orders_db.dart';
import 'package:ecommerce/databases/favorite_item_db.dart';
import 'package:ecommerce/databases/mart_item_db.dart';
import 'package:ecommerce/databases/order_mitems_db.dart';
import 'package:ecommerce/mart_objects/customer.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/providers/customer_orders_provider.dart';
import 'package:ecommerce/screens/home_screen.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../utility_functions.dart';
import 'dart:io' show Platform;

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin{
  bool showPassword=false;
  double marginVal=16;
  Color textFillColor=Color(0x22FFFFFF);
  AnimationController _controller;
  CurvedAnimation slideInLeftAnim;

  String _email;
  String _email2;
  String _pno;
  String _fname;
  String _sname;
  String _state;
  String _password;
  String _password2;
  bool progress=false;
  String selectedState='Nigeria';
  CupertinoPicker stateCupPicker;
  Widget stateDropDown;

  FocusNode snameFocus=FocusNode();
  FocusNode fnameFocus=FocusNode();
  FocusNode emailFocus=FocusNode();
  FocusNode email2Focus=FocusNode();
  FocusNode phoneNumFocus=FocusNode();
  FocusNode passwordFocus=FocusNode();
  FocusNode password2Focus=FocusNode();

  Color hintColor=Colors.grey;

  Color hintSelectedColor=Colors.grey;

  void showProgress(bool b){
    progress=b;
    setState(() {

    });
  }
  Future<void> attemptSave() async {
    showProgress(true);
    try {
      _fname = _fname.trim();
      if (_fname == null || _fname.isEmpty) {
        showProgress(false);
        uShowErrorDialog(this.context, 'First name cannot be empty');
        return;
      } else if (_fname.contains(' ')) {
        showProgress(false);
        uShowErrorDialog(
            this.context, 'First name cannot contain white/empty space');
        return;
      }else if(_fname.length>10){
        showProgress(false);
        uShowErrorDialog(
            this.context, 'First name length is too long');
        return;
      }

      _sname = _sname.trim();
      if (_sname == null || _sname.isEmpty) {
        showProgress(false);
        uShowErrorDialog(this.context, 'Last/Sur name cannot be empty');
        return;
      } else if (_sname.contains(' ')) {
        showProgress(false);
        uShowErrorDialog(
            this.context, 'Last/Sur name cannot contain white/empty space');
        return;
      }else if(_sname.length>10){
        showProgress(false);
        uShowErrorDialog(
            this.context, 'Last name length is too long');
        return;
      }

      _email = _email.trim();
      if (_email == null || _email.isEmpty) {
        showProgress(false);
        uShowErrorDialog(this.context, 'email cannot be empty');
        return;
      } else if (!_email.contains('@') || !_email.contains('.com') ||
          _email.contains(' ')) {
        showProgress(false);
        uShowErrorDialog(this.context, 'Invalid email');
        return;
      }else if(_email!=_email2){
        showProgress(false);
        uShowErrorDialog(this.context, 'Email does not match.');
        return;
      }

      _pno = _pno.trim();
      if (_pno == null || _pno.isEmpty) {
        showProgress(false);
        uShowErrorDialog(this.context, 'Phone number cannot be empty');
        return;
      } else if (_pno.length != 11) {
        showProgress(false);
        uShowErrorDialog(this.context, 'Invalid phone number');
        return;
      }

      // _state = _state.trim();
      // if (_state == null || _state.isEmpty) {
      //   showProgress(false);
      //   uShowErrorDialog(this.context, 'State cannot be empty');
      //   return;
      // } else if (_state.contains(' ')) {
      //   showProgress(false);
      //   uShowErrorDialog(this.context, 'Invalid state selection');
      //   return;
      // }

      if (_password.isEmpty || _password2.isEmpty) {
        showProgress(false);
        uShowErrorDialog(this.context, 'Password cannot be empty');
        return;
      } else if (_password2 != _password) {
        showProgress(false);
        uShowErrorDialog(this.context, 'Password does not match');
        return;
      }
      if (!(await uCheckInternet())) {
        showProgress(false);
        uShowNoInternetDialog(this.context);
        return;
      }
      await attemptSignUp();
    }catch(e){
      uShowErrorDialog(context, 'An error occured. Please check inputs.');
    }
    showProgress(false);
  }

  Future<void> attemptSignUp() async {
    print('sign up mail $_email');
    // DataSnapshot snapshot= await kDbref.reference().child("cus").child(_email.replaceAll('.', '')).once();
    bool isEmailRegistered= await AzSingle().checkUserMail(_email);

    try {
      if (isEmailRegistered) {
        print('sign up mail value $_email');
        showProgress(false);
        uShowCustomDialog(context: this.context,
          icon: CupertinoIcons.person,
          iconColor: Colors.blueGrey,
          text: 'It appears this email is registered.\nSign-up with another email.',
        );
        return;
      }
      print('ran others');
      SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.setString('email', _email);
      await sp.setString('pno', _pno);
      await sp.setString('fname', _fname);
      await sp.setString('lname', _sname);
      await sp.setString('state', _state);
      await sp.setString(kCartItemsId, '');
      await sp.setString(kPasswordKey, _password);
      await sp.setString('uploaded', 'false');

      var userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email, password: _password);
      String userId = userCred.user.uid.toString();
      // String userId=uGetUniqueId();
      while (await AzSingle().checkIfIdExists(userId)) {
        userId = uGetUniqueId();
      }
      Customer customer = Customer()
        ..i = userId
        ..e = _email
        ..p = _pno
        ..s = _state
        ..f = _fname
        ..l = _sname
        ..q = _password
        ..a = ''
        ..w = '0'
        ..cid = ''
        ..t = 'c';
      await AzSingle().uploadCustomer2Azure(customer, changePass: false);
      await AzSingle().uploadUserMail(_email, userId);
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
      showProgress(false);
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MyHomePage(justSignedIn: true,);
      }));
      dispose();
    }catch(e,t){
      showProgress(false);
      uShowErrorNotification('An error occured');
      print('error: $e, trace: $t');
    }
  }

  toggleIconVisibility(){
    showPassword=!showPassword;
    setState(() {
    });
  }

  Widget getPicker(){
    if(Platform.isIOS){
      return  CupertinoPicker(
          squeeze: 3,
          diameterRatio: 1.5,
          useMagnifier: true,
          magnification: 1.2,
          itemExtent: 35, onSelectedItemChanged: (dex){
        _state=kStateList[dex].value.toString();
      }, children: kCupertinoStateList);
    }
    return DropdownButtonHideUnderline(
      child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
              value: _state,
              hint: Text('Select state', style: TextStyle(color: hintColor),),
              dropdownColor: kLightBlue,
              isDense: true,
              style: kStatePickerTextStyle,
              items: kStateList,
              onChanged: (value){
                _state=value.toString();
                print(_state);
                setState(() {
                  _state=value.toString();
                });
              })),
    );
  }

  @override
  void initState() {
    _controller=AnimationController(
      duration: Duration(milliseconds:1200, ),
      vsync: this,
    );

    slideInLeftAnim=CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _controller.addListener(() {
      setState(() {
      });
    });

    stateDropDown= DropdownButtonHideUnderline(
      child: ButtonTheme(
            alignedDropdown: true,
          child: DropdownButton<String>(
          value: _state,
          dropdownColor: kLightBlue,
          isDense: true,
          style: kStatePickerTextStyle,
          items: kStateList,
          onChanged: (value){
            _state=value.toString();
            print(_state);
            setState(() {
              _state=value.toString();
            });
          })),
    );
    stateCupPicker= CupertinoPicker(
        squeeze: 3,
        diameterRatio: 1.5,
        useMagnifier: true,
        magnification: 1.2,
        itemExtent: 35, onSelectedItemChanged: (dex){
      _state=kStateList[dex].value.toString();
    }, children: kCupertinoStateList);
  }

  @override
  Widget build(BuildContext context) {
    // showProgress(false);
    return ModalProgressHUD(
      inAsyncCall: progress,
      child: Container(
        child: Scaffold(
          backgroundColor: kThemeBlue,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 150,),
                    Hero(
                        tag: 'mainLogo',
                        child: Image.asset('images/logo.png', height: _controller.value*150,)),
                    SizedBox(height: 30,),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal:marginVal),
                      child: TextField(
                        onChanged: (string){_fname=string;},
                        focusNode: fnameFocus,
                        maxLength: 10,
                        maxLengthEnforced: true,
                        inputFormatters:[
                          LengthLimitingTextInputFormatter(10)
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          prefixIcon: Icon(CupertinoIcons.person, color: Colors.white,),
                          labelText: 'Enter first name',
                          labelStyle: TextStyle(
                              color:fnameFocus.hasFocus?hintColor:hintSelectedColor
                          ),
                          counterStyle: kHintStyle,
                          fillColor: textFillColor,
                        ),
                        textInputAction: TextInputAction.next,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.name,
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal:marginVal),
                      child: TextField(
                        onChanged: (string){_sname=string;},
                        focusNode: snameFocus,
                        maxLength: 10,
                        maxLengthEnforced: true,
                        inputFormatters:[
                          LengthLimitingTextInputFormatter(10)
                        ],
                        decoration: InputDecoration(
                            filled: true,
                            prefixIcon: Icon(CupertinoIcons.person, color: Colors.white,),
                            labelText: 'Enter last name',
                            labelStyle: TextStyle(
                                color:snameFocus.hasFocus?hintColor:hintSelectedColor
                            ),
                            hintStyle: TextStyle(
                                color: Colors.grey
                            ),
                            counterStyle: kHintStyle,
                            helperStyle: TextStyle(color: Colors.blue),
                            fillColor: textFillColor
                        ),
                        textInputAction: TextInputAction.next,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.name,
                      ),
                    ),

                    SizedBox(height: 10,),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal:marginVal),
                      child: TextField(
                        onChanged: (string){_pno=string;},
                        focusNode: phoneNumFocus,
                        maxLength: 11,
                        maxLengthEnforced: true,
                        inputFormatters:[
                          LengthLimitingTextInputFormatter(11)
                        ],
                        decoration: InputDecoration(
                            filled: true,
                            counterStyle: kHintStyle,
                            prefixIcon: Icon(CupertinoIcons.phone, color: Colors.white,),
                            labelText: 'Enter phone number',
                            labelStyle: TextStyle(
                                color:snameFocus.hasFocus?hintColor:hintSelectedColor
                            ),
                            fillColor: textFillColor
                        ),
                        textInputAction: TextInputAction.next,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    SizedBox(height: 10,),
                    // Container(
                    //   height: 70,
                    //   width: double.maxFinite,
                    //   color: textFillColor,
                    //   padding: EdgeInsets.symmetric(vertical: 5),
                    //   margin: EdgeInsets.symmetric(horizontal: marginVal),
                    //   child: Row(
                    //       crossAxisAlignment: CrossAxisAlignment.center,
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children:[
                    //         SizedBox(width: 10,),
                    //         Icon(CupertinoIcons.location, color: Colors.white,),
                    //         Expanded(
                    //           child: Container(
                    //               child: getPicker()
                    //           ),
                    //         ),
                    //       ]
                    //   ),
                    // ),

                    SizedBox(height: 30,),
                    Text('Enter and confirm email.\nThis email would be connected to all your transactions. ENSURE IT IS VALID.', textAlign: TextAlign.center, style: kNavTextStyle,),
                    SizedBox(height: 10,),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: marginVal),
                      child: TextField(
                        onChanged: (string){_email=string;},
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
                    SizedBox(height: 20,),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: marginVal),
                      child: TextField(
                        onChanged: (string){_email2=string;},
                        focusNode: email2Focus,
                        decoration: InputDecoration(
                            filled: true,
                            prefixIcon: Icon(CupertinoIcons.mail, color: Colors.white,),
                            labelText: 'Confirm email',
                            labelStyle: TextStyle(
                                color:email2Focus.hasFocus?hintColor:hintSelectedColor
                            ),
                            fillColor: textFillColor
                        ),
                        textInputAction: TextInputAction.next,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    SizedBox(height: 30,),
                    Text('Enter and confirm password.\nPassword must be at least 6 characters long.', textAlign: TextAlign.center, style: kNavTextStyle,),
                    SizedBox(height: 10,),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: marginVal),
                      child: TextField(
                        onChanged: (string){_password=string;},
                        focusNode: passwordFocus,
                        decoration: InputDecoration(
                            filled: true,
                            prefixIcon: Icon(CupertinoIcons.lock, color: Colors.white,),
                            suffixIcon: IconButton(icon: Icon(showPassword?Icons.visibility:Icons.visibility_off, color: Colors.grey,), onPressed: toggleIconVisibility,),
                            labelText: 'Enter password',
                            labelStyle: TextStyle(
                                color:passwordFocus.hasFocus?hintColor:hintSelectedColor
                            ),
                            fillColor: textFillColor
                        ),
                        textInputAction: TextInputAction.next,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: showPassword?false:true,
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: marginVal),
                      child: TextField(
                        onChanged: (string){_password2=string;},
                        focusNode: password2Focus,
                        decoration: InputDecoration(
                            filled: true,
                            prefixIcon: Icon(CupertinoIcons.lock, color: Colors.white,),
                            suffixIcon: IconButton(icon: Icon(showPassword?Icons.visibility:Icons.visibility_off, color: Colors.grey,), onPressed: toggleIconVisibility,),
                            labelText: 'Confirm password',
                            labelStyle: TextStyle(
                                color:password2Focus.hasFocus?hintColor:hintSelectedColor
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
                      margin: EdgeInsets.symmetric(horizontal: marginVal),
                      height: 45,
                      child: Row(
                        children: [
                          Expanded(
                              child:  Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                    color: kLightBlue,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: FlatButton(onPressed: (){
                                  attemptSave();
                                },
                                  child: Text('Sign up', style: kNavTextStyle,),
                                  splashColor: Colors.white,),
                              )
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 300,),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(height: 70,),
                  IconButton(
                    padding: EdgeInsets.all(20),
                      alignment: Alignment.bottomLeft,
                      splashColor: Colors.white,
                      icon: Icon(CupertinoIcons.arrow_left, color: Colors.white,), onPressed: (){Navigator.pop(context);}),],
              )]
          ),
        ),
      ),
    );

  }

}
