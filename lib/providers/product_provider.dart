import 'package:flutter/material.dart';
import '../model/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/http_exception.dart';

class ProductsProvider with ChangeNotifier {   //"MixIn" is used with the keyword "with", mixin is like lite version of inheritance where you merge the some properties from the parent class but do not return an instance of it.
  List<Product> _items = [
//    Product (                //Mixins are a way of reusing a class’s code in multiple class hierarchies.
//    id: 'p1',
//    title: 'Red Shirt',
//    description: 'A red shirt - it is pretty red!',
//    price: 29.99,
//    imageUrl:
//    'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
//  ),
//    Product(
//      id: 'p2',
//      title: 'Trousers',
//      description: 'A nice pair of trousers.',
//      price: 59.99,
//      imageUrl:
//      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
//    ),
//    Product(
//      id: 'p3',
//      title: 'Yellow Scarf',
//      description: 'Warm and cozy - exactly what you need for the winter.',
//      price: 19.99,
//      imageUrl:
//      'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
//    ),
//    Product(
//      id: 'p4',
//      title: 'A Pan',
//      description: 'Prepare any meal you want.',
//      price: 49.99,
//      imageUrl:
//      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
//    ),
  ];

//  var _showFavoritesOnly = false;

  final String authToken;
  final String userID;

  ProductsProvider(this.authToken,this._items,this.userID);

  List<Product> get items {         //items is the getter method name
//    if(_showFavoritesOnly)
//      {
//        return _items.where((prodItem) => prodItem.isFavorite).toList();
//      }
    return [..._items];            //returning a copy of the above list
  }

  Product findById(String id)
  {
    return _items.firstWhere((prod) => prod.id == id);
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
}

//  void showFavoriteItemsOnly() {
//    _showFavoritesOnly = true;
//    notifyListeners();
//  }
//
//  void showAllItems()
//  {
//    _showFavoritesOnly = false;
//    notifyListeners();
//  }


  Future<void> fetchProducts() async {
    var url = "https://flutterapp-b0875.firebaseio.com/products.json?auth=$authToken";

    try{
      final fetchResponse = await http.get(url);
      final extractedData = json.decode(fetchResponse.body) as Map<String, dynamic>;             // as we are fetching a Map which contains a String randomly generated ID and another Map inside of it, we have to use "dynamic" keyword rather than using "Map" in the generic type as that will give error

      if(extractedData == null)
        {
          return;
        }

      url = "https://flutterapp-b0875.firebaseio.com/userFavorites/$userID.json?auth=$authToken";         //overriding the value of url after we get the products from firebase, we fetch it from another url thus overriding the current value

      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode((fetchResponse.body));

      final List<Product> loadedProducts =[];

      extractedData.forEach((prodID, prodData) {
        loadedProducts.add(Product(
          id : prodID,
          title: prodData['title'],
          description: prodData['decription'],
          price: prodData['price'],
          isFavorite: favoriteData == null ? false : favoriteData[prodID] ?? false,                 //"??" operator checks the value for null.
          imageUrl: prodData['imageUrl']
        ));
      });

      _items = loadedProducts;                                                         //replacing with the new fetched products
      notifyListeners();
    }
    catch(error)
    {
      print(error.toString());
    }

  }



  Future<void> addProduct(Product product) async {                                                                              //async method always returns a Future object, also eliminates the need of .then() and .catchError() methods
    final url = "https://flutterapp-b0875.firebaseio.com/products.json?auth=$authToken";               //products is the name of the collection which will be created in firebase

    try {
      final response  = await http.post(url, body: json.encode({
        "title" : product.title,
        "description" : product.description,
        "imageUrl" : product.imageUrl,
        "price" : product.price,
      }),
      );                                                                                                                //response is a generic type of Future object that executes actions once the post request is completed. here response is the Future object that is returned which is the Firebase unique ID of each project (random generated alphanumeric ID, go to Firebase db to see it

      print(json.decode(response.body));                                                  //prints a Map with a "name" key and "randomly generated alphanumeric id of the product item" value, same is done in line 89
      final newProduct = Product(
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          id: json.decode(response.body)["name"]);

      _items.add(newProduct);
      notifyListeners();                                                                    //method from mixin ChangeNotifier,notifies all the listeners of the widgets listening for a change
    }
    catch(error) {
      print(error);
      throw error;
    }
    //.catchError((error) {
    }



  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if(prodIndex >= 0)
      {
        final url = "https://flutterapp-b0875.firebaseio.com/products/$id.json?auth=$authToken";
        await http.patch(url, body: json.encode({
          'title' : newProduct.title,
          'description' : newProduct.description,
          'imageUrl' : newProduct.imageUrl,
          'price' : newProduct.price
        }));
        _items[prodIndex] = newProduct;
        notifyListeners();
      }
    else
      {
        print("Product already exists!!");
      }
  }


  Future<void> deleteProduct(String id) async {
    final url = "https://flutterapp-b0875.firebaseio.com/products/$id.json?auth=$authToken";

    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];                                     //reference to the product

    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url) ;                                               //delete a particular product with the argument "id"

    if(response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);                                 //on error, re-insert the data back into the list
       notifyListeners();
       throw HttpException("Could not delete product");
     }
    existingProduct = null;
  }



}