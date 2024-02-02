//new_message
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();
  String? _imageUrl;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();

    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });
  }


  final _firebase = FirebaseAuth.instance.currentUser;

  File? _imageShot;

  void _pickImage() async {
    final selectImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 200,
    );

    if (selectImage != null) {
      setState(() {
        _imageShot = File(selectImage.path);
      });
    }

    final _firebase = FirebaseAuth.instance.currentUser;
    final userCred = await _firebase;

    final storageReference = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('${userCred!.uid}_SentImageG_${DateTime.now().millisecondsSinceEpoch}.jpg');

    await storageReference.putFile(_imageShot!);

    String imageUrl = await storageReference.getDownloadURL();

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCred.uid)
        .get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': imageUrl,
      'createdAt': Timestamp.now(),
      'userId': userCred.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            icon: const Icon(
              Icons.send,
            ),
            onPressed: _submitMessage,
          ),
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: _pickImage,
          ),
        ],
      ),
    );
  }
}