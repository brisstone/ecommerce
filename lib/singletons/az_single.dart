import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:azstore/azstore.dart';
import 'package:ecommerce/custom_widgets/mart_grid_item.dart';
import 'package:ecommerce/mart_objects/cart_item.dart';
import 'package:ecommerce/mart_objects/customer.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/mart_objects/order_item.dart';
import 'package:ecommerce/mart_objects/small_mitem.dart';
import 'package:ecommerce/screens/item_description_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../utility_functions.dart';

class AzSingle {

  AzSingle._privateConstructor();


  static final AzSingle _instance = AzSingle._privateConstructor();

  factory AzSingle() {
    return _instance;
  }

  Future<String> uploadPicToAzureGetID(String path) async {
    String downloadUrls='';
    //Optimised get pics to upload pics only if not already online
    String picId=uGetUniqueIdWPath(path);
    File testFile =File(path);
    Uint8List bytes = testFile.readAsBytesSync();
    var storage = AzureStorage.parse(uGetConnString());
//    try {
    await storage.putBlob('/gmart-pics/$picId.jpg',
      bodyBytes: bytes,
      contentType: 'image/png',
    );
    return picId;
  }

  Future<void> setOrderStatus(String orderId, String stat) async {
    String onlineDate= uExtractDate4rmGoogle(await uGetGoogleDate());
    String sendUrl = 'https://gmart-search.search.windows.net/indexes/order-dex/docs/index?api-version=2020-06-30';
    Request req = Request('POST', Uri.parse(sendUrl));
    req.headers['Content-Type'] = 'application/json';
    req.headers['api-key'] = uGetSearchKey();
    req.body =
    '{"value":[{"@search.action": "merge","id":"${orderId}","k":"$stat","upd":"$onlineDate"}]}';
    print('started search upload');
    await req.send().then((value) {
      print('upload result: ${value.statusCode},  ${value.reasonPhrase.toString()}');
      if(value.statusCode>=400) throw AzsingleException(' ${value.reasonPhrase.toString()}');
    });
  }

  Future<String> downloadAzurePic(String picId) async {
    if(picId.contains('GmartPics'))return picId;
    String url;
    String fileId=picId;
    url=picId.contains(kAzureImageStart)?picId: (kAzureImageStart+picId+'.jpg');

    //CONDITIONS: PIC REFERENCE WAS REPLACED WITH kUrlStart or kPicLink or PICS'S ID WAS STORED DIRECTLY
    final directory= await getApplicationDocumentsDirectory();
    String path= directory.path+'/GmartPics';
    if(!Directory(path).existsSync()) await Directory(path).create();

    path+='/$fileId';
    print('path: $path\nurl:$url\nfileId:$fileId\npicId:$picId');
    File newFile=File(path);
    await newFile.create();
    Response response=await get(url);
    await newFile.writeAsBytes(response.bodyBytes);
    return path;
  }

  Future<List<MartItem>> fetchFullSellerItems(String sellerId) async {
    Response response= await get('https://gmart-search.search.windows.net/indexes/gmart-dex/docs?api-version=2020-06-30&\$filter=(i%20eq%20\'${sellerId.startsWith('-')?'\-'+sellerId.substring(1):sellerId}\')',
        headers:
        {'Content-Type':'application/json',
          'api-key':uGetSearchKey()});
    print('fetch result: ${response.body.toString()}');//DEBUG
    List<MartItem> martList=[];
    MartItem tempItem;
    if(response!=null && response.body!=null){
      var res= jsonDecode(response.body);
      for (var v in res['value']) {
        tempItem = MartItem.fromAzureList(value: v);
        if(tempItem==null) continue;
        martList.add(tempItem);
//        await lDb.insertItem(tempItem);
      }
    }
    print('returned from Azure search');
    return martList;
  }

