
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/mart_objects/customer.dart';
import 'package:ecommerce/providers/profile_provider.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  bool _progress=false;

  var fNameController;
  var sNameController;
  var phoneController;
  var addressController;


  @override
  void initState() {
    setProviderPack();

  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_)  {
      print("WidgetsBinding");
      fNameController=TextEditingController(text: Provider.of<ProfileProvider>(context, listen: false).fName);
      sNameController=TextEditingController(text: Provider.of<ProfileProvider>(context, listen: false).sName);
      phoneController=TextEditingController(text: Provider.of<ProfileProvider>(context, listen: false).phoneNum);
      addressController=TextEditingController(text: Provider.of<ProfileProvider>(context, listen: false).sAddress);
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> butList=[
      Expanded(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
          decoration: BoxDecoration(
              color: kLightBlue,
              borderRadius: BorderRadius.circular(10)
          ),
          child: FlatButton(onPressed:(){
            attemptSaveAgain();
          },
            child: Text('Save', style: kNavTextStyle,),
            splashColor: Colors.white,),
        ),
      )
    ];

    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: _progress,
        child: Padding(
          padding:  EdgeInsets.symmetric(vertical:38.0, horizontal: 15),
          child: SingleChildScrollView(
            child: Material(
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(height: 30,),
                  Container(
                      alignment: Alignment.centerLeft,
                      child: FlatButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.clear, color: kThemeBlue, size:  20, ))),
                  Icon(CupertinoIcons.person_add_solid, color: kLightBlue, size:  100,),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child:  TextField(
                        controller: TextEditingController(text: Provider.of<ProfileProvider>(context).fName),
                        style: kInputTextStyle,
                        textAlign: TextAlign.start,
                        maxLength: 20,
                        inputFormatters:[
                          LengthLimitingTextInputFormatter(20)
                        ],
                        onChanged: (value){
                          Provider.of<ProfileProvider>(context,listen: false).setFname(value);
                        },
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          filled: true,
                          prefixIcon: Icon(CupertinoIcons.phone, color: kThemeBlue,),
                          fillColor: Colors.white,
                          labelText: 'Input first name',
                          hintStyle: kHintStyle,
                          border: kInputOutlineBorder,
                        )
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child:  TextField(
                        controller: TextEditingController(text: Provider.of<ProfileProvider>(context).sName),
                        style: kInputTextStyle,
                        textAlign: TextAlign.start,
                        maxLength: 20,
                        inputFormatters:[
                          LengthLimitingTextInputFormatter(20)
                        ],
                        onChanged: (value){
                          Provider.of<ProfileProvider>(context,listen: false).setSname(value);
                        },
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          filled: true,
                          prefixIcon: Icon(CupertinoIcons.person, color: kThemeBlue,),
                          fillColor: Colors.white,
                          labelText: 'Input last/sur name',
                          hintStyle: kHintStyle,
                          border: kInputOutlineBorder,
                        )
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child:  TextField(
                        controller: TextEditingController(text: Provider.of<ProfileProvider>(context).phoneNum),
                        style: kInputTextStyle,
                        textAlign: TextAlign.start,
                        maxLength: 11,
                        maxLengthEnforced: true,
                        inputFormatters:[
                          LengthLimitingTextInputFormatter(11)
                        ],
                        onChanged: (value){
                          Provider.of<ProfileProvider>(context,listen: false).setPhoneNum(value);
                          print ('phone num ${ Provider.of<ProfileProvider>(context,listen: false).phoneNum}phoneNum');
                        },
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          filled: true,
                          prefixIcon: Icon(CupertinoIcons.phone, color: kThemeBlue,),
                          fillColor: Colors.white,
                          labelText: 'Input (whatsapp) phone number ',
                          hintStyle: kHintStyle,
                          border: kInputOutlineBorder,
                        )
                    ),
                  ),
                  // Container(
                  //   height: 70,
                  //   width: double.maxFinite,
                  //   decoration: BoxDecoration(
                  //       border: Border.all(width: 1, color: kThemeBlue,
                  //       ),
                  //       borderRadius: BorderRadius.circular(8)
                  //   ),
                  //   margin: EdgeInsets.all(8.0),
                  //   child: Row(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children:[
                  //         SizedBox(width: 10,),
                  //         Icon(CupertinoIcons.location, color: kThemeBlue,),
                  //         Expanded(
                  //           child: Container(
                  //             child: getPicker()
                  //           ),
                  //         ),
                  //       ]
                  //   ),
                  // ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child:  TextField(
                        controller: TextEditingController(text: Provider.of<ProfileProvider>(context).sAddress),
                        style: kInputTextStyle,
                        textAlign: TextAlign.start,
                        maxLength: 30,
                        inputFormatters:[
                          LengthLimitingTextInputFormatter(30)
                        ],
                        onChanged: (value){
                          Provider.of<ProfileProvider>(context,listen: false).setAddress(value);
                          print ('address ${ Provider.of<ProfileProvider>(context,listen: false).sAddress}');
                        },
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        maxLengthEnforced: true,
                        decoration: InputDecoration(
                          filled: true,
                          prefixIcon: Icon(CupertinoIcons.location_solid, color: kThemeBlue,),
                          fillColor: Colors.white,
                          labelText: 'Input specific address',
                          hintStyle: kHintStyle,
                          border: kInputOutlineBorder,
                        )
                    ),
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
      ),
    );
    return Container();
  }


  List<Widget> getCupertinpText(){
    List<Widget> ans=[];
    for(String s in kStateStringList){
      ans.add(  Text(s, style: TextStyle(color: kThemeBlue)));
    }
    return ans;
  }

  Future<void> attemptSaveAgain() async {
    showProgress(true);
    try {

      if(!(await uCheckInternet())){
        showProgress(false);
        uShowNoInternetDialog(context);
        return;
      }
      if ( Provider.of<ProfileProvider>(context,listen: false).fName.toString() == 'null' ||  Provider.of<ProfileProvider>(context,listen: false).fName.isEmpty) {
        showProgress(false);
        uShowErrorDialog(this.context, 'First name cannot be empty');
        return;
      } else if ( Provider.of<ProfileProvider>(context,listen: false).fName.contains(' ')) {
        showProgress(false);
        uShowErrorDialog(this.context, 'First name cannot contain white/empty space');
        return;
      }else if(Provider.of<ProfileProvider>(context,listen: false).fName.length>10){
        showProgress(false);
        uShowErrorDialog(this.context, 'First name is too long');
        return;
      }
      if (Provider.of<ProfileProvider>(context,listen: false).sName.toString() == 'null' || Provider.of<ProfileProvider>(context,listen: false).sName.isEmpty) {
        showProgress(false);
        uShowErrorDialog(this.context, 'Last/Sur name cannot be empty');
        return;
      } else if (Provider.of<ProfileProvider>(context,listen: false).sName.contains(' ')) {
        showProgress(false);
        uShowErrorDialog(this.context, 'Last/Sur name cannot contain white/empty space');
        return;
      }else if(Provider.of<ProfileProvider>(context,listen: false).sName.length>10){
        showProgress(false);
        uShowErrorDialog(
            this.context, 'Last/Sur name is too long');
        return;
      }
      // phoneNum = phoneNum;
      if (Provider.of<ProfileProvider>(context,listen: false).phoneNum.toString() == 'null' || Provider.of<ProfileProvider>(context,listen: false).phoneNum.isEmpty) {
        showProgress(false);
        uShowErrorDialog(this.context, 'Phone number cannot be empty');
        return;
      } else if (Provider.of<ProfileProvider>(context,listen: false).phoneNum.length != 11) {
        showProgress(false);
        uShowErrorDialog(this.context, 'Invalid phone number');
        return;
      }


      // state = state;
      if (Provider.of<ProfileProvider>(context,listen: false).sAddress == null || Provider.of<ProfileProvider>(context,listen: false).sAddress.trim().isEmpty) {
        showProgress(false);
        uShowErrorDialog(this.context, 'Address cannot be empty');
        return;
      }
      reSaveDetails();
    }catch(e, t){
      print('error $e trace: $t');
      showProgress(false);
      uShowErrorDialog(context, 'An error occured. Please check inputs.');
    }
  }

  Future<void> reSaveDetails() async {
    print('ran others');
    SharedPreferences sp=await SharedPreferences.getInstance();
    await uSetPrefsValue('pno', Provider.of<ProfileProvider>(context,listen: false).phoneNum);
    await uSetPrefsValue('fname', Provider.of<ProfileProvider>(context,listen: false).fName);
    await uSetPrefsValue(kLnameKey, Provider.of<ProfileProvider>(context,listen: false).sName);
    if(!Provider.of<ProfileProvider>(context,listen: false).sAddress.isEmpty && Provider.of<ProfileProvider>(context,listen: false).sAddress.toString()!='null')
      await uSetPrefsValue(kAdressKey,Provider.of<ProfileProvider>(context,listen: false).sAddress);
    else
      await uSetPrefsValue(kAdressKey,'');

    await sp.setString(kResetKey,"true");
    await Provider.of<ProfileProvider>(context,listen: false).setUserDetails();
    Customer customer=Customer()
      ..i=await uGetSharedPrefValue(kIdKey)
      ..e=Provider.of<ProfileProvider>(context,listen: false).email
      ..p=Provider.of<ProfileProvider>(context,listen: false).phoneNum
      // ..s=Provider.of<ProfileProvider>(context,listen: false).state
      ..f=Provider.of<ProfileProvider>(context,listen: false).fName
      ..l=Provider.of<ProfileProvider>(context,listen: false).sName
      ..q=await uGetSharedPrefValue(kPasswordKey)
      ..a=Provider.of<ProfileProvider>(context,listen: false).sAddress
      ..w=await uGetSharedPrefValue(kWalletKey)
      ..t=await uGetSharedPrefValue(kShopInfo);//(sp.containsKey(kShopInfo)&&sp.getString(kShopInfo).length>0 && sp.getString(kShopInfo).toString()!='null')?sp.getString(kShopInfo):'c';
    // IMPLEMENT PROFILE EDIT
    await AzSingle().uploadCustomer2Azure(customer);
    showProgress(false);
    Navigator.pop(context);
  }

  void showProgress(bool bool) {
    setState(() {
      _progress=bool;
    });
  }

  Future<void> setProviderPack() async {
    showProgress(true);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("WidgetsBinding");
      await Provider.of<ProfileProvider>(context,listen:false).setUserDetails();
    });
    showProgress(false);
  }

}
