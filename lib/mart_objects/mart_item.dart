import 'dart:convert';


import 'package:ecommerce/mart_objects/small_mitem.dart';

import '../constants.dart';

class MartItem{
  String l;//Item id
  String t;//tittle
  String d;//description
  String s;//state
  String i;//seller Id
  String p;//seller profile
  String k;//pictures
  String b;//allow payment(bool)
  String h;//subscription expiration time
  String m;//price (m)
  String n;//number left
  String q;//device pics

  MartItem.empty(){}

  void addSmally(SmallMitem smitem){
    this.l= smitem.I;//Item id
    this.t= smitem.N;//Item name
    this.i= smitem.S;//SellerId
    this.s= smitem.T;//state
    this.h= smitem.E;//Expiration Date
  }


  @override
  String toString() {
    return 'itemId: $l, tittle:$t, description:$d, state:$s, sellerId:$i, seller profile:$p, pictures:$k, allow payment:$b, expiration time:$h, prices:$m, numLeft:$n, devicePics:$q';
  }

  MartItem.fromMap(Map<String, dynamic> value) {
    l=value['l'].toString();
    t=value['t'].toString();
    i=value['i'].toString();
    h=value['h'].toString();
    q=value['q'].toString();
    p = value['p'].toString();
    b = value['b'].toString();
    d = value['d'].toString();
    k = value['k'].toString();
    s = value['s'].toString();
    n = value['n'].toString();
    m = value['m'].toString();
  }

  Map<String, dynamic> toMap(){
    return {
      'l': l,
      't':t,
      'd':d,
      's':s,
      'i':i,
      'p':p,
      'k':k,
      'b':b,
      'h':h,
      'm':m,
      'n':n,
      'q':q
    };
  }
  MartItem.newp();

  MartItem.fromOgAzureIndex({dynamic responseBody}) {
    if (responseBody != null && responseBody.toString().contains('value')) {
      var response= jsonDecode(responseBody);
      if(response['value'].length==0)return;
      var value = response['value'][0];
      l = value.containsKey('id') ? value['id'].toString() : "";
      t = value.containsKey('t') ? value['t'].toString() : '';
      i = value.containsKey('i') ? value['i'].toString() : '';
      h = value.containsKey('h') ? value['h'].toString() : '';
      q = value.containsKey('q') ? value['q'].toString() : '';
      p = value.containsKey('p') ? value['p'].toString() : '';
      b = value.containsKey('b') ? value['b'].toString() : '';
      d = value.containsKey('d') ? value['d'].toString() : '';
      k = value.containsKey('k') ? value['k'].toString() : '';
      s = value.containsKey('s') ? value['s'].toString() : '';
      n = value.containsKey('n') ? value['n'].toString() : '';
      m = value.containsKey('m') ? value['m'].toString() : '';
    }
  }

  MartItem.fromAzureList({dynamic value}) {
    if (value != null ) {
      l = value.containsKey('id') ? value['id'].toString() : "";
      t = value.containsKey('t') ? value['t'].toString() : '';
      i = value.containsKey('i') ? value['i'].toString() : '';
      h = value.containsKey('h') ? value['h'].toString() : '';
      q = value.containsKey('q') ? value['q'].toString() : '';
      p = value.containsKey('p') ? value['p'].toString() : '';
      b = value.containsKey('b') ? value['b'].toString() : '';
      d = value.containsKey('d') ? value['d'].toString() : '';
      k = value.containsKey('k') ? value['k'].toString() : '';
      s = value.containsKey('s') ? value['s'].toString() : '';
      n = value.containsKey('n') ? value['n'].toString() : '';
      m = value.containsKey('m') ? value['m'].toString() : '';
    }
  }

  MartItem({dynamic snapShot, SmallMitem smitem}) {
    if(snapShot!=null && snapShot.value!=null ) {
      var value = snapShot.value;
      l=value.containsKey('l')? value['l'].toString():"";
      t=value.containsKey('t')?value['t'].toString():'';
      i=value.containsKey('i')?value['i'].toString():'';
      h=value.containsKey('h')?value['h'].toString():'';
      q=value.containsKey('q')?value['q'].toString():'';
      p = value.containsKey('p')?value['p'].toString():'';
      b = value.containsKey('b')?value['b'].toString():'';
      d = value.containsKey('d')?value['d'].toString():'';
      k = value.containsKey('k')?value['k'].toString():'';
      s = value.containsKey('s')?value['s'].toString():'';
      n = value.containsKey('n')?value['n'].toString():'';
      m = value.containsKey('m')?value['m'].toString():'';
    }

    if(smitem!=null) {
      l = smitem.I.toString(); //Item id
      t = smitem.N.toString(); //Item name
      i = smitem.S.toString(); //SellerId
      s = smitem.T.toString(); //state
      h = smitem.E.toString(); //Expiration Date
    }
  }

  MartItem getLargeUpload() {
    MartItem res=MartItem();
    res.b=b;
    res.d=d;
    res.n=n;
    res.m=m;
    res.p=p;
    if(k!=null) {
      res.k = k.replaceAll(kPicLink.toString(), '');
      if(res.k.startsWith(','))res.k=res.k.substring(1);
      List<String> pics=res.k.split(',');
      if(pics.length>1)
        res.k=pics[1];
      else
        res.k='';
    }else res.k='';
    res.l='';
    res.t='';
    res.i='';
    res.h='';
    res.q='';
    res.s='';
    return res;
  }

  SmallMitem getSmallUpload(){
//    String I;//Item id
//    String P;//Item picture
//    String N;//Item name
//    String M;//Item price (Money)
//    String S;//SellerId
//    String T;//state
//    String E;//Expiration Date
    SmallMitem smitem=SmallMitem();

    smitem.I='';
    smitem.P='';

    smitem.N=t;
    smitem.M=m!=null?m.split("<")[0]:m;
    smitem.S=i;
    smitem.T=s;
    smitem.E=h;
    if(k!=null) {
      if (k.startsWith(",")) {
        List<String> picParts=k.substring(1).split(",");

        smitem.P = picParts[0].replaceAll(kPicLink.toString(), '');
        int dex=1;
        while(dex<picParts.length && smitem.P.isEmpty){
          smitem.P=picParts[dex].replaceAll(kPicLink.toString(), '');
        }
      } else {
        List<String> picParts=k.split(",");
        smitem.P = picParts[0].replaceAll(kPicLink.toString(), '');
        int dex=1;
        while(dex<picParts.length && smitem.P.isEmpty){
          smitem.P=picParts[dex].replaceAll(kPicLink.toString(), '');
        }
      }
    }else{
      smitem.P=k;
    }
    return smitem;
  }
}