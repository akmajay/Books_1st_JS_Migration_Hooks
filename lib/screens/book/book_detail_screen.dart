import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as ta;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';
import '../../config/deeplink_config.dart';
import '../../widgets/login_gate.dart';
import '../../widgets/book/bundle_items_list.dart';
import '../../widgets/book/seller_card.dart';
import '../../widgets/book/book_action_bar.dart';
import '../../widgets/book/similar_books_section.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  RecordModel? _book;
  bool _isLoading = true;
  int _currentImageIndex = 0;
  final PageController _imageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchBookDetails();
    _incrementViewCount();
  }

  Future<void> _fetchBookDetails() async {
    try {
      final pb = AuthService().pb;
      final book = await pb.collection('books').getOne(
        widget.bookId,
        expand: 'seller,school',
      );
      if (mounted) {
        setState(() {
          _book = book;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _incrementViewCount() async {
    // Debounce: check if viewed recently in local storage or just call and let backend handle it?
    // Instruction said call once when opened. 
    try {
      final pb = AuthService().pb;
      await http.get(Uri.parse('${pb.baseURL}/api/books/${widget.bookId}/view'));
    } catch (e) {
      // Fail silently
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_book == null) return const Scaffold(body: Center(child: Text('Book not found')));

    final photos = _book!.getListValue<String>('photos');
    final double sellingPrice = _book!.getDoubleValue('selling_price');
    final double mrp = _book!.getDoubleValue('mrp');
    final String status = _book!.getStringValue('status');
    final bool isSold = status == 'sold';
    final bool isReserved = status == 'reserved';
    final sellerList = _book!.get<List<RecordModel>>('expand.seller');
    final seller = sellerList.isNotEmpty ? sellerList.first : null;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Image Gallery
                _buildImageGallery(photos),

                // 2. Price & Status
                _buildPriceSection(sellingPrice, mrp, status),

                const Divider(height: 1),

                // 3. Book Details Card
                _buildBookDetails(),

                // 4. Bundle Section
                if (_book!.getBoolValue('is_bundle'))
                  BundleItemsList(bundleId: _book!.id),

                const Divider(height: 1),

                // 5. Seller Info
                if (seller != null)
                  SellerCard(
                    seller: seller,
                    isOwnListing: AuthService().currentUser?.id == seller.id,
                  ),

                const Divider(height: 1),

                // 6. Similar Books
                SimilarBooksSection(
                  currentBookId: _book!.id,
                  category: _book!.getStringValue('category'),
                  board: _book!.getStringValue('board'),
                  classYear: _book!.getStringValue('class_year'),
                ),

                const SizedBox(height: 100), // Bottom padding for action bar
              ],
            ),
          ),

          // Top Header Buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.8),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.8),
                    child: IconButton(
                      icon: const Icon(Icons.share, color: Colors.black),
                      onPressed: () {
                        final link = DeepLinkConfig.bookUrl(widget.bookId);
                        SharePlus.share('Check out "${_book!.getStringValue('title')}" on JayGanga Books! 📚\n$link');
                      },
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.8),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.black),
                      onSelected: (val) {
                        if (val == 'report') {
                          LoginGate.show(context, onSuccess: () {
                            context.push('/report/${widget.bookId}?title=${Uri.encodeComponent(_book!.getStringValue('title'))}');
                          });
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'report',
                          child: Row(
                            children: [
                              Icon(Icons.report_problem_outlined, color: Colors.red, size: 20),
                              SizedBox(width: 12),
                              Text('Report Listing', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BookActionBar(
        bookId: _book!.id,
        sellerId: seller?.id ?? '',
        bookTitle: _book!.getStringValue('title'),
        price: sellingPrice,
        isSold: isSold,
        isReserved: isReserved,
      ),
    );
  }

  Widget _buildImageGallery(List<String> photos) {
    if (photos.isEmpty) {
      return Container(
        height: 300,
        width: double.infinity,
        color: Colors.grey[200],
        child: const Icon(Icons.book, size: 80, color: Colors.grey),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _imageController,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final url = '${AuthService().pb.baseURL}/api/files/${_book!.collectionId}/${_book!.id}/${photos[index]}';
              return InteractiveViewer(
                child: Hero(
                  tag: index == 0 ? 'book_image_${_book!.id}' : 'book_image_${_book!.id}_$index',
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
            child: Text(
              '${_currentImageIndex + 1}/${photos.length}',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(double price, double mrp, String status) {
    final bool isFree = price == 0;
    final int discount = mrp > 0 ? (((mrp - price) / mrp) * 100).round() : 0;
    final String createdStr = ta.format(DateTime.parse(_book!.getStringValue('created')));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SOLD/RESERVED Banners
          if (status == 'sold')
            _buildStatusBanner('❌ This book has been sold', Colors.red)
          else if (status == 'reserved')
            _buildStatusBanner('⚠️ This book is currently reserved', Colors.orange),

          Row(
            children: [
              if (isFree)
                const Text('FREE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green))
              else
                Text('₹${price.toInt()}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              
              if (mrp > price && !isFree) ...[
                const SizedBox(width: 8),
                Text('₹${mrp.toInt()}', style: TextStyle(fontSize: 16, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                  child: Text('$discount% off', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),
          
          Row(
            children: [
              _buildConditionChip(_book!.getStringValue('condition')),
              const Spacer(),
              _buildMetricIcon(Icons.remove_red_eye_outlined, '${_book!.getIntValue('views_count')} views'),
              const SizedBox(width: 12),
              _buildMetricIcon(Icons.access_time, createdStr),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildConditionChip(String condition) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(condition.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMetricIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildBookDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'book_title_${_book!.id}',
            child: Material(
              type: MaterialType.transparency,
              child: Text(_book!.getStringValue('title'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 4),
          Text('By ${_book!.getStringValue('author')}', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          
          const SizedBox(height: 16),
          _buildDetailRow('Publisher', _book!.getStringValue('publisher')),
          _buildDetailRow('Edition', _book!.getStringValue('edition')),
          _buildDetailRow('Board', _book!.getStringValue('board')),
          _buildDetailRow('Class', 'Class ${_book!.getStringValue('class_year')}'),
          
          const SizedBox(height: 16),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(_book!.getStringValue('description')),
          
          const SizedBox(height: 16),
          const Text('Handover Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(_book!.getStringValue('area'), style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }
}
