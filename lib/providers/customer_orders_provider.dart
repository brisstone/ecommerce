import 'dart:async';

import 'package:ecommerce/constants.dart';
import 'package:ecommerce/custom_widgets/order_list_item.dart';
import 'package:ecommerce/databases/customer_orders_db.dart';
import 'package:ecommerce/databases/order_mitems_db.dart';
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

class CustomerOrderProvider extends ChangeNotifier{

  Map<String,OrderItem> customerOrders ={};
  List<OrderListItem> orderWidgets=[];
  bool listenSet=false;
  String filterStat='';

  OrderFilterData filterValue;

  void filterOrderStats(OrderFilterData orderK){
    filterValue=orderK;
    List<OrderItem> itemsWithK = customerOrders.values.where((element) => element.k.trim() == orderK).toList();
    filterStat=orderK.status;
    if(orderK.statusCode==''){
      List<OrderItem> itemsWithK = customerOrders.values.toList();
      orderWidgets = [];
      for(OrderItem oid in itemsWithK){
        orderWidgets.add(OrderListItem(oItem: oid, onPressedFunc: (){}));
      }
    }
    else if(orderK.statusCode=='o'){
      List<OrderItem> itemsWithK = customerOrders.values.where((
          element) => element.k.trim() != '5' && element.k.trim() != '6').toList();
      orderWidgets = [];
      for(OrderItem oid in itemsWithK){
        orderWidgets.add(OrderListItem(oItem: oid, onPressedFunc: (){}));
      }
    }
    else if(orderK.statusCode.startsWith('c')){
      List<OrderItem> itemsWithK = customerOrders.values.where((
          element) => element.k.trim() == '5' || element.k.trim() == '6').toList();
      orderWidgets = [];
      for(OrderItem oid in itemsWithK){
        orderWidgets.add(OrderListItem(oItem: oid, onPressedFunc: (){}));
      }
    }else {
      itemsWithK = customerOrders.values.where((
          element) => element.k.trim() == orderK.statusCode).toList();
      orderWidgets = [];
      for (OrderItem oid in itemsWithK) {
        orderWidgets.add(OrderListItem(oItem: oid, onPressedFunc: () {}));
      }
    }
    notifyListeners();
  }

  Future<void> retrieveCustomerOrders() async {
    CustomerOrdersDb customerOrdersDb= CustomerOrdersDb();
    List<OrderItem> sellerOrdList=await customerOrdersDb.getMartItems();
    orderWidgets=[];
    customerOrders= {};
    for(OrderItem oid in sellerOrdList){
      customerOrders[oid.i]=oid;
      orderWidgets.add(OrderListItem(oItem: oid, onPressedFunc: (){}));
    }
    notifyListeners();
  }

  Future<bool> hasAnyMartItems() async {
    String subTime='';
    OrderItemsDb oDb = OrderItemsDb();
    List<MartItem> orderMartItems= await oDb.getMartItems();
    if(orderMartItems==null||orderMartItems.length==0) return false;
    for(MartItem martItem in orderMartItems){
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
      List<OrderItem> orderIds= await AzSingle().getCustomerOrderIds(userId);
      List<String> mainIds=[];
      Set<String> newIds=new Set();
      for(OrderItem id in orderIds){
        if(!customerOrders.containsKey(id.i))mainIds.add(id.i);
        else await updateOrderStatus(id);
        newIds.add(id.i);
      }
      for(String id in mainIds){
        await downloadOrderAndNotify(id);
        if(filterValue!=null)filterOrderStats(filterValue);
      }
      for(String id in customerOrders.keys){
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
    List<OrderItem> orderIds= await AzSingle().getCustomerOrderIds(userId);
    List<String> mainIds=[];
    Set<String> newIds=new Set();
    customerOrders = {};
    for(OrderItem id in orderIds){
      if(!customerOrders.containsKey(id.i))mainIds.add(id.i);
      else await updateOrderStatus(id);
      newIds.add(id.i);
    }
    for(String id in mainIds){
      await downloadOrderAndNotify(id);
      if(filterValue!=null)filterOrderStats(filterValue);
    }
    for(String id in customerOrders.keys){
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

    OrderItemsDb sellit= OrderItemsDb();
    MartItem orderMitem= await sellit.getItem(objectId);

    CustomerOrdersDb cdb= CustomerOrdersDb();
    await cdb.insertItem(oit);

    print('order main item: ${orderMitem}');
    OrderItemsDb odb= OrderItemsDb();
    if(orderMitem!=null) await odb.insertItem(orderMitem);

    if(orderMitem!=null && orderMitem.q.startsWith(',')&& orderMitem.q.length>1)
      orderMitem.q=orderMitem.q.substring(1);
    String image = orderMitem!=null && orderMitem.q!=null?orderMitem.q.split(',')[0]:'';

    orderWidgets.add(OrderListItem(oItem: oit,
        image: image
        , onPressedFunc: (){}));
    showNotification(flutterLocalNotificationsPlugin,tittle : '[Gmart Update] Order retrieved.', message: "${oit.n}");
    notifyListeners();
  }

  void addToOrdersList(OrderItem oit) {
    customerOrders[oit.i]=oit;
  }

  Future<void> closeOrder(String id) async {

    CustomerOrdersDb sdb= CustomerOrdersDb();
    OrderItem oit=customerOrders[id];
    if(oit==null) return;
    if(oit.k=='2'){
      showNotification(flutterLocalNotificationsPlugin,tittle : '[Gmart Update] Seller closed order.', message: "${oit.n}");
      oit.k='5';
      await sdb.insertItem(oit);
      updateWidgetList(oit);
    }else if(oit.k=='4'){
      showNotification(flutterLocalNotificationsPlugin,tittle : '[Gmart Update] Buyer collected refund.', message: "${oit.n}");
      oit.k='6';
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

  Future<void> updateOrderStatus(OrderItem id) async {

    CustomerOrdersDb cdb= CustomerOrdersDb();
    OrderItem oit=customerOrders[id.i];
    if(oit==null) return;
    if(oit.k!=id.k) {
      showNotification(flutterLocalNotificationsPlugin,tittle : '[Gmart Update] Buyer updated order status.', message: "${oit.n}");
      oit.k=id.k;
      await cdb.insertItem(oit);
      updateWidgetList(oit);
    }
  }
}