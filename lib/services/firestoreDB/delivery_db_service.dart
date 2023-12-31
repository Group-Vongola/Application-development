
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/src/features/auth/models/delivery.dart';

class DeliveryDatabaseService{
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DocumentReference>addOrderDeliveryInfo(DeliveryModel deliveryData)async{
    DocumentReference docReference = await _db.collection('delivery').add(deliveryData.toDeliveryJason());
    return docReference;
  }

  //update whole delivery data
  updateDelivery(DeliveryModel deliveryData)async{
    await _db.collection('delivery').doc(deliveryData.docId).update(deliveryData.toDeliveryJason());
  }

  //get information of all delivery man
  Stream<List<DeliveryModel>> getDeliveryManInList(){
    return _db.collection('delivery').snapshots().map((QuerySnapshot snapshot){
      return snapshot.docs.map(
        (DocumentSnapshot doc){
          return DeliveryModel.fromFireStore(
            doc.data() as Map<String, dynamic>, doc.id
          );
        }
      ).toList();
    });
  }

  //update delivery status of this delivery man
  Future<void> updateDeliveryStatusOfDeliveryMan(String deliveryUserId, String orderOpenedId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _db
          .collection('delivery')
          .where('deliveryUserId', isEqualTo: deliveryUserId)
          .where('orderOpenedId', isEqualTo: orderOpenedId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> document = snapshot.docs.first;
        if (document['deliveryUserId'] == deliveryUserId && document['orderOpenedId'] == orderOpenedId) {
          await _db.collection('delivery').doc(document.id).update({
            'DeliveryStatus': 'Start',
          });
        }
      }
    } catch (e) {
      throw Exception('Error updating delivery status of delivery man');
    }
  }

  Future<DeliveryModel?> getDeliveryManInfo(String deliveryUserId, String orderOpenedId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _db
      .collection('delivery')
      .where('deliveryUserId', isEqualTo: deliveryUserId)
      .where('orderOpenedId', isEqualTo: orderOpenedId)
      .get();
      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> document = snapshot.docs.first;
        if (document['deliveryUserId'] == deliveryUserId &&document['orderOpenedId'] == orderOpenedId) {
          return DeliveryModel.fromFireStore(document.data()!, document.id);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching information of delivery man');
    }
  }

  //get specific delivery man order by using docId
  // Future<DeliveryModel?> getDeliveryManInfo(String docId) async{
  //   try{
  //     DocumentSnapshot<Map<String, dynamic>> snapshot = await _db.collection('delivery').doc(docId).get();
  //     if (snapshot.exists) {
  //       return DeliveryModel.fromDocumentSnapshot(snapshot);
  //     }
  //     else{
  //       return null;
  //     }
  //   }catch (e) {
  //     throw Exception('Error fetching information of delivery man');
  //   }
  // }
}