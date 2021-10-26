import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class DeliveryChargeProvider extends ChangeNotifier{

  String deliveryAmount='';
  String cardDate='';
  setDeliveryNotifier(String amount){
    deliveryAmount=amount;
    notifyListeners();
  }

  clearCardDate(){
    cardDate='';
    notifyListeners();
  }

  setCardDate(String value){
    cardDate=value;
    if(cardDate.length==2)cardDate+='/';
    notifyListeners();
  }


}
