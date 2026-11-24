import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../app_colors.dart';

class PhotoPickerField extends StatefulWidget {
  const PhotoPickerField({
    required this.onChanged,
    this.initialImageUrl,
    this.avatarSize = 100,
    super.key,
  });

  final ValueChanged<XFile?> onChanged;
  final String? initialImageUrl;
  final double avatarSize;

  @override
  State<PhotoPickerField> createState() => _PhotoPickerFieldState();
}

class _PhotoPickerFieldState extends State<PhotoPickerField> {
  final _picker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  bool _isPicking = false;
  String? _errorMessage;

  Future<void> _pickImage() async {
    setState(() {
      _isPicking = true;
      _errorMessage = null;
    });

    final XFile? image;
    try {
      image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 82,
      );
    } on PlatformException {
      if (!mounted) return;
      setState(() {
        _isPicking = false;
        _errorMessage = 'Impossible d’ouvrir la galerie de photos.';
      });
      return;
    }
    if (!mounted) return;

    if (image == null) {
      setState(() => _isPicking = false);
      return;
    }

    final bytes = await image.readAsBytes();
    if (!mounted) return;
    if (bytes.length > 2 * 1024 * 1024) {
      setState(() {
        _isPicking = false;
        _errorMessage = 'La photo doit faire 2 Mo maximum.';
      });
      return;
    }

    setState(() {
      _selectedImage = image;
      _imageBytes = bytes;
      _isPicking = false;
    });
    widget.onChanged(image);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.avatarSize;
    final selectedBytes = _imageBytes;
    final imageUrl = widget.initialImageUrl;
    final image = selectedBytes != null
        ? Image.memory(
            selectedBytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
          )
        : imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _placeholder(size),
          )
        : _placeholder(size);

    return Column(
      children: [
        ClipOval(
          child: SizedBox(width: size, height: size, child: image),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _isPicking ? null : _pickImage,
          icon: _isPicking
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.photo_camera_outlined),
          label: Text(
            _isPicking
                ? 'Chargement…'
                : _selectedImage != null || imageUrl != null
                ? 'Changer la photo'
                : 'Ajouter une photo',
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(height: 8),
        const Text(
          'JPG, PNG, GIF ou WebP · 2 Mo maximum',
          style: TextStyle(color: AppColors.muted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _placeholder(double size) => Container(
    width: size,
    height: size,
    color: const Color(0xFFECEFE7),
    child: Icon(
      Icons.person_outline_rounded,
      color: AppColors.green,
      size: size * .55,
    ),
  );
}
