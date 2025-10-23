import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_fire_app/services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _image;
  bool _loading = false;
  final FirestoreService _firestoreService = FirestoreService();

  //Imqge Pick Function
  Future<XFile?> pickeImage() async {
    final pickedImg = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (pickedImg != null)
      setState(() {
        _image = File(pickedImg.path);
      });
  }

  //Post Publish And Add Functions
  Future<void> _publishPost() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in the title and text...')),
      );
      return;
    }
    //Loading Start
    setState(() {
      _loading = true;
    });

    try {
      //send data to FireStore
      await _firestoreService.createPost(
        _titleController.text,
        _contentController.text,
        imageUrl: null,
      );
      //if Success Loading stop and go to previous page
      setState(() {
        _loading = false;
      });

      // Success Massege
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post Published Successfull')),
      );

      // stop this page and go to previous pag
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Post Faild: ${e.toString()}')));
    }
  }

  // It is important to dispose the controllers when the widget is disposed (closed).
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Your Title",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: "Write Your Content here",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 10),
            _image != null
                ? Image.file(_image!, height: 150)
                : TextButton.icon(
                    onPressed: pickeImage,
                    icon: Icon(Icons.image),
                    label: Text("Select Cover Image"),
                  ),
            SizedBox(height: 20),
            _loading
                ? SpinKitCircle(color: Colors.red,size: 40,)
                : ElevatedButton(onPressed: _publishPost, child: Text("post")),
          ],
        ),
      ),
    );
  }
}
