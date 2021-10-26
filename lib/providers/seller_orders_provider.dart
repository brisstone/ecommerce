import 'dart:async';

import 'package:ecommerce/constants.dart';
import 'package:ecommerce/custom_widgets/order_list_item.dart';
import 'package:ecommerce/databases/order_mitems_db.dart';
import 'package:ecommerce/databases/seller_items_db.dart';
import 'package:ecommerce/databases/seller_orders_db.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/mart_objects/order_filter_data.dart';
import 'package:ecommerce/mart_objects/order_item.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../NotificationHelper.dart';
import '../main.dart';

class SellerOrderProvider extends ChangeNotifier{

  Map<String,OrderItem> sellerOrders ={};
  List<OrderListItem> orderWidgets=[];
  bool listenSet=false;
  double amount = 0;
  String filterStatus='';
  OrderFilterData filterValue = OrderFilterData('', '');

  void filterOrderStats(OrderFilterData orderK){
    orderWidgets = [];
    List<OrderItem> itemsWithK = sellerOrders.values.where((
        element) => element.k.trim() == orderK).toList();
    double tempBill;
    filterStatus=orderK.status;
    filterValue=orderK;
    if(orderK.statusCode.isEmpty){
      amount=0;
      orderWidgets = [];
      List<OrderItem> itemsWithK = sellerOrders.values.toList();
      for(OrderItem oid in itemsWithK){
        orderWidgets.add(OrderListItem(oItem: oid, onPressedFunc: (){}));
        tempBill= double.tryParse(oid.p) ?? 0;
        if(tempBill!=null &&amount!=null)amount = amount + tempBill;
        else if(tempBill==null)amount=null;
      }
    }
    else if(orderK.statusCode=='o'){
      amount=0;
      orderWidgets = [];
      List<OrderItem> itemsWithK = sellerOrders.values.where((
          element) => element.k.trim() != '5' && element.k.trim() != '6').toList();
      for(OrderItem oid in itemsWithK){
        orderWidgets.add(OrderListItem(oItem: oid, onPressedFunc: (){}));
        tempBill= double.tryParse(oid.p)??0;
        if(tempBill!=null &&amount!=null)amount= amount + tempBill;
        else if(tempBill==null)amount=null;
      }
    }   else if(orderK.statusCode.startsWith('c')){
      List<OrderItem> itemsWithK = sellerOrders.values.where((
          element) => element.k.trim() == '5' || element.k.trim() == '6').toList();
      for(OrderItem oid in itemsWithK){
        orderWidgets.add(OrderListItem(oItem: oid, onPressedFunc: (){}));
      }
    }else {
      amount=0;
      itemsWithK = sellerOrders.values.where((
          element) => element.k.trim() == orderK.statusCode).toList();
      orderWidgets = [];
      for (OrderItem oid in itemsWithK) {
        orderWidgets.add(OrderListItem(oItem: oid, onPressedFunc: () {}));
        tempBill= double.tryParse(oid.p)??0;
        if(tempBill!=null &&amount!=null)amount= amount + tempBill;
        else if(tempBill==null)amount=null;
      }
    }
    notifyListeners();
  }

  Future<void> retrieveSellerOrders() async {
    SellerOrdersDb sellerOrdersDb= SellerOrdersDb();
    List<OrderItem> sellerOrdList=(await sellerOrdersDb.getMartItems())??[];
    for(OrderItem oid in sellerOrdList){
      sellerOrders[oid.i]=oid;
      orderWidgets.add(OrderListItem(oItem: oid, onPressedFunc: (){}));
    }
    notifyListeners();
  }

  Future<bool> hasAnyMartItems() async {
    String subTime='';
    SellerLargeItemsDb sDb = SellerLargeItemsDb();
    List<MartItem> sellerItems= await sDb.getAllMartItems();
    if(sellerItems==null||sellerItems.length==0) return false;
    for(MartItem martItem in sellerItems){
      subTime=martItem.h;
      if(subTime!=null&&subTime.contains(':')&&!uIsItemExpired(subTime))return true;
    }
    return false;
  }

