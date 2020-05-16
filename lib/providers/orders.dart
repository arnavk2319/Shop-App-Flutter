import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:shop_app_flutter/widget/cart_item.dart';
import 'package:shop_app_flutter/widget/order_item.dart';
import '../model/order_data.dart';
import '../model/cart_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Orders with ChangeNotifier {

  List<OrderData> _orders = [];

  final String authToken;
  final String userID;

  Orders(this.authToken,this._orders,this.userID);

  List<OrderData> get getOrders {
    return[..._orders];
  }

  Future<void> fetchOrders() async {
    final url = "https://flutterapp-b0875.firebaseio.com/orders/$userID.json?auth=$authToken";

    final response = await http.get(url);
    final List<OrderData> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if(extractedData == null){
        return;
    }

    extractedData.forEach((orderID, orderData) {
      loadedOrders.add(OrderData(
          id : orderID,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          orderedProducts: (orderData['products'] as List<dynamic>).map((items) {
            CartData(
              id: items['id'],
              price : items['price'],
              quantity : items['quantity'],
              title : items['title'],
            );
          }).toList(),
      ));
    });

    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartData> cartProducts, double total ) async {
    final url = "https://flutterapp-b0875.firebaseio.com/orders/$userID.json?auth=$authToken";
    final timestamp = DateTime.now();

    final response = await http.post(url, body : json.encode({
      'amount' : total,
      'dateTime' : timestamp.toIso8601String(),
      'products' : cartProducts.map((cartProd) => {
          'id' : cartProd.id,
          'title' : cartProd.title,
          'quantity' : cartProd.quantity,
          'price' : cartProd.price
        })
    }),);

    _orders.insert(0, OrderData(
        id: json.decode(response.body)['name'],
        amount: total,
        orderedProducts: cartProducts,
        dateTime: timestamp),
    );
    notifyListeners();    //listener at CartScreen in onPressed
  }

}