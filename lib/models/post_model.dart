import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id; // পোস্টের নিজস্ব ইউনিক আইডি
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final Timestamp timestamp;
  final String? imageUrl; // ইমেজ URL, ? দিয়ে বোঝাচ্ছি এটি null হতে পারে

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.timestamp,
    this.imageUrl,
  });


  factory PostModel.fromMap(String id, Map<String, dynamic> data) {                                   //// When reading data from Firestore: Convert to Map -> Post object
    return PostModel(
      id: id, // ডকুমেন্ট আইডি
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      imageUrl: data['imageUrl'], // এটি null হলেও সমস্যা নেই
    );
  }

  Map<String, dynamic> toMap() {                                        //toMap(): This method turns our Post object into a Map, which Firestore can easily understand and save.
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'timestamp': timestamp,
      'imageUrl': imageUrl, // এটি null হলে Firestore-এ null হিসেবে সেভ হবে
    };
  }
}