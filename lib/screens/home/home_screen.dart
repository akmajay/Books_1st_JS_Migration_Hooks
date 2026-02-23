import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
import '../../widgets/home/section_header.dart';
import '../../widgets/home/category_bar.dart';
import '../../widgets/home/book_grid.dart';
import '../../widgets/home/banner_carousel.dart';
import '../../widgets/home/ad_strip.dart';
import '../../widgets/home/filter_chips_bar.dart';
import '../../widgets/home/near_you_section.dart';
import '../../widgets/home/recommendations_section.dart';
import '../../widgets/shared/app_drawer.dart';
import '../../widgets/login_gate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _scrollController = ScrollController();
  String _selectedFilter = 'all';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Map UI filter values to PocketBase filter strings
  String? _getFilterString(String value) {
    if (value == 'all' || value == 'near_me') return 'status = "active"';
    if (value == 'free') return 'status = "active" && selling_price = 0';
    
    if (value.startsWith('class_')) {
      final cls = value.replaceFirst('class_', '');
      return 'status = "active" && class_year = "$cls"';
    }
    
    if (value == 'cbse') return 'status = "active" && board = "CBSE"';
    if (value == 'icse') return 'status = "active" && board = "ICSE"';
    if (value == 'state_board') return 'status = "active" && board = "State Board"';
    
    if (value == 'jee') return 'status = "active" && category = "jee_engineering"';
    if (value == 'neet') return 'status = "active" && category = "neet_medical"';
    
    if (value == 'my_school') {
      final user = _authService.currentUser;
      if (user?.school != null) {
        return 'status = "active" && school = "${user!.school}"';
      }
    }
    
    return 'status = "active"';
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      drawer: const AppDrawer(),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('JayGanga Books'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => context.push('/home/search'),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () => LoginGate.show(context, onSuccess: () => context.push('/wishlists')),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () => LoginGate.show(context, onSuccess: () => context.push('/notifications')),
              ),
            ],
          ),
          
          // Welcome & Location
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome, ${user?.name ?? 'Guest'} 👋',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  const LocationStatusDisplay(),
                ],
              ),
            ),
          ),
          
          // Promotions
          const SliverToBoxAdapter(child: BannerCarousel()),
          
          // Quick Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: FilterChipsBar(
                selectedFilter: _selectedFilter,
                onSelect: (val) => setState(() => _selectedFilter = val),
              ),
            ),
          ),
          
          // Categories
          SliverToBoxAdapter(
            child: CategoryBar(
              onCategorySelected: (cat) => context.push('/home/search?category=$cat'),
            ),
          ),
          
          // Personalized Sections
          const SliverToBoxAdapter(child: NearYouSection()),
          const SliverToBoxAdapter(child: AdStrip()),
          const SliverToBoxAdapter(child: RecommendationsSection()),
          
          // Main Feed Header
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Recently Added',
                actionLabel: 'See All',
                onAction: () => context.push('/home/search'),
              ),
            ),
          ),
          
          // Infinite Scroll Grid
          BookGrid(
            useSliver: true,
            filter: _getFilterString(_selectedFilter),
          ),
          
          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => LoginGate.show(context, onSuccess: () => context.push('/home/sell')),
        label: const Text('Sell Book'),
        icon: const Icon(Icons.add_a_photo),
      ),
    );
  }
}

class LocationStatusDisplay extends StatefulWidget {
  const LocationStatusDisplay({super.key});

  @override
  State<LocationStatusDisplay> createState() => _LocationStatusDisplayState();
}

class _LocationStatusDisplayState extends State<LocationStatusDisplay> {
  bool _isDetecting = false;

  Future<void> _handleDetect() async {
    setState(() => _isDetecting = true);
    await LocationService.getCurrentLocation();
    if (mounted) setState(() => _isDetecting = false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: LocationService.getLastKnown(),
      builder: (context, snapshot) {
        final hasLocation = snapshot.hasData && snapshot.data != null;
        
        return InkWell(
          onTap: _isDetecting ? null : _handleDetect,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withAlpha(30)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.blue[700]),
                const SizedBox(width: 6),
                if (_isDetecting)
                  const SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  )
                else
                  Text(
                    hasLocation ? 'Nearby · 5 km' : 'Set location',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  'Detect',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
