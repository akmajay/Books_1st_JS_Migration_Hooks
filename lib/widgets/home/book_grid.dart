import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/book_service.dart';
import '../../services/location_service.dart';
import '../../widgets/shared/book_card.dart';
import '../../widgets/shared/paginated_list_view.dart';
import '../../controllers/paginated_controller.dart';

class BookGrid extends StatefulWidget {
  final String? filter;
  final String? sort;
  final bool useSliver;

  const BookGrid({
    super.key,
    this.filter,
    this.sort,
    this.useSliver = false,
  });

  @override
  State<BookGrid> createState() => _BookGridState();
}

class _BookGridState extends State<BookGrid> {
  late PaginatedController<RecordModel> _controller;
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _initController(isInitial: true);
    _loadUserPosition();
  }

  void _initController({bool isInitial = false}) {
    if (!isInitial) {
      _controller.dispose();
    }
    _controller = PaginatedController<RecordModel>(
      fetcher: (page, perPage) => BookService.instance.getBooks(
        page: page,
        perPage: perPage,
        filter: widget.filter,
        sort: widget.sort,
        expand: 'seller,school',
      ),
      mapper: (record) => record,
    );
    _controller.loadInitial();
  }

  Future<void> _loadUserPosition() async {
    final pos = await LocationService.getCurrentLocation();
    if (pos != null && mounted) {
      setState(() => _userPosition = pos);
    }
  }

  @override
  void didUpdateWidget(BookGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter || oldWidget.sort != widget.sort) {
      _initController();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedListView<RecordModel>(
      controller: _controller,
      isGrid: true,
      useSliver: widget.useSliver,
      gridCrossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      itemBuilder: (book, index) {
        double? distance;
        if (_userPosition != null) {
          final sellerLat = book.get<num>('location_lat').toDouble();
          final sellerLng = book.get<num>('location_lon').toDouble();
          if (sellerLat != 0 && sellerLng != 0) {
            distance = LocationService.calculateDistance(
              _userPosition!.latitude,
              _userPosition!.longitude,
              sellerLat,
              sellerLng,
            );
          }
        }

        return BookCard(
          book: book,
          distanceKm: distance,
        );
      },
    );
  }
}
