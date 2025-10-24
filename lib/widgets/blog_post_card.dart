import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../screens/post/edit_post_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BlogPostCard extends StatelessWidget {
  final PostModel post;
  final String currentUser;

  const BlogPostCard({super.key, required this.post, required this.currentUser});

  //Delet Confermations Dialog
  void _showDeleteConfirmationDialog(BuildContext context, FirestoreService firestoreService) {
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),),

          TextButton(onPressed: () async{
            try{
              await firestoreService.deletePost(post.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post Delet Successfull')),
              );
            }catch(e){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }

          }, child: const Text("Delete"))

        ],

      );
    });

  }
  
  // BottomSheet For Editing And Delet Post
  void _showBottomSheet(BuildContext context ){
    final FirestoreService firestoreService = FirestoreService();
    showModalBottomSheet(context: context, builder: (context){
      return Wrap(
        children: [
          //Edit Post
          ListTile(
            leading: const Icon(Icons.edit,color: Colors.blue,),
            title: const Text("Edit Post"),
            onTap:(){
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=> EditPostScreen(post: post)));    // Navigate to Edit Post Screen

            }
          ),

          //Delet Post
          ListTile(
            leading: const Icon(Icons.delete,color: Colors.red,),
            title: const Text("Delete Post"),
            onTap:(){
              Navigator.of(context).pop();
              _showDeleteConfirmationDialog(context, firestoreService);      // Show Delete Confirmation Dialog
            }

          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = post.authorId == currentUser;       // Check if the current user is the author of the post

    return Card(
      elevation: 3.5,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
      clipBehavior: Clip.antiAlias,   //To match the image to the corner of the card
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Theme.of(context).primaryColor, width: 5.0),
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Post Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if(isCurrentUser)                                                        // Show the options only if the current user is the author of the post
                  IconButton(onPressed: (){
                    _showBottomSheet(context);
                  }, icon: const Icon(Icons.more_vert),tooltip: "Options",padding: EdgeInsets.zero,constraints: BoxConstraints(),)
              ],
            ),
            //Post Author
            Text(
              "By ${post.authorName}",
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16.0),
            //Post Content
            Text(
              post.content,
              style: TextStyle(fontSize: 16.0,color: Colors.grey[800],height: 1.4,),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10.0),
            //If Cpver Image Url Exist Then Show Imag

            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              Container(
                height: 180,
                width: double.infinity,
                child: Image.network(
                  post.imageUrl!,
                  fit: BoxFit.cover,
                  //Loading Builder When Image Loading
                  loadingBuilder: (context, child, loadingProgress){
                    if(loadingProgress == null) return child;
                    return Center(
                      child: SpinKitCircle(
                        color: Theme.of(context).primaryColor,
                        size: 50.0,
                      ),
                    );
                  },
                  //Error When Image Not Load
                  errorBuilder: (_,erroe,stackTrace)=>Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey[400],
                      size: 40.0,
                    ),
                  ),
                  ),
                ),


            ]

          ],
        ),
      ),
    );
  }
}
