import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to send a message
  Future<void> sendMessage(String senderId, String receiverId, String messageContent) async {
    try {
      await _firestore.collection('chats').add({
        'senderId': senderId,
        'receiverId': receiverId,
        'messageContent': messageContent,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
      // Handle error appropriately
    }
  }

  // Stream to get messages between two users
  Stream<List<Map<String, dynamic>>> getMessages(String userId1, String userId2) {
    return _firestore
        .collection('chats')
        .where('senderId', isEqualTo: userId1)
        .where('receiverId', isEqualTo: userId2)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList())
        .mergeWith(
          _firestore
              .collection('chats')
              .where('senderId', isEqualTo: userId2)
              .where('receiverId', isEqualTo: userId1)
              .orderBy('timestamp', descending: false)
              .snapshots()
              .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList()),
        )
        .map((lists) {
          List<Map<String, dynamic>> allMessages = [];
          for (var list in lists) {
            allMessages.addAll(list);
          }
          allMessages.sort((a, b) => (a['timestamp'] as Timestamp).compareTo(b['timestamp'] as Timestamp));
          return allMessages;
        });
  }

  // You might want to add methods to get a list of users the current user has chatted with
  // or to manage chat rooms/groups.
}

extension on Stream<List<Map<String, dynamic>>> {
  Stream<List<List<Map<String, dynamic>>>> mergeWith(Stream<List<Map<String, dynamic>>> other) {
    return Stream.fromFutures([
      first,
      other.first,
    ]).asBroadcastStream().asyncMap((event) async {
      List<List<Map<String, dynamic>>> result = [];
      await for (var item in this) {
        result.add(item);
      }
      await for (var item in other) {
        result.add(item);
      }
      return result;
    });
  }
}
