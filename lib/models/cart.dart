// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';

import 'product.dart';

class Cart {
  Product product;
  String quantity;
  Sku sku;

  Cart({
    this.product,
    this.quantity,
    this.sku,
  });

  factory Cart.fromFirestore(
    DocumentSnapshot documentSnapshot,
    String quantity,
    Sku sku,
  ) {
    return Cart(
      product: Product.fromFirestore(documentSnapshot),
      quantity: quantity,
      sku: sku,
    );
  }
}
