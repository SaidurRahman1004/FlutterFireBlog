import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  Future<String?> uploadImage(XFile imageFile) async {
    final url = Uri.parse('https://api.imgbb.com/1/upload?key=$ImageApiKey');

    //Create Multi Request because We Sent File
    final request = http.MultipartRequest('POST', url);

    try {
      if (kIsWeb){   //If Web Version
        final Uint8List bytes = await imageFile.readAsBytes();    //Read Image by Byte

        //create MultiPart File From Byte
        final file = http.MultipartFile.fromBytes('image', bytes, filename: imageFile.name); //Create File   //image Name of Api Feild
        request.files.add(file);  //Add File to Request
      }else{
        //if Movile Version       //Add Image to 'image' Feild
        final file = await http.MultipartFile.fromPath('image', imageFile.path);
        request.files.add(file);    ////Add File to Request
      }


      final streamedResponse = await request
          .send(); //Send Request and Wait For Response

      //Convert Response to String
      final response = await http.Response.fromStream(streamedResponse);
      //if success return url
      if (response.statusCode == 200) {
        final ResponseData = jsonDecode(
          response.body,
        ); //Decode Response //parse Json Response
        return ResponseData['data']['url'];                                     //Return Url From i*** Image  //Response Formet {"data": {"url": "image_url_here"}, "success": true}
      }else{
        print('Error uploading image: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
