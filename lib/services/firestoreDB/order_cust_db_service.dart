import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/features/auth/models/order_customer.dart';

class OrderCustDatabaseService{
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  //when customer place or edit order
  final CollectionReference placeOrderCollection = FirebaseFirestore.instance.collection('cust order');

  //add COD or Replace Meal Payment method
  Future<DocumentReference>addOrder(OrderCustModel orderData) async{
    DocumentReference documentReference = await _db.collection('cust order').add(orderData.toOrderJason());
    return documentReference;
  }

  //(WHOLE) update order
  updateOrder(OrderCustModel orderData) async{
    await _db.collection('cust order').doc(orderData.id).update(orderData.toOrderJason());
  }

  //update the 'delivered' data in selected customer order
  Future<void> updateDeliveredInOrder(String documentId)async{
    await _db.collection('cust order').doc(documentId).update({
      'Delivered' : 'Yes'
    });
  }

  //update payment status
  Future<void> updatePaymentStatus(String documentId)async{
    await _db.collection('cust order').doc(documentId).update({
      'Payment Status' : 'Yes'
    });
  }

  //update collected status
  Future<void> updateCollectedStatus(String documentId)async{
    await _db.collection('cust order').doc(documentId).update({
      'isCollected' : 'Yes'
    });
  }

