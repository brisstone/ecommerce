import 'package:ecommerce/constants.dart';
import 'package:ecommerce/mart_objects/small_mitem.dart';
import 'package:ecommerce/providers/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utility_functions.dart';

class MartGridItem extends StatelessWidget {

  MartGridItem({this.smitem, this.onPressedFunc}){
    setItemDets();
  }

  SmallMitem smitem;
  String imageUrl='';
  String heroTagNum='';
  String title='';
  String price='';
  Function onPressedFunc;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: onPressedFunc!=null?onPressedFunc:(){},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 11,
                    child: Hero(
                      tag: smitem.I,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child:FadeInImage.assetNetwork(
                            placeholder: 'assets/fading.gif',
                            image:imageUrl, fit: BoxFit.fill, height: 150, width: double.infinity, )),
                    ),
                  ),
                  SizedBox(height:10),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Text(title, textAlign: TextAlign.left, style: TextStyle( fontWeight: FontWeight.bold, color: kThemeBlue)),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(price, textAlign: TextAlign.left, style: TextStyle( color: kThemeOrange, fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(height:10),
                ],
              ),
            ),
            GestureDetector(
              onTap: (){
                uToggleFavoriteStatus(context: context, smitem: smitem);
              },
              child:Provider.of<FavoriteProvider>(context).isItemFavorite(smitem)?
              Icon(Icons.favorite, color:Colors.red)  :
              Icon(Icons.favorite_border, color: kThemeOrange,)
            )
          ]
        ),
      ),
    );
  }

  Future<void> setItemDets() async {
    heroTagNum=smitem.I;
    title=smitem.N;
    price='\u20a6 ${smitem.M.split('<')[0]}';
//    imageUrl=await uGetPicDownloadUrl(smitem.P);// kUrlStart+smitem.P.replaceAll(kUrlStart, '');
    imageUrl=uGetAzurePicUrl(smitem.P);
  }

}
