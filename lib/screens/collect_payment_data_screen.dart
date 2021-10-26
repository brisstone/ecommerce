import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/custom_widgets/my_button.dart';
import 'package:ecommerce/custom_widgets/rating_widget.dart';
import 'package:ecommerce/mart_objects/order_item.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';

class CollectPaymentDataScreen extends StatefulWidget {
  Function(String, String, String) onPaymentComplete;
  bool isSeller=false;
  OrderItem order;

  CollectPaymentDataScreen({@required this.onPaymentComplete, @required this.order, this.isSeller=false});

  @override
  _CollectPaymentDataScreenState createState() => _CollectPaymentDataScreenState();
}

class _CollectPaymentDataScreenState extends State<CollectPaymentDataScreen> {
  List<DropdownMenuItem<BankData>> bankList=[];

  BankData _chosenBankData;
  String _chosenBank= '';
  String _accNum= '';
  String _accName= '';
  String _accountDetails='';
  String _feedback='';
  String _accountName='';

  bool _isAccResolved=false;
  bool _progress=false;

  var _accController;
  TextStyle labelStyle=kHintStyle.copyWith(color: kThemeBlue, fontWeight: FontWeight.w300, fontSize: 12 );
  PageController _pageController=PageController(
      initialPage: 0
  );
  var _resolveProgress=false;

  int _sellerRating=0;


  @override
  void initState() {
    // checkReviewStat();
  }

  @override
  Widget build(BuildContext context) {
    return _getCollectAccountDataPage();
  }