  //update deliveryman Id in the selected customer orders
  Future<void> updateOrderDeliveryManId(List<String> locations, String userId) async {
    QuerySnapshot<Map<String, dynamic>> ordersSnapshot = await _db
    .collection('cust order')
    .where('Destination', whereIn: locations)
    .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> orderDoc in ordersSnapshot.docs) {
      String docId = orderDoc.id;
      await _db.collection('cust order').doc(docId).update({
        'DeliveryManId': userId,
      });
    }
  }

  //update status of delivery progress
  Future<void> updateDeliveryStartedOrNot(List<String> locations) async{
    QuerySnapshot<Map<String, dynamic>> ordersSnapshot = await _db
    .collection('cust order')
    .where('Destination', whereIn: locations)
    .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> orderDoc in ordersSnapshot.docs) {
      String docId = orderDoc.id;
      await _db.collection('cust order').doc(docId).update({
        'DeliveryStatus': 'Start',
      });
    }
  }

  //update order delivered image
  Future<void> updateORderDeliveredImage(String documentId, String image)async{
    await _db.collection('cust order').doc(documentId).update({
      'Delivered order' : image
    });
  }

  //update existing order 
  Future<void> updateExistingOrder(
    String documentId,
    String name,
    String destination,
    String remark,
    String email,
    String phone
  )async{
    await _db.collection('cust order').doc(documentId).update({
      'custName' : name,
      'Destination' : destination,
      'Remark' : remark,
      'Email' : email,
      'Phone' : phone
    });
  }

  Stream<List<OrderCustModel>> getAllOrder(){
    return placeOrderCollection.snapshots().map(
      (QuerySnapshot snapshot){
        return snapshot.docs.map(
          (DocumentSnapshot doc){
            return OrderCustModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id
            );
          }
        ).toList();
      }
    );
  }

  //Get order in list
  Stream<List<OrderCustModel>> getOrderWithoutDeliveryManId() {
    return placeOrderCollection
    .where('DeliveryManId', isEqualTo: '')
    .snapshots()
    .map(
      (QuerySnapshot snapshot) {
        return snapshot.docs.map(
          (DocumentSnapshot doc) {
            return OrderCustModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          },
        ).toList();
      },
    );
  }

  //get pending order by orderId
  Stream<List<OrderCustModel>> getPendingOrder(String orderId){
    return placeOrderCollection
    .where('Delivered', isEqualTo: 'No')
    .where('Menu_orderId', isEqualTo: orderId)
    .snapshots()
    .map(
      (QuerySnapshot snapshot){
        return snapshot.docs.map(
          (DocumentSnapshot doc){
            return OrderCustModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id
            );
          }
        ).toList();
      }
    );
  }

  //get completed order by orderId
  Stream<List<OrderCustModel>> getCompletedOrder(String orderId){
    return placeOrderCollection
    .where('Delivered', isEqualTo: 'Yes')
    .where('Menu_orderId', isEqualTo: orderId)
    .snapshots()
    .map(
      (QuerySnapshot snapshot){
        return snapshot.docs.map(
          (DocumentSnapshot doc){
            return OrderCustModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id
            );
          }
        ).toList();
      }
    );
  }

  //get order in list by user id
  Stream<List<OrderCustModel>> getOrderById(String userId){
    return placeOrderCollection
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((QuerySnapshot snapshot){
        return snapshot.docs.map(
        (DocumentSnapshot doc){
            return OrderCustModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id
            );
          }
        ).toList();
      }
    );
  }

  //get order in list by destination and order id
  Stream<List<OrderCustModel>> getOrderForDeliveryMan(List<String> locations, String orderId){
    return placeOrderCollection
      .where('Menu_orderId', isEqualTo: orderId)
      .where('Destination', whereIn: locations)
      .snapshots()
      .map((QuerySnapshot snapshot){
        return snapshot.docs.map(
          (DocumentSnapshot doc){
            return OrderCustModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id
            );
          }
        ).toList();
      }
    );
  }

  //get order in list by order id
  Stream<List<OrderCustModel>> getOrderByOrderId(String orderId){
    return placeOrderCollection
      .where('Menu_orderId', isEqualTo: orderId)
      .snapshots()
      .map((QuerySnapshot snapshot){
        return snapshot.docs.map(
        (DocumentSnapshot doc){
            return OrderCustModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id
            );
          }
        ).toList();
      }
    );
  }

  //get specific customer's order
  Future<OrderCustModel?> getCustOrder(String documentId) async{
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _db.collection('menu').doc(documentId).get();

      if (snapshot.exists) {
        return OrderCustModel.fromDocumentSnapshot(snapshot);
      }
      else{
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching menu');
    }
  }
  
  //get order data by document id
  Future<OrderCustModel?> getOrderDataById(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _db.collection('cust order').doc(id).get();

      if (snapshot.exists) {
        return OrderCustModel.fromFirestore(snapshot.data()!, snapshot.id);
      } else {
        return null;
      }
    } catch (e) {
      // You might want to throw an exception or return null in case of an error
      throw Exception('Error fetching order data');
    }
  }

  //get order data by customer id
  Future<OrderCustModel?> getCustOrderById(String id) async{
    try{
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db
      .collection('cust order')
      .where('id', isEqualTo: id)
      .get();
      if (querySnapshot.docs.isNotEmpty) {
        return OrderCustModel.fromFirestore(
          querySnapshot.docs.first.data(),
          querySnapshot.docs.first.id,
        );
      } else {
        return null;
      }
    }catch (e) {
      throw Exception('Error fetching customer order');
    }
  }

  //delete Order placed by customer
  Future<void> deleteCustOrder(String? documentId, BuildContext context) async{
    if (documentId == null || documentId.isEmpty) {
      // Show an alert or return an appropriate response
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Invalid Document ID'),
            content: const Text('The document ID is null or empty. Cannot delete.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                  fontSize: 20
                )
                ),
              ),
            ],
          );
        },
      );
    } else {
      // Call the deletePayment function with a valid documentId
      await _db.collection('cust order').doc(documentId).delete();
      // Navigator.of(context).pushNamedAndRemoveUntil(
      //   payMethodPageRoute, 
      //   (route) => false,
      // );
    } 
  }

  //when customer place or edit order
  final CollectionReference cancelOrderCollection = FirebaseFirestore.instance.collection('cust order');

  Future<void> cancelOrder(OrderCustModel orderData) async {
    // Add the order to the 'cust cancel order' collection
    await _db.collection('cust cancel order').add(orderData.toOrderJason());

    // Delete the order from the 'cust order' collection
    await _db.collection('cust order').doc(orderData.id).delete();
  }
  //get order in list by user id
  Stream<List<OrderCustModel>> getCancelledOrderById(String userId){
    return _db.collection('cust cancel order')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((QuerySnapshot snapshot){
        return snapshot.docs.map(
        (DocumentSnapshot doc){
            return OrderCustModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id
            );
          }
        ).toList();
      }
    );
  }

}