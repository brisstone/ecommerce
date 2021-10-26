import 'package:firebase_database/firebase_database.dart';

class CartItem{

  String i;//Cart item unique ID
  String t;//Item ID
  String n;//Item name
  String u;//Item units
  String p;//order price
  String s;//Seller ID
  String c;//Customer ID
  String y;//Seller details
  String z;//Customer details
  String d;//Order date
  String k;//Order status

  CartItem();

  @override
  String toString() {
    return 'oderId:$i, itemId: $t, object name:$n, object-units:$u, sellerId:$s, customerId:$i, seller details:$y, customer details:$z, order-date:$d, order-status:$k';
  }

  CartItem.fromAzureList({dynamic value}) {
    if (value != null ) {
      i=value.containsKey('id')?value['id'].toString():'';
      t=value.containsKey('t')?value['t'].toString():'';
      n=value.containsKey('n')?value['n'].toString():'';
      u=value.containsKey('u')?value['u'].toString():'';
      p = value.containsKey('p')?value['p'].toString():'';
      s = value.containsKey('s')?value['s'].toString():'';
      c =value.containsKey('c')? value['c'].toString():'';
      y = value.containsKey('y')?value['y'].toString():'';
      z =value.containsKey('z')? value['z'].toString():'';
      d = value.containsKey('d')?value['d'].toString():'';
      k = value.containsKey('k')?value['k'].toString():'';
    }
  }

  CartItem.fromMap(dynamic value) {
    i=value.containsKey('i')?value['i'].toString():'';
    t=value.containsKey('t')?value['t'].toString():'';
    n=value.containsKey('n')?value['n'].toString():'';
    u=value.containsKey('u')?value['u'].toString():'';
    p = value.containsKey('p')?value['p'].toString():'';
    s = value.containsKey('s')?value['s'].toString():'';
    c =value.containsKey('c')? value['c'].toString():'';
    y = value.containsKey('y')?value['y'].toString():'';
    z =value.containsKey('z')? value['z'].toString():'';
    d = value.containsKey('d')?value['d'].toString():'';
    k = value.containsKey('k')?value['k'].toString():'';
  }

  Map<String, dynamic> toMap(){
    return {
      'i':i,
      't':t,
      'n':n,
      'u':u,
      'p':p,
      's':s,
      'c':c,
      'y':y,
      'z':z,
      'd':d,
      'k':k
    };
  }


  CartItem getLargeUpload() {
    CartItem res= CartItem();
    res.i=i;//Order ID
    res.t=t;//Item ID
    res.n=n;//Item name
    res.u=u;//Item units
    res.p=p;//order price
    res.s=s;//Seller ID
    res.c=c;//Customer ID
    res.y=y;//Seller details
    res.z='';//Customer details
    res.d=d;//Order date
    res.k=k;//Order status
    return res;
  }

}