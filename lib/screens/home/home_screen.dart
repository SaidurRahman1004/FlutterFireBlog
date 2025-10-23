// D:\CodesApplication\Flutter Projects\FlutterFireBlog\lib\screens\home\home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fire_app/models/post_model.dart';
import 'package:flutter_fire_app/services/auth_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../services/firestore_service.dart';
import '../post/create_post_screen.dart';
import '../../widgets/blog_post_card.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final firestoreService =
      FirestoreService(); //instance of firestore service services/firestore_service.dart';

  final String currentUserId = AuthService().currentUser?.uid ?? "";      //instance of auth service services/auth_service.dart; take Current User ID from Here


  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterFire Blog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: firestoreService.readAllPosts(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: SpinKitCircle(color: Colors.red, size: 40));
          }
          if (snap.hasError) return Center(child: Text("Error Loading Post"));
          if (!snap.hasData || snap.data!.isEmpty)
            return Center(child: Text("No Posts"));
          final List<PostModel> postsCtrl =
              snap.data!; //instance of Firestote Post DAta Data List
          return ListView.builder(
            itemCount: postsCtrl.length,
            itemBuilder: (_, index) {
              final postAccess = postsCtrl[index];
              return BlogPostCard(post: postAccess,currentUser: currentUserId);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CreatePostScreen()),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
