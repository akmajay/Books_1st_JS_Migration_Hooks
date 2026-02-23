import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../services/auth_service.dart';

import '../../controllers/paginated_controller.dart';
import '../../widgets/shared/paginated_list_view.dart';
import '../../services/pocketbase_service.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  
  late PaginatedController<RecordModel> _buyingController;
  late PaginatedController<RecordModel> _sellingController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initControllers();
  }

  void _initControllers() {
    final userId = _authService.currentUser?.id ?? '';
    
    _buyingController = PaginatedController<RecordModel>(
      fetcher: (page, perPage) => PocketBaseService.instance.pb.collection('transactions').getList(
        page: page,
        perPage: perPage,
        filter: 'buyer = "$userId"',
        sort: '-created',
        expand: 'book,seller,buyer',
      ),
      mapper: (record) => record,
    )..loadInitial();

    _sellingController = PaginatedController<RecordModel>(
      fetcher: (page, perPage) => PocketBaseService.instance.pb.collection('transactions').getList(
        page: page,
        perPage: perPage,
        filter: 'seller = "$userId"',
        sort: '-created',
        expand: 'book,seller,buyer',
      ),
      mapper: (record) => record,
    )..loadInitial();
  }

  @override
  void dispose() {
    _buyingController.dispose();
    _sellingController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Transactions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'As Buyer'),
            Tab(text: 'As Seller'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_buyingController, true),
          _buildList(_sellingController, false),
        ],
      ),
    );
  }

  Widget _buildList(PaginatedController<RecordModel> controller, bool isAsBuyer) {
    return PaginatedListView<RecordModel>(
      controller: controller,
      emptyWidget: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No transactions yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ],
        ),
      ),
      padding: const EdgeInsets.all(16),
      itemBuilder: (txn, index) {
        final book = txn.get<List<RecordModel>>('expand.book').first;
        final otherUser = isAsBuyer 
            ? txn.get<List<RecordModel>>('expand.seller').first
            : txn.get<List<RecordModel>>('expand.buyer').first;
        
        final status = txn.getStringValue('status');
        final price = txn.get<int>('agreed_price');
        final created = DateTime.parse(txn.getStringValue('created'));
        
        final photoUrl = book.get<List<dynamic>>('photos').isNotEmpty
            ? PocketBaseService.instance.getFileUrl(book, book.get<List<dynamic>>('photos').first).toString()
            : '';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: ListTile(
            onTap: () => context.push('/transaction/${txn.id}'),
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: photoUrl.isNotEmpty 
                  ? Image.network(photoUrl, width: 50, height: 50, fit: BoxFit.cover)
                  : Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.book)),
            ),
            title: Text(
              book.getStringValue('title'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${isAsBuyer ? 'Seller' : 'Buyer'}: ${otherUser.getStringValue('name')}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹$price',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 14),
                    ),
                    _buildStatusChip(status),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('MMM dd').format(created),
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
                const Icon(Icons.chevron_right, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'initiated':
        color = Colors.grey;
        break;
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'handover_pending':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'reviewed':
        color = Colors.purple;
        break;
      case 'disputed':
        color = Colors.red;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
