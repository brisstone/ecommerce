
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/custom_widgets/my_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterwavePayoutDialog extends StatefulWidget {
  String price;
  String email;
  
  @override
  _FlutterwavePayoutDialogState createState() => _FlutterwavePayoutDialogState();
}

class _FlutterwavePayoutDialogState extends State<FlutterwavePayoutDialog> {
  String cardNum='';
  String expYear='';
  String expMonth='';
  String cvv='';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.email, style:kHintStyle,),
          Text('\u20a6 ${widget.price}', style:kInputLabelStyle,),
          SizedBox(height: 10,),
          TextFormField(
              controller: TextEditingController(text: cardNum),
              style: kInputTextStyle,
              textAlign: TextAlign.start,
              maxLength: 10,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10)
              ],
              onChanged:(value){cardNum=value;},
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                filled: true,
                suffix: Icon(
                  CupertinoIcons.creditcard, color: kThemeBlue,),
                fillColor: Colors.white,
                labelText: 'Input first name',
                hintStyle: kHintStyle,
                border: kInputOutlineBorder,
              )
          ),
          SizedBox(height: 10,),
          Row(
            children:[
              Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: kThemeBlue,
                  ),
                  borderRadius: BorderRadius.circular(8)
              ),
              margin: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  TextFormField(
                      controller: TextEditingController(text: expMonth),
                      style: kInputTextStyle,
                      textAlign: TextAlign.center,
                      maxLength: 2,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(2)
                      ],
                      onChanged:(value){expMonth=value;},
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'MM',
                        hintStyle: kHintStyle,
                      )
                  ),
                  TextFormField(
                    controller: TextEditingController(text: expYear),
                    style: kInputTextStyle,
                    textAlign: TextAlign.start,
                    maxLength: 2,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(2)
                    ],
                    onChanged:(value){
                        expYear=value;
                      },
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText:'YY' ,
                      hintStyle: kHintStyle,
                    )
                ),
                ]
              ),
            ),
              TextFormField(
                  controller: TextEditingController(text: cvv),
                  style: kInputTextStyle,
                  textAlign: TextAlign.center,
                  maxLength: 3,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(3)
                  ],
                  onChanged:(value){cvv=value;},
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'cvv',
                    hintStyle: kHintStyle,
                  )
              ),

            ]
          ),
          MyButton(text: 'Pay Now', onPressed: (){paySplitPayment();}),
          SizedBox(height: 10,),
          Text('Secured by', style:kHintStyle,),
          Text('FLUTTERWAVE', style:kInputLabelStyle,),
        ],
      ),
    );
  }

  void paySplitPayment() {
  }

}

