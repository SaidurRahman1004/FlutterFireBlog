import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../services/firestore_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EditPostScreen extends StatefulWidget {
  final PostModel post;                                         //ReceveD PostModel Object From import '../../models/post_model.dart';

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  // Initialize the text fields with the values of the post being edited //Setting previous data in controllers in initState
  @override
  void initState() {                                                                        //initState As soon as the widget loads, the text in _titleController and _contentController is filled with the title and content of the previous post.
    super.initState();
    _titleController.text =
        widget.post.title; // Set the initial values of the text fields
    _contentController.text =
        widget.post.content; // to the values of the post being edited
  }

  // Save the edited post to Firestore
  void _saveEditedPost() async {

    final String newTitle = _titleController.text.trim();
    final String newContent = _contentController.text.trim();

    // Check if the title and content fields are not empty  //isUnchanged which checks whether there have been any changes to the title or content.
    final bool isUnchanged = newTitle == widget.post.title && newContent == widget.post.content;
    if (isUnchanged){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes made')),
      );
      return;
    }


    // Check if the title and content fields are not empty
    if (newTitle.isEmpty || newContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    // Show a loading indicator while the post is being updated
    setState(() {
      _isLoading = true;
    });
//
    try {
      // Update the post in Firestore with the new title and content values
      await _firestoreService.updatePost(
        widget.post.id,
        newTitle,
        newContent,
      );
      // Hide the loading indicator and show a success message
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Post Updated Successfull')));

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Your Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Your Content',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 10,
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveEditedPost,                 //Saving Changes ////_isLoading ? null : _saveEditedPost Use to disable button while loading
                      child: Text(_isLoading ? 'Saving...' : 'Save Changes'),    //Text Change Button
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(7),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: SpinKitWave(
                color: Colors.blue,
                size: 50.0,
              ),
            ),
        ],
      ),
    );
  }
}
