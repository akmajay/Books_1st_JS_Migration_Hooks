import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/app_error.dart';

/// Generic controller to manage paginated data fetching from PocketBase.
class PaginatedController<T> extends ChangeNotifier {
  final Future<ResultList<RecordModel>> Function(int page, int perPage)? fetcher;
  final T Function(RecordModel record) mapper;
  final int perPage;

  List<T> _items = [];
  int _currentPage = 1;

  int _totalPages = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  AppError? _error;

  // Getters
  List<T> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get isEmpty => _items.isEmpty && !_isLoading;
  AppError? get error => _error;
  bool get isFirstLoad => _items.isEmpty && _isLoading;

  PaginatedController({
    this.fetcher,
    required this.mapper,
    this.perPage = 20,
  });

  /// Initial load
  Future<void> loadInitial() async {
    if (_isLoading && _currentPage == 1) return;
    _currentPage = 1;
    _items = [];
    _error = null;
    _hasMore = true;
    notifyListeners();
    await _fetchPage(1);
  }

  /// Load next page (triggered by scroll)
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    await _fetchPage(_currentPage + 1);
  }

  /// Refresh (pull-to-refresh)
  Future<void> refresh() async {
    _currentPage = 1;
    _error = null;
    _hasMore = true;
    // We don't clear items immediately to avoid a blank screen during pull-to-refresh
    await _fetchPage(1);
  }

  Future<ResultList<RecordModel>> fetch(int page, int perPage) {
    if (fetcher != null) return fetcher!(page, perPage);
    throw UnimplementedError('fetcher not provided and fetch not overridden');
  }

  Future<void> _fetchPage(int page) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Fetching page $page (perPage: $perPage) via $runtimeType');
      final result = await fetch(page, perPage);
      final mapped = result.items.map(mapper).toList();
      
      debugPrint('Fetch SUCCESS: ${result.items.length} records found.');

      if (page == 1) {
        _items = mapped;
      } else {
        _items.addAll(mapped);
      }

      _currentPage = page;
      _totalPages = result.totalPages;
      _hasMore = page < _totalPages && result.items.isNotEmpty;
    } catch (e) {
      debugPrint('Fetch ERROR in $runtimeType: $e');
      if (e is ClientException) {
        debugPrint('PocketBase ClientException Details: path=${e.url?.path}, status=${e.statusCode}, response=${e.response}');
      }
      _error = e is AppError ? e : AppError(
        message: 'Failed to load data. Please try again.',
        detail: e.toString(),
        type: ErrorType.unknown,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove item locally by its ID
  void removeItemById(String id) {
    _items.removeWhere((item) {
      if (item is RecordModel) return item.id == id;
      // Fallback for custom types that might have an id property
      try {
        return (item as dynamic).id == id;
      } catch (_) {
        return false;
      }
    });
    notifyListeners();
  }

  /// Update item locally
  void updateItem(T item) {
    if (item is RecordModel) {
      final index = _items.indexWhere((it) => (it as RecordModel).id == item.id);
      if (index != -1) {
        _items[index] = item;
        notifyListeners();
      }
    }
  }

  /// Get total items (if known)
  int get totalItems => _items.length; // Simplified for now, or use result.totalItems if stored

  /// Insert item at top (optimistic add)
  void insertAtTop(T item) {
    _items.insert(0, item);
    notifyListeners();
  }
}

/// Specialization for chat messages (LIFO/Reverse display)
class ReversePaginatedController<T> extends PaginatedController<T> {
  ReversePaginatedController({
    super.fetcher,
    required super.mapper,
    super.perPage = 30,
  });

  @override
  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;
    
    // For reverse pagination, we fetch older messages and prepend them
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await fetch(_currentPage + 1, perPage);
      final mapped = result.items.map(mapper).toList();

      // Prepend older messages to the START of the list
      // In a reverse ListView, index 0 is at the bottom (newest)
      // So older messages (which are prepended) will appear at the top as the user scrolls up.
      _items.addAll(mapped); 
      
      _currentPage++;
      _totalPages = result.totalPages;
      _hasMore = _currentPage < _totalPages && result.items.isNotEmpty;
    } catch (e) {
      _error = e is AppError ? e : AppError(
        message: 'Failed to load history',
        detail: e.toString(),
        type: ErrorType.unknown,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
