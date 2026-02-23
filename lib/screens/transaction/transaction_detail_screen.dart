import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:go_router/go_router.dart';
// Removal of unused intl import
import '../../services/auth_service.dart';
import '../../services/transaction_service.dart';
import '../../services/pocketbase_service.dart';
import '../../widgets/shared/report_sheet.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;
  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final TransactionService _txnService = TransactionService();
  final AuthService _authService = AuthService();
  
  RecordModel? _txn;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
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
      debugPrint('Error loading transaction: $e');
      if (mounted) context.pop();
    }
  }

  Future<void> _handleAction() async {
    if (_txn == null) return;
    final status = _txn!.get<String>('status');
    final isBuyer = _txn!.get<String>('buyer') == _authService.currentUser?.id;

    if (status == 'initiated' && isBuyer) {
      await _txnService.confirmDeal(_txn!.id);
      _loadTransaction();
    } else if (status == 'handover_pending') {
      if (isBuyer) {
        context.push('/transaction/${_txn!.id}/scan');
      } else {
        context.push('/transaction/${_txn!.id}/qr');
      }
    } else if (status == 'completed' && isBuyer) {
      context.push('/transaction/${_txn!.id}/review');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_txn == null) return const Scaffold(body: Center(child: Text('Transaction not found')));

    final book = _txn!.get<List<RecordModel>>('expand.book').first;
    final seller = _txn!.get<List<RecordModel>>('expand.seller').first;
    final buyer = _txn!.get<List<RecordModel>>('expand.buyer').first;
    final isBuyer = buyer.id == _authService.currentUser?.id;
    final status = _txn!.get<String>('status');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deal Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () => context.push('/chat/${_txn!.get<String>('chat')}'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransaction,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(status),
            const SizedBox(height: 24),
            _buildBookCard(book),
            const SizedBox(height: 24),
            _buildPeopleSection(buyer, seller),
            const SizedBox(height: 32),
            _buildTimeline(status),
            const SizedBox(height: 40),
            _buildActionButtons(status, isBuyer),
            if (status != 'completed' && status != 'reviewed' && status != 'disputed')
              Center(
                child: TextButton(
                  onPressed: () => showReportSheet(context, targetType: 'transaction', targetId: widget.transactionId),
                  child: const Text('Report a Problem', style: TextStyle(color: Colors.red)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case 'initiated':
        color = Colors.blue;
        icon = Icons.info_outline;
        text = 'Deal Initiated';
        break;
      case 'confirmed':
      case 'handover_pending':
        color = Colors.orange;
        icon = Icons.timer_outlined;
        text = 'Pending Handover';
        break;
      case 'completed':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        text = 'Handover Completed';
        break;
      case 'reviewed':
        color = Colors.purple;
        icon = Icons.star_outline;
        text = 'Transaction Reviewed';
        break;
      case 'disputed':
        color = Colors.red;
        icon = Icons.warning_amber_outlined;
        text = 'Deal Disputed';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
        text = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBookCard(RecordModel book) {
    final photo = book.get<List<dynamic>>('photos').first;
    final photoUrl = PocketBaseService.instance.getFileUrl(book, photo);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(photoUrl, width: 60, height: 80, fit: BoxFit.cover,            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: const Icon(Icons.book))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.get<String>('title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('By ${book.get<String>('author')}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 8),
                Text('₹${_txn!.get<int>('agreed_price')}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeopleSection(RecordModel buyer, RecordModel seller) {
    return Row(
      children: [
        _buildUserMini(seller, 'Seller'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
        ),
        _buildUserMini(buyer, 'Buyer'),
      ],
    );
  }

  Widget _buildUserMini(RecordModel user, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              CircleAvatar(radius: 12, backgroundColor: Colors.blue[50], child: Text(user.get<String>('name')[0].toUpperCase(), style: const TextStyle(fontSize: 10))),
              const SizedBox(width: 8),
              Expanded(child: Text(user.get<String>('name'), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(String currentStatus) {
    final stages = [
      {'id': 'initiated', 'label': 'Deal Initiated'},
      {'id': 'confirmed', 'label': 'Deal Confirmed'},
      {'id': 'handover_pending', 'label': 'Handover Ready'},
      {'id': 'completed', 'label': 'Completed'},
    ];

    int currentIndex = stages.indexWhere((s) => s['id'] == currentStatus);
    if (currentIndex == -1 && currentStatus == 'reviewed') currentIndex = 3;
    if (currentIndex == -1 && currentStatus == 'disputed') currentIndex = 0; // Or handle differently

    return Column(
      children: stages.asMap().entries.map((entry) {
        int idx = entry.key;
        bool isDone = idx <= currentIndex;
        bool isLast = idx == stages.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDone ? Colors.blue : Colors.white,
                    border: Border.all(color: isDone ? Colors.blue : Colors.grey[300]!),
                    shape: BoxShape.circle,
                  ),
                  child: isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isDone ? Colors.blue : Colors.grey[200],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(entry.value['label']!, style: TextStyle(color: isDone ? Colors.black : Colors.grey, fontWeight: isDone ? FontWeight.bold : FontWeight.normal)),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(String status, bool isBuyer) {
    String? label;
    IconData? icon;
    
    if (status == 'initiated' && isBuyer) {
      label = 'Confirm Deal';
      icon = Icons.check_circle_outline;
    } else if (status == 'confirmed' && !isBuyer) {
      label = 'Start Handover';
      icon = Icons.qr_code;
    } else if (status == 'handover_pending') {
      label = isBuyer ? 'Scan Seller QR' : 'Show My QR';
      icon = isBuyer ? Icons.qr_code_scanner : Icons.qr_code;
    } else if (status == 'completed' && isBuyer) {
      label = 'Write a Review';
      icon = Icons.star_outline;
    }

    if (label == null) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _handleAction,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
