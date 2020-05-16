import 'package:flutter/material.dart';
import '../providers/product_provider.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

//  final String title;
//  ProductDetailScreen(this.title);

  @override
  Widget build(BuildContext context) {
    final productID = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct = Provider.of<ProductsProvider>(context).findById(productID);         //listen arg allows to listen to the Provider class, in this case ProductProvider, and chooses whether to run re-build as the build() method is rebuilt because the provider listener is registered in this class/widget i.e product detail screen.

    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 300,
              width: double.infinity,
              child: Image.network(loadedProduct.imageUrl , fit: BoxFit.cover,),
            ),
            SizedBox(height: 10),
            Text("\$${loadedProduct.price}",
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width :  double.infinity,
              child : Text(
                loadedProduct.description,
                textAlign: TextAlign.center,
                softWrap: true,
              )
            )
          ],
        ),
      ),
    );
  }
}
