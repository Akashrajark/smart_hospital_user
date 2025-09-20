import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CustomImagePickerButton extends StatefulWidget {
  final String? selectedImage;
  final Function(File file) onPick;
  final bool showRequiredError;
  final double height, width, borderRadius;

  const CustomImagePickerButton({
    super.key,
    required this.onPick,
    this.height = 200,
    this.width = 200,
    this.selectedImage,
    this.showRequiredError = false,
    this.borderRadius = 8,
  });

  @override
  State<CustomImagePickerButton> createState() => _CustomImagePickerButtonState();
}

class _CustomImagePickerButtonState extends State<CustomImagePickerButton> {
  File? _selectedFile;

  // Pick image using File Picker
  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null && result.files.isNotEmpty) {
        File pickedFile = File(result.files.first.path!);
        setState(() {
          _selectedFile = pickedFile;
        });

        widget.onPick(pickedFile);
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: Colors.grey[200],
          child: InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: _selectedFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: Image.file(_selectedFile!, height: widget.height, width: widget.width, fit: BoxFit.cover),
                  )
                : widget.selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: Image.network(
                      widget.selectedImage!,
                      height: widget.height,
                      width: widget.width,
                      fit: BoxFit.cover,
                    ),
                  )
                : SizedBox(
                    height: widget.height,
                    width: widget.width,
                    child: const Icon(Icons.add_photo_alternate_rounded, color: Colors.grey),
                  ),
          ),
        ),
        if (widget.showRequiredError)
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 2),
            child: Text(
              'This photo is required',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red[800]),
            ),
          ),
      ],
    );
  }
}
