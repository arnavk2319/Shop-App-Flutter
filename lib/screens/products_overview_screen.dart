import 'package:flutter/material.dart';
import '../widget/product_grid.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widget/badge.dart';
import '../providers/cart.dart';
import '../screens/cart_screen.dart';
import '../widget/app_drawer.dart';

enum FilterMenuOptions {
  Favorites,    //value 0 in list of the pop up menu, which is also for False boolean value
  All           //value 1 in list of the pop up menu, which is also for True boolean value
}

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {

  var _showOnlyFavoritesData = false;
  var _isInit = true;
  var _isLoading = false;


  @override
  void initState() {
//    Provider.of<ProductsProvider>(context).fetchProducts();      WONT WORK SEPARATELY ,SEE NOTES

//    Future.delayed(Duration.zero).then((_) {
//    Provider.of<ProductsProvider>(context).fetchProducts();       It can be used as a hack when fetching data is required
//  });
    super.initState();
  }


  @override
  void didChangeDependencies() {                                               //most correct way to fetch data.
    if(_isInit){
      setState(() {
        _isLoading = true;
      });

      Provider.of<ProductsProvider>(context).fetchProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
//    final productsData = Provider.of<ProductsProvider>(context,listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("My Shop"),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterMenuOptions selectedValue) {
              setState(() {
                if(selectedValue == FilterMenuOptions.Favorites){
//                productsData.showFavoriteItemsOnly()
                  _showOnlyFavoritesData = true;
                }
                else
                {
//                  productsData.showAllItems();
                  _showOnlyFavoritesData = false;
                }
              });
            },
            icon: Icon(Icons.more_vert,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(child: Text("Only Favorites"), value: FilterMenuOptions.Favorites),
              PopupMenuItem(child: Text("Show All"), value: FilterMenuOptions.All),
            ],
          ),
          Consumer<Cart>(
          builder: (_ ,cartData,ch) => Badge(             //Consumer having generic type of Cart as Provider for cart items is created in Cart.dart. It takes 3 arguments  : context, instance of the class being referred to, child
            child: ch,
            value: cartData.getItemCount.toString() ,
          ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart, color: Colors.white,),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
    },
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : ProductsGrid(_showOnlyFavoritesData),
    );
  }
}

