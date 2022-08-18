import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ShopImagePicker extends StatefulWidget {
  ShopImagePicker(this.submitImageFn);
  final void Function(File pickedImage) submitImageFn;
  @override
  _ShopImagePickerState createState() => _ShopImagePickerState();
}

class _ShopImagePickerState extends State<ShopImagePicker> {
  File _pickedshopImage;
  void _imagePicker() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
        source: ImageSource.camera, imageQuality: 80, maxWidth: 150);
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _pickedshopImage = pickedImageFile;
    });
    widget.submitImageFn(pickedImageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage:
              _pickedshopImage != null ? FileImage(_pickedshopImage) : null,
        ),
        SizedBox(
          height: 5,
        ),
        FlatButton.icon(
            color: Theme.of(context).primaryColor,
            onPressed: _imagePicker,
            icon: Icon(Icons.image),
            label: Text('Add Image')),
      ],
    );
  }
}
