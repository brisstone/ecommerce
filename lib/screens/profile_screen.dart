
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecommerce/custom_widgets/order_list_item.dart';
import 'package:ecommerce/databases/customer_orders_db.dart';
import 'package:ecommerce/databases/order_mitems_db.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/mart_objects/order_filter_data.dart';
import 'package:ecommerce/mart_objects/order_item.dart';
import 'package:ecommerce/mart_objects/user_info_object.dart';
import 'package:ecommerce/providers/customer_orders_provider.dart';
import 'package:ecommerce/providers/profile_provider.dart';
import 'package:ecommerce/screen_models/profile_model.dart';
import 'package:ecommerce/screens/profile_edit_screen.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import 'order_details_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  ProfileModel _profileModel= ProfileModel();
  bool progress=false;
  OrderFilterData _chosenOrderFilter;
  List<DropdownMenuItem<OrderFilterData>> _filterList=[
    DropdownMenuItem<OrderFilterData>(child: Text('All'), value:OrderFilterData('All open orders', '') ,) ,
    DropdownMenuItem<OrderFilterData>(child: Text('All open'), value:OrderFilterData('All open orders', 'o') ,) ,
    DropdownMenuItem<OrderFilterData>(child: Text('All closed'), value:OrderFilterData('All closed orders', 'c') ,) ,
  ];

  var listStyle=TextStyle(color: kThemeBlue, fontSize: 16);
  RefreshController _refreshController=RefreshController(initialRefresh: false);

  String _filterValue='All';

  @override
  void initState() {
    setUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kThemeBlue,
      appBar: AppBar(
          title: Text('Profile', style: TextStyle(color: kLightBlue, fontWeight: FontWeight.bold),),
          backgroundColor: kThemeBlue,
          iconTheme: IconThemeData(
              color: Colors.white
          ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color:Colors.white),
            splashColor: Colors.white,
            onPressed: (){
              showEditDialog(context);
            },
          )
        ],
        ),
      body: SmartRefresher(
        controller:_refreshController,
        onRefresh: startRefresh,
        child: ModalProgressHUD(
          inAsyncCall: progress,
          color: Colors.transparent,
          child: Container(
            color: kThemeBlue,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                 Container(
                   padding: EdgeInsets.all(20),
                   alignment: Alignment.centerLeft,
                   child: Text( Provider.of<ProfileProvider>(context).name??'', style: TextStyle(color: kLightBlue, fontWeight: FontWeight.w900, fontSize: 35),),
                 ),
                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      width: double.maxFinite,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height*0.4
                      ),
                      padding: EdgeInsets.all(10),
                      child: Column(children:Provider.of<ProfileProvider>(context).userDetails??[],)),

                  if(Provider.of<CustomerOrderProvider>(context).customerOrders.length>0)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(26),
                    child: Text('My Orders', style: TextStyle(color: kLightBlue, fontWeight: FontWeight.w900, fontSize: 20),)),

                  if(Provider.of<CustomerOrderProvider>(context).customerOrders.length>0)
                    Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only (topLeft:Radius.circular(30), topRight:Radius.circular(30),bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                        color: Colors.white,
                      ),
                    padding: EdgeInsets.only(bottom: 100, top: 16),
                    child:   Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children:[
                        Padding(
                          padding:  EdgeInsets.only(right: 18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(width: 30,),
                              Text('Total: ${Provider.of<CustomerOrderProvider>(context).orderWidgets.length}', style: kHintStyle.copyWith(color: kThemeBlue, fontWeight: FontWeight.bold),),
                              Spacer(),
                              Text(_filterValue, style: kHintStyle.copyWith(color: kThemeBlue, fontWeight: FontWeight.bold),),
                              DropdownButtonHideUnderline(
                              child: ButtonTheme(
                                alignedDropdown: true,
                                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                child: DropdownButton <OrderFilterData>(
                                    dropdownColor: kLightBlue,
                                    isDense: true,
                                    icon: Icon(Icons.filter_list_sharp, color: kThemeBlue, size: 24,),
                                    style: kStatePickerTextStyle,
                                    items: this._filterList,
                                    onChanged: (value){
                                      _chosenOrderFilter=value;
                                      Provider.of<CustomerOrderProvider>(context, listen: false).filterOrderStats(value);
                                      print('selected ${value.status} ${value.statusCode}');
                                      setState(() {
                                        _filterValue=value.status;
                                      });
                                    }),
                              ),
                            )
                              ,]
                          ),
                        ),
                        for(OrderListItem olitem in Provider.of<CustomerOrderProvider>(context).orderWidgets)_addOnTap(olitem),
                      ]
                    )

                  ),
                  // Container(height: double.maxFinite, color: Colors.white,)

                ],
                ),
              ),
          ),
        ),
      ),
    );
  }

  Future<void> startRefresh() async {
    print('initiated refesh');
    showProgress(true);
    await Provider.of<CustomerOrderProvider>(context,listen: false).quickFetchForOrders();
    showProgress(false);
  }

  void showProgress(bool b){
    _refreshController.refreshCompleted();
    setState(() {
      progress=b;
    });
  }

  Future<void> setupOrders() async {
     await Provider.of<CustomerOrderProvider>(context, listen: false).retrieveCustomerOrders();
     // Provider.of<CustomerOrderProvider>(context, listen: false).quickFetchForOrders();
    Provider.of<CustomerOrderProvider>(context, listen: false).listenForOrders();
    Provider.of<CustomerOrderProvider>(context, listen: false).filterOrderStats(_filterList[0].value);

    // if(await userOrdersNotLoaded()) await downloadOrdersFromAzure();
    // CustomerOrdersDb cdb=CustomerOrdersDb();
    // OrderItemsDb odb= OrderItemsDb();
    //
    // List<OrderItem> oList= await cdb.getMartItems();
    // for(OrderItem oit in oList){
    //   MartItem mitem= await odb.getItem(oit.t);
    //
    //   if(mitem!=null && mitem.q.startsWith(',')&& mitem.q.length>1)
    //     mitem.q=mitem.q.substring(1);
    //   String image = mitem!=null && mitem.q!=null?mitem.q.split(',')[0]:'';
    //
    //   for(String im in mitem.q.split(',')){
    //     image=im;
    //     if(image!=null && image.trim().length>0)break;
    //   }
    //   ordersList.add(OrderListItem(oItem: oit, image: image, onPressedFunc: (){
    //     Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderDetailsScreen(oit)));
    //   }));
    // }
  }

  Future<void> setUserDetails() async {
    showProgress(true);
    await Provider.of<ProfileProvider>(context,listen: false).setUserDetails();
    await setupOrders();
    showProgress(false);
  }

  Future<void> downloadOrdersFromAzure() async {
    String cusId = await uGetSharedPrefValue(kIdKey);
    List<OrderItem> orderList = await AzSingle().fetchCustomerOrderItems(cusId);
    CustomerOrdersDb cdb = CustomerOrdersDb();
    for (OrderItem orderItem in orderList) {
      print('order-item: $orderItem');
      await cdb.insertItem(orderItem);
    }
    await uSetPrefsValue(kOrdersLoadedKey, 'true');
  }



  Future<void> showEditDialog(BuildContext context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileEditScreen()));
    // SharedPreferences sp= await SharedPreferences.getInstance();
    // phoneNum=sp.getString(kPhoneKey);
    // email=sp.getString(kMailKey);
    // fName=sp.getString(kFnameKey);
    // sName=sp.getString(kLnameKey);
    // state=sp.getString(kStateKey);
    // sAddress=sp.getString(kAdressKey)??'';
    //
    // List<Widget> butList=[
    //   Expanded(
    //     child: Container(
    //       margin: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
    //       decoration: BoxDecoration(
    //           color: kLightBlue,
    //           borderRadius: BorderRadius.circular(10)
    //       ),
    //       child: FlatButton(onPressed:(){
    //           attemptSaveAgain();
    //       },
    //         child: Text('Save', style: kNavTextStyle,),
    //         splashColor: Colors.white,),
    //     ),
    //   )
    // ];
    //
    // Dialog errorDialog= Dialog(
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    //   backgroundColor: Colors.white,//Color(0xFFDDDDFF),
    //   child: SingleChildScrollView(
    //     child: Column(
    //       children: [
    //         SizedBox(height: 30,),
    //         Container(
    //             alignment: Alignment.centerLeft,
    //             child: FlatButton(
    //                 onPressed: (){
    //                   Navigator.pop(context);
    //                 },
    //                 child: Icon(Icons.clear, color: kThemeBlue, size:  20, ))),
    //         Icon(CupertinoIcons.person_add_solid, color: kLightBlue, size:  100,),
    //         Padding(
    //           padding: EdgeInsets.all(8.0),
    //           child:  TextField(
    //               controller: TextEditingController(text: fName),
    //               style: kInputTextStyle,
    //               textAlign: TextAlign.start,
    //               maxLength: 10,
    //               inputFormatters:[
    //                 LengthLimitingTextInputFormatter(10)
    //               ],
    //               onChanged: (value){
    //                 fName=value;
    //               },
    //               keyboardType: TextInputType.text,
    //               textInputAction: TextInputAction.next,
    //               decoration: InputDecoration(
    //                 filled: true,
    //                 prefixIcon: Icon(CupertinoIcons.phone, color: kThemeBlue,),
    //                 fillColor: Colors.white,
    //                 labelText: 'Input first name',
    //                 hintStyle: kHintStyle,
    //                 border: kInputOutlineBorder,
    //               )
    //           ),
    //         ),
    //         Padding(
    //           padding: EdgeInsets.all(8.0),
    //           child:  TextField(
    //               controller: TextEditingController(text: sName),
    //               style: kInputTextStyle,
    //               textAlign: TextAlign.start,
    //               maxLength: 10,
    //               maxLengthEnforced: true,
    //               inputFormatters:[
    //                 LengthLimitingTextInputFormatter(10)
    //               ],
    //               onChanged: (value){
    //                 sName=value;
    //               },
    //               keyboardType: TextInputType.text,
    //               textInputAction: TextInputAction.next,
    //               decoration: InputDecoration(
    //                 filled: true,
    //                 prefixIcon: Icon(CupertinoIcons.person, color: kThemeBlue,),
    //                 fillColor: Colors.white,
    //                 labelText: 'Input last/sur name',
    //                 hintStyle: kHintStyle,
    //                 border: kInputOutlineBorder,
    //               )
    //           ),
    //         ),
    //         Padding(
    //           padding: EdgeInsets.all(8.0),
    //           child:  TextField(
    //               controller: TextEditingController(text: phoneNum),
    //               style: kInputTextStyle,
    //               textAlign: TextAlign.start,
    //               maxLength: 11,
    //               maxLengthEnforced: true,
    //               inputFormatters:[
    //                 LengthLimitingTextInputFormatter(11)
    //               ],
    //               onChanged: (value){
    //                 phoneNum=value;
    //                 print ('phone num $phoneNum');
    //               },
    //               keyboardType: TextInputType.number,
    //               textInputAction: TextInputAction.next,
    //               decoration: InputDecoration(
    //                 filled: true,
    //                 prefixIcon: Icon(CupertinoIcons.phone, color: kThemeBlue,),
    //                 fillColor: Colors.white,
    //                 labelText: 'Input (whatsapp) phone number ',
    //                 hintStyle: kHintStyle,
    //                 border: kInputOutlineBorder,
    //               )
    //           ),
    //         ),
    //         Container(
    //           height: 70,
    //           width: double.maxFinite,
    //           decoration: BoxDecoration(
    //             border: Border.all(width: 1, color: kThemeBlue,
    //             ),
    //             borderRadius: BorderRadius.circular(8)
    //           ),
    //           margin: EdgeInsets.all(8.0),
    //           child: Row(
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children:[
    //                 SizedBox(width: 10,),
    //                 Icon(CupertinoIcons.location, color: kThemeBlue,),
    //                 Expanded(
    //                   child: Container(
    //                       child:  CupertinoPicker(
    //                   scrollController: FixedExtentScrollController(initialItem: kStateStringList.indexOf(state)>=0? kStateStringList.indexOf(state):0),
    //                   diameterRatio: 1.5,
    //                   useMagnifier: true,
    //                   magnification: 1.2,
    //                   itemExtent: 30,
    //                   onSelectedItemChanged: (dex){
    //                     state=kStateList[dex].value.toString();
    //                   },
    //                 children: getCupertinpText()
    //                       ),
    //                   ),
    //                 ),
    //               ]
    //           ),
    //         ),
    //         Padding(
    //           padding: EdgeInsets.all(8.0),
    //           child:  TextField(
    //               controller: TextEditingController(text: sAddress),
    //               style: kInputTextStyle,
    //               textAlign: TextAlign.start,
    //               maxLength: 24,
    //               inputFormatters:[
    //                 LengthLimitingTextInputFormatter(24)
    //               ],
    //               onChanged: (value){
    //                 sAddress=value;
    //                 print ('address $sAddress');
    //               },
    //               keyboardType: TextInputType.text,
    //               textInputAction: TextInputAction.next,
    //               maxLengthEnforced: true,
    //               decoration: InputDecoration(
    //                 filled: true,
    //                 prefixIcon: Icon(CupertinoIcons.location_solid, color: kThemeBlue,),
    //                 fillColor: Colors.white,
    //                 labelText: 'Input specific address',
    //                 hintStyle: kHintStyle,
    //                 border: kInputOutlineBorder,
    //               )
    //           ),
    //         ),
    //         Container(
    //           height: butList!=null?60:2,
    //           margin: EdgeInsets.only(bottom: 70),
    //           child: Row(
    //             children: butList,
    //           ),
    //         )
    //       ],
    //     ),
    //   ),
    // );
    // showGeneralDialog(context: context,
    //     barrierLabel: 'btxt',
    //     barrierDismissible: true,
    //     barrierColor: Colors.black.withOpacity(0.5),
    //     transitionDuration: Duration(milliseconds: 500),
    //     transitionBuilder: (_, anim, __, child){
    //       return SlideTransition(position: Tween(begin: Offset(0,-1), end: Offset(0,0)).animate(anim), child: child,);
    //     },
    //     pageBuilder: (BuildContext context, _, __)=>(errorDialog)
    // );
  }

  // Future<void> attemptSaveAgain() async {
  //   showProgress(true);
  //   try {
  //     fName = fName;
  //     if (fName.toString() == 'null' || fName.isEmpty) {
  //       showProgress(false);
  //       uShowErrorDialog(this.context, 'First name cannot be empty');
  //       return;
  //     } else if (fName.contains(' ')) {
  //       showProgress(false);
  //       uShowErrorDialog(
  //           this.context, 'First name cannot contain white/empty space');
  //       return;
  //     }else if(fName.length>10){
  //       showProgress(false);
  //       uShowErrorDialog(
  //           this.context, 'First name is too long');
  //       return;
  //     }
  //     sName = sName;
  //     if (sName.toString() == 'null' || sName.isEmpty) {
  //       showProgress(false);
  //       uShowErrorDialog(this.context, 'Last/Sur name cannot be empty');
  //       return;
  //     } else if (sName.contains(' ')) {
  //       showProgress(false);
  //       uShowErrorDialog(
  //           this.context, 'Last/Sur name cannot contain white/empty space');
  //       return;
  //     }else if(sName.length>10){
  //       showProgress(false);
  //       uShowErrorDialog(
  //           this.context, 'Last/Sur name is too long');
  //       return;
  //     }
  //
  //     phoneNum = phoneNum;
  //     if (phoneNum.toString() == 'null' || phoneNum.isEmpty) {
  //       showProgress(false);
  //       uShowErrorDialog(this.context, 'Phone number cannot be empty');
  //       return;
  //     } else if (phoneNum.length != 11) {
  //       showProgress(false);
  //       uShowErrorDialog(this.context, 'Invalid phone number');
  //       return;
  //     }
  //
  //     state = state;
  //     if (state == null || state.isEmpty) {
  //       showProgress(false);
  //       uShowErrorDialog(this.context, 'State cannot be empty');
  //       return;
  //     } else if (state.contains(' ')) {
  //       showProgress(false);
  //       uShowErrorDialog(this.context, 'Invalid state selection');
  //       return;
  //     }
  //     Navigator.pop(context);
  //     reSaveDetails();
  //   }catch(e){
  //     print('error $e');
  //     showProgress(false);
  //     uShowErrorDialog(context, 'An error occured. Please check inputs.');
  //   }
  // }

  // Future<void> reSaveDetails() async {
  //
  //   print('ran others');
  //   SharedPreferences sp=await SharedPreferences.getInstance();
  //   await uSetPrefsValue('pno', phoneNum);
  //   await uSetPrefsValue('fname', fName);
  //   await uSetPrefsValue(kLnameKey, sName);
  //   if(!sAddress.isEmpty && sAddress.toString()!='null')
  //     await uSetPrefsValue(kAdressKey,sAddress);
  //   else
  //     await uSetPrefsValue(kAdressKey,'');
  //
  //   await uSetPrefsValue(kStateKey,state);
  //   await sp.setString(kResetKey,"true");
  //   await setUserDetails();
  //   showProgress(false);
  //   showProfileUpdatedDialog();
  // }


  List<Widget> getCupertinpText(){
    List<Widget> ans=[];
    for(String s in kStateStringList){
      ans.add(  Text(s, style: TextStyle(color: kThemeBlue)));
    }
    return ans;
  }

  // Widget getPicker(){
  //   if(Platform.isIOS){
  //     return CupertinoPicker(
  //         scrollController: FixedExtentScrollController(
  //             initialItem: kStateStringList.indexOf( Provider.of<ProfileProvider>(context).state)>=0? kStateStringList.indexOf( Provider.of<ProfileProvider>(context).state):0),
  //         diameterRatio: 1.5,
  //         useMagnifier: true,
  //         magnification: 1.2,
  //         itemExtent: 30,
  //         onSelectedItemChanged: (dex){
  //           Provider.of<ProfileProvider>(context).state=kStateList[dex].value.toString();
  //         },
  //         children: getCupertinpText()
  //     );
  //   }
  //   List<DropdownMenuItem> dropdownList=[];
  //   for(String s in kStateStringList){
  //     dropdownList.add(DropdownMenuItem(child: Text(s, style: TextStyle(color: kThemeBlue)), value: s,));
  //   }
  //   return DropdownButtonHideUnderline(
  //     child: DropdownButton(
  //         value: Provider.of<ProfileProvider>(context).state,
  //         hint: Text('Select state', style: TextStyle(color: kThemeBlue),),
  //         dropdownColor: kLightBlue,
  //         isDense: true,
  //         style: TextStyle(color: kThemeBlue),
  //         items: dropdownList,
  //         focusColor: kThemeBlue,
  //         onChanged: (value){
  //           print(Provider.of<ProfileProvider>(context,listen: false).state);
  //           setState(() {
  //             Provider.of<ProfileProvider>(context,listen: false).state=value;
  //           });
  //         }),
  //   );
  // }

  void showProfileUpdatedDialog() {
    Dialog errorDialog= Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Color(0xFFEFEFFF),
      child: Container(
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('👍', textAlign: TextAlign.center, style: TextStyle(fontSize: 120),),
            ),
            SizedBox(height: 10,),
            Expanded(

              child: Container(
                  alignment: Alignment.center,
                  child: Text('Profile updated', textAlign: TextAlign.center,
                    style: TextStyle(color:kThemeBlue,fontSize: 25),)),
            ),
          ],
        ),
      ),
    );
    showGeneralDialog(context: context,
        barrierLabel: 'pro Upload',
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 500),
        transitionBuilder: (_, anim, __, child){
          return SlideTransition(position: Tween(begin: Offset(0,-1),
              end: Offset(0,0)).animate(anim), child: child,);
        },
        pageBuilder: (BuildContext context, _, __)=>(errorDialog)
    );
  }

  Future<bool> userOrdersNotLoaded() async {
    SharedPreferences sp=await SharedPreferences.getInstance();
    if(!sp.containsKey(kOrdersLoadedKey)){
      return true;
    }
    String loadedValue= await uGetSharedPrefValue(kOrdersLoadedKey);
    if(loadedValue.contains('true')) return false;
    return true;
  }

  _addOnTap(OrderListItem olitem) {
    olitem.onPressedFunc=(){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderDetailsScreen(olitem.oItem)));
    };
    return olitem;
  }

}
