import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/custom_widgets/mart_grid_azure.dart';
import 'package:ecommerce/custom_widgets/mart_grid_item.dart';
import 'package:ecommerce/custom_widgets/martgrid_id.dart';
import 'package:ecommerce/custom_widgets/nav_button.dart';
import 'package:ecommerce/databases/cart_items_db.dart';
import 'package:ecommerce/databases/customer_orders_db.dart';
import 'package:ecommerce/databases/favorite_item_db.dart';
import 'package:ecommerce/databases/mart_item_db.dart';
import 'package:ecommerce/databases/order_mitems_db.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/mart_objects/small_mitem.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/providers/customer_orders_provider.dart';
import 'package:ecommerce/providers/favorite_provider.dart';
import 'package:ecommerce/providers/promo_model.dart';
import 'package:ecommerce/providers/seller_orders_provider.dart';
import 'package:ecommerce/screen_models/search_screen_model.dart';
import 'package:ecommerce/screens/cart_screen.dart';
import 'package:ecommerce/screens/change_password_screen.dart';
import 'package:ecommerce/screens/login_screen.dart';
import 'package:ecommerce/screens/search_screen.dart';
import 'package:ecommerce/screen_models/home_screen_model.dart';
import 'package:ecommerce/screens/update_prompt_screen.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:http/http.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:package_info/package_info.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import 'item_description_screen.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.justLoggedIn=false, this.justSignedIn=false}) : super(key: key);
   String title;
  bool justLoggedIn;
  bool justSignedIn;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  HomeScreenModel homeScreenModel=new HomeScreenModel();
  String _email='sample@example.com';
  String _name='Name';

  List<Widget> martList=[];

  bool resolvingItems=false;
  bool progress=false;

  // TODO: Add link to website
  // TODO: change company name
  @override
  void initState() {
//    setAllMarketItems(context);
    setupCartItems();
    initUserDetails();
    setupFavorites();
    initDynamicLinks();
    setAllAzureItems();
   // setupSellerOrderListener();
    // uCheck4Updates(context);
  }


  @override
  void didChangeDependencies() {
    if(widget.justLoggedIn){
      widget.justLoggedIn=false;
      uShowLoginDialog(context: context);
    }
    if(widget.justSignedIn){
      widget.justSignedIn=false;
      uShowSignupDialog(context: context);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Gmart',
        style: TextStyle(
          color: kThemeBlue
        ),),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: kThemeBlue
        ),
        actions: [
          IconButton(
              icon: Icon(CupertinoIcons.refresh, color:kThemeBlue),
              splashColor: Colors.white,
            onPressed: (){
              setAllAzureItems();
            },
          ),
          IconButton(
              icon: Icon(CupertinoIcons.search, color:kThemeBlue),
              splashColor: Colors.white,
            onPressed: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context){
                      return SearchScreen();
                    }));
            },
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: progress,
        child: Center(
          child: ModalProgressHUD(
            inAsyncCall: resolvingItems,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.bottomLeft,
                  child: Text('Top Categories',
                  style: TextStyle(
                    color: kThemeBlue,
                    fontWeight: FontWeight.w900
                  ),),
                ),
                CarouselSlider(
                    items: homeScreenModel.getCarSliderItems(searchForString)
                    , options: CarouselOptions(height: 120,
                        enlargeCenterPage: true,
                      viewportFraction: 0.35
                    )),
                SizedBox(height: 15,),
                Expanded(
                  child: GridView(
                    semanticChildCount: 2,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.78
                    ),
                    children: martList,
                  ),
                )
              ]
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: kThemeBlue,
          child: Column(
            children: [
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Container(
                        alignment: Alignment.bottomLeft,
                        child: Card(
                          color: Colors.transparent,

                          child: ListTile(

                            tileColor: kThemeBlue,
                            leading: Image.asset('images/logo.png'),
                            title: Text(_name,style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold
                            ),),
                            subtitle: Text(_email,style: kNavTextStyleSmall,),
                          ),
                        ),
                      ),
                    ),
                  )),
              Container(
                height: 1,
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              ),

              Stack(
                children: [
                  Container(
                    alignment: Alignment.center,
                  width: double.infinity,
                  height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: kLightBlue,
                    ),
                  ),

                  Container(
                      alignment: Alignment.center,
                      color: kLightBlue,
                      width: double.infinity,
                      height: 48,
                      margin: EdgeInsets.only(right: 40),),

                  NavButton(
                    alignment: Alignment.topCenter,
                    heroTag: 'ho',
                    label: 'Home',
                  icon: CupertinoIcons.home,
                  ),
                ]
              ),
              NavButton(
                label: 'Profile',
                heroTag: 'pro',
                icon: CupertinoIcons.person,
              onTapFunc: () async{
                  await homeScreenModel.openProfile(context);
              },),
              NavButton(
                label: 'cart',
                heroTag: 'cart',
                icon: CupertinoIcons.shopping_cart,
                onTapFunc: (){
                  print('pushed');
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>CartScreen()));
                },),
              NavButton(
                label: 'Favorites',
                heroTag: 'fav',
                icon: CupertinoIcons.square_favorites,
                onTapFunc: (){
                  print('pushed');
                  Navigator.pushNamed(context, '/favorites');
                },),
              NavButton(
                label: 'Wallet',
                heroTag: 'sold',
                icon: CupertinoIcons.money_dollar_circle,
                onTapFunc: ()async{
                  await homeScreenModel.openWallet(context);
                },),
              // NavButton(
              //   label: 'Seller Portal',
              //   icon: CupertinoIcons.doc_chart,
              //   heroTag: 'seller',
              //   onTapFunc: ()async{
              //      homeScreenModel.openSellerPortal(context);
              //     },),
              NavButton(
                label: 'About',
                heroTag: 'infoIcon',
                icon: CupertinoIcons.info,
              onTapFunc: (){
                displayAboutDialog();
              },),
              Container(
                height: 1,
                color: Colors.white,
                margin: EdgeInsets.all( 16),
              ),
              NavButton(
                label: 'Logout',
                heroTag: 'logout',
                icon: Icons.logout,
                onTapFunc: (){
                  showLogoutDialog();
                },),
              Expanded(
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    child: Text(''//'Follow us'
                      ,textAlign: TextAlign.start,
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white),),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }


  displayAboutDialog(){
    Navigator.pop(context);
    showAboutDialog(
        applicationName: 'Gmart.ng',
        context: this.context,
        applicationVersion: '2.0.0',
        applicationLegalese: 'Brought to you by Gcorp enterprise.',
        applicationIcon:Container(child: Image.asset('images/logo.png',height: 70, width: 70, color: kLightBlue,),),
        children: [
          SizedBox(height: 20,),
          Text('Developed by Algure', style: TextStyle(fontSize: 14,color: kThemeBlue),),
          Text('UI/UX Consult: PDS',style: TextStyle(fontSize: 14, color: kThemeBlue),),
          Text('UI/UX Consult: TeeKay', style: TextStyle(fontSize: 14, color: kThemeBlue),),
          Container(
            alignment: Alignment.center,
            color: Colors.transparent,
            child: RawMaterialButton(onPressed: (){},
                splashColor: Colors.white
                , child: Text('Visit website.', style: TextStyle(fontSize: 14, color: Colors.blue),)),
          )
        ]
    );
  }


  void setDlinksProgress(bool b){
    setState(() {
      resolvingItems=b;
    });
  }

  void setProgress(bool b){
    setState(() {
      progress=b;
    });
  }

  Future<void> setAllAzureItems() async {
    if(!(await uCheckInternet())){
    return;
    }
    setProgress(true);
    List<Widget> itemList=[];
    List<SmallMitem> objList=[];

    Response response= await get('https://gmart-search.search.windows.net/indexes/gmart-dex/docs?api-version=2020-06-30&search=*&select=id,k,t,m,i,s,h',
    headers:
    {'Content-Type':'application/json',
    'api-key':kSearchApiKey});

    var res= jsonDecode(response.body);
    List<String> ids=[];
    for(var v in res['value']){
      ids.add(v['id']);
      SmallMitem smitem= SmallMitem.fromAzureSearch(v);
      if(smitem.N.trim() == 'null' || smitem.P.trim() == 'null') continue;
      objList.add(smitem);
      itemList.add(MartGridAzure(smitem: smitem, onPressedFunc:(){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ItemDescriptionScreen(smallMitem: smitem)));
      }));
