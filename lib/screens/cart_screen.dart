import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/custom_widgets/cart_list_item_widget.dart';
import 'package:ecommerce/custom_widgets/my_button.dart';
import 'package:ecommerce/custom_widgets/variant_list_item.dart';
import 'package:ecommerce/databases/customer_orders_db.dart';
import 'package:ecommerce/databases/order_mitems_db.dart';
import 'package:ecommerce/mart_objects/cart_item.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/mart_objects/order_item.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/screens/item_description_screen.dart';
import 'package:ecommerce/screens/profile_screen.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  List<Widget> favList=[];
  BoxDecoration selectedDecoration= BoxDecoration(
    color: kLightBlue,
    borderRadius: BorderRadius.circular(20),
  );
  BoxDecoration unSelectedDecoration= BoxDecoration(
    color: Colors.black12,
    borderRadius: BorderRadius.circular(20),
  );

  bool progress = false;

  @override
  void initState() {
    // setCartItems();
  }

  @override
  void didChangeDependencies() {
    // toggleOption(FavOption.Item, shouldReload:false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart', style: TextStyle(color: kThemeBlue),),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: kThemeBlue),
        actions: [
          GestureDetector(
              onTap:refreshCart,
              child: Icon(Icons.refresh, color: kThemeBlue, size: 20,)),
          SizedBox(width: 20,)
        ],
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: progress,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 30,),
              //Account for the swipe to delete indicator
                Expanded(
                  child: (Provider.of<CartProvider>(context).statMap.length>0) ?
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children:[
                      Container(
                        height:double.maxFinite,
                        width:double.maxFinite,
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            for (CartItem citem in Provider.of<CartProvider>(context).statMap.values)
                              CartListItem( onPressedFunc: openItemDescription, oItem: citem,
                                onRemoveItemPressed: removeCartItem, context: context,)
                          ],
                ),
                      ),
                      Container(
                        child: MyButton(
                          buttonColor: kThemeOrange,
                          textColor: Colors.white,
                          text: 'complete checkout',
                          onPressed: () async {
                            String sAddress = await uGetSharedPrefValue(kAdressKey);
                            if(sAddress==null || sAddress.trim().isEmpty|| sAddress.toString().trim()=='null' ){
                                uShowCustomDialog(context: context, icon: Icons.person_add_alt_1, iconColor: kThemeBlue,
                                   text: 'Address has not been updated. Please proceed to profile page to update address.' ,
                                  buttonList: [['proceed',kThemeOrange, (){Navigator.push(context,
                                  MaterialPageRoute(builder: (context)=>ProfileScreen()));}],
                                  ['cancel',Colors.black,(){Navigator.pop(context);}]]);
                                return;
                            }
                            showPayoutDialog();
                          },
                        ),
                      )
                    ]
                  ):
                  Container(
                      alignment: Alignment.center,
                      child: Icon(Icons.remove_shopping_cart_outlined, size: 100, color: kLightBlue,)),
                )
            ],
          ),
        ),
      ),
    );
  }

  Future<void>  removeCartItem(CartItem p1) async {
    if(!(await uCheckInternet())){
      uShowErrorNotification('No internet detected !');
      return;
    }
    setProgress(true);
    try{
      await AzSingle().removeCartItem(p1.i);
      await Provider.of<CartProvider>(context, listen: false)
          .removeItemFromCart(p1);
    }catch(e, t){
      print('error: $e, trace: $t');

    }
    setProgress(false);
  }

  void setProgress(bool bool) {
    setState(() {
      progress = bool;
    });
  }

  Future<void> openItemDescription(CartItem p1) async {
    setProgress(true);
    if(!(await uCheckInternet())){
      uShowErrorNotification('No internet detected');
      setProgress(false);
      return;
    }
    try {
      MartItem mitem= await AzSingle().getLargeItem(p1.t);
      print('item:  $mitem');
      setProgress(false);
      if(mitem!=null&& mitem.l.toString()!='null'&&mitem.k.toString()!='null'&&mitem.t.toString()!='null')
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ItemDescriptionScreen(martItem: mitem,)));
      else uShowErrorDialog(context, 'It appears the item is no longer up for sale.');
    }catch(e){
      uShowErrorNotification('An error occured !');
      print('open item exception ${e.toString()}');
    }
    setProgress(false);
  }

  Future<void> completeOrderForCartItems() async {
    String sName = await uGetSharedPrefValue(kLnameKey);
    String fName = await uGetSharedPrefValue(kFnameKey);
    String sAddress = await uGetSharedPrefValue(kAdressKey);
    String phoneNum = await uGetSharedPrefValue(kPhoneKey);
    if(sName==null || sName.trim().isEmpty|| sName.toString().trim().toLowerCase()=='null'){
      uShowErrorNotification( 'Invalid last name detected.');
      return;
    }
    if(fName==null || fName.trim().isEmpty|| fName.toString().trim().toLowerCase()=='null'){
      uShowErrorNotification( 'Invalid first name detected.');
      return;
    }

    if(phoneNum==null || phoneNum.trim().isEmpty|| phoneNum.toString().trim()=='null' ){
      uShowErrorDialog(context, 'No phone number detected.');
      return;
    }
    try {
      setProgress(true);
      Navigator.pop(context);
      List<CartItem> cList = Provider.of<CartProvider>(context, listen: false).statMap.values.toList();
      for(CartItem citem in cList){
         MartItem saveItem = await AzSingle().getLargeItem(citem.t);
          OrderItem mOrder = OrderItem();
          mOrder.i = citem.i; //Order ID
          mOrder.t = citem.t; //Item ID
          mOrder.n = citem.n; //Item name
          mOrder.u = citem.u; //Item units
          mOrder.p = citem.p; //Order price
          mOrder.s = citem.s; //Seller ID
          mOrder.c = citem.c; //Customer ID
          mOrder.d = await getTodaysDate(); //Order date
          mOrder.k = '1<${mOrder.d}'; //Order status
          mOrder.y = saveItem.p; //Seller details
          mOrder.z = (await uGetSharedPrefValue(kAdressKey))+ '<'+(await uGetSharedPrefValue(kPhoneKey)); //Customer details

        await AzSingle().uploadOrder(mOrder);
          CustomerOrdersDb cdb = CustomerOrdersDb();
          await cdb.insertItem(mOrder);

          // DOWNLOAD PICTURE AND SAVE ORDER ITEM TO DB
          String picPath = await AzSingle().
            downloadAzurePic(saveItem.k.split(',').firstWhere((element) => element!=null&&element.trim().isNotEmpty));
          saveItem.q = picPath;
          OrderItemsDb odb = OrderItemsDb();
          await odb.insertItem(saveItem);
          print('After insert');

          // REDUCE ONLINE ORDER AMOUNT
          String snap = await AzSingle().getItemNumleft(saveItem.l);
          double d= double.tryParse(snap)??0;
          d-=double.tryParse(citem.u)??1;
          // await AzSingle().setNumLeft(saveItem.l, d.toString());

          await AzSingle().removeCartItem(citem.i);
          await Provider.of<CartProvider>(context, listen: false).removeItemFromCart(citem);
      }
      uShowOkNotification('Order created');
    }catch(e){
      uShowErrorNotification('Sorry! an error occured. Please try again later');
      print('initiate upload exception ${e.toString()}');
    }
    setProgress(false);
  }

  Future<String> getTodaysDate() async {
    String dateBase = await uGetGoogleDate();
    String dateExtract=extractDate(dateBase);
    return dateExtract;
  }

  String extractDate(String dateBase) {
    List<String> months=['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul','aug', 'sep', 'oct', 'nov', 'dec'];
    List<String> dBase=dateBase.split(' ');
    int month=(months.indexOf(dBase[2].toLowerCase())+1);
    int day=int.tryParse(dBase[1]);
    int year=int.tryParse(dBase[3]);

    DateTime dt= DateTime(year,month,day);
    DateFormat df=DateFormat('yy:MM:dd');
    return df.format(dt).toString();
  }

  Future<void> refreshCart() async {
    if(progress) return;
    if(!(await uCheckInternet())){
      uShowErrorNotification('No internet detected');
      return;
    }
    setProgress(true);
    try {
      await Provider.of<CartProvider>(context, listen:false).downloadAndSetUserCartItems();
    }catch(e, t){
      print('error: $e, trace: $t');
    }
    setProgress(false);

  }

  showPayoutDialog() {
    uShowCustomDialog(context: context, icon: Icons.shopping_cart,
        iconColor: kThemeOrange, text: 'Complete order pay out.',
        buttonList: [['proceed',kThemeOrange, completeOrderForCartItems],
          ['cancel',Colors.black, (){Navigator.pop(context);}],] );
  }
}
