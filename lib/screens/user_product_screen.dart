import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widget/user_product_item.dart';
import '../widget/app_drawer.dart';
import '../screens/edit_product_screen.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = "/user-products";

  Future<void> _refreshProducts (BuildContext bldCtx) async  {
   await Provider.of<ProductsProvider>(bldCtx).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {

    final productData = Provider.of<ProductsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Products"),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.add), onPressed: () {
            Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh:  () => _refreshProducts(context),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ListView.builder(
            itemCount: productData.items.length,
            itemBuilder: (ctx, index) => Column(
              children: <Widget>[
                UserProductItem(
                  productData.items[index].id,
                    productData.items[index].title,
                    productData.items[index].imageUrl
                ),
              ],
            ),
            ),
        ),
      ),
    );
  }
}
