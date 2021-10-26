
import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/custom_widgets/mart_grid_item.dart';
import 'package:ecommerce/custom_widgets/round_icon_button.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/mart_objects/small_mitem.dart';
import 'package:ecommerce/screen_models/search_screen_model.dart';
import 'package:ecommerce/singletons/az_single.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';

import 'item_description_screen.dart';

class SearchScreen extends StatefulWidget {


  SearchScreen({this.shopId, this.shopDets, this.searchText= ''});
  String shopDets;
  String shopId;
  String searchText;
  @override
  _SearchScreenState createState() => _SearchScreenState(shopId:this.shopId);
}

class _SearchScreenState extends State<SearchScreen> {

  _SearchScreenState({this.shopId});

  SearchScreenModel _searchScreenModel= SearchScreenModel();
  EdgeInsets contactsPadding=EdgeInsets.all(8);
  List<Widget> gridList=[];
  bool isLoading=false;
  String shopId;
  String sellerPNum='';
  String sellerEmail='';
  String sellerName='';
  String searchText='';
  @override
  void initState() {
    resolveSearchParams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gmart ${widget.shopId!=null? 'Shop':''}',
          style: TextStyle(
              color: kThemeBlue
          ),),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
            color: kThemeBlue
        ),
      ),
      body: ModalProgressHUD(
        opacity: 0.5,
        color: Colors.white,
        progressIndicator: CircularProgressIndicator(),
        inAsyncCall: isLoading,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Visibility(
                  visible: widget.shopId==null,
                  child: TextField(
                    controller: TextEditingController(text: searchText),
                    onSubmitted: (string){seachForItem(string);},
                    style: TextStyle(color: kThemeBlue),
                    textAlign: TextAlign.center,
                      onChanged: (string){
                      searchText = string;
                      },
                    decoration: InputDecoration(
                        filled: true,
                        icon: Icon(CupertinoIcons.search,
                            color: kThemeBlue),
                        hintText: 'Enter search text',
                        hintStyle: TextStyle(
                            color: kLightBlue
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(5)
                          ),
                          borderSide: BorderSide.none,
                        ),
                    )
                  ),
                ),
              ),
              if(widget.shopId!=null && widget.shopDets!=null && widget.shopDets.isNotEmpty)_getSellerCard(),
              Expanded(
                child: GridView(
                  padding: EdgeInsets.all(10),
                  children:gridList,
                  semanticChildCount: 2,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.78
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showProgress(bool b){
    setState(() {
      isLoading=b;
    });
  }

  Future<void> setGridList() async {
    isLoading=true;
    gridList= await _searchScreenModel.getAllMarketItems(this.context);
    isLoading=false;
    setState(() {
    });
  }

  Widget _getSellerCard(){
    String sellerProf=widget.shopDets;
    if(!sellerProf.contains('<'))return null;
    List<String> sList= sellerProf.split('<');
    if(sList.length<2) return null;
    sellerEmail=sList[0];
    sellerPNum=sList[1];
    return Card(
      child: Column(
        children: [
          SizedBox(height: 10,),
          // Text(shopTitle, textAlign: TextAlign.start, style:
          // TextStyle(color: Colors.black,
          //     fontFamily: 'Pacifico',
          //     fontWeight: FontWeight.w200, fontSize: 17),),
          Text('Contact Seller. $sellerName', textAlign: TextAlign.start, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12),),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  padding: contactsPadding,
                  decoration: BoxDecoration(
                      color: Colors.black, shape: BoxShape.circle
                  ), child: Icon(CupertinoIcons.phone,color: Colors.white)),
              SizedBox(width: 16,),
              Container(
                  padding: contactsPadding,
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,  shape: BoxShape.circle
                  ), child: Icon(CupertinoIcons.chat_bubble_text,color: Colors.white)),
              SizedBox(width: 16,),
              Container(
                  padding: contactsPadding,
                  decoration: BoxDecoration(
                      color: Colors.red,   shape: BoxShape.circle
                  ), child: Icon(CupertinoIcons.mail, color: Colors.white,)),
              SizedBox(width: 16,),
              CircleAvatar(
                radius: 16,
                child: GestureDetector(
                    onTap: (){
                    },
                    child: Image.asset('images/whatsapp.png', height: 26,)),backgroundColor: Colors.green,),
            ],
          ),
          SizedBox(height: 10,),
        ],
      ),
    );
  }


  void callSeller(){
    launch("tel:$sellerPNum");
  }

  void smsSeller(){
    launch("sms:$sellerPNum");
  }

  void whatsappSeller(){
    String phoneNum2Use=sellerPNum!=null&&sellerPNum.trim().isNotEmpty?sellerPNum:'08065023649';
    if(!phoneNum2Use.startsWith('+')){
      phoneNum2Use='+234'+phoneNum2Use.substring(1);
    }
    if(Platform.isAndroid ){
      launch('https://wa.me/$phoneNum2Use');
    }else if(Platform.isIOS){
      launch('https://api.whatsapp.com/send?phone=$phoneNum2Use');
    }
//    launch('https://api.whatsapp.com/send?phone=$sellerPNum');
  }

  Future<void> emailSeller() async{
    final Uri params = Uri(
      scheme: 'mailto',
      path: '$sellerEmail',
    );
    String  url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print( 'Could not launch $url');
      uShowErrorNotification('Sorry! An error occured.');
    }
  }

  void seachForItem(String value) async{
    if(!(await uCheckInternet())){
      showProgress(false);
      uShowNoInternetDialog(context);
      return ;
    }
    isLoading=true;
    setState(() {

    });

    gridList= await getSearchResultFor(value, this.context);
    isLoading=false;
    setState(() {

    });
  }

  void resolveSearchParams() {
    searchText = widget.searchText;
    if(widget.shopId!=null && widget.shopId.isNotEmpty){
      searchForShopItems(widget.shopId);
    }
  }

  Future<void> searchForShopItems(String shopId) async {
    showProgress(true);
    // var mRef= FirebaseDatabase.instance.reference().child('S').orderByChild('s').equalTo(shopId).limitToLast(8);
    // DataSnapshot qVal= await mRef.once();
    // print('ans value: ${qVal.value.toString()}');
    //
    // Map<dynamic , dynamic> maps= Map.from(qVal.value);
    if(!(await uCheckInternet())){
      showProgress(false);
      uShowNoInternetDialog(context);
      return;
    }
    List<SmallMitem> sList=[];
    List<MartItem> largerItems= (await AzSingle().getSellerItems(shopId, top: 20));
    if(largerItems.length>0)widget.shopDets=largerItems[0].p;
    for(var k in largerItems){
      SmallMitem item=SmallMitem.fromMartItem(k);
      // item.I=k.key.toString();
      sList.add(item);
    }

    List<Widget> itemList=[];
    for(SmallMitem smit in sList){
      itemList.add(MartGridItem(smitem: smit, onPressedFunc: (){
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return ItemDescriptionScreen(heroTag: smit.I, smallMitem: smit,);
        }));
      },));
    }
    gridList=itemList;
    showProgress(false);
  }

  Future<List<Widget>> getSearchResultFor(String s, BuildContext context) async {

    List<Widget> wids=[];
    List<MartItem> martList= await AzSingle().searchForWord(s);
    for(MartItem mitem in martList){
      SmallMitem item=SmallMitem.fromMartItem(mitem);
      wids.add(MartGridItem(smitem: item,onPressedFunc: (){
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return ItemDescriptionScreen(heroTag: item.I, smallMitem: item,);
        }));
      },));
    }
    return wids;
  }
}

