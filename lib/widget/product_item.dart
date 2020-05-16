import 'package:flutter/material.dart';
import '../screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import '../model/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {

//  final String id;
//  final String title;
//  final String imageUrl;
//
//  ProductItem(this.id, this.title, this.imageUrl);


  @override
  Widget build(BuildContext context) {

//    final productInfo = Provider.of<Product>(context);                      //here the class of ChangeNotifierProvider is Product (and not ProductProvider) as we are trying to listen to the change in the isFavorite property of ONLY ONE product and not all the products.
    final cart = Provider.of<Cart>(context,listen: false);   //false
    final authData = Provider.of<Auth>(context,listen: false);

    return Consumer<Product>(                          //wrapping only those widgets with Consumer widget which are interested in listening for a change, equivalent to a listener like Provider.of(context)
      builder: (ctx, productInfo, child) => ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: GridTile(
          child : GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(ProductDetailScreen.routeName, arguments: productInfo.id,);
            },
            child: Image.network(
              productInfo.imageUrl,
              fit: BoxFit.cover,)
            ,),
          footer: GridTileBar(
            backgroundColor: Colors.black54,
            leading: IconButton(
              icon: Icon(productInfo.isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () {
                productInfo.toggleFavoriteStatus(authData.getToken,authData.getUserID);
              },
              color: Theme.of(context).accentColor,
            ),
            trailing: IconButton(
                icon: Icon(Icons.shopping_cart,
                  color: Theme.of(context).accentColor,
                ),
                onPressed: () {
                  cart.addItem(productInfo.id, productInfo.price, productInfo.title);
                  Scaffold.of(context).hideCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("Added item to cart!",),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                        label: "UNDO",
                        onPressed: () {
                          cart.removeSingleItem(productInfo.id);
                        }),
                  ),
                  );
                }),
            title: Text(
              productInfo.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
