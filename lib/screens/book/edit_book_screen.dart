import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';
import '../../services/book_service.dart';
import '../../widgets/sell/book_form.dart';

class EditBookScreen extends StatefulWidget {
  final String bookId;
  const EditBookScreen({super.key, required this.bookId});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  RecordModel? _book;
  bool _isLoading = true;
  bool _isSaving = false;
  String _status = 'active';

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    try {
      final pb = AuthService().pb;
      final book = await pb.collection('books').getOne(widget.bookId);
      
      if (book.getStringValue('seller') != AuthService().currentUser?.id) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You can only edit your own listings')));
          context.pop();
        }
        return;
      }

      setState(() {
        _book = book;
        _status = book.getStringValue('status');
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading book: $e')));
        context.pop();
      }
    }
  }

  Future<void> _handleSave(Map<String, dynamic> data, List<dynamic> photos) async {
    setState(() => _isSaving = true);
    try {
      final newPhotos = photos.whereType<XFile>().toList();
      final existingPhotos = photos.where((p) => p is Map && p['isExisting'] == true).map((p) => p['url'] as String).toList();

      List<http.MultipartFile> files = [];
      for (var f in newPhotos) {
        final bytes = await f.readAsBytes();
        files.add(http.MultipartFile.fromBytes(
          'photos',
          bytes,
          filename: f.name,
        ));
      }

      final body = { 
        ...data, 
        'status': _status,
        'photos': existingPhotos, // PocketBase keeps these, adds new files from multipart
      };
      
      await BookService.instance.updateBook(widget.bookId, body: body, files: files);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Changes saved!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _handleStatusChange(String? val) async {
    if (val == null) return;
    
    String message = '';
    if (val == 'reserved') message = 'Mark as reserved? Buyers can still view but can\'t start new chats.';
    if (val == 'sold') message = 'Mark as sold? This listing will move to your sold items.';
    if (val == 'active' && _status == 'sold') message = 'Relist this book? It will appear as a new active listing.';

    if (message.isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Status Change'),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _status = val);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Listing')),
      body: Stack(
        children: [
          Column(
            children: [
              _buildStatusPicker(),
              const Divider(),
              Expanded(
                child: BookForm(
                  initialBook: _book,
                  isLoading: _isSaving,
                  onSubmit: _handleSave,
                ),
              ),
            ],
          ),
          if (_isSaving) Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPicker() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text('Listing Status:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
              items: ['active', 'reserved', 'sold'].map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
              onChanged: _handleStatusChange,
            ),
          ),
        ],
      ),
    );
  }
}
