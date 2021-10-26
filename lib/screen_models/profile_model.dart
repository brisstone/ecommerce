
import 'dart:io';

import 'package:ecommerce/mart_objects/user_info_object.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class ProfileModel{

  Future<String> getUserName() async {
    SharedPreferences sp=await SharedPreferences.getInstance();
    String fname=await sp.get(kFnameKey).toString();
    String sname=await sp.get(kLnameKey).toString();
    return '$fname $sname';
  }

  Future<List<Widget>> getUserDetailsWidgets() async {

    SharedPreferences sp=await SharedPreferences.getInstance();

    List payMethodList=[
      UserInfoObjects(CupertinoIcons.mail, await sp.getString(kMailKey)??'', 'Email'),
      UserInfoObjects(CupertinoIcons.phone, await sp.getString(kPhoneKey)??'', 'Phone number'),
      UserInfoObjects(CupertinoIcons.location, await sp.getString(kStateKey)??'', 'State'),
    ];
    if(sp.containsKey(kAdressKey) && sp.getString(kAdressKey).length>0) {
      payMethodList.add(UserInfoObjects(CupertinoIcons.location_solid, await sp.getString(kAdressKey) ?? '', 'Address'));
    }
    List<Widget> res=[];
    int i= payMethodList.length-1;

    for(UserInfoObjects item in payMethodList){
      res.add(
          TextButton(
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
}