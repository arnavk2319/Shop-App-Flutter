import '../model/cart_data.dart';
import 'package:flutter/foundation.dart';

class OrderData {
  final String id;
  final double amount;
  final List<CartData> orderedProducts;
  final DateTime dateTime;

  OrderData({
    @required this.id,
    @required this.amount,
    @required this.orderedProducts,
    @required this.dateTime});

}