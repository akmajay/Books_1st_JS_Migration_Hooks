
import 'package:geolocator/geolocator.dart';
import 'package:pocketbase/pocketbase.dart';
import '../controllers/paginated_controller.dart';
import '../services/book_service.dart';
import '../services/location_service.dart';

enum SortMode { relevance, priceLow, priceHigh, newest, nearest }

class SearchProvider extends PaginatedController<RecordModel> {
  String _query = '';
  SortMode _sortMode = SortMode.relevance;
  final Map<String, dynamic> _filters = {};
  final Map<String, double> _distances = {};
  bool _isGridView = true;
  Position? _userPosition;

  SearchProvider() : super(
    mapper: (record) => record,
  );

  String get query => _query;
  SortMode get sortMode => _sortMode;
  Map<String, dynamic> get filters => _filters;
  bool get isGridView => _isGridView;

  // New getters to match UI expectations
  int get activeFiltersCount => _filters.length;
  bool get freeOnly => _filters['price_range'] == 'free';
  dynamic get priceRange => _filters['price_range'];
  List<String> get selectedCategories => _filters['categories']?.cast<String>() ?? [];
  List<String> get selectedBoards => _filters['boards']?.cast<String>() ?? [];
  List<String> get selectedClasses => _filters['classes']?.cast<String>() ?? [];
  List<String> get selectedConditions => _filters['conditions']?.cast<String>() ?? [];

  // Alias for compatibility
  PaginatedController<RecordModel> get controller => this;

  void updateQuery(String q) {
    _query = q;
    // Update fetcher logic if needed based on query
    refresh();
  }

  void setSort(SortMode mode) {
    _sortMode = mode;
    refresh();
  }

  void updateFilters(Map<String, dynamic> newFilters) {
    _filters.clear();
    _filters.addAll(newFilters);
    refresh();
  }

  void clearFilters() {
    _filters.clear();
    refresh();
  }

  void toggleLayout() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  double? getDistanceForBook(String bookId) {
    return _distances[bookId];
  }

  Future<void> _updateDistances() async {
    _userPosition ??= await LocationService.getCurrentLocation();
    if (_userPosition == null) return;

    for (final book in items) {
      final lat = book.getDoubleValue('location_lat');
      final lon = book.getDoubleValue('location_lon');
      if (lat != 0 && lon != 0) {
        _distances[book.id] = LocationService.calculateDistance(
          _userPosition!.latitude,
          _userPosition!.longitude,
          lat,
          lon,
        );
      }
    }
  }

  @override
  Future<ResultList<RecordModel>> fetch(int page, int perPage) async {
    final filterParts = <String>[];
    
    // 0. Base Filter: only active books
    filterParts.add('status = "active"');

    // 1. Query
    if (_query.isNotEmpty) {
      filterParts.add('(title ~ "$_query" || author ~ "$_query" || description ~ "$_query")');
    }

    final categories = selectedCategories;
    if (categories.isNotEmpty) {
      filterParts.add('(${categories.map((c) => 'category = "$c"').join(' || ')})');
    }

    final boards = selectedBoards;
    if (boards.isNotEmpty) {
      filterParts.add('(${boards.map((b) => 'board = "$b"').join(' || ')})');
    }

    final classes = selectedClasses;
    if (classes.isNotEmpty) {
      filterParts.add('(${classes.map((c) => 'class_year = "$c"').join(' || ')})');
    }

    final conditions = selectedConditions;
    if (conditions.isNotEmpty) {
      filterParts.add('(${conditions.map((c) => 'condition = "$c"').join(' || ')})');
    }

    // 6. Price
    if (freeOnly) {
      filterParts.add('selling_price = 0');
    }

    final filterString = filterParts.isEmpty ? null : filterParts.join(' && ');

    final result = await BookService.instance.getBooks(
      page: page, 
      perPage: perPage,
      filter: filterString,
      sort: _getSortString(),
      expand: 'seller,school',
    );

    // After fetching, calculate distances for all items
    await _updateDistances();

    // If sorting by nearest, we have to sort client-side after fetching
    // NOTE: This only sorts the current page. Proper global nearest sort
    // would require server-side support or fetching everything (which is bad).
    if (_sortMode == SortMode.nearest) {
      items.sort((a, b) {
        final distA = _distances[a.id] ?? double.infinity;
        final distB = _distances[b.id] ?? double.infinity;
        return distA.compareTo(distB);
      });
    }

    return result;
  }

  String _getSortString() {
    switch (_sortMode) {
      case SortMode.priceLow: return '+selling_price';
      case SortMode.priceHigh: return '-selling_price';
      case SortMode.newest: return '-created';
      case SortMode.nearest: return '-created'; // Fallback for server-side
      default: return '-created';
    }
  }
}
