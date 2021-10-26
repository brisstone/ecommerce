

import 'package:ecommerce/constants.dart';
import 'package:ecommerce/mart_objects/user_info_object.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfileProvider extends ChangeNotifier{

  String phoneNum = '';
  String email = '';
  String fName = '';
  String sName = '';
  String sAddress = '';
  String name='';

  List<Widget> userDetails=[];

  void setPhoneNum(String s){
    phoneNum=s;
    // notifyListeners();
  }
  void setEmail(String s){
    email=s;
    // notifyListeners();
  }
  void setFname(String s){
    fName=s;
    print('fName : $fName');
    // notifyListeners();
  }
  void setSname(String s){
    sName=s;

    // notifyListeners();
  }

  void setAddress(String s){
    sAddress=s;
    // notifyListeners();
  }
  setUserDetails() async {
    userDetails=await getUserDetailsWidgets();
    SharedPreferences sp= await SharedPreferences.getInstance();
    phoneNum=sp.getString(kPhoneKey);
    email=sp.getString(kMailKey);
    fName=sp.getString(kFnameKey);
    sName=sp.getString(kLnameKey);
    // state=sp.getString(kStateKey);
    sAddress=sp.getString(kAdressKey)??'';
    name=await getUserName();
    notifyListeners();
  }

  Future<List<Widget>> getUserDetailsWidgets() async {

    SharedPreferences sp=await SharedPreferences.getInstance();

    List payMethodList=[
      UserInfoObjects(CupertinoIcons.mail, await sp.getString(kMailKey)??'', 'Email'),
      UserInfoObjects(CupertinoIcons.phone, await sp.getString(kPhoneKey)??'', 'Phone number'),
    ];
    if(sp.containsKey(kAdressKey) && sp.getString(kAdressKey).length>0) {
      payMethodList.add(UserInfoObjects(CupertinoIcons.location_solid, await sp.getString(kAdressKey) ?? '', 'Address'));
    }
    List<Widget> res=[];
    int i= payMethodList.length-1;

    for(UserInfoObjects item in payMethodList){
      res.add(TextButton(
        onPressed: () {  },
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
    return res;
  }

  Future<String> getUserName() async {
    SharedPreferences sp=await SharedPreferences.getInstance();
    String fname=await sp.get(kFnameKey).toString();
    String sname=await sp.get(kLnameKey).toString();
    return '$fname $sname';
  }

}