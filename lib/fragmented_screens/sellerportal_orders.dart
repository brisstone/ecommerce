import 'dart:ui';

// import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/custom_widgets/order_list_item.dart';
import 'package:ecommerce/mart_objects/mart_item.dart';
import 'package:ecommerce/mart_objects/order_item.dart';
import 'package:ecommerce/providers/promo_model.dart';
import 'package:ecommerce/providers/seller_orders_provider.dart';
import 'package:ecommerce/screens/order_details_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

class SellerportalOrdersPage extends StatefulWidget {
  @override
  _SellerportalOrdersPageState createState() => _SellerportalOrdersPageState();
}

class _SellerportalOrdersPageState extends State<SellerportalOrdersPage> {

  double totalRevenue=0.0;
  TextStyle smallTextStyle=TextStyle(color: kLightBlue, fontSize: 10, fontWeight: FontWeight.w500);
  TextStyle largeTextStyle=  TextStyle(color: kLightBlue, fontSize: 20, fontWeight: FontWeight.w900);
  double netRevenue=0.0;
  // SellerPortalOrdersModel _smoModel= SellerPortalOrdersModel();
  BoxDecoration btnSelectedDecoration = BoxDecoration(borderRadius: BorderRadius.circular(30),
                  color: kThemeBlue,
                  );
  OrderButtons selectedBtn= OrderButtons.Pending;
  RefreshController _refreshController=RefreshController(initialRefresh: false);
  List<Widget> _orderList=[];

  bool progress=false;

  void setOrderButtton(OrderButtons option) {
    setState(() {
      selectedBtn= option;
    });
  }

  @override
  void initState() {
    selectedBtn=OrderButtons.Pending;
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      onRefresh: startRefresh,
      controller:_refreshController,
      child: ModalProgressHUD(
        inAsyncCall: progress,
        child: Container(
          color: kThemeBlue,
          child: Column(
            children: [
              // Text('My Orders', style: largeTextStyle,),
              SizedBox(height: 30,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Text('${Provider.of<SellerOrderProvider>(context).filterStatus} ${Provider.of<SellerOrderProvider>(context).amount!=null?': \u20a6 ${Provider.of<SellerOrderProvider>(context).amount}':''} ',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                    Spacer(),
                    Text('Total: ${Provider.of<SellerOrderProvider>(context).orderWidgets.length}',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                  ]
                ),
              ),
             Expanded(
                child: Container(
                  padding: EdgeInsets.only( top: 20),
                  decoration:   BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    color: Colors.white,
                  ),
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.white,
                        height: double.maxFinite,
                        margin: EdgeInsets.only(top: 170),
                      ),
                     if( Provider.of<SellerOrderProvider>(context).sellerOrders.length>0) ListView.builder(
                        itemCount: Provider.of<SellerOrderProvider>(context).orderWidgets.length,
                        itemBuilder: (context, dex){
                          OrderListItem olitem= Provider.of<SellerOrderProvider>(context).orderWidgets[dex];
                          olitem.onPressedFunc=(){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderDetailsScreen(olitem.oItem, isSeller: true,)));
                          };
                          return olitem;
                        },
                      ),
                      if( Provider.of<SellerOrderProvider>(context).sellerOrders.length==0)
                        Icon(Icons.remove_shopping_cart_outlined, color: Colors.grey, size: MediaQuery.of(context).size.height*0.5,)
                    ],
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget _getBarChart()  {
    return Container();
    // List<OrderGraphData> data= sortOrdersBy(selectedBtn);
    // List<charts.Series<OrderGraphData, String>> series = [
    //   charts.Series(
    //       id: "Subscribers",
    //       data: data,
    //       // seriesColor: charts.Color(r: 250,g: 250,b: 250),
    //       labelAccessorFn: (OrderGraphData series, _) => series.name ,
    //       domainFn: (OrderGraphData series, _) => series.name,
    //       measureFn: (OrderGraphData series, _) => series.num,
    //       insideLabelStyleAccessorFn:(OrderGraphData series, _)=>charts.TextStyleSpec(color: charts.Color(r: 20,g: 20,b: 250), fontSize: 8) ,
    //       outsideLabelStyleAccessorFn:(OrderGraphData series, _)=>charts.TextStyleSpec(color:charts.Color(r: 250,g: 200,b: 50), fontSize: 8, ) ,
    //       colorFn: (OrderGraphData series, _) => charts.Color(r: 250,g: 200,b: 50)//charts.Color.white
    //   )
    // ];
    // return charts.BarChart(
    //   series,
    //   // animate: true,
    //   barRendererDecorator: new charts.BarLabelDecorator<String>(),
    //   domainAxis: new charts.OrdinalAxisSpec(renderSpec: new charts.NoneRenderSpec()),
    //   primaryMeasureAxis: new charts.NumericAxisSpec(renderSpec: new charts.SmallTickRendererSpec(
    //     labelStyle: charts.TextStyleSpec(
    //     color: charts.Color.white,
    //     ))),
    // );
  }

  Future<void> startRefresh() async {
    print('initiated refesh');
    showProgress(true);
    await Provider.of<SellerOrderProvider>(context,listen: false).quickFetchForOrders();
    showProgress(false);
  }

  void showProgress(bool bool) {
    _refreshController.refreshCompleted();
    setState(() {
      progress=bool;
    });
  }

   List<OrderGraphData> sortOrdersBy(OrderButtons selectedBtn)  {
    Map<String,int> itemIdNnums=new Map();
    Map<String,double> itemIdPrices=new Map();
    Map<String,int> itemIdUnits=new Map();
    OrderItem orderItem;
    for(OrderListItem orderListItem in Provider.of<SellerOrderProvider>(context,listen: false).orderWidgets){
       orderItem=orderListItem.oItem;
      if(itemIdNnums.containsKey(orderItem.t)){
        itemIdNnums[orderItem.t]++;
        itemIdPrices[orderItem.t]+=double.tryParse(orderItem.p)??0;
        itemIdUnits[orderItem.t]+=int.tryParse(orderItem.u)??0;
      }else{
        itemIdNnums[orderItem.t]=1;
        itemIdPrices[orderItem.t]=double.tryParse(orderItem.p)??0;
        itemIdUnits[orderItem.t]=int.tryParse(orderItem.u)??0;
      }
    }

    List<OrderGraphData> graphItems= [];
    for(MartItem mitem in Provider.of<PromoModel>(context,listen: false).martItemsList){
      OrderGraphData odg=OrderGraphData()
        ..id=mitem.l
        ..price=mitem.p
        ..name=mitem.t;
      if(itemIdNnums.containsKey(mitem.l)){
        odg.num=itemIdNnums[mitem.l].toDouble();
       switch(selectedBtn){
          case OrderButtons.byRevenue:
            odg.num=itemIdPrices[mitem.l];
            break;
          case OrderButtons.byUnits:
            odg.num=itemIdNnums[mitem.l].toDouble();
            break;
          default:
            break;
        }
      }else{
        odg.num=0;
      }
      print('graph name: ${odg.name}, id: ${odg.id}, num: ${odg.num}');
      graphItems.add(odg);
    }
    return graphItems;
  }
}
class OrderGraphData {
  String name;
  String id;
  String price;
  double num;

  Color color=kThemeOrange as Color;
}
enum OrderButtons{ Pending, Closed, byRevenue, byUnits, byPeriod }
