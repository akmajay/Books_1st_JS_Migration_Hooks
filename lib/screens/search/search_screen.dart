import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../providers/search_provider.dart';
import '../../services/search_history_service.dart';
import '../../widgets/shared/book_card.dart';
import '../../widgets/shared/book_list_tile.dart';
import '../../widgets/shared/paginated_list_view.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../../widgets/search/filter_sheet.dart';
import '../../widgets/search/sort_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = context.read<SearchProvider>().query;
      if (query.isNotEmpty) {
        _searchController.text = query;
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        context.read<SearchProvider>().updateQuery(value);
      }
    });
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          setState(() {
            _searchController.text = val.recognizedWords;
            _onSearchChanged(val.recognizedWords);
          });
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _buildSearchBar(searchProvider),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: searchProvider.activeFiltersCount > 0,
              label: Text('${searchProvider.activeFiltersCount}'),
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => _showFilterSheet(),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortSheet(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (searchProvider.activeFiltersCount > 0) _buildActiveFilters(searchProvider),
          Expanded(
            child: _searchController.text.isEmpty && searchProvider.activeFiltersCount == 0
                ? _buildPreSearchView()
                : _buildResultsView(searchProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(SearchProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search for books, authors...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    provider.updateQuery('');
                  },
                ),
              IconButton(
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : null),
                onPressed: _listen,
              ),
            ],
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          filled: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildActiveFilters(SearchProvider provider) {
    final chips = <Widget>[
      ActionChip(
        label: const Text('Clear All'),
        onPressed: provider.clearFilters,
        avatar: const Icon(Icons.close, size: 16),
      ),
      const SizedBox(width: 8),
    ];

    if (provider.freeOnly) {
      chips.add(_filterChip('Free Only', () => provider.updateFilters({...provider.filters}..remove('price_range'))));
    }

    for (final cat in provider.selectedCategories) {
      chips.add(_filterChip(cat, () {
        final next = [...provider.selectedCategories]..remove(cat);
        provider.updateFilters({...provider.filters, 'categories': next});
      }));
    }

    for (final board in provider.selectedBoards) {
      chips.add(_filterChip(board, () {
        final next = [...provider.selectedBoards]..remove(board);
        provider.updateFilters({...provider.filters, 'boards': next});
      }));
    }

    for (final cls in provider.selectedClasses) {
      chips.add(_filterChip('Class $cls', () {
        final next = [...provider.selectedClasses]..remove(cls);
        provider.updateFilters({...provider.filters, 'classes': next});
      }));
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: chips,
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onDeleted) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InputChip(
        label: Text(label),
        onDeleted: onDeleted,
        deleteIcon: const Icon(Icons.cancel, size: 16),
      ),
    );
  }

  Widget _buildPreSearchView() {
    final history = SearchHistoryService.getHistory();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (history.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Searches', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => setState(() => SearchHistoryService.clearHistory()), child: const Text('Clear All')),
            ],
          ),
          Wrap(
            spacing: 8,
            children: history.map((q) => InputChip(
              label: Text(q),
              onPressed: () {
                _searchController.text = q;
                context.read<SearchProvider>().updateQuery(q);
              },
              onDeleted: () => setState(() => SearchHistoryService.removeQuery(q)),
            )).toList(),
          ),
          const SizedBox(height: 24),
        ],
        const Text('Trending Searches', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: ['NCERT Class 10', 'HC Verma', 'RD Sharma', 'NEET Biology', 'Arihant JEE'].map((q) => ActionChip(
            label: Text(q),
            onPressed: () {
              _searchController.text = q;
              context.read<SearchProvider>().updateQuery(q);
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildResultsView(SearchProvider provider) {
    if (provider.isLoading && provider.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.items.isEmpty) {
      return const EmptyStateWidget(
        title: 'No results found',
        message: 'Try adjusting your filters or search term',
        type: EmptyStateType.noResults,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('${provider.items.length} books found', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const Spacer(),
              IconButton(
                icon: Icon(provider.isGridView ? Icons.view_list : Icons.grid_view),
                onPressed: provider.toggleLayout,
              ),
            ],
          ),
        ),
        Expanded(
          child: PaginatedListView<RecordModel>(
            controller: provider.controller,
            externalScrollController: _scrollController,
            isGrid: provider.isGridView,
            gridCrossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            itemBuilder: (book, index) {
              if (provider.isGridView) {
                return BookCard(
                  book: book,
                  distanceKm: provider.getDistanceForBook(book.id),
                );
              }
              return BookListTile(
                book: book,
                onTap: () => context.push('/book/${book.id}'),
                onDelete: (_) {},
                onMarkSold: (_) {},
                onRelist: (_) {},
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const FilterSheet(),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SortSheet(),
    );
  }
}
