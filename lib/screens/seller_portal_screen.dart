
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/fragmented_screens/sellerportal_mainpage.dart';
import 'package:ecommerce/fragmented_screens/sellerportal_orders.dart';
import 'package:ecommerce/mart_objects/order_filter_data.dart';
import 'package:ecommerce/providers/seller_orders_provider.dart';
import 'package:ecommerce/screens/collect_payment_data_screen.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class SellerPortalScreen extends StatefulWidget {
  @override
  _SellerPortalScreenState createState() => _SellerPortalScreenState();
}

class _SellerPortalScreenState extends State<SellerPortalScreen> {

  bool progress=false;
  int selectedDex=0;

  PageController _pageController=PageController(
    initialPage: 0
  );

  bool ordersSet=false;
  OrderFilterData _chosenOrderFilter;
  List<DropdownMenuItem<OrderFilterData>>  _filterList=[
    DropdownMenuItem<OrderFilterData>(child: Text('All'), value:OrderFilterData('All orders', '') ,) ,
    DropdownMenuItem<OrderFilterData>(child: Text('All open'), value:OrderFilterData('All open orders', 'o') ,) ,
    DropdownMenuItem<OrderFilterData>(child: Text('Paid/pending'), value:OrderFilterData('Paid/pending', '1') ,) ,
    DropdownMenuItem<OrderFilterData>(child: Text('Delivered'), value:OrderFilterData('Delivered', '2'),) ,
    DropdownMenuItem<OrderFilterData>(child: Text('Refund request'), value:OrderFilterData('Refund request', '3'),) ,
    DropdownMenuItem<OrderFilterData>(child: Text('Refund approved'), value:OrderFilterData('Refund approved', '4'),) ,
    DropdownMenuItem<OrderFilterData>(child: Text('Seller settled'), value: OrderFilterData('Payment close', '5'),),
    DropdownMenuItem<OrderFilterData>(child: Text('Buyer settled'), value:OrderFilterData('Refund close', '6') ,) ,
  ];

  @override
  void initState() {
    showShopInfo();
  }

  @override
  void didChangeDependencies() {
//    itemsSet=true;
    if(!ordersSet) setupSellerOrderListener();// if(itemsSet)setSellerItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedDex==0?'My Portal':'My Orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: kThemeBlue,
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        leading: FlatButton(
            onPressed: (){
              Navigator.pop(context);
            },
            splashColor: Colors.white,
            child: Icon(CupertinoIcons.arrow_left, color: Colors.white,)),
        elevation: 0,
        actions: [
          if(selectedDex==0)
          IconButton(
            icon: Icon(Icons.share, color:Colors.white),
            splashColor: Colors.white,
            onPressed: (){
              shareItem();
            },
          ),
          if(selectedDex==1)
            Padding(
              padding: EdgeInsets.only(right:8.0),
              child: DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton <OrderFilterData>(
                      value: Provider.of<SellerOrderProvider>(context).filterValue,
                      dropdownColor: kLightBlue,
                      isDense: true,
                      icon: Icon(Icons.filter_list_sharp, color: Colors.white, size: 24,),
                      style: kStatePickerTextStyle,
                      items: this._filterList,
                      onChanged: (value){
                        _chosenOrderFilter=value;
                        Provider.of<SellerOrderProvider>(context, listen: false).filterOrderStats(value);
                        print('selected ${value.status} ${value.statusCode}');
                      }),
                ),
              ),
            )
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: progress,
//        child: SellerPortalMainPage(),
        child: PageView(
          onPageChanged: (n){
            selectedDex=n;
            setState(() { });
          },
          children: [
            SellerPortalMainPage(),
            SellerportalOrdersPage()
          ],
          controller: _pageController,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Orders'),
        ],
        currentIndex: selectedDex,
        selectedItemColor: kThemeOrange,
        unselectedItemColor: Colors.grey,
        onTap: (dex){
//          if(dex==1) {
//            Navigator.pop(context);
//            Navigator.push(context, MaterialPageRoute(builder: (context) => SellerPortalOrders()));
//          }
                    _pageController.animateToPage(dex, duration: Duration(milliseconds: 600), curve: Curves.easeInSine);
        },
      ),
    );
  }

  Future<void> setupSellerOrderListener() async {
    String sellerD= await uGetSharedPrefValue(kShopItemsDownloaded);
    if(sellerD==null || sellerD.isEmpty){
      return;
    }
    await Provider.of<SellerOrderProvider>(context, listen: false).retrieveSellerOrders();
    Provider.of<SellerOrderProvider>(context, listen: false).listenForOrders();
    Provider.of<SellerOrderProvider>(context, listen: false).filterOrderStats(_filterList[0].value);

    ordersSet=true;
  }


  @override
  void dispose() {
    _pageController.dispose();
  }

  Future<void> shareItem() async {
    setProgress(true);
    try {
      String sellId= await uGetSharedPrefValue(kIdKey);
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix:'https://gmart.page.link',// 'https://com.algure.gmartapp',
        link: Uri.parse('https://gmart.page.link/shop:${sellId}'),
        androidParameters: AndroidParameters(
          packageName: 'com.algure.gmartapp',
          minimumVersion: 0,
        ),
        iosParameters: IosParameters(
          bundleId: 'com.algure.gmartapp',
          minimumVersion: '1.0.1',
          appStoreId: kIosAppStoreId,
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
            title: 'Check out this shop on Gmart.ng',
            description: 'Buy and sell anything!',
            imageUrl: Uri.parse(kShopSharePic)
        ),
      );
      Uri dynamicUrl = await parameters.buildUrl();

      if(await uCheckInternet()) {
        final ShortDynamicLink shortDynamicLink = await parameters
            .buildShortLink();
        dynamicUrl = shortDynamicLink.shortUrl;
      }
      setProgress(false);
      print('dynamic url: ${dynamicUrl.toString()}');
      Share.share('Check out this shop on Gmart.ng ${dynamicUrl.toString()}',
          subject: 'Gmart.ng');
    }catch(e){
      setProgress(false);
      uShowErrorNotification('An error occured !');
      print('share exception ${e.toString()}');
    }
  }

  void showShopInfo() async {
    String s= await uGetSharedPrefValue(kShopInfo);
    print('kShopInfo: $s');
  }

  void setProgress(bool bool) {
    setState(() {
      progress=bool;
    });
  }

}
