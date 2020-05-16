import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../widget/cart_item.dart';
import '../providers/orders.dart';
import '../screens/orders_screen.dart';

class CartScreen extends StatelessWidget {
  static const routeName = "/cart";
  @override
  Widget build(BuildContext context) {

    final cartInfo = Provider.of<Cart>(context);                                                 //entire screen listening to the changes in the list

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
      ),
      body: Column(
        children: <Widget>[
        Card(
          margin: EdgeInsets.all(15),
          child: Padding(
              padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: <Widget>[
            Text("Total", style: TextStyle(fontSize: 20),
            ),
               Spacer(),
               Chip(
                 label: Text("\$${cartInfo.getTotalAmount.toString()}",
                 style: TextStyle(color: Theme.of(context).primaryTextTheme.title.color
                 ),
                 ),
                 backgroundColor: Theme.of(context).primaryColor,
               ),
               OrderButton(cartInfo: cartInfo)                                       //extracted order button
          ],
          ),
          ),
        ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
                itemCount : cartInfo.getItems.length,
                itemBuilder: (ctx,index) => CartItem(
                    cartInfo.getItems.values.toList()[index].id,      //items is a getter that returns a Map which can be converted to a iterable using values.toList()
                    cartInfo.getItems.keys.toList()[index],             //key is the product ID
                    cartInfo.getItems.values.toList()[index].price,
                    cartInfo.getItems.values.toList()[index].quantity,
                    cartInfo.getItems.values.toList()[index].title),
            ),
          )
      ],
      ),
    );
  }
}





class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cartInfo,
  }) : super(key: key);

  final Cart cartInfo;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text("Order Now"),
    onPressed: (widget.cartInfo.getTotalAmount <= 0  || _isLoading) ? null                                         //disabling the button when there are no items in the cart
        : () async {
        setState(() {
          _isLoading = true;
        });
        await Provider.of<Orders>(context,listen: false).addOrder(widget.cartInfo.getItems.values.toList(), widget.cartInfo.getTotalAmount);
        setState(() {
          _isLoading = false;                                                                   //remove loading indicator just before going to the next page
        });
        Navigator.of(context).pushNamed(OrdersScreen.routeName);
        widget.cartInfo.clear();
    },
    textColor: Theme.of(context).primaryColor,);
  }
}