  Widget _getCollectAccountDataPage(){
    return       SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20,),
            ListTile(
                leading: Image.asset('images/logo.png', color: kThemeBlue, height:50, width: 50,),
                title: Text('Request Gmart Settlement.', textAlign: TextAlign.center, style: kNavTextStyle.copyWith(color: kThemeBlue, fontWeight: FontWeight.bold))),
            SizedBox(height: 20,),
            Container(
                alignment: Alignment.centerLeft,child: Text('Enter Bank Account number.', textAlign: TextAlign.start, style: labelStyle)),
            SizedBox(height: 5,),
            Container(
              child: TextField(
                onChanged: (string){
                  if(_accNum!=string && _isAccResolved)falsifyAccResolved();
                  _accNum=string;
                },
                controller: _accController,
                maxLength: 10,
                inputFormatters:[
                  LengthLimitingTextInputFormatter(10)
                ],
                decoration: InputDecoration(
                    filled: true,
                    // prefixIcon: Icon(Icons.account_balance_outlined, color: kThemeBlue,),
                    hintText: 'Enter bank account number',
                    hintStyle: kHintStyle,
                    counterStyle: kHintStyle,
                    helperStyle: TextStyle(color: Colors.blue),
                    fillColor: kLightBlue.withOpacity(0.2)
                ),
                textInputAction: TextInputAction.next,
                style: TextStyle(color: kThemeBlue),
                keyboardType: TextInputType.numberWithOptions(),
              ),
            ),
            Container(
                alignment: Alignment.centerLeft,child: Text('Select bank', textAlign: TextAlign.start, style: labelStyle)),
            SizedBox(height: 5,),
            Container(
              height: 50,
              width: double.maxFinite,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: kLightBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: ModalProgressHUD(
                inAsyncCall: _progress,
                opacity: 0,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton <BankData>(
                      isExpanded: true,
                      value: _chosenBankData,
                      hint: Text('Select bank', style: kHintStyle,),
                      dropdownColor: Colors.white,
                      isDense: true,
                      style: kStatePickerTextStyle.copyWith(color: kThemeBlue),
                      items: this.bankList,
                      onChanged: (value){
                        if(_chosenBank!=value.bankCode && _isAccResolved)falsifyAccResolved();
                        _chosenBank=value.bankCode;
                        print('selected ${value.bankName} ${value.bankCode}');
                        setState(() {
                          _chosenBankData=value;
                        });
                      }),
                ),
              ),
            ),
            Container(
              height: 40, width: 100,
              alignment: Alignment.centerLeft,
              child: ModalProgressHUD(
                  inAsyncCall: _resolveProgress,
                  opacity: 0,
                  child: Container(height: 25, width: 25,)),
            ),
            if(_isAccResolved && _accountDetails!=null &&_accountDetails.trim().isNotEmpty)Container(
                alignment: Alignment.centerLeft,child: Text('Account name', textAlign: TextAlign.start, style: labelStyle)),
            if(_isAccResolved) Container(height:50, alignment: Alignment.topLeft, child: Text(_accountDetails, style: kNavTextStyle.copyWith(color: Colors.black, fontSize: 13, ),),),
            MyButton(text: _isAccResolved?'Request Pay Out':'Confirm Account',
              buttonColor: _isAccResolved?kThemeBlue:Colors.black,
              onPressed: (){
                if(_isAccResolved){
                  completeUpload();
                }else{
                  resolveAccountNumber();
                }
              },),

            SizedBox(height: 20,),
            Text('Secured on Azure 🔒', textAlign: TextAlign.center, style: kNavTextStyle.copyWith(color: kThemeBlue, fontWeight: FontWeight.bold)),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );

  }


  Future<void> setBankList() async {
    String url="https://api.paystack.co/bank";
    setProgress(true);
    http.Response response=await http.get(url);
    if(response.statusCode>=200 && response.statusCode<300) {
      dynamic rawlist= jsonDecode(response.body.toString());
      for(var bankRawData in rawlist['data']){
        bankList.add(DropdownMenuItem<BankData>(value:BankData(bankRawData['name'].toString(),bankRawData['code'].toString()) , child: Text(bankRawData['name'].toString()),)   );
      }
    }else{
      uShowErrorDialog(context, 'Operation error.');
    }
    setProgress(false);
  }


  void setProgress(bool bool) {
    setState(() {
      _progress=bool;
    });
  }

  void setResolveProgress(bool bool) {
    setState(() {
      _resolveProgress=bool;
    });
  }

  Future<void> resolveAccountNumber() async {
   if(_accNum==null || _accNum.isEmpty || _accNum.trim().length!=10){
     uShowErrorNotification('Invalid account number.');
     return;
   }
   if(_chosenBankData==null || _chosenBank==null || _chosenBank.trim().isEmpty){
     uShowErrorNotification('Invalid bank chosen');
     return;
   }
   if(!(await uCheckInternet())){
     uShowErrorNotification('No internet');
     return;
   }
    String url="https://gmartfunctions.azurewebsites.net/api/get-acc-dets?acc=$_accNum&bcode=$_chosenBank";
   setResolveProgress(true);
    http.Response response=await http.get(url);
    print("account res result: "+await response.body.toString()+(response.statusCode.toInt()==200).toString());
    if(response!=null && response.statusCode.toInt()>=200 && response.statusCode.toInt()<300) {
      dynamic rawList= jsonDecode(response.body.toString());
      if(rawList['status'].toString().trim().toLowerCase()!='true'){
        uShowErrorNotification('Operation error.');
        setResolveProgress(false);
        return;
      }
      _accName=rawList['data']['account_name'].toString();
      _accountDetails=rawList['data']['account_name'];//'Account name: ${rawList['data']['account_name']}\nAccount number: ${rawList['data']['account_number']}';
      setAccResolved2True();
    }else{
      uShowErrorNotification('Operation error.');
    }
   setResolveProgress(false);
  }

  void completeUpload(){
    widget.onPaymentComplete(_accNum, _chosenBank, _accName).call();
  }

  void falsifyAccResolved() {
    setState(() {
      _isAccResolved=false;
    });
  }
  
  void setAccResolved2True() {
    _isAccResolved=true;
  }


  void moveToNext() {
    _pageController.animateToPage(1, duration: Duration(milliseconds: 600), curve: Curves.easeInSine);
  }

}

class BankData{
  String bankName;
  String bankCode;
  BankData(this.bankName, this.bankCode);
}


