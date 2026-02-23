import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/book_service.dart';
import '../../services/location_service.dart';
import '../../widgets/sell/book_form.dart';

class SellBookScreen extends StatefulWidget {
  const SellBookScreen({super.key});

  @override
  State<SellBookScreen> createState() => _SellBookScreenState();
}

class _SellBookScreenState extends State<SellBookScreen> {
  bool _isPublishing = false;

  Future<void> _publishBook(Map<String, dynamic> data, List<dynamic> photos) async {
    setState(() => _isPublishing = true);
    try {
      
      // Capture location
      final pos = await LocationService.getCurrentLocation();
      if (pos == null && mounted) {
        throw 'Location access is required to post a book.';
      }

      final photoFiles = photos.whereType<XFile>().toList();

      List<http.MultipartFile> files = [];
      for (var f in photoFiles) {
        if (kIsWeb) {
          final bytes = await f.readAsBytes();
          files.add(http.MultipartFile.fromBytes(
            'photos',
            bytes,
            filename: f.name,
          ));
        } else {
          files.add(await http.MultipartFile.fromPath('photos', f.path));
        }
      }

      final body = {
        ...data,
        'seller': AuthService().currentUser?.id,
        'status': 'active',
        'location_lat': pos?.latitude ?? 0,
        'location_lon': pos?.longitude ?? 0,
      };
      
      await BookService.instance.createBook(body, files);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Book posted successfully!')));
        context.go('/home');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error publishing: $e')));
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sell a Book')),
      body: Stack(
        children: [
          BookForm(
            isLoading: _isPublishing,
            onSubmit: _publishBook,
          ),
          if (_isPublishing) Container(
            color: Colors.black26, 
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
