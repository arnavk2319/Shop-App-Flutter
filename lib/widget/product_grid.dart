import 'package:flutter/material.dart';
import 'package:provider/provider.dart';      //import important for using the provider
import '../widget/product_item.dart';
import '../providers/product_provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;

  ProductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);   //tells flutter that we want to achieve a direct relation with the provided package of the ProductsProvider class
    final products = showFavs ? productsData.favoriteItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        value: products[index],    //passing a single product rather than all the products at once for "Favorite" as toggling favorite is more important for just one item.
        child: ProductItem(
//          products[index].id,
//          products[index].title,
//          products[index].imageUrl,
        ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }

}