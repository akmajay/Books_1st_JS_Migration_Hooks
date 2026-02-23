import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PhotoPicker extends StatelessWidget {
  final List<dynamic> items; 
  final Function(List<dynamic>) onChanged;
  final int maxPhotos;

  const PhotoPicker({
    super.key,
    required this.items,
    required this.onChanged,
    this.maxPhotos = 5,
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final newItems = List.from(items)..add(picked);
      onChanged(newItems);
    }
  }

  void _removeItem(int index) {
    final newItems = List.from(items)..removeAt(index);
    onChanged(newItems);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Photos', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length + (items.length < maxPhotos ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == items.length) {
                return _buildAddButton();
              }
              return _buildPhotoCard(items[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add_a_photo, color: Colors.grey),
      ),
    );
  }

  Widget _buildPhotoCard(dynamic item, int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: item is XFile 
                ? (kIsWeb 
                    ? NetworkImage(item.path) 
                    : FileImage(io.File(item.path))) as ImageProvider
                : CachedNetworkImageProvider(item['url'] as String),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeItem(index),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
