import 'package:ecommerce/constants.dart';
import 'package:ecommerce/custom_widgets/variant_list_item.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ConfirmPricePage extends StatefulWidget {


  ConfirmPricePage({this.numOfOrder, this.addItemFunction,
    this.minusItemFunction,this.numProgress, this.price = 0, this.variantsData, this.changeVariant, this.uploadToCart});

  String variantsData;
  Function addItemFunction;
  Function minusItemFunction;
  String numOfOrder;
  bool numProgress=false;
  Function changeVariant;
  Function uploadToCart;
  double price;

  @override
  _ConfirmPricePageState createState() => _ConfirmPricePageState();

}

class _ConfirmPricePageState extends State<ConfirmPricePage> {
  bool progress = false;
  String variantName;

  List<Widget> variantsList = [];


  @override
  void initState() {
    setVariantsList(widget.variantsData);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: double.maxFinite,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            Text('Select units', textAlign: TextAlign.center,),
            Container(
              height: 100,
              width: 400,
              child: ModalProgressHUD(
                inAsyncCall: progress,
                color: Colors.transparent,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(onPressed: ()async{
                        showProgress(true);
                        widget.numOfOrder = (await widget.addItemFunction()).toString();
                        print('widget.numOfOrder: ${widget.numOfOrder}');
                        showProgress(false);
                      },
                          child: Icon(Icons.plus_one, size: 24, color: kThemeOrange,)),
                      Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.all (Radius.circular(10)),
                          ),
                          alignment: Alignment.center,
                          height:100,
                          width: 100,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('${widget.numOfOrder}', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
                          )),

                      TextButton(onPressed:  () async {
                        showProgress(true);
                        widget.numOfOrder =  await widget.minusItemFunction();
                        print('widget.numOfOrder: ${widget.numOfOrder}');
                        showProgress(false);
                      },
                          child: Icon(Icons.exposure_minus_1, size: 24, color: kThemeOrange,)),
                    ],
                  ),
                ),
              ),
            ),
            if(variantsList.length>0)
              Text('\t\t\t\tSelect variant'),
            Container(
              height: variantsList.length>0? 50:0,
              alignment: Alignment.center,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: variantsList,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(getBillText(), textAlign: TextAlign.center,
                style: TextStyle(color: kThemeOrange, fontWeight: FontWeight.w900, fontSize: 15),),
            ),
            SizedBox(height: 10,),
            GestureDetector(
                onTap: widget.uploadToCart,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                  decoration: BoxDecoration(
                      color: kThemeOrange,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Text('Add to cart', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                )),

            SizedBox(height: 20,)
          ]
      ),
    );
  }

  void setVariantsList(String pricesAndVariants) {
    if (!pricesAndVariants.contains("<")) {
      return ;
    }
    List<String> variantsArray = pricesAndVariants.split("<");
    if (variantsArray.length <= 2) {
      return ;
    }
    List<Widget> variantsList = [];
    for (int i = 2; i < variantsArray.length; i++) {
      if(!variantsArray[i].contains('>') && !variantsArray[i].contains(','))continue;
      List variantDetails = variantsArray[i].contains('>')?variantsArray[i].split(">"):variantsArray[i].split(',');
      variantsList.add(
          VariantListItem(title: variantDetails[0],
            price:variantDetails[1],
            selected: variantName!=null&&variantName.isNotEmpty?variantDetails[0].toString().contains(variantName):false,
            onPressedFunc: (){
              widget.changeVariant(amount: variantDetails[1], vName: variantDetails[0]);
              changeVariant(amount: variantDetails[1], vName: variantDetails[0]);
              setVariantsList(widget.variantsData);
              setVariantsList(widget.variantsData);
            },));
    }
    this.variantsList= variantsList;
  }

  void changeVariant({String amount, String vName}){
    widget.price=double.tryParse(amount)??0;
    variantName=vName;
    print('vName in dialog: $vName, vAmount: $amount');
    if(this.mounted)
      setState(() {
      });
  }

  void showProgress(bool bool) {
    setState(() {
      progress = bool;
    });
  }

  String getBillText() {
    double currentNum= double.tryParse(widget.numOfOrder)??0;

    return '\u20a6 ${widget.price * currentNum}';
  }
}






