import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_fire_app/services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../services/image_upload_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  // File? _image; ////variable For Store Selected Pic
  XFile? _pickedImage;
  bool _loading = false;
  String _loadingText = "Publishing...."; //loadind Text For Pic
  final FirestoreService _firestoreService = FirestoreService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  //Imqge Pick From Galary Function
  Future<void> pickeImage() async {
    final ImagePicker picker = ImagePicker();
    //Select Image From Gallery
    final pickedImg = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (pickedImg != null) {
      setState(() {
        // _image = File(pickedImg.path);
        _pickedImage = pickedImg; //Direct Xfile
      });
    }
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
    String? imageUrl; //For Srore Image Url

    try {
      //if Image Selected then Upload Image
      if (_pickedImage != null) {
        setState(() {
          _loadingText = "Uploading Image...";
        });

        ///Upload Image to ImgBB
        imageUrl = await _imageUploadService.uploadImage(
          _pickedImage!,
        ); //_image its variable For Store Selected Pic
        if (imageUrl == null) {
          throw Exception('Failed to upload image');
        }
      }

      setState(() {
        _loadingText = "Post Saveing...";
      });

      //send data to FireStore
      await _firestoreService.createPost(
        _titleController.text,
        _contentController.text,
        imageUrl: imageUrl,
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
//Remove Image
  void _removeImage() {
    setState(() {
      _pickedImage = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image Removed,Save...')),
    );
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
            GestureDetector(
              onTap: pickeImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _pickedImage != null
                    ? ClipRect(child: kIsWeb ? Image.network(_pickedImage!.path,fit: BoxFit.cover): Image.file(
                  File(_pickedImage!.path),
                  fit: BoxFit.cover,
                ) )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Add Image",
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
              ),
            ),
            Row(
              children: [
                if (_pickedImage != null)...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _removeImage,
                      child: Text("⛔"),
                    ),

                  )
                ]


              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Your Title",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: "Write Your Content here",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _publishPost,
              child: Text(_loading ? _loadingText : "Publish"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 15),
            if (_loading)
              Container(

                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SpinKitCircle(
                        color: Colors.red,
                        size: 30,
                      ),
                      SizedBox(height: 10),
                      Text(
                        _loadingText,
                        style: TextStyle(color: Colors.blue),
                      ),

                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
