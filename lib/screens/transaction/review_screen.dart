import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:go_router/go_router.dart';
import '../../services/transaction_service.dart';

class ReviewScreen extends StatefulWidget {
  final String transactionId;
  const ReviewScreen({super.key, required this.transactionId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TransactionService _txnService = TransactionService();
  final TextEditingController _commentController = TextEditingController();
  
  RecordModel? _txn;
  bool _isLoading = true;
  double _rating = 5.0;
  final List<String> _selectedTags = [];
  bool _isSubmitting = false;

  final List<String> _availableTags = [
    'On Time',
    'Book as Described',
    'Friendly',
    'Fair Price',
    'Fast Response',
  ];

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadTransaction() async {
    setState(() => _isLoading = true);
    try {
      final txn = await _txnService.getTransaction(widget.transactionId);
      setState(() {
        _txn = txn;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) context.pop();
    }
  }

  Future<void> _submitReview() async {
    if (_txn == null) return;
    
    setState(() => _isSubmitting = true);
    try {
      await _txnService.submitReview(
        txnId: _txn!.id,
        reviewedUserId: _txn!.get<String>('seller'),
        rating: _rating,
        comment: _commentController.text,
        tags: _selectedTags,
      );
      
      if (mounted) {
        final navigator = Navigator.of(context);
        final router = GoRouter.of(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Thank You! 🌟'),
            content: const Text('Your review helps build a safer community for everyone.'),
            actions: [
              TextButton(
                onPressed: () {
                  navigator.pop();
                  router.go('/home');
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_txn == null) return const Scaffold(body: Center(child: Text('Transaction not found')));

    final seller = _txn!.get<List<RecordModel>>('expand.seller').first;

    return Scaffold(
      appBar: AppBar(title: const Text('Write Review')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue[50],
              child: Text(seller.get<String>('name')[0].toUpperCase(), style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 16),
            Text(
              'How was your experience with ${seller.get<String>('name')}?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) => setState(() => _rating = rating),
            ),
            const SizedBox(height: 32),
            
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('What went well?', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                  selectedColor: Colors.blue.withAlpha(50),
                  checkmarkColor: Colors.blue,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Add a comment (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
