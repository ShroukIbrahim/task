// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/config.dart';

class MyOrder {
  String cancelledBy;
  String reason;
  String refundStatus;
  String refundTransactionId;
  CustDetails custDetails;
  DeliveryDetails deliveryDetails;
  Timestamp deliveryTimestamp;
  String orderId;
  String orderStatus;
  Timestamp orderTimestamp;
  String paymentMethod;
  List<OrderProduct> products;
  String transactionId;
  Charges charges;

  MyOrder({
    this.cancelledBy,
    this.reason,
    this.refundStatus,
    this.refundTransactionId,
    this.custDetails,
    this.deliveryDetails,
    this.deliveryTimestamp,
    this.orderId,
    this.orderStatus,
    this.orderTimestamp,
    this.paymentMethod,
    this.products,
    this.transactionId,
    this.charges,
  });

  factory MyOrder.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return MyOrder(
      cancelledBy: data['cancelledBy'],
      reason: data['reason'],
      refundStatus: data['refundStatus'],
      refundTransactionId: data['refundTransactionId'],
      custDetails: CustDetails.fromHashmap(data['custDetails']),
      deliveryDetails: DeliveryDetails.fromHashmap(data['deliveryDetails']),
      deliveryTimestamp: data['deliveryTimestamp'],
      orderId: data['orderId'],
      orderStatus: data['orderStatus'],
      orderTimestamp: data['orderTimestamp'],
      paymentMethod: data['paymentMethod'],
      products: List<OrderProduct>.from(
        data['products'].map(
          (data) {
            return OrderProduct(
              category: data['category'],
              id: data['id'],
              ogPrice: data['ogPrice'],
              price: data['price'],
              productImage: data['productImage'],
              quantity: data['quantity'],
              subCategory: data['subCategory'],
              totalAmt: data['totalAmt'],
              unitQuantity: data['unitQuantity'],
              name: data['name'],
              skuId: data['skuId'],
            );
          },
        ),
      ),
      transactionId: data['transactionId'],
      charges: Charges.fromHashmap(data['charges']),
    );
  }
}

class Charges {
  String orderAmt;
  String shippingAmt;
  String discountAmt;
  String totalAmt;
  String taxAmt;
  String couponDiscountAmt;
  bool appliedCoupon;
  String couponCode;
  String couponId;

  Charges({
    this.discountAmt,
    this.orderAmt,
    this.shippingAmt,
    this.totalAmt,
    this.taxAmt,
    this.appliedCoupon,
    this.couponCode,
    this.couponDiscountAmt,
    this.couponId,
  });

  factory Charges.fromHashmap(Map<String, dynamic> charges) {
    return Charges(
      discountAmt: charges['discountAmt'],
      orderAmt: charges['orderAmt'],
      shippingAmt: charges['shippingAmt'],
      totalAmt: charges['totalAmt'],
      taxAmt: charges['taxAmt'],
      appliedCoupon: charges['appliedCoupon'],
      couponCode: charges['couponCode'],
      couponDiscountAmt: charges['couponDiscountAmt'],
      couponId: charges['couponId'],
    );
  }
}

class DeliveryDetails {
  String deliveryStatus;
  String phoneNumber;
  String name;
  String uid;
  String otp;
  String reason;
  Timestamp timestamp;

  DeliveryDetails({
    this.phoneNumber,
    this.name,
    this.uid,
    this.deliveryStatus,
    this.otp,
    this.reason,
    this.timestamp,
  });

  factory DeliveryDetails.fromHashmap(Map<String, dynamic> deliveryDetails) {
    return DeliveryDetails(
      deliveryStatus: deliveryDetails['deliveryStatus'],
      phoneNumber: deliveryDetails['phoneNumber'],
      name: deliveryDetails['name'],
      uid: deliveryDetails['uid'],
      otp: deliveryDetails['otp'],
      reason: deliveryDetails['reason'],
      timestamp: deliveryDetails['timestamp'],
    );
  }
}

class CustDetails {
  String address;
  String phoneNumber;
  String name;
  String uid;

  CustDetails({
    this.address,
    this.phoneNumber,
    this.name,
    this.uid,
  });

  factory CustDetails.fromHashmap(Map<String, dynamic> custDetails) {
    return CustDetails(
      address: custDetails['address'],
      phoneNumber: custDetails['phoneNumber'],
      name: custDetails['name'],
      uid: custDetails['uid'],
    );
  }
}

class OrderProduct {
  String category;
  String id;
  String ogPrice;
  String price;
  String productImage;
  String quantity;
  String subCategory;
  String totalAmt;
  String unitQuantity;
  String name;
  String skuId;

  OrderProduct({
    this.category,
    this.id,
    this.ogPrice,
    this.price,
    this.productImage,
    this.quantity,
    this.subCategory,
    this.totalAmt,
    this.unitQuantity,
    this.name,
    this.skuId,
  });

  factory OrderProduct.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return OrderProduct(
      category: data['category'],
      id: data['id'],
      ogPrice: data['ogPrice'],
      price: data['price'],
      productImage: data['productImage'],
      quantity: data['quantity'],
      subCategory: data['subCategory'],
      totalAmt: data['totalAmt'],
      unitQuantity: data['unitQuantity'],
      name: data['name'],
      skuId: data['skuId'],
    );
  }

  String getIndex(int index) {
    switch (index) {
      case 0:
        return name;
      case 1:
        return unitQuantity;
      case 2:
        return category;
      case 3:
        return quantity;
      case 4:
        return '${Config().currency}$price';
      case 5:
        return '${Config().currency}$totalAmt';
    }
    return '';
  }
}
