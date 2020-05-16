import 'package:flutter/material.dart';

class CartData{
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartData({
  @required this.id,
  @required this.title,
  @required this.quantity,
  @required this.price
  });

}