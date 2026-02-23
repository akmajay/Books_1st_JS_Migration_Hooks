import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoItem {
  final File? file;
  final String? url;
  final String? name; // For existing photos

  PhotoItem({this.file, this.url, this.name});
  bool get isNew => file != null;
}

class PhotoPicker extends StatelessWidget {
  final List<PhotoItem> items;
  final Function(List<PhotoItem>) onChanged;
  final Function(int) onRemove;
  final Function(List<PhotoItem>) onReorder;

  const PhotoPicker({
    super.key,
    required this.items,
    required this.onChanged,
    required this.onRemove,
    required this.onReorder,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final List<PhotoItem> newItems = List.from(items);
      if (newItems.length < 5) {
        newItems.add(PhotoItem(file: File(pickedFile.path)));
      }
      onChanged(newItems);
    }
  }

  void _showSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Add Photos (Max 5)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: (items.length < 5) ? items.length + 1 : 5,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex -= 1;
              if (oldIndex < items.length && newIndex < items.length) {
                final List<PhotoItem> newList = List.from(items);
                final item = newList.removeAt(oldIndex);
                newList.insert(newIndex, item);
                onReorder(newList);
              }
            },
            itemBuilder: (context, index) {
              if (index < items.length) {
                return _buildPhotoCard(index);
              } else {
                return _buildAddButton(context, index);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(int index) {
    final item = items[index];
    return Container(
      key: ValueKey(item.file?.path ?? item.url ?? index.toString()),
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.isNew
                ? Image.file(item.file!, width: 110, height: 110, fit: BoxFit.cover)
                : Image.network(item.url!, width: 110, height: 110, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: () => onRemove(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
          if (index == 0)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'COVER',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, int index) {
    return InkWell(
      key: const ValueKey('add_button'),
      onTap: () => _showSourceSheet(context),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: Colors.grey[600]),
            const SizedBox(height: 4),
            Text(
              'Add Photo',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
