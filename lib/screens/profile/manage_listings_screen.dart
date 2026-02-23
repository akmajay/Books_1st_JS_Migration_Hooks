import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../services/auth_service.dart';
import '../../services/book_service.dart';
import '../../widgets/shared/book_list_tile.dart';
import '../../widgets/shared/paginated_list_view.dart';
import '../../controllers/paginated_controller.dart';

class ManageListingsScreen extends StatefulWidget {
  const ManageListingsScreen({super.key});

  @override
  State<ManageListingsScreen> createState() => _ManageListingsScreenState();
}

class _ManageListingsScreenState extends State<ManageListingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PaginatedController<RecordModel> _activeController;
  late PaginatedController<RecordModel> _reservedController;
  late PaginatedController<RecordModel> _soldController;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _activeController = _createController('active');
    _reservedController = _createController('reserved');
    _soldController = _createController('sold');

    _activeController.loadInitial();
    _reservedController.loadInitial();
    _soldController.loadInitial();
  }

  PaginatedController<RecordModel> _createController(String status) {
    return PaginatedController<RecordModel>(
      fetcher: (page, perPage) => BookService.instance.getBooks(
        page: page,
        perPage: perPage,
        filter: 'seller = "${_authService.currentUser?.id}" && status = "$status"',
        sort: '-updated',
      ),
      mapper: (record) => record,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _activeController.dispose();
    _reservedController.dispose();
    _soldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Reserved'),
            Tab(text: 'Sold'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_activeController),
          _buildList(_reservedController),
          _buildList(_soldController),
        ],
      ),
    );
  }

  Future<void> _handleDelete(RecordModel book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await BookService.instance.deleteBook(book.id);
        _refreshAll();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing deleted')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
      }
    }
  }

  Future<void> _handleMarkSold(RecordModel book) async {
    try {
      await BookService.instance.updateBook(book.id, body: {'status': 'sold'});
      _refreshAll();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Book marked as sold!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _handleRelist(RecordModel book) async {
    try {
      await BookService.instance.updateBook(book.id, body: {'status': 'active'});
      _refreshAll();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing is active again!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error relisting: $e')));
    }
  }

  void _refreshAll() {
    _activeController.loadInitial();
    _reservedController.loadInitial();
    _soldController.loadInitial();
  }

  Widget _buildList(PaginatedController<RecordModel> controller) {
    return PaginatedListView<RecordModel>(
      controller: controller,
      itemBuilder: (book, index) => BookListTile(
        book: book,
        onTap: () => context.push('/book/${book.id}'),
        onDelete: (_) => _handleDelete(book),
        onMarkSold: (_) => _handleMarkSold(book),
        onRelist: (_) => _handleRelist(book),
      ),
    );
  }
}
