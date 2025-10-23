import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import 'auth_service.dart';

class FirestoreService {
  final CollectionReference posts = FirebaseFirestore.instance.collection(
    'posts',
  ); //// Create an instance of the 'posts' collection (an instance of the FirebaseFirestore collection name)

  //AuthService Instance
  final AuthService _authService = AuthService();

  ///Create A New Post
  Future<void> createPost(
    String title,
    String content, {
    String? imageUrl,
  }) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('Please Login first to Create Account');
    }
    final newPost = PostModel(
      //// Create a new Post object according to our data model post_model.dart
      id: '',
      //I'm leaving the id blank here because Firestore will create it automatically
      title: title,
      content: content,
      authorId: user.uid,
      authorName: user.displayName ?? user.email ?? 'Uknown Author',
      timestamp: Timestamp.now(),
      imageUrl: imageUrl,
    );
    await posts.add(
      newPost.toMap(),
    ); //// Adding a new document to the 'posts' collection and the .add() method will save newPost.toMap() to Firestore
  }

  //STREAM fO5R reAD aLL  post From FireStore Function
  Stream<List<PostModel>> readAllPosts() {
    //posts.orderBy('timestamp', descending: true) I'm telling Firestore to give me a collection of posts, but sort them from largest to smallest (newest to oldest) according to the timestamp field.
    return posts
        .orderBy('timestamp', descending: true)
        .snapshots() //.snapshots(): This returns a Stream. This Stream automatically sends new data whenever there is a data change (new post, edit, delete) in Firestore.
        .map((
          //.map((snapshot) { ... }): We are converting the raw data (QuerySnapshot) that comes from snapshots() into a List<PostModel> of our convenience. // The function processes each event in the Stream.
          snapshot,
        ) {
          return snapshot.docs.map((doc) {
            // snapshot.docs is the list of documents available from Firestore
            final data = doc.data() as Map<String, dynamic>;
            return PostModel.fromMap(
              doc.id,
              data,
            ); // //// Convert each document (doc) to a PostModel
          }).toList(); // Convert all PostModels to a List
        });
  }

  //Update an existing post
  Future<void> updatePost(
    String Postid,
    String newtitle,
    String nweContent, {
    String? newImgUrl,
  }) async {
    // Create a map of the updated data to be sent to Firestore
    Map<String, dynamic> updatedData = {
      'title': newtitle,
      'content': nweContent,
      'timestamp': Timestamp.now(), // Update the timestamp to the current time
    };

    // Check if the new image URL is provided and update the 'imageUrl' field accordingly
    if (newImgUrl != null) {
      updatedData['imageUrl'] = newImgUrl;
    }
    await posts
        .doc(Postid)
        .update(
          updatedData,
        ); // Update the document in Firestore with the new data and the updated timestamp //use post.doc to specify the document you want to update //use .update to update the document to Firestore
  }

  //Delet a post Methode

Future<void> deletePost(String postId) async {
    await posts.doc(postId).delete();                   // use .doc(postId) to specify the document you want to delete //use .delete() to delete the document from Firestore
}
}
