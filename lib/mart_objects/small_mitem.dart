import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

import 'mart_item.dart';

class SmallMitem{

  String I;//Item id
  String P;//Item picture
  String N;//Item name
  String M;//Item price (Money)
  String S;//SellerId
  String T;//state
  String E;//Expiration date

  @override
  String toString() {
    return('Item id:$I, picture: $P, Name: $N, price:$M, SellerId:$S, state:$T, Expiration date:$E');
  } //Expiration Date


  SmallMitem();

  SmallMitem.fromMartItem(MartItem item){
    this.I=item.l;
    this.N=item.t;
    this.M=item.m.split("<")[0];
    this.P=item.k;
    this.S=item.i;
    this.T=item.s;
    if(item.k.startsWith(",")){
      this.P=item.k.substring(1).split(",")[0];
    }else{
      this.P=item.k.split(",")[0];
    }
  }
  Map<String, dynamic> toMap(){
    return {
      'i':I,
      'p':P,
      'n':N,
      'm':M,
      's':S,
      't':T,
      'e':E
    };
  }

  SmallMitem.fromJson(var value) {

    I=value['i'].toString();
    P=value['p'].toString();
    N=value['n'].toString();
    M=value['m'].toString();
    S=value['s'].toString();
    T=value['t'].toString();
    E=value['e'].toString();
  }

  SmallMitem.fromSnapshot(DataSnapshot snapShot) {
    var value=snapShot.value;

    I=value['i'].toString();
    P=value['p'].toString();
    N=value['n'].toString();
    M=value['m'].toString();
    S=value['s'].toString();
    T=value['t'].toString();
    E=value['e'].toString();
  }

  SmallMitem.fromAzureSearch( value) {
    try {
      I = value['id'].toString();
      P = value['k'].toString();
      N = value['t'].toString();
      M = value['m'].toString();
      S = value['i'].toString();
      T = value['s'].toString();
      E = value['h'].toString();
    }catch(e){
      print('azure data to smitem error: ${e.toString()}');
    }
  }
}