import 'package:flutter/material.dart';
import '../model/product.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {

  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();

  final _form = GlobalKey<FormState>();                //access the state behind the form widget

  var _editedProduct = Product(id: null,title: "", price: 0,description: "",imageUrl: "");

  var _isInit = true;
  var _isLoading = false;

  var _initValues = {                          //values we see on the form fields when we first load the edit page
    "title" : "",
    "description" : "",
    "price" : "",
    "imageUrl" : ""
  };


  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageURL);       //disposing off focus nodes when we go to another screen, otherwise focus node objects take up memory
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }


  void _updateImageURL()
  {
    if(!_imageUrlFocusNode.hasFocus) {
      if((!_imageUrlController.text.startsWith("http") && !_imageUrlController.text.startsWith("https")) ||
          (!_imageUrlController.text.endsWith(".png") && !!_imageUrlController.text.endsWith(".jpg") && !!_imageUrlController.text.endsWith(".jpeg")))
        {
          return;
        }
    }
    setState(() {});
  }


  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();   //checks for errors in the form, the errors are found when validator is used in each of the fields
    if(!isValid)
      return;

    _form.currentState.save();              //save() method is provided by the State object of the Form widget, calls onSave method on each of the form field elements, which here we update the _editedProduct by initialising the Product class with each form field value on onSave

    setState(() {
      _isLoading = true;
    });

    if(_editedProduct.id != null){
      await Provider.of<ProductsProvider>(context,listen: false).updateProduct(_editedProduct.id,_editedProduct);
    }
    else{
      try{
        await Provider.of<ProductsProvider>(context,listen: false).addProduct(_editedProduct);
      }
      catch(error)
    {
      await showDialog(
          context: context,
          builder: ((ctx) {
            return AlertDialog(
              title : Text("An error has ocurred!"),
              content: Text("Something went wrong!"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Okay"),
                  onPressed: (){
                    Navigator.of(ctx).pop();
                    },
                )
              ],
            );
          })
      );
    }
//    finally{
//      setState(() {
//        _isLoading = true;
//      });
//      Navigator.of(context).pop();                          //"context" like "widget" is available everywhere as it is provided by the State object.
//    }
    }
    setState(() {
      _isLoading = true;
    });
    Navigator.of(context).pop();

  }
  
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageURL);
    super.initState();
  }


  @override
  void didChangeDependencies() {                     //saveForm adds the new(_editedProduct) to the existing products list, didChange handles when we return to edit the product page in the form fields
    if(_isInit){
      final productID = ModalRoute.of(context).settings.arguments as String;
      if(productID != null)
        {
          _editedProduct = Provider.of<ProductsProvider>(context, listen: false).findById(productID);
          _initValues = {                           //values we see when we return to edit a current product page
            "title" : _editedProduct.title,
            "description" : _editedProduct.description,
            "price" : _editedProduct.price.toString(),
//            "imageUrl" : _editedProduct.imageUrl,                      //imageUrl cannot be initialized directly as it has a controller attached, therefore "initialValue" cannot be used in TextFormField. So we have to initialize the controller here as we are already referring to it in the respective form element(Image URL)
          "imageUrl " : ""
          };

          _imageUrlController.text = _editedProduct.imageUrl;
        }
    }
    _isInit = false;
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Products"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm ,)
        ],
      ),
      body: _isLoading ? Center(child : CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(10),
        child: Form(
          key: _form,
          child: ListView(children: <Widget>[
            TextFormField(
              initialValue: _initValues["title"],                  //to provide initial values to the form fields when we return to edit those pages
              decoration: InputDecoration(labelText: "Title",),
              textInputAction: TextInputAction.next,                  //input button on the soft keyboard(green button with a white arrow pointing right) that takes to the next input field
              onFieldSubmitted: (value) {                             //"value" is the string value in the input field
                FocusScope.of(context).requestFocus(_priceFocusNode);
              },
              validator: (value) {
                if(value.isEmpty){
                  return "Please provide a value";
                }
                return null;
              },
              onSaved: (value) {
                _editedProduct = Product(id: _editedProduct.id, title: value, description: _editedProduct.description, price: _editedProduct.price, imageUrl: _editedProduct.imageUrl,isFavorite: _editedProduct.isFavorite);
              },
            ),
            TextFormField(
              initialValue: _initValues["price"],                      //to provide initial values to the form fields when we return to edit those pages
              decoration: InputDecoration(labelText: "Price",),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              focusNode: _priceFocusNode,
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(_descriptionFocusNode);
              },
              validator: (value) {
                if(value.isEmpty)
                  {
                    return "Please enter a price";
                  }
                if(double.tryParse(value) == null)
                  {
                    return "Please enter a valid number";
                  }
                if(double.parse(value) <= 0)
                  {
                    return "Please enter a value greater than 0";
                  }
                return null;
              },
              onSaved: (value) {
                _editedProduct = Product(id: _editedProduct.id, title: _editedProduct.title, description: _editedProduct.description, price: double.parse(value), imageUrl: _editedProduct.imageUrl,isFavorite: _editedProduct.isFavorite);
              },
            ),
            TextFormField(
              initialValue: _initValues["description"],           //to provide initial values to the form fields when we return to edit those pages
              decoration: InputDecoration(labelText: "Description",),
              maxLines: 3,                                            //normal lines that need to be rendered on the screen
              keyboardType: TextInputType.multiline,
              focusNode: _descriptionFocusNode,
                validator: (value) {
                if(value.isEmpty)
                  {
                    return "Please enter a dscription";
                  }
                if(value.length < 10)
                  {
                    return "Should be at least 10 characters long";
                  }
                return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(id: _editedProduct.id, title: _editedProduct.title, description: value, price: _editedProduct.price, imageUrl: _editedProduct.imageUrl,isFavorite: _editedProduct.isFavorite);
                }
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
              Container(
                width: 100,
                height: 100,
                margin: EdgeInsets.only(top: 2, right : 10,),
                decoration: BoxDecoration(border: Border.all(
                  width: 1,
                  color:  Colors.grey,
                ),
                ),
                child: Container(
                  child: _imageUrlController.text.isEmpty ?
                      Text("Enter a URL")
                      : FittedBox(child: Image.network(_imageUrlController.text),fit: BoxFit.cover),
                ),
              ),
              Expanded(
                child: TextFormField(                        //TextFormField takes as much width as possible
                  decoration: InputDecoration(labelText: "Image URL"),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  controller: _imageUrlController,
                  focusNode: _imageUrlFocusNode,
                  onFieldSubmitted: (value) {
                    _saveForm();
                  },
                    validator: (value) {
                    if(value.isEmpty)
                      {
                        return "Please enter a image URL here.";
                      }
                    if(!value.startsWith("http") && !value.startsWith("https"))
                      {
                        return "Please provide a valid URL";
                      }
                    if(!value.endsWith(".png") && !value.endsWith(".jpg") && !value.endsWith(".jpeg"))
                      {
                        return "Please provide a valid image URL";
                      }
                    return null;
                    },
                    onSaved: (value) {
                      _editedProduct = Product(id: _editedProduct.id, title: _editedProduct.title, description: _editedProduct.description, price: _editedProduct.price, imageUrl: value,isFavorite: _editedProduct.isFavorite);
                    }
                ),
              ),
            ],
            )
          ],
          ),
        ),
      ),
    );
  }
}
