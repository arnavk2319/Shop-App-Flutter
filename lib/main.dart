import 'package:flutter/material.dart';
import 'screens/products_overview_screen.dart';
import 'screens/product_detail_screen.dart';
import 'package:provider/provider.dart';        //Line 4 and 5 imports are importing the same file but both are important. Line 4 import is necessary for the registering the provider, line 5 is necessary for calling the constructor of the file
import 'providers/product_provider.dart';
import 'providers/cart.dart';
import 'screens/cart_screen.dart';
import 'providers/orders.dart';
import 'screens/orders_screen.dart';
import 'screens/user_product_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/auth_screen.dart';
import 'providers/auth.dart';
import 'screens/splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {                                    //we can also use the ChangeNotifier class as earlier where we return the ChangeNotifier class and define an itemBuilder object using an anonymous function having context data as arg("ctx")
    return MultiProvider(providers: [                                               //Provider package registers a list of providers so that we can avoid nested providers
      ChangeNotifierProvider.value(
          value: Auth()),

      ChangeNotifierProxyProvider<Auth, ProductsProvider>(                            //Registering the provider with the Root widget, parent of the all the children. Allows to register a class that other widgets are listening to and then only widgets are updated.
        builder : (ctx, auth, previousProduct) =>
            ProductsProvider(
                auth.getToken,
                previousProduct == null? [] : previousProduct.items,
                auth.getUserID,
            ),                                                              //items is the getter method here                  //new instance of the class that widgets which are listening will be notified through notifyListeners() method in product provider, not the whole material app
        ),
      ChangeNotifierProvider.value(
          value: Cart(),
      ),
      ChangeNotifierProxyProvider<Auth, Orders>(
          builder: (ctx,auth, previousOrder) =>
              Orders(
                  auth.getToken,
                  previousOrder == null ? [] : previousOrder.getOrders,
                  auth.getUserID
              ),
      ),
    ],
    child: Consumer<Auth>(builder: (ctx,authData,_){
      return MaterialApp(                                                 //receives all the providers in the list above of Multi providers
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: authData.isAuth ? ProductOverviewScreen() : FutureBuilder(
              future: authData.tryAutoLogin(),
              builder: (ctx,authResultSnapshot) => authResultSnapshot.connectionState == ConnectionState.waiting ? SplashScreen() : AuthScreen() ),
          routes: {
            ProductDetailScreen.routeName : (ctx) => ProductDetailScreen(),
            CartScreen.routeName : (ctx) => CartScreen(),
            OrdersScreen.routeName : (ctx) => OrdersScreen(),
            UserProductScreen.routeName : (ctx) => UserProductScreen(),
            EditProductScreen.routeName : (ctx) => EditProductScreen(),
          }
      );
    },),
    );
  }
}

