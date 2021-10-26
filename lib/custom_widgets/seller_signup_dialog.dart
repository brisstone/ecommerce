import 'package:ecommerce/constants.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerSignUp extends StatefulWidget {
  Function completeSignUp;
  @override
  _SellerSignUpState createState() => _SellerSignUpState();
}

class _SellerSignUpState extends State<SellerSignUp> {
  var shopInfo='';
  bool _termsCheckedValue=false;
  List<Widget> butList=[];

  var errorText='';

  bool _progress=false;

  @override
  void initState() {
    butList=[
      Expanded(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
          decoration: BoxDecoration(
              color: kThemeBlue,
              borderRadius: BorderRadius.circular(10)
          ),
          child: GestureDetector(onTap:() async {
            showProgress(true);

            if(!_termsCheckedValue) {
              showProgress(false);
              uShowErrorNotification('Please agree to our terms and conditions.');
              return;
            }
            if(shopInfo.isEmpty || shopInfo=='null'){
              showProgress(false);
              uShowErrorNotification( 'Your shop description cannot be null.');
              return;
            }else if(shopInfo.length>30){
              showProgress(false);
              uShowErrorNotification( 'Your shop description is too long');
              return;
            }else if(shopInfo.length<5){
              showProgress(false);
              uShowErrorNotification( 'Your shop description is too short');
              return;
            }else if(!(await uCheckInternet())){
              showProgress(false);
              uShowNoInternetDialog(context);
              return;
            }
            showProgress(true);
            await uSetPrefsValue(kShopInfo, shopInfo);
            await uSetPrefsValue(kShopItemsDownloaded, 'non');
            await AzSingle().setUserAsSeller();
            showProgress(false);
            Navigator.popAndPushNamed(context, '/sellerPortal');
          },
            child: Text('Proceed', style: kNavTextStyle,),
          ),
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _progress,
      child: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10,),
                Container(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.clear, color: kThemeBlue, size:  20, ))),
                Padding(padding: EdgeInsets.all(8),
                  child: Text('New seller sign-up',
                    textAlign:TextAlign.center, style: TextStyle(color: kThemeBlue, fontSize: 18, fontWeight: FontWeight.bold),),
                ),Image.asset('images/mobileshop.png', height: 150, width: 150,),
                // Icon(CupertinoIcons.shopping_cart, color: kThemeOrange, size:  150,),
                Padding(padding: EdgeInsets.all(8),
                  child: Text('We need a brief shop name. e.g BJ\'s unisex shoes & clothes',
                    textAlign:TextAlign.center, style: TextStyle(color: kThemeBlue, fontSize: 12),),
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child:  TextField(
                      controller: TextEditingController(text: shopInfo),
                      style: kInputTextStyle,
                      textAlign: TextAlign.start,
                      maxLength: 30,
                      onChanged: (value){
                        shopInfo=value;
                        print('shopInfo $shopInfo');
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(30)
                      ],
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      maxLines: 2,
                      decoration: InputDecoration(
                        filled: true,
                        prefixIcon: Icon(CupertinoIcons.info, color: kThemeBlue,),
                        fillColor: Colors.white,
                        labelText: 'Shop description.' ,
                        errorStyle: kHintStyle.apply(color: Colors.red),
                        hintStyle: kHintStyle,
                        border: kInputOutlineBorder,
                      )
                  ),
                ),
                CheckboxListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text("By ticking, you agree to our ", style: TextStyle(color: kThemeBlue, fontSize: 10),),GestureDetector(
                        // onTap: openTermsPage,
                        child: Text("\tterms.", style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),)),]
                  ),
                  value: _termsCheckedValue,
                  onChanged: (newValue) {
                    setState(() {
                      _termsCheckedValue = newValue;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                ),
                Container(
                  height: butList!=null?60:2,
                  margin: EdgeInsets.only(bottom: 70),
                  child: Row(
                    children: butList,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onSignUpPressed(){

  }

  Future<void> openTermsPage() async {
    try {
      const url = kSellerTermsAndConditionsPage;
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }catch(e){
      uShowErrorNotification('An error occured');
    }
  }

  void showProgress(bool bool) {
    setState(() {
      _progress=bool;
    });
  }
}