  Future<List<Widget>> getSearchResultFor(String s, BuildContext context) async {
    Response response= await get('https://gmart-search.search.windows.net/indexes/gmart-dex/docs?api-version=2020-06-30&\$searchFields=d&\$search=$s',
        headers:
        {'Content-Type':'application/json',
          'api-key':uGetSearchKey()});

    var res= jsonDecode(response.body);
    List<String> ids=[];
    for(var v in res['value']){
      ids.add(v['id']);
    }
    List<Widget> wids=[];
    var database;
    var myRef = database.reference().child('S');
    for(String s in ids){
      DataSnapshot snapShot= await myRef.child(s).once();
      SmallMitem item=SmallMitem.fromSnapshot(snapShot);
      item.I=s;
      wids.add(MartGridItem(smitem: item,onPressedFunc: (){
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return ItemDescriptionScreen(heroTag: item.I, smallMitem: item,);
        }));
      },));
    }
    return wids;
  }

  deleteImage(String pathId) async {
    var storage = AzureStorage.parse(uGetConnString());
//    try {
    await storage.deleteBlob('/gmart-pics/$pathId.jpg');
  }

  Future<String> getItemNumleft(String itemId) async {
   String numsLeft='';
   print('num item id: $itemId');
    Response response= await get('https://gmart-search.search.windows.net/indexes/gmart-dex/docs?api-version=2020-06-30&\$filter=id%20eq%20\'${itemId.startsWith('-')?'\-'+itemId.substring(1):itemId}\'&\$select=n',
        headers:
        {'Content-Type':'application/json',
          'api-key':uGetSearchKey()});
    var res= jsonDecode(response.body??'');
    print('response: ${response.body}');
    if(res!=null && response.body.contains('value') && res['value'].length>0) {
      String nres = res['value'][0]['n'];
       numsLeft = '${nres}';
    }else{
      numsLeft='';
    }
    return numsLeft;
  }

  Future<bool> checkIfIdIsUsed(String itemId) async {
   print('num item id: $itemId');
    Response response= await get('https://gmart-search.search.windows.net/indexes/gmart-dex/docs?api-version=2020-06-30&\$filter=id%20eq%20\'${itemId.startsWith('-')?'\-'+itemId.substring(1):itemId}\'&\$select=n',
        headers:
        {'Content-Type':'application/json',
          'api-key':uGetSearchKey()});
    var res= jsonDecode(response.body??'');
    print('response: ${response.body}');
    if(res!=null && response.body.contains('value') && res['value'].length>0) {
      return true;
    }else{
      return false;
    }
  }

  Future<void> deleteFromSearch( String id) async {
    String sendUrl = 'https://gmart-search.search.windows.net/indexes/gmart-dex/docs/index?api-version=2020-06-30';
    Request req = Request('POST', Uri.parse(sendUrl));
    req.headers['Content-Type'] = 'application/json';
    req.headers['api-key'] = uGetSearchKey();
    req.body =
    '{"value":[{"@search.action": "delete","id":"${id}"}]}';
    print('started search upload');

    await req.send().then((value) {
      print('upload result: ${value.statusCode},  ${value.reasonPhrase.toString()}');
          if(value.statusCode>=400) throw AzsingleException(' ${value.reasonPhrase.toString()}');
    });
  }

  setCloudPromoStatus(int indexOf, String itemId, String expirationDate, int duration) async {

      String sendUrl = 'https://gmart-search.search.windows.net/indexes/gmart-dex/docs/index?api-version=2020-06-30';
      Request req = Request('POST', Uri.parse(sendUrl));
      req.headers['Content-Type'] = 'application/json';
      req.headers['api-key'] = uGetSearchKey();
      req.body =
      '{"value":[{"@search.action": "merge","id":"${itemId}","promo":"prm,cat:$indexOf,$expirationDate,${duration>1?'naija':'state'}"}]}';
      print('started search upload');

      await req.send().then((value) {
        print('upload result: ${value.statusCode},  ${value.reasonPhrase.toString()}');
        if(value.statusCode>=400) throw AzsingleException(' ${value.reasonPhrase.toString()}');
      });
  }

  Future<String> getMarketStatus() async {
    Response response= await get('https://gmart-search.search.windows.net/indexes/gmart-dex/docs?api-version=2020-06-30-Preview&\$filter=id%20eq%20\'ALGURE_GMART_MARKET_STATUS\'&\$select=b',
        headers:
        {'Content-Type':'application/json',
          'api-key':kSearchApiKey});
    print('market status response: ${response.body}');
    if(response!=null && response.body!=null){
      var res= jsonDecode(response.body);
      if(res['value'].length>0){
        return res['value'][0]['b'].toString();
      }
    }
    return '';
    // var storage = AzureStorage.parse(uGetConnString());
    // bool b=false;
    // String res=null;
    // try {
    //   var result = await storage.getBlob('info/martstat');
    //   res=await result.stream.bytesToString();
    //   b=true;
    // }catch(e){
    //   b=false;
    // }
    // return res ;
  }

  Future<MartItem> getLargeItem(String itemId) async {
    Response response= await get('https://gmart-search.search.windows.net/indexes/gmart-dex/docs?api-version=2020-06-30-Preview&\$filter=id%20eq%20\'${itemId.startsWith('-')?'\-'+itemId.substring(1):itemId}\'',
        headers:
        {'Content-Type':'application/json',
          'api-key':kSearchApiKey});
    print('item to get id: $itemId, response: ${response.body}');
    MartItem mitem = MartItem();

    if(response!=null && response.body!=null){
      mitem= MartItem.fromOgAzureIndex(responseBody: response.body);
    }
    return mitem;
  }

  Future<String> getCartPictureUrl(CartItem cartItem) async {
    MartItem mitem = await getLargeItem(cartItem.t);
    String picId = mitem.k.split(',').firstWhere((element) => element.trim().isNotEmpty);
    return uGetAzurePicUrl(picId.trim());
  }

   Future<List<MartItem>> getSellerItems(String sellerId,{int top=8}) async {
     List<MartItem> objList=[];
     Response response= await get('https://gmart-search.search.windows.net/indexes/gmart-dex/docs?api-version=2020-06-30&\$filter=(i%20eq%20\'${sellerId.startsWith('-')?'\-'+sellerId.substring(1):sellerId}\')&\$top=$top',
         headers:
         {'Content-Type':'application/json',
           'api-key':kSearchApiKey });
     if(response!=null && response.body!=null){
       var res= jsonDecode(response.body);
       List<String> ids=[];
       for(var v in res['value']){
         ids.add(v['id']);
         MartItem mitem= MartItem.fromAzureList( value: v);
         objList.add(mitem);
       }
     }
     return objList;
   }

   Future<String> getItemReviews(String itemId) async {
     String review='';
     print('num item id: $itemId');
     Response response= await get('https://gmart-search.search.windows.net/indexes/gmart-dex/docs?api-version=2020-06-30&\$filter=id%20eq%20\'${itemId.startsWith('-')?'\-'+itemId.substring(1):itemId}\'&\$select=revs',
         headers:
         {'Content-Type':'application/json',
           'api-key':uGetSearchKey()});
     var res= jsonDecode(response.body??'');
     print('response: ${response.body}');
     if(res!=null && response.body.contains('value') && res['value'].length>0) {
       String nres = res['value'][0]['revs'];
       review = '${nres}';
     }else{
       review='';
     }
     return review;
   }

  Future<String> getItemPayableData(String itemId) async {
    print('num item id: $itemId');
    Response response= await get('https://gmart-search.search.windows.net/indexes/gmart-dex/docs?api-version=2020-06-30&\$filter=id%20eq%20\'${itemId.startsWith('-')?'\-'+itemId.substring(1):itemId}\'&\$select=b',
        headers:
        {'Content-Type':'application/json',
          'api-key':uGetSearchKey()});
    var res= jsonDecode(response.body??'');
    print('response: ${response.body}');

    if(res!=null && response.body.toString().contains('value') && res['value'].length>0) {
      return res['value'][0]['b'].toString() ;
    }else{
      return '';
    }
  }

  uploadItemToSearchService(MartItem mitem) async {
//    try {
    String sendUrl = 'https://gmart-search.search.windows.net/indexes/gmart-dex/docs/index?api-version=2020-06-30';
    Request req = Request('POST', Uri.parse(sendUrl));
    req.headers['Content-Type'] = 'application/json';
    req.headers['api-key'] = uGetSearchKey();
    req.body =
    '{"value":[{"@search.action": "mergeOrUpload","id":"${mitem.l}","d":"${mitem.d}","t":"${mitem.t}","s":"${mitem.s}","i":"${mitem.i}","p":"${mitem.p}","k":"${mitem.k}","b":"${mitem.b}","h":"${mitem.h}","m":"${mitem.m}","n":"${mitem.n}","n1":"item"}]}';
    print('started search upload');

    await req.send().then((value) {
      print('upload result: ${value.statusCode},  ${value.reasonPhrase.toString()}');
      if(value.statusCode>=400) throw Exception(' ${value.reasonPhrase.toString()}');
    });
//    }catch(e){
//      print('Upload exception: ${e.toString()}');
//    }
  }

  uploadOrder(OrderItem orderItem) async {
    String sendUrl = 'https://gmart-search.search.windows.net/indexes/order-dex/docs/index?api-version=2020-06-30';
    Request req = Request('POST', Uri.parse(sendUrl));
    req.headers['Content-Type'] = 'application/json';
    req.headers['api-key'] = uGetSearchKey();
    req.body =
    '{"value":[{"@search.action": "upload","id":"${orderItem.i}","t":"${orderItem.t}","n":"${orderItem.n}","u":"${orderItem.u}","p":"${orderItem.p}","s":"${orderItem.s}","c":"${orderItem.c}","y":"${orderItem.y}","z":"${orderItem.z}","d":"${orderItem.d}","k":"${orderItem.k}"}]}';
    print(' order started search upload');

    await req.send().then((value) {
      print('order upload result: ${value.statusCode},  ${value.reasonPhrase.toString()}');
      if(value.statusCode>=400) throw Exception(' ${value.reasonPhrase.toString()}');
    });
  }

  setNumLeft(String itemId, String numLeft) async {
    String sendUrl = 'https://gmart-search.search.windows.net/indexes/gmart-dex/docs/index?api-version=2020-06-30';
    Request req = Request('POST', Uri.parse(sendUrl));
    req.headers['Content-Type'] = 'application/json';
    req.headers['api-key'] = uGetSearchKey();
    req.body =
    '{"value":[{"@search.action": "merge","id":"${itemId}","n":"$numLeft"}]}';
    print('started num left upload');

    await req.send().then((value) {
      print('upload result: ${value.statusCode},  ${value.reasonPhrase.toString()}');
      if(value.statusCode>=400) throw AzsingleException(' ${value.reasonPhrase.toString()}');
    });
  }

  updateUser({String state = '', String address = '', String phoneNum = ''}) {
    //TODO: Create update user method to be called after buyer goes through a purchase process
  }

  Future<List<OrderItem>> fetchCustomerOrderItems(String cusId) async {
    Response response= await get('https://gmart-search.search.windows.net/indexes/order-dex/docs?api-version=2020-06-30&\$filter=(c%20eq%20\'${cusId.startsWith('-')?'\-'+cusId.substring(1):cusId}\')',
        headers:
        {'Content-Type':'application/json',
          'api-key':uGetSearchKey()});
    print('fetch result: ${response.body.toString()}');//DEBUG
    List<OrderItem> orderList=[];
    OrderItem tempItem;
    if(response!=null && response.body!=null){
      var res= jsonDecode(response.body);
      for (var v in res['value']) {
        tempItem = OrderItem.fromAzureList(value: v);
        if(tempItem==null) continue;
        orderList.add(tempItem);
//        await lDb.insertItem(tempItem);
      }
    }
    print('returned from Azure search');
    return orderList;
  }

  Future<List<CartItem>> fetchCustomerCartItems(String cusId) async {
    Response response= await
    get('https://gmart-search.search.windows.net/indexes/cartdex/docs?api-version=2020-06-30&\$filter=(c%20eq%20\'${cusId.startsWith('-')?'\-'+cusId.substring(1):cusId}\')',
        headers:
        {'Content-Type':'application/json',
          'api-key':uGetSearchKey()});
    print('fetch result: ${response.body.toString()}');//DEBUG
    List<CartItem> cartList=[];
    CartItem tempItem;
    if(response!=null && response.body!=null){
      var res= jsonDecode(response.body);
      for (var v in res['value']) {
        tempItem = CartItem.fromAzureList(value: v);
        if(tempItem==null) continue;
        cartList.add(tempItem);
//        await lDb.insertItem(tempItem);
      }
    }
    print('returned from Azure search');
    return cartList;
  }

  Future<List<MartItem>> searchForWord(String word) async {
    Response response= await get('https://gmart-search.search.windows.net/indexes/gmart-dex/docs?api-version=2020-06-30&searchFields=d,t&search=$word',
        headers:
        {'Content-Type':'application/json',
          'api-key':kSearchApiKey});

    List<MartItem> objList=[];
    if(response!=null && response.body!=null){
      var res= jsonDecode(response.body);
      List<String> ids=[];
      for(var v in res['value']){
        ids.add(v['id']);
        MartItem mitem= MartItem.fromAzureList( value: v);
        objList.add(mitem);
      }
    }
    return objList;
  }

  Future<List<OrderItem>> getSellerOrderIds(String sellerId) async {
    Response response= await get('https://gmart-search.search.windows.net/indexes/order-dex/docs?api-version=2020-06-30&\$filter=(s%20eq%20\'${sellerId.startsWith('-')?'\-'+sellerId.substring(1):sellerId}\')&\$select=id,k&\$top=1000',
        headers:
        {'Content-Type':'application/json',
          'api-key':uGetSearchKey()});
    print('fetch seller order ids result: ${response.body.toString()}');//DEBUG
    List<OrderItem> orderIds=[];
    OrderItem tempItem;
    if(response!=null && response.body!=null){
      var res= jsonDecode(response.body);
      for (var v in res['value']) {
        if(v==null) continue;
        tempItem=new OrderItem();
        tempItem.i = v['id'].toString();
        tempItem.k = v['k'].toString();
        orderIds.add(tempItem);
      }
    }
    print('returned from Azure search');
    return orderIds;
  }


  Future<List<OrderItem>> getCustomerOrderIds(String sellerId) async {
    Response response= await get('https://gmart-search.search.windows.net/indexes/order-dex/docs?api-version=2020-06-30&\$filter=(c%20eq%20\'${sellerId.startsWith('-')?'\-'+sellerId.substring(1):sellerId}\')&\$select=id,k&\$top=1000',
        headers:
        {'Content-Type':'application/json',
          'api-key':uGetSearchKey()});
    print('fetch seller order ids result: ${response.body.toString()}');//DEBUG
    List<OrderItem> orderIds=[];
    OrderItem tempItem;
    if(response!=null && response.body!=null){
      var res= jsonDecode(response.body);
      for (var v in res['value']) {
        if(v==null) continue;
        tempItem=new OrderItem();
        tempItem.i = v['id'].toString();
        tempItem.k = v['k'].toString();
        orderIds.add(tempItem);
      }
    }
    print('returned from Azure search');
    return orderIds;
  }

  Future<void> uploadCartItem(CartItem cartItem) async {
    String sendUrl = 'https://gmart-search.search.windows.net/indexes/cartdex/docs/index?api-version=2020-06-30';
    Request req = Request('POST', Uri.parse(sendUrl));
    req.headers['Content-Type'] = 'application/json';
    req.headers['api-key'] = uGetSearchKey();
    req.body =
    '{"value":[{"@search.action": "upload","id":"${cartItem.i}","t":"${cartItem.t}","n":"${cartItem.n}","u":"${cartItem.u}","p":"${cartItem.p}","s":"${cartItem.s}","c":"${cartItem.c}","y":"${cartItem.y}","z":"${cartItem.z}","d":"${cartItem.d}","k":"${cartItem.k}"}]}';
    print(' order started search upload');

    await req.send().then((value) {
      print('order upload result: ${value.statusCode},  ${value.reasonPhrase.toString()}');
      if(value.statusCode>=400) throw Exception(' ${value.reasonPhrase.toString()}');
    });
  }

  Future<void> removeCartItem(String cartItemId) async {
    String sendUrl = 'https://gmart-search.search.windows.net/indexes/cartdex/docs/index?api-version=2020-06-30';
    Request req = Request('POST', Uri.parse(sendUrl));
    req.headers['Content-Type'] = 'application/json';
    req.headers['api-key'] = uGetSearchKey();
    req.body = '{"value":[{"@search.action": "delete","id":"${cartItemId}"}]}';
    print('started search upload');

    await req.send().then((value) {
      print('upload result: ${value.statusCode},  ${value.reasonPhrase.toString()}');
      if(value.statusCode>=400) throw AzsingleException(' ${value.reasonPhrase.toString()}');
    });
  }

  Future<OrderItem> fetchOrderItem(String orderId) async {
    Response response= await
    get('https://gmart-search.search.windows.net/indexes/order-dex/docs?api-version=2020-06-30&\$filter=id%20eq%20\'${orderId.startsWith('-')?'\-'+orderId.substring(1):orderId}\'',
        headers:
        {'Content-Type':'application/json',
          'api-key':uGetSearchKey()});

    var res= jsonDecode(response.body??'');
    print('response: ${response.body}');
    OrderItem orderItem = OrderItem();
    if(res!=null && response.body.contains('value') && res['value'].length>0) {
      orderItem= OrderItem.fromAzureList(value:res['value'][0]);
    }else{

    }
    return orderItem;
  }

  Future<void> uploadCustomer2Azure(Customer customer, {bool changePass=true}) async {
      var storage = AzureStorage.parse(uGetConnString());
      if(changePass) {
        Customer oldC = await getOnlineCustomer(customer.i);
        if(oldC==null) throw 'Null cloud';
        print('gotten online customer: $oldC');
        customer.q=oldC.q;
      }
      // customer.t=await uGetSharedPrefValue(kShopInfo);
      String json= jsonEncode(customer.toMap());
      await storage.putBlob('profiles/${customer.i}', contentType: 'application/json', body: json);
  }

  Future<Customer> getOnlineCustomer(String id) async {
    var storage = AzureStorage.parse(uGetConnString());
    var res= await storage.getBlob('profiles/$id');
    var result=jsonDecode(await res.stream.bytesToString());
    print('fetch customer : $result, ${result['e']}');

    if(res==null|| result==null) return null;
    return Customer.fromMap(result);
  }
  
  Future<void> uploadUserMail(String email, String value) async {
    email=email.replaceAll('.', '').replaceAll('#', '').replaceAll('[', '').replaceAll(']', '').replaceAll('*', '').replaceAll('+', '').replaceAll('-', '').replaceAll('?', '').replaceAll('{', '').replaceAll('}', '').replaceAll('(', '').replaceAll(')', '').replaceAll('!', '').replaceAll('&', '').replaceAll('^', '').replaceAll('"', '').replaceAll('~', '').replaceAll(':', '').replaceAll('\\', '');
    var storage = AzureStorage.parse(uGetConnString());
    await storage.putBlob('usermails/$email',body: value );
  }

  Future<bool> checkUserMail(String email) async {
    email=email.replaceAll('.', '').replaceAll('#', '').replaceAll('[', '').replaceAll(']', '').replaceAll('*', '').replaceAll('+', '').replaceAll('-', '').replaceAll('?', '').replaceAll('{', '').replaceAll('}', '').replaceAll('(', '').replaceAll(')', '').replaceAll('!', '').replaceAll('&', '').replaceAll('^', '').replaceAll('"', '').replaceAll('~', '').replaceAll(':', '').replaceAll('\\', '');
    var storage = AzureStorage.parse(uGetConnString());
    bool b=false;
    try {
      var res = await storage.getBlob('usermails/$email');
      if(res.statusCode >=300) throw Exception ('Auth error');
      print('res: ${await res.stream.bytesToString()}');
      b=true;
    }catch(e){
      b=false;
    }
    return b;
  }

  Future<String> getUserId(String email) async {
    email=email.replaceAll('.', '').replaceAll('#', '').replaceAll('[', '').replaceAll(']', '').replaceAll('*', '').replaceAll('+', '').replaceAll('-', '').replaceAll('?', '').replaceAll('{', '').replaceAll('}', '').replaceAll('(', '').replaceAll(')', '').replaceAll('!', '').replaceAll('&', '').replaceAll('^', '').replaceAll('"', '').replaceAll('~', '').replaceAll(':', '').replaceAll('\\', '');
    var storage = AzureStorage.parse(uGetConnString());
    bool b=false;
    try {
      var res = await storage.getBlob('usermails/$email');
      return await res.stream.bytesToString();
      b=true;
    }catch(e){
      b=false;
    }
    return null;
  }

  Future<bool> updateCloudWallet(var value) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      if (sp.containsKey(kIdKey) && sp.get(kIdKey).toString() != null && sp
          .get(kIdKey)
          .toString()
          .length > 0) {
        String id = sp.get(kIdKey).toString();
        print('gotten to wallet upload $id');
        await sp.setString(kIdKey, id);

        Customer oldC= await getOnlineCustomer(id);
 Customer customer = new Customer();
        customer.i = await uGetSharedPrefValue(kIdKey);
        customer.s =  await uGetSharedPrefValue(kStateKey);
        customer.l =  await uGetSharedPrefValue(kLnameKey);
        customer.f =  await uGetSharedPrefValue(kFnameKey);
        customer.w = value.toString();
        customer.a =  await uGetSharedPrefValue(kAdressKey);
        customer.p =  await uGetSharedPrefValue(kPhoneKey);
        customer.e =  await uGetSharedPrefValue(kMailKey);
        customer.q=oldC.q;
        customer.t=await uGetSharedPrefValue(kShopInfo);//(sp.containsKey(kShopInfo)&&sp.getString(kShopInfo).length>0 && sp.getString(kShopInfo).toString()!='null')?sp.getString(kShopInfo):'c';
        print('gotten to upload');
        await uploadCustomer2Azure(customer);
//        await kDbref.child('cad').child(id).child('w').set(value);
        print('wallet uploaded $value');
      } else {

        String mail = sp.get(kMailKey).toString();
        String password = sp.get(kPasswordKey).toString();

        print(mail);
        print('gotten to create user');

        Customer customer = new Customer();
        print('gotten to upload');
      }
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  Future<bool> checkIfIdExists(String id) async {
    var storage = AzureStorage.parse(uGetConnString());
    bool b=false;
    try {
      var res = await storage.getBlob('profiles/$id');
     if(res.statusCode >=300 ) throw Exception('Error');
      b=true;
    }catch(e){
      b=false;
    }
    return b;
  }

  Future<void> setUserAsSeller() async {
    String id= await uGetSharedPrefValue(kIdKey);
    String mail= await uGetSharedPrefValue(kMailKey);
    String sellerInfo=await uGetSharedPrefValue(kShopInfo);
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (sp.containsKey(kIdKey) && sp.get(kIdKey).toString() != null && sp
        .get(kIdKey)
        .toString()
        .length > 0) {
      String id = sp.get(kIdKey).toString();
      print('gotten to wallet upload $id');
      Customer oldC= await getOnlineCustomer(id);
      await sp.setString(kIdKey, id);
      Customer customer = new Customer();
      customer.i = await uGetSharedPrefValue(kIdKey);
      customer.s =  await uGetSharedPrefValue(kStateKey);
      customer.l =  await uGetSharedPrefValue(kLnameKey);
      customer.f =  await uGetSharedPrefValue(kFnameKey);
      customer.w = await uGetSharedPrefValue(kWalletKey);
      customer.a =  await uGetSharedPrefValue(kAdressKey);
      customer.p =  await uGetSharedPrefValue(kPhoneKey);
      customer.e =  await uGetSharedPrefValue(kMailKey);
      customer.q=oldC.q;
      customer.t=await uGetSharedPrefValue(kShopInfo);
      print('gotten to upload  stat:');
      await uploadCustomer2Azure(customer);
//        await kDbref.child('cad').child(id).child('w').set(value);
      print('wallet uploaded $customer');
    } else {

      String mail = sp.get(kMailKey).toString();
      String password = sp.get(kPasswordKey).toString();

      print(mail);
      print('gotten to create user');

      Customer customer = new Customer();
      print('gotten to upload');
      }
    }

  Future<String> retrieveCouponValue(String code) async {
    //This retrieves coupon value and deletes the coupon
    var storage = AzureStorage.parse(uGetConnString());
    bool b=false;
    String res=null;
    try {
      var result = await storage.getBlob('coupons/$code');
      res=await result.stream.bytesToString();
      b=true;
      await storage.deleteBlob('coupons/$code');
    }catch(e){
      b=false;
    }
    return res ;
  }

 Future<String> getAppUpdate() async{
    String connectionString='DefaultEndpointsProtocol=https;AccountName=gmartstore;AccountKey=fVzyg6tHRLehC5TKAnR4EFjGjZnBOqQPQlV75BCZgX+Iue0K364qv1G/tfQDIO3JP/KeCErjTQYOIVS9HNpk+g==;EndpointSuffix=core.windows.net';
    var storage = AzureStorage.parse(connectionString);
    var response= await storage.getBlob('info/update');
    String value=await response.stream.bytesToString();
    return value;
  }
}

class AzsingleException implements Exception{
  String _message;
  AzsingleException(this._message);

  @override
  String toString() {
    return 'AzsingleException{message: $_message}';
  }


}