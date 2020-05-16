import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:shop_app_flutter/model/cart_data.dart';


class Cart with ChangeNotifier {
  Map<String,CartData> _cartItems = {};
  
  Map<String,CartData> get getItems {
    return {..._cartItems};
  }

  int get getItemCount {
    return _cartItems.length;
  }

  double get getTotalAmount {
    double total = 0.0;
    _cartItems.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(String productID,double price,String title)
  {
    if(_cartItems.containsKey(productID))
      {
        _cartItems.update(productID, (existingCartItem) => CartData(
            id: existingCartItem.id,
            title: existingCartItem.title,
            quantity: existingCartItem.quantity + 1,
            price: existingCartItem.price  ));
      }
    else
      {
        _cartItems.putIfAbsent(productID, () => CartData(
            id: DateTime.now().toString(),
            title : title,
            quantity: 1,
            price: price ));
      }
    notifyListeners();
  }

  void removeItem(String id)
  {
    _cartItems.remove(id);
    notifyListeners();
  }

  void removeSingleItem(String productID){
    if(!_cartItems.containsKey(productID))
      return;

    if(_cartItems[productID].quantity > 1){
      _cartItems.update(productID, (existingCartItem) => CartData(
          id: existingCartItem.id,
          title: existingCartItem.title,
          quantity: existingCartItem.quantity - 1,
          price: existingCartItem.price
      ));
    }
    else
      {
        _cartItems.remove(productID);
      }
    notifyListeners();
  }

  void clear() {
    _cartItems = {};
    notifyListeners();
  }

}