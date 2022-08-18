import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/services.dart';

class DatabaseService {
  static Future<dynamic> isShopExist(String shopUid) async {
    try {
      final documentSnapshot =
          await Firestore.instance.collection("shops").document(shopUid).get();
      return documentSnapshot.exists;
    } on PlatformException catch (_) {
      return "Error occured";
    } catch (_) {
      return "Error occured";
    }
  }

  static Future<dynamic> updateRequestStatus(
      String shopId, String requestId, String status) async {
    try {
      await Firestore.instance
          .collection("shops")
          .document(shopId)
          .collection("requests")
          .document(requestId)
          .updateData({
        "status": status,
      });
      return requestId;
      //Will return requestId if status updated successfully.
    } on PlatformException catch (_) {
      return "Error occured while updating status";
    } catch (_) {
      return "Error occured while updating status";
    }
  }

  static Future updateRequestTime(
      String shopId, String requestId, int totalCompletionTime) async {
    try {
      await Firestore.instance
          .collection("shops")
          .document(shopId)
          .collection("requests")
          .document(requestId)
          .updateData({
        "totalCompletionTime": totalCompletionTime,
      });
      return requestId;
    } on PlatformException catch (_) {
      return "Error occured while updating time";
    } catch (_) {
      return "Error occured while updating time";
    }
  }
}
