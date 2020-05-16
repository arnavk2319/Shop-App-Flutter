import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productID;
  final double price;
  final int quantity;
  final String title;

  CartItem(this.id,this.productID,this.price,this.quantity,this.title);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
        background : Container(
          color :  Theme.of(context).errorColor,
          child: Icon(
              Icons.delete,
              color: Colors.white,
              size:40),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right : 8),
          margin: EdgeInsets.symmetric(horizontal: 15,vertical: 4),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direc) {
          return showDialog(            //showDialog returns a Future object
            context: context,
            builder: (ctx) =>
                AlertDialog(title: Text("Are you sure?"),
                  content: Text("Remove item from the cart?"),
                  actions: <Widget>[
                    FlatButton(child: Text("No"), onPressed: () {
                      Navigator.of(ctx).pop(false);              //tells the dismissible that it is a false action, so do not delete the item
                    },
                    ),
                    FlatButton(child: Text("Yes"), onPressed: () {
                      Navigator.of(ctx).pop(true);                //tells the dismissible that it is a true action, so it should delete the item
                    },
                    ),
                  ],
                ),
          );
        },
        onDismissed: (direction) {
        Provider.of<Cart>(context,listen: false).removeItem(productID);    //not listening to cart item's individual changes but listening to changes in the entire page on CartScreen
        },
        child : Card(
          margin: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 4),
          child:
          Padding(
            padding: EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(
                child : Padding(
                  padding: EdgeInsets.all(5),
                  child: FittedBox(
                    child: Text("\$$price"),
                  ),
                ),
              ),
              title: Text(title),
              subtitle: Text("Total : \$${(price * quantity)}"),
              trailing: Text("$quantity x"),
            ),
          ),
        )
    );
  }
}
