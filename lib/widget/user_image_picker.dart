import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.setProfileImage});
  final void Function(File? image) setProfileImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? selectedImage;

  void selectImage(bool isCamera) async {
    final pickedImage = await ImagePicker().pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        maxHeight: 150,
        imageQuality: 50);

    if (pickedImage == null) return;
    setState(() {
      selectedImage = File(pickedImage.path);
    });
    widget.setProfileImage(selectedImage);

    if (context.mounted) Navigator.of(context).pop();
  }

  void showImagePickerDialog() {
    showDialog(
        context: context,
        builder: (ctx) => SimpleDialog(
              title: const Text("Select Image"),
              children: [
                TextButton(
                  onPressed: () => selectImage(true),
                  child: const Text("Image from Camera"),
                ),
                TextButton(
                  onPressed: () => selectImage(false),
                  child: const Text("Image from Gallary"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("Close"),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey,
            foregroundImage:
                selectedImage != null ? FileImage(selectedImage!) : null,
          ),
        ),
        TextButton.icon(
          onPressed: showImagePickerDialog,
          icon: const Icon(Icons.image),
          label: Text(
            "Select Image",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        )
      ],
    );
  }
}
