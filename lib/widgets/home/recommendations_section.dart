import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../services/auth_service.dart';
import '../shared/book_card.dart';
import '../shared/animated_list_item.dart';

class RecommendationsSection extends StatefulWidget {
  const RecommendationsSection({super.key});

  @override
  State<RecommendationsSection> createState() => _RecommendationsSectionState();
}

class _RecommendationsSectionState extends State<RecommendationsSection> {
  List<RecordModel> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    final user = AuthService().currentUser;
    if (user == null) return;

    try {
      final pb = AuthService().pb;
      
      // Filter based on user profile
      String filter = 'status = "active"';
      List<String> conditions = [];
      if (user.board != null) conditions.add('board = "${user.board}"');
      if (user.classYear != null) conditions.add('class_year = "${user.classYear}"');
      if (user.stream != null) conditions.add('stream = "${user.stream}"');
      if (user.examType != null) conditions.add('exam_type = "${user.examType}"');

      if (conditions.isNotEmpty) {
        filter += ' && (${conditions.join(' || ')})';
      }

      final result = await pb.collection('books').getList(
        page: 1,
        perPage: 5,
        filter: filter,
        sort: '-created',
        expand: 'seller,school',
      );

      if (mounted) {
        setState(() {
          _books = result.items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null) return const SizedBox.shrink();

    // If profile incomplete, show CTA
    if (user.userType == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            const Text(
              'Complete your profile to get personalized recommendations',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            TextButton(
              onPressed: () => /* GoRouter.of(context).go('/settings/profile-edit') */ {},
              child: const Text('Update Profile'),
            ),
          ],
        ),
      );
    }

    if (!_isLoading && _books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommended for You',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => /* GoRouter.of(context).go('/home/search') */ {},
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280, // Height matching BookCard + padding
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _books.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) => SizedBox(
                  width: 180,
                  child: StaggeredListItem(
                    index: index,
                    child: BookCard(book: _books[index], currentUser: user),
                  ),
                ),
              ),
        ),
      ],
    );
  }
}
