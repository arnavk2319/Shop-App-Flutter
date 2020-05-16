import 'package:flutter/material.dart';
import '../model/order_data.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class OrderItem extends StatefulWidget {
  final OrderData orderData;

  OrderItem(this.orderData);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {

  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(children: <Widget>[
        ListTile(
          title: Text("\$${widget.orderData.amount}"),
          subtitle: Text(DateFormat("dd/MM/yyyy").format(widget.orderData.dateTime)),
          trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              }) ,
        ),
        if (_expanded)    //on pressing the expanded icon
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15,vertical: 4),
            height: min(widget.orderData.orderedProducts.length * 20.0 + 10.0, 100.0),
        child: ListView(
          children : widget.orderData.orderedProducts.map((prod) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                prod.title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                ),
              ),
              Text("${prod.quantity} x \$${prod.price}",
                style: TextStyle(fontSize: 18,color: Colors.grey),
              ),
        ],
          )).toList(),
        ),
        ),
      ],
      ),
    );
  }
}