//      itemList.add(MartGridWithID(smitem: smitem,));
    }
    martList= itemList;
    setProgress(false);
  }

  Future<void> setAllMarketItems(BuildContext context) async {
    if(!(await uCheckInternet())){
      return;
    }
    setProgress(true);
    List<Widget> itemList=[];
    List<SmallMitem> objList=[];
    print('near value');
    DatabaseReference myRef= FirebaseDatabase.instance.reference().child('S');
    DataSnapshot snapShot=await myRef.once();
    print('gotten value');
    print(snapShot.value.toString());

    Map<dynamic , dynamic> maps= Map.from(snapShot.value);
    for(var k in maps.entries){
      SmallMitem item=SmallMitem.fromJson(k.value);
      item.I=k.key.toString();
      objList.add(item);
    }
    for(SmallMitem smit in objList){
//      itemList.add(MartGridItem(smitem: smit, onPressedFunc: (){
//        Navigator.push(context, MaterialPageRoute(builder: (context){
//          return ItemDescriptionScreen(heroTag: smit.I, smallMitem: smit,);
//        }));
//      },));
     itemList.add(MartGridWithID(smitem: smit,));
    }
    martList= itemList;
   setProgress(false);
  }

  void showLogoutDialog(){
    uShowCustomDialog(context: context,
        icon: Icons.logout, iconColor: kThemeBlue, text: "Confirm Logout",
        buttonList: [['confirm', kThemeOrange,logOut],['cancel', Colors.black,(){Navigator.pop(context);}],]);
  }

  Future<void> logOut() async {
    SharedPreferences sp=await SharedPreferences.getInstance();
    await sp.clear();

    CartItemsDb cdb = CartItemsDb();
    CustomerOrdersDb cusdb = CustomerOrdersDb();
    FavoriteItemsDb fdb = FavoriteItemsDb();
    OrderItemsDb odb = OrderItemsDb();
    LargeMartItemsDb ldb = LargeMartItemsDb();
     await cdb.clearAllItems();
     await cusdb.clearAllItems();
     await fdb.clearAllItems();
     await odb.clearAllItems();
     await ldb.clearAllItems();
    await Provider.of<CartProvider>(context, listen:false).fillUpCartMapFromDb();
    await Provider.of<FavoriteProvider>(context, listen:false).fillUpFavoritesMap();
    await Provider.of<CustomerOrderProvider>(context, listen:false).retrieveCustomerOrders();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context)=> LoginScreen()), (route) => false);
  }

  Future<void> setupFavorites() async {
    // FavoriteProvider favPd= FavoriteProvider();
    await Provider.of<FavoriteProvider>(context,listen: false).fillUpFavoritesMap();
  }

  Future<void> setupCartItems() async {
    // FavoriteProvider favPd= FavoriteProvider();
    await Provider.of<CartProvider>(context,listen: false).fillUpCartMapFromDb();
  }

  Future<void> setupSellerOrderListener() async {
    String sellerD= await uGetSharedPrefValue(kShopItemsDownloaded);
    if(sellerD==null || sellerD.isEmpty){
      return;
    }

    await Provider.of<SellerOrderProvider>(context, listen: false).retrieveSellerOrders();
    Provider.of<SellerOrderProvider>(context, listen: false).listenForOrders();
    await Provider.of<CustomerOrderProvider>(context, listen: false).retrieveCustomerOrders();
    Provider.of<CustomerOrderProvider>(context, listen: false).listenForOrders();
    await Provider.of<PromoModel>(context).setWidgetLists(context, showNots: true);

  }

  Future<void> openItemWithId(String itemId) async {
    try {

      MartItem mitem = await AzSingle().getLargeItem(itemId);
      // SmallMitem smitem = SmallMitem.fromMartItem(mitem);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ItemDescriptionScreen(heroTag: mitem.l, martItem: mitem,);
      }));
    }catch(e){
      print('open item error: ${e.toString()}');
    }
  }

  Future<MartItem> getLargeItem(String itemId) async {

    LargeMartItemsDb lDb = LargeMartItemsDb();
    MartItem martItem = await lDb.getItem(itemId);
    if (martItem != null) {
      for(var v in martItem.toMap().entries){
        print('${v.key} : ${v.value.runtimeType.toString()} : ${v.value}');
      }
      print('returned from db');
      return martItem;
    }
    FirebaseDatabase database = SearchScreenModel.database;
    DatabaseReference mRyRefSmall = database.reference().child('S').child(itemId);
    DatabaseReference myRef = database.reference().child('R').child(itemId);
    var snapShot = await myRef.once();
    var snapShotSmall = await mRyRefSmall.once();

    SmallMitem smitem=SmallMitem.fromJson(snapShotSmall.value);
    smitem.I=itemId;
    print('retrive shot ${snapShot.value}');
    martItem = MartItem(snapShot:snapShot, smitem: smitem);

    lDb.insertItem(martItem);
    print('returned from firebase');
    return martItem;
  }

  openShopWithId(String shopId) {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchScreen(shopId: shopId,)));
  }

  void initDynamicLinks() async {
    print('initing dynamic links');
//    FirebaseDynamicLinks.instance.onLink(
////        onSuccess: (PendingDynamicLinkData dynamicLink) async {
////          final Uri deepLink = dynamicLink?.link;
////          print('link uri: ${deepLink.path}');
////          if (deepLink != null) {
////            Navigator.pushNamed(context, deepLink.path);
////          }
////        },
////        onError: (OnLinkErrorException e) async {
////          print('onLinkError ${e.message}');
////          print(e.message);
////        }
////    );
    try {
      // setDlinksProgress(true);
      final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance
          .getInitialLink();
      final Uri deepLink = data?.link;
      String linkDetails = deepLink.toString();
      print('link details: ${linkDetails}');
      if (linkDetails.contains('https://gmart.page.link/')) {
        linkDetails =
            linkDetails.replaceAll('https://gmart.page.link/', '').replaceAll(
                ' ', '');
        // setDlinksProgress(false);
        if (deepLink != null && linkDetails != null &&
            linkDetails.startsWith('item')) {
          String itemId = linkDetails.split(':')[1]; //.replaceAll(':', '');
          print('OPENING link details: ${itemId}');
          if(!(await uCheckInternet())){
            uShowNoInternetDialog(context);
            throw "No internet to open item: $itemId";
          }
          await openItemWithId(itemId);
        } else if (linkDetails != null && linkDetails.startsWith('shop')) {
          String shopId = linkDetails.split(':')[1]; //.replaceAll(':', '');
          print('OPENING link details: ${shopId}');
          openShopWithId(shopId);
        }
        else {
          print('Nothing done651');
        }
      }
      // else if (linkDetails.contains('gmartpass.pageret.link')) {
      //   String id = await uGetSharedPrefValue(kIdKey);
      //   String email2get = await uGetSharedPrefValue(kMail2Retrieve);
      //   if (id != null && id != 'null' && id.length > 5) return;
      //   if (email2get != null && email2get != 'null' && email2get
      //       .trim()
      //       .isEmpty) return;
      //   Navigator.pushReplacement(context,
      //       MaterialPageRoute(builder: (context) => ChangePasswordScreen()));
      // }
    }catch(e,t){
      print('dynamic links. error:$e, stack trace: $t');
    }
    setDlinksProgress(false);
  }


  searchForString(String p1) {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchScreen(searchText: p1,)));
  }

  Future<void> initUserDetails() async {
    _email = await uGetSharedPrefValue(kMailKey) ;
    _name = await uGetSharedPrefValue(kFnameKey) + ' '+ await uGetSharedPrefValue(kLnameKey) ;
  }
}

