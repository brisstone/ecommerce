import 'package:ecommerce/NotificationHelper.dart';
import 'package:ecommerce/custom_widgets/promo_list_item.dart';
import 'package:ecommerce/custom_widgets/seller_list_item.dart';
import 'package:ecommerce/databases/seller_items_db.dart';
import 'package:ecommerce/main.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/screens/promote_options_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../utility_functions.dart';

class PromoModel extends ChangeNotifier{

  List<Widget> promoList = [];
  List<Widget> martList = [];
  List<MartItem> martItemsList = [];
  bool itemExpired=false;
  String walletValue='0';

  PromoModel._privateConstructor();

  static final PromoModel _instance = PromoModel._privateConstructor();

  factory PromoModel() {
    return _instance;
  }

  Future<void>  setWidgetLists(BuildContext context,{ bool showNots=false}) async {
    List<Widget> promoItems=[];
    try {
      String promotedItems= await uGetSharedPrefValue(kPromotedItems1);
      SellerLargeItemsDb sDb = SellerLargeItemsDb();
      martItemsList= await sDb.getAllMartItems();
      List<Widget> widList = [];
      for(MartItem element in martItemsList){
        bool isPromoted=false;
        int dex= promotedItems.indexOf(element.l);
        if(dex>=0){
          String sub=promotedItems.substring(dex);
          int dex2=sub.indexOf('<');
          if(dex2>=0){
            sub=sub.substring(0,dex2);
          }
          List<String> psplit=sub.split(',');
          if(psplit.length>1){

            isPromoted= isPromoActive(psplit[1]);
          }
          if(!isPromoted){
            promotedItems=promotedItems.replaceFirst(sub, '');
            promotedItems=promotedItems.replaceAll('<<', '<');
            await uSetPrefsValue(kPromotedItems1, promotedItems);
          }
        }
        int days2exp= isItemExpired(element.h);
        print('Days to expire: $days2exp');
        if(days2exp<=3 && days2exp>0) {
          if(showNots)showSub2expireNotification(days2exp, element.t);
        }else if(days2exp<=0) {
          element.h = '';
          itemExpired=true;
          if(showNots)showSubExpiredNotification(element.t);
        }
        if(isPromoted)promoItems.add(PromoListItem(context: context, mitem: element,));
        widList.add(ListItem(context: context, isPromoted: isPromoted, mitem: element,
          promoteItem: () {
            PromoteOptionsScreen( mitem: element, itemId: element.l, itemName:element.t, backContext: context,);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>
                PromoteOptionsScreen(mitem: element,itemId: element.l, itemName: element.t, backContext: context,)));
          },));
      }
      this.martList=widList;
      promoList=promoItems;
      await setWalletValue();
      notifyListeners();
      print('notified change');
    }catch(e){
      print('download items exception');
      return null;
    }
  }

  void showSubExpiredNotification(String title){
    showNotification(flutterLocalNotificationsPlugin,tittle : 'ALERT: Gmart item subscription.',
        message: "$title expired !!! Re-subscribe now.");
  }

  Future<void> showPromoteItemDialog(BuildContext context, String id, String itemName) async {
    String promo1ID=(await uGetSharedPrefValue(kPromo1Key))??30;
    String promo2ID=(await uGetSharedPrefValue(kPromoMultiKey))??100;
    Dialog promoteDialog= Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: kDialogLight,
        child:PromoteOptionsScreen(itemId: id, itemName:itemName, backContext: context, mitem: MartItem(),)
    );
    showGeneralDialog(context: context,
        barrierLabel: 'nune',
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 500),
        transitionBuilder: (_, anim, __, child){
          return SlideTransition(position: Tween(begin: Offset(0,1), end: Offset(0,0)).animate(anim), child: child,);
        },
        pageBuilder: (BuildContext context, _, __)=>(promoteDialog));
  }

  bool isPromoActive(String psplit) {
    List<String> splitDates=psplit.split(':');
    if(splitDates.length!=3)return false;
    int month=int.parse(splitDates[1]);
    int day=int.tryParse(splitDates[2])??1;
    int year=(int.tryParse(splitDates[0])??0)+2000;
    DateTime dt= DateTime(year,month,day);
    DateTime today=DateTime.now();
    return today.isBefore(dt)||today.isAtSameMomentAs(dt);
  }

  int isItemExpired(String psplit) {
    List<String> splitDates=psplit.split(':');
    if(splitDates.length!=3)return 10;// takes care of checks

    int month=int.parse(splitDates[1]);
    int day=int.tryParse(splitDates[2])??1;
    int year=(int.tryParse(splitDates[0])??0)+2000;

    DateTime dt= DateTime(year,month,day);
    DateTime today=DateTime.now();

    return  dt.difference(today).inDays;
  }

  setWalletValue() async{
    String wallVal=await uGetSharedPrefValue(kWalletKey);
    double walv=double.tryParse(wallVal)??0;
    walletValue=walv==null?'0':walv.toString();
    notifyListeners();
  }

  void showSub2expireNotification(int days2exp, String title) {
    showNotification(flutterLocalNotificationsPlugin,tittle : 'ALERT: Gmart item subscription.',
        message: "$title expires in $days2exp days !!! Re-subscribe now.");

  }
}