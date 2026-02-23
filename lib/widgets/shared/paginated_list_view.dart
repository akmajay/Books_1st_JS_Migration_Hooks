import 'package:flutter/material.dart';
import '../../controllers/paginated_controller.dart';
import 'animated_list_item.dart';
import 'shimmer_skeleton.dart';
import 'error_state_widget.dart';
import 'empty_state_widget.dart';

class PaginatedListView<T> extends StatefulWidget {
  final PaginatedController<T> controller;
  final Widget Function(T item, int index) itemBuilder;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final EdgeInsets? padding;
  final bool isGrid;
  final int gridCrossAxisCount;
  final double gridChildAspectRatio;
  final ScrollPhysics? physics;
  final Widget? header;
  final bool shrinkWrap;
  final ScrollController? externalScrollController;
  final bool useSliver; // New parameter

  const PaginatedListView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.emptyWidget,
    this.loadingWidget,
    this.padding,
    this.isGrid = false,
    this.gridCrossAxisCount = 2,
    this.gridChildAspectRatio = 0.7,
    this.physics,
    this.header,
    this.shrinkWrap = false,
    this.externalScrollController,
    this.useSliver = false, // Default to false
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  late final ScrollController _scrollController;
  bool _isLocalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.externalScrollController != null) {
      _scrollController = widget.externalScrollController!;
    } else {
      _scrollController = ScrollController();
      _isLocalController = true;
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (_isLocalController) _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    // Trigger load more when 200px from bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final ctrl = widget.controller;

        // First load
        if (ctrl.isFirstLoad) {
          final skeleton = widget.loadingWidget ?? _buildSkeletonList();
          return widget.useSliver ? SliverToBoxAdapter(child: skeleton) : skeleton;
        }

        // Error on empty
        if (ctrl.error != null && ctrl.isEmpty) {
          final errorWidget = ErrorStateWidget(
            error: ctrl.error!,
            onRetry: ctrl.loadInitial,
          );
          return widget.useSliver ? SliverToBoxAdapter(child: errorWidget) : errorWidget;
        }

        // Empty state
        if (ctrl.isEmpty) {
          final emptyWidget = widget.emptyWidget ?? const EmptyStateWidget(
            title: 'No items found',
            message: 'Try searching for something else',
            type: EmptyStateType.noResults,
          );
          return widget.useSliver ? SliverToBoxAdapter(child: emptyWidget) : emptyWidget;
        }

        // Data list
        if (widget.useSliver) {
          return widget.isGrid ? _buildSliverGrid(ctrl) : _buildSliverList(ctrl);
        }

        return RefreshIndicator(
          onRefresh: ctrl.refresh,
          color: Theme.of(context).colorScheme.primary,
          child: widget.isGrid ? _buildGrid(ctrl) : _buildList(ctrl),
        );
      },
    );
  }

  Widget _buildList(PaginatedController<T> ctrl) {
    return ListView.builder(
      controller: _isLocalController ? _scrollController : null,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
      itemCount: ctrl.items.length + (widget.header != null ? 1 : 0) + 1,
      itemBuilder: (context, index) {
        return _buildItem(ctrl, index);
      },
    );
  }

  Widget _buildSliverList(PaginatedController<T> ctrl) {
    return SliverPadding(
      padding: widget.padding ?? EdgeInsets.zero,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildItem(ctrl, index),
          childCount: ctrl.items.length + (widget.header != null ? 1 : 0) + 1,
        ),
      ),
    );
  }

  Widget _buildItem(PaginatedController<T> ctrl, int index) {
    // Header
    if (widget.header != null && index == 0) {
      return widget.header!;
    }

    final dataIndex = widget.header != null ? index - 1 : index;

    // Items
    if (dataIndex < ctrl.items.length && dataIndex >= 0) {
      return StaggeredListItem(
        index: dataIndex,
        child: widget.itemBuilder(ctrl.items[dataIndex], dataIndex),
      );
    }

    // Footer: loading or end
    if (dataIndex == ctrl.items.length) {
      if (ctrl.hasMore) {
        return _buildLoadingMore();
      } else if (ctrl.items.isNotEmpty) {
        return _buildEndOfList();
      }
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildGrid(PaginatedController<T> ctrl) {
    return GridView.builder(
      controller: _isLocalController ? _scrollController : null,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.gridCrossAxisCount,
        childAspectRatio: widget.gridChildAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: ctrl.items.length + (ctrl.hasMore ? 1 : 1),
      itemBuilder: (context, index) => _buildGridItem(ctrl, index),
    );
  }

  Widget _buildSliverGrid(PaginatedController<T> ctrl) {
    return SliverPadding(
      padding: widget.padding ?? EdgeInsets.zero,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.gridCrossAxisCount,
          childAspectRatio: widget.gridChildAspectRatio,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildGridItem(ctrl, index),
          childCount: ctrl.items.length + (ctrl.hasMore ? 1 : 1),
        ),
      ),
    );
  }

  Widget _buildGridItem(PaginatedController<T> ctrl, int index) {
    if (index < ctrl.items.length) {
      return StaggeredListItem(
        index: index,
        child: widget.itemBuilder(ctrl.items[index], index),
      );
    }
    
    if (ctrl.hasMore) {
      return _buildLoadingMore();
    } else {
      return const SizedBox.shrink(); 
    }
  }

  Widget _buildLoadingMore() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildEndOfList() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Opacity(
          opacity: 0.5,
          child: Column(
            children: [
              const Icon(Icons.auto_stories_outlined, size: 24),
              const SizedBox(height: 8),
              Text(
                'You\'ve reached the end 📚',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    if (widget.isGrid) {
      return GridView.builder(
        padding: widget.padding,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.gridCrossAxisCount,
          childAspectRatio: widget.gridChildAspectRatio,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const BookCardSkeleton(),
      );
    }
    return ListView.builder(
      padding: widget.padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      itemBuilder: (context, index) => const BookListTileSkeleton(),
    );
  }
}
