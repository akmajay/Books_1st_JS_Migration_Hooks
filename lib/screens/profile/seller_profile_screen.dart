import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../services/auth_service.dart';
import '../../services/pocketbase_service.dart';
import '../../config/deeplink_config.dart';
import '../../widgets/shared/report_sheet.dart';
import '../../widgets/shared/book_card.dart';
import '../../services/location_service.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/paginated_controller.dart';
import '../../widgets/shared/paginated_list_view.dart';

class SellerProfileScreen extends StatefulWidget {
  final String userId;
  const SellerProfileScreen({super.key, required this.userId});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> with SingleTickerProviderStateMixin {
  final PocketBase _pb = PocketBaseService.instance.pb;
  final AuthService _authService = AuthService();
  
  late TabController _tabController;
  RecordModel? _seller;
  late PaginatedController<RecordModel> _listingsController;
  late PaginatedController<RecordModel> _reviewsController;
  bool _isLoadingSeller = true;
  double? _distanceKm;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initControllers();
    
    // Redirect if viewing own profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userId == _authService.currentUser?.id) {
        context.go('/home/profile');
      } else {
        _loadSellerInfo();
      }
    });
  }

  void _initControllers() {
    _listingsController = PaginatedController<RecordModel>(
      fetcher: (page, perPage) => _pb.collection('books').getList(
        page: page,
        perPage: perPage,
        filter: 'seller = "${widget.userId}" && status = "active"',
        sort: '-created',
        expand: 'seller',
      ),
      mapper: (record) => record,
    )..loadInitial();

    _reviewsController = PaginatedController<RecordModel>(
      fetcher: (page, perPage) => _pb.collection('reviews').getList(
        page: page,
        perPage: perPage,
        filter: 'reviewed_user = "${widget.userId}"',
        sort: '-created',
        expand: 'reviewer',
      ),
      mapper: (record) => record,
    )..loadInitial();
  }

  @override
  void dispose() {
    _listingsController.dispose();
    _reviewsController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSellerInfo() async {
    setState(() => _isLoadingSeller = true);
    try {
      // 1. Fetch Seller Info
      final seller = await _pb.collection('users').getOne(widget.userId);
      
      if (mounted) {
        // Calculate distance
        double? dist;
        final userPos = await LocationService.getLastKnown();
        if (userPos != null) {
          final sLat = seller.get<num?>('location_lat')?.toDouble();
          final sLng = seller.get<num?>('location_lon')?.toDouble();
          if (sLat != null && sLng != null && sLat != 0) {
            dist = LocationService.calculateDistance(
              userPos.latitude,
              userPos.longitude,
              sLat,
              sLng,
            );
          }
        }

        setState(() {
          _seller = seller;
          _distanceKm = dist;
          _isLoadingSeller = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading seller info: $e');
      if (mounted) {
        setState(() => _isLoadingSeller = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _startChat() {
    // Navigate to chat or initiate one
    context.push('/chat/new?sellerId=${widget.userId}');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSeller) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_seller == null) return const Scaffold(body: Center(child: Text('User not found')));

    final avatarUrl = _seller!.getStringValue('avatar').isNotEmpty 
        ? PocketBaseService.instance.getFileUrl(_seller!, _seller!.getStringValue('avatar'))
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(_seller!.getStringValue('name')),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final link = DeepLinkConfig.sellerUrl(widget.userId);
              SharePlus.share('Check out ${_seller!.getStringValue('name')}\'s books on JayGanga Books! \ud83d\udcda\n$link');
            },
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'report') {
                showReportSheet(context, targetType: 'user', targetId: widget.userId);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'report', child: Text('Report User', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl.isEmpty ? Text(_seller!.getStringValue('name')[0], style: const TextStyle(fontSize: 32)) : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _seller!.getStringValue('name'),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      if (_seller!.getBoolValue('is_verified'))
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.verified, color: Colors.blue, size: 20),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${_seller!.get<double>('trust_score').toStringAsFixed(1)} Trust Score',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        ' (${_seller!.getIntValue('total_reviews')} reviews)',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Member since ${timeago.format(DateTime.parse(_seller!.getStringValue('created')), locale: 'en_short')}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  if (_distanceKm != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '📍 ${LocationService.formatDistance(_distanceKm!)} from you',
                      style: const TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                  if (_seller!.getStringValue('bio').isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      _seller!.getStringValue('bio'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildHeaderStat('Books Sold', _seller!.getIntValue('books_sold').toString()),
                      ListenableBuilder(
                        listenable: _listingsController,
                        builder: (context, _) => _buildHeaderStat('Active', _listingsController.totalItems.toString()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _startChat,
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Chat with Seller', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.blue,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Listings'),
                  Tab(text: 'Reviews'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildListingsGrid(),
            _buildReviewsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildListingsGrid() {
    return PaginatedListView<RecordModel>(
      controller: _listingsController,
      isGrid: true,
      gridCrossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      emptyWidget: const Center(child: Text('No active listings yet.')),
      itemBuilder: (book, index) => BookCard(book: book),
    );
  }

  Widget _buildReviewsList() {
    return PaginatedListView<RecordModel>(
      controller: _reviewsController,
      padding: const EdgeInsets.all(20),
      emptyWidget: const Center(child: Text('No reviews yet.')),
      itemBuilder: (review, index) {
        final reviewerRes = review.get<List<RecordModel>>('expand.reviewer');
        if (reviewerRes.isEmpty) return const SizedBox.shrink();
        final reviewer = reviewerRes.first;
        final rating = review.get<num>('rating').toDouble();
        final tags = review.get<List<dynamic>>('tags');

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    child: Text(reviewer.getStringValue('name')[0].toUpperCase()),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(reviewer.getStringValue('name'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: List.generate(5, (i) => Icon(
                            i < rating.floor() ? Icons.star : Icons.star_border,
                            size: 14,
                            color: Colors.orange,
                          )),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    timeago.format(DateTime.parse(review.getStringValue('created'))),
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (review.getStringValue('comment').isNotEmpty)
                Text(review.getStringValue('comment'), style: const TextStyle(fontSize: 14)),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(t, style: TextStyle(color: Colors.grey[700], fontSize: 10)),
                  )).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SliverTabDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabDelegate oldDelegate) => false;
}
