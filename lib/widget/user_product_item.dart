import 'package:flutter/material.dart';
import '../screens/edit_product_screen.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageURL;

  UserProductItem(this.id,this.title,this.imageURL);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return Card(
      child: ListTile(
        title: Text(title) ,
        leading: CircleAvatar(backgroundImage: NetworkImage(imageURL),    //NetworkImage is built into flutter
        ),
        trailing: Container(
          width: 100,
          child: Row(children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit) ,
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName,arguments: id );
              },
              color: Theme.of(context).primaryColor,),
            IconButton(
              icon : Icon(Icons.delete),
              onPressed: () async{
                try{
                 await Provider.of<ProductsProvider>(context,listen: false).deleteProduct(id);
                }
                catch(error){
                  scaffold.showSnackBar(SnackBar(content: Text("Unable to delete", textAlign: TextAlign.center,), ));
                }
              },
              color: Theme.of(context).errorColor,)
          ],
          ),
        ),
      ),
    );
  }
}
