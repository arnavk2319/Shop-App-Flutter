import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {                              //ChangeNotifier is a type of provider package, for listening to changes in isFavorite
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue)
  {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String authToken, String userID ) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = "https://flutterapp-b0875.firebaseio.com/userFavorites/$userID/$id.json?auth=$authToken";
    try {
      final response = await http.put(url, body: json.encode(
        isFavorite,
      )
      );
      if(response.statusCode >= 400)
        {
          _setFavValue(oldStatus);
        }
    }
    catch(error)
    {
      _setFavValue(oldStatus);
    }
  }

}