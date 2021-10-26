import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/custom_widgets/my_button.dart';
import 'package:ecommerce/custom_widgets/rating_widget.dart';
import 'package:ecommerce/mart_objects/order_item.dart';
import 'package:ecommerce/utility_functions.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;

class ConfirmOrderDelivery extends StatefulWidget {

  ConfirmOrderDelivery({this.order, this.onConfirmPressed});
  OrderItem order;
  Function onConfirmPressed;

  @override
  _ConfirmOrderDeliveryState createState() => _ConfirmOrderDeliveryState();
}

class _ConfirmOrderDeliveryState extends State<ConfirmOrderDelivery> {

  bool _progress=false;
  String _feedback='';
  int _sellerRating=0;
  int _page=0;
  var _accController;
  TextStyle labelStyle=kHintStyle.copyWith(color: kThemeBlue, fontWeight: FontWeight.w300, fontSize: 12 );
  PageController _pageController=PageController(
      initialPage: 0
  );


  @override
  void initState() {
    checkReviewStat();
  }

  @override
  Widget build(BuildContext context) {
    if(_page==0)  return _getReviewOrderPage();
    return _getConfirmDeliveryPage();
    // return Container(
    //
    //   child: PageView(
    //     children: [
    //       _getReviewOrderPage(),
    //       _getConfirmDeliveryPage()
    //     ],
    //     controller: _pageController,
    //   ),
    // );
  }

  Widget _getConfirmDeliveryPage(){
    return Container(
      height: MediaQuery.of(context).size.height*0.65,
      padding: EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20,),
          Expanded(child: Image.asset('images/box.png', height: 200,)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Confirm delivery', style: TextStyle(color: kThemeBlue, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          ),
          SizedBox(height: 20,),
          Container(
            height: 50,
            padding: EdgeInsets.all(8.0),
            child: MyButton(
              text: 'Proceed',
              buttonColor: Colors.blue,
              onPressed: (){
                widget.onConfirmPressed.call();
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _getReviewOrderPage(){
    return ModalProgressHUD(
      inAsyncCall: _progress,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20,),
              ListTile(
                  leading: Image.asset('images/logo.png', color: kThemeBlue, height:50, width: 50,),
                  title: Text('Please rate the seller\'s service.', textAlign: TextAlign.center, style: kNavTextStyle.copyWith(color: kThemeBlue, fontWeight: FontWeight.bold))),
              SizedBox(height: 20,),
              // Container(
              //     alignment: Alignment.centerLeft,child: Text('Please rate the seller\'s service.', textAlign: TextAlign.start, style: labelStyle)),
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.all(16),
                child: TextButton(
                    onPressed: moveToNext,
                    child: Text('Skip', textAlign: TextAlign.end, style: kHintStyle.copyWith(color: Colors.blue, fontWeight: FontWeight.bold),)),
              ),
              SizedBox(height: 5,),
              Container(
                  height: 50,
                  child: RatingRow(rating: _sellerRating, onPressed: _setRating,)),
              SizedBox(height: 5,),
              Container(
                  alignment: Alignment.centerLeft,child: Text('Additional feedback.', textAlign: TextAlign.start, style: labelStyle)),
              SizedBox(height: 5,),
              Container(
                child: TextField(
                  onChanged: (string){
                    _feedback=string;
                  },
                  // controller: _accController,
                  maxLength: 80,
                  inputFormatters:[
                    LengthLimitingTextInputFormatter(80)
                  ],
                  maxLines: 3,
                  decoration: InputDecoration(
                      filled: true,
                      // prefixIcon: Icon(Icons.account_balance_outlined, color: kThemeBlue,),
                      hintText: '',
                      hintStyle: kHintStyle,
                      counterStyle: kHintStyle,
                      helperStyle: TextStyle(color: Colors.blue),
                      fillColor: kLightBlue.withOpacity(0.2)
                  ),
                  textInputAction: TextInputAction.next,
                  style: TextStyle(color: kThemeBlue),
                  keyboardType: TextInputType.text,
                ),
              ),
              MyButton(text:'Continue',
                buttonColor: Colors.black,
                onPressed: (){
                  sendReview();
                },),

              SizedBox(height: 20,),
              Text('Secured on Azure 🔒', textAlign: TextAlign.center, style: kNavTextStyle.copyWith(color: kThemeBlue, fontWeight: FontWeight.bold)),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendReview() async {
    try {
      if (_sellerRating == null || _sellerRating == 0) {
        uShowErrorNotification('Invalid rating.');
        return;
      }
      setProgress(true);
      if(!(await uCheckInternet())){
        uShowErrorNotification('No internet');
        setProgress(false);
        return;
      }
      String orderId = widget.order.i;
      String itemId = widget.order.t;
      String message = _feedback;
      String rating = _sellerRating.toString();
      String url = "https://gmartfunctions.azurewebsites.net/api/review-order?iid=$itemId&oid=$orderId&message=$message&rating=$rating";
      http.Response response = await http.get(url);
      print("send review result: " + await response.body.toString() +
          (response.statusCode.toInt() == 200).toString());
      if (response != null && response.statusCode.toInt() >= 200 &&
          response.statusCode.toInt() < 300) {
        String reviewedOrders = await uGetSharedPrefValue(kOrdersReviewedKey);
        reviewedOrders += ',$orderId';
        await uSetPrefsValue(kOrdersReviewedKey, reviewedOrders);
      } else {
        uShowErrorNotification('Operation error.');
      }
    }catch(e){
      print('send review error: $e');
      uShowErrorNotification('An error occured. Please try again later.');
    }
    setProgress(false);
    moveToNext();
  }

  void moveToNext() {
    // _pageController.animateToPage(1, duration: Duration(milliseconds: 600), curve: Curves.easeInSine);
    setState(() {
      _page=1;
    });
  }

  Future<void> checkReviewStat() async {
    setProgress(true);
    String review= await uGetSharedPrefValue(kOrdersReviewedKey);
    if(review.contains(widget.order.i)){
      setProgress(false);
      moveToNext();
    }
    setProgress(false);
  }

  void setProgress(bool bool) {
    setState(() {
      _progress=bool;
    });
  }

  void _setRating(int rating) {
    setState(() {
      _sellerRating=rating;
    });
  }

}