  Future<void> listenForOrders() async {
    if(listenSet)return;
    if(!(await hasAnyMartItems()))return;
    String userId= await uGetSharedPrefValue(kIdKey);

    await quickFetchForOrders();
    listenSet=true;
    Timer.periodic(Duration(minutes: 2), (timer) async {
      List<OrderItem> orderIds= await AzSingle().getSellerOrderIds(userId);
      List<String> mainIds=[];
      Set<String> newIds=new Set();
      for(OrderItem id in orderIds){
        if(!sellerOrders.containsKey(id.i))mainIds.add(id.i);
        else await updateOrderStatus(id);
        newIds.add(id.i);
      }
      for(String id in mainIds){
        await downloadOrderAndNotify(id);
        if(filterValue!=null)filterOrderStats(filterValue);
      }
      for(String id in sellerOrders.keys){
        if(!newIds.contains(id)){
          closeOrder(id);
          if(filterValue!=null)filterOrderStats(filterValue);
        }
      }
    });
  }

  Future<void> quickFetchForOrders() async {
    if(!(await uCheckInternet()))return;
    String userId= await uGetSharedPrefValue(kIdKey);
    List<OrderItem> orderIds= await AzSingle().getSellerOrderIds(userId);
    List<String> mainIds=[];
    Set<String> newIds=new Set();
    for(OrderItem id in orderIds){
      if(!sellerOrders.containsKey(id.i))mainIds.add(id.i);
      else await updateOrderStatus(id);
      newIds.add(id.i);
    }
    for(String id in mainIds){
      await downloadOrderAndNotify(id);
      if(filterValue!=null)filterOrderStats(filterValue);
    }
    for(String id in sellerOrders.keys){
      if(!newIds.contains(id)){
        closeOrder(id);
        if(filterValue!=null)filterOrderStats(filterValue);
      }
    }
  }

  Future<void> downloadOrderAndNotify(String orderId) async {
    OrderItem oit= await AzSingle().fetchOrderItem(orderId);
    if(oit==null)return;
    String objectId= oit.t;
    addToOrdersList(oit);

    SellerLargeItemsDb sellit= SellerLargeItemsDb();
    MartItem orderMitem= await sellit.getItem(objectId);

    SellerOrdersDb sdb= SellerOrdersDb();
    await sdb.insertItem(oit);

    print('order main item: ${orderMitem}');
    OrderItemsDb odb= OrderItemsDb();
    if(orderMitem!=null) await odb.insertItem(orderMitem);

    if(orderMitem!=null && orderMitem.q.startsWith(',')&& orderMitem.q.length>1)
      orderMitem.q=orderMitem.q.substring(1);
    String image = orderMitem!=null && orderMitem.q!=null?orderMitem.q.split(',')[0]:'';

    orderWidgets.add(OrderListItem(oItem: oit,
        image: image
        , onPressedFunc: (){}));
    if(oit.k.startsWith('1'))showNotification(flutterLocalNotificationsPlugin,tittle : '[Gmart Seller Update]', message: "You have a new order. ${oit.n}");
    else showNotification(flutterLocalNotificationsPlugin,tittle : '[Gmart Seller Update]', message: " You have an order. ${oit.n}");
    notifyListeners();
  }

  void addToOrdersList(OrderItem oit) {
    sellerOrders[oit.i]=oit;
  }


  Future<void> closeOrder(String id) async {

    SellerOrdersDb sdb= SellerOrdersDb();
    OrderItem oit=sellerOrders[id];
    if(oit==null) return;
    if(oit.k=='2'){
      showNotification(flutterLocalNotificationsPlugin,tittle : 'Seller closed order.', message: "${oit.n}");
      oit.k='5';
      await sdb.insertItem(oit);
      updateWidgetList(oit);
    }else if(oit.k=='4'){
      showNotification(flutterLocalNotificationsPlugin,tittle : 'Buyer collected refund.', message: "${oit.n}");
      oit.k='6';
      await sdb.insertItem(oit);
      updateWidgetList(oit);
    }
  }

  Future<void> updateOrderStatus(OrderItem id) async {

    SellerOrdersDb sdb= SellerOrdersDb();
    OrderItem oit=sellerOrders[id.i];
    if(oit==null) return;
    if(oit.k!=id.k) {
      showNotification(flutterLocalNotificationsPlugin,tittle : 'Buyer updated order status.', message: "${oit.n}");
      oit.k=id.k;
      await sdb.insertItem(oit);
      updateWidgetList(oit);
    }
  }

  void updateWidgetList(OrderItem oit){
    int dex= orderWidgets.indexWhere((element) => element.oItem.i==oit.i);
    if(dex<0)return;
    orderWidgets.removeAt(dex);
    orderWidgets.insert(0,OrderListItem(oItem: oit, onPressedFunc: (){}));
    notifyListeners();
  }
}