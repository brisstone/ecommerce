import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/src/flutter_local_notifications_plugin.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/providers/customer_orders_provider.dart';
import 'package:ecommerce/providers/delivery_charge_provider.dart';
import 'package:ecommerce/providers/favorite_provider.dart';
import 'package:ecommerce/providers/profile_provider.dart';
import 'package:ecommerce/providers/promo_model.dart';
import 'package:ecommerce/providers/seller_orders_provider.dart';
import 'package:ecommerce/screen_models/wallet_model.dart';
import 'package:ecommerce/screens/decision_page.dart';
import 'package:ecommerce/screens/edit_item_screen.dart';
import 'package:ecommerce/screens/retrieve_account_screen.dart';
import 'package:ecommerce/screens/favorites_screen.dart';
import 'package:ecommerce/screens/info_screen.dart';
import 'package:ecommerce/screens/login_screen.dart';
import 'package:ecommerce/screens/profile_screen.dart';
import 'package:ecommerce/screens/search_screen.dart';
import 'package:ecommerce/screens/seller_portal_screen.dart';
import 'package:ecommerce/screens/sign_up_screen.dart';
import 'package:ecommerce/screens/wallet_screen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'NotificationHelper.dart';
import 'screens/home_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin= FlutterLocalNotificationsPlugin();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications(flutterLocalNotificationsPlugin);
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context)=> DeliveryChargeProvider()),
        ChangeNotifierProvider(create: (context)=> FavoriteProvider()),
        ChangeNotifierProvider(create: (context)=> WalletModel()),
        ChangeNotifierProvider(create: (context)=> PromoModel()),
        ChangeNotifierProvider(create: (context)=> SellerOrderProvider()),
        ChangeNotifierProvider(create: (context)=> CustomerOrderProvider()),
        ChangeNotifierProvider(create: (context)=> ProfileProvider()),
        ChangeNotifierProvider(create: (context)=> CartProvider()),
      ],child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return OverlaySupport(
      child: MaterialApp(
        title: 'Ecommerce',
        theme: ThemeData(
            primaryColor: Colors.white
        ),
        routes:{
          '/':(context)=>DecisionPage(),
          '/home':(context)=>MyHomePage(title: 'Gmart',),
          '/search':(context)=>SearchScreen(),
          '/wallet':(context)=>WalletScreen(),
          '/profile':(context)=>ProfileScreen(),
          '/sellerPortal':(context)=>SellerPortalScreen(),
          '/editScreen':(context)=>EditItemScrren.empty(),
          '/info':(context)=>InfoScreen(),
          '/favorites':(context)=>FavoritesScreen(),
          '/login':(context)=>LoginScreen(),
          '/signup':(context)=>SignUpScreen(),
          '/retrieve':(context)=>RetrieveAccountScreen(),
        },
      ),
    );
  }
}
