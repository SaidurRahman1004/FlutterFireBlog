import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/post_model.dart';
import '../../services/firestore_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../services/image_upload_service.dart';

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
  final ImageUploadService _imageUploadService = ImageUploadService();
  String _loadingText = 'সেভ করা হচ্ছে...';

  XFile? _pickedImage;
  String? _existingImageUrl;

  // Initialize the text fields with the values of the post being edited //Setting previous data in controllers in initState
  @override
  void initState() {                                                                        //initState As soon as the widget loads, the text in _titleController and _contentController is filled with the title and content of the previous post.
    super.initState();
    _titleController.text =
        widget.post.title; // Set the initial values of the text fields
    _contentController.text =
        widget.post.content; // to the values of the post being edited
    _existingImageUrl = widget.post.imageUrl; // Set the initial value of the image URL

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

    String? finalImageUrl = _existingImageUrl; // Initialize finalImageUrl with the existing image URL



    try {
      // If User Selected New Pic
      if (_pickedImage != null) {
        setState(() {
          _loadingText = 'New Image Uploading...';
        });
        // নUpload New pic
        finalImageUrl = await _imageUploadService.uploadImage(_pickedImage!);
        if (finalImageUrl == null) {
          throw Exception('Image Upload Faild..');
        }
      }

      setState(() {
        _loadingText = 'Post Updated...';
      });

      // Update the post in Firestore with the new title and content values
      await _firestoreService.updatePost(
        widget.post.id,
        newTitle,
        newContent,
        newImgUrl: finalImageUrl,    //Parse Final Image

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

  // Upload a new image to Firebase Storage and update the post in Firestore
  // //Select Image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile; // New Image Save in XFile
        _existingImageUrl = null; // Remove the existing image URL For PreView
      });
    }
  }

  // Remove New Pic
  void _removeImage() {
    setState(() {
      _pickedImage = null;
      _existingImageUrl = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image Removed,Save...')),
    );
  }

  // New Image Preview
  Widget _buildImagePreview() {
    // User Selected New Pic
    if (_pickedImage != null) {
      return kIsWeb
          ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
          : Image.file(File(_pickedImage!.path), fit: BoxFit.cover);
    }
    // If Existing Pic Exist
    if (_existingImageUrl != null) {
      return Image.network(_existingImageUrl!, fit: BoxFit.cover);
    }
    // No Image Selected
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 50, color: Colors.grey),
        SizedBox(height: 8),
        Text('Add Cover Image', style: TextStyle(color: Colors.grey)),
      ],
    );
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
                  ///Image
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildImagePreview(), // Preview
                    ),
                  ),
                  // Buttons For Image Change And Delet
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image_search),
                        label: const Text('Change The Picture'),
                      ),
                      // // Show the 'delete' button only if there is an image (new or old)
                      if (_pickedImage != null || _existingImageUrl != null)
                        TextButton.icon(
                          onPressed: _removeImage,
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text('Delet The Picture', style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                  /// Image
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveEditedPost,                 //Saving Changes ////_isLoading ? null : _saveEditedPost Use to disable button while loading
                      child: Text(_isLoading ? 'Saving...' : _loadingText),    //Text Change Button
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
