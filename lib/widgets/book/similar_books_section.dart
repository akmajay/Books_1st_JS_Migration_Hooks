import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../services/auth_service.dart';
import '../shared/book_card.dart';

class SimilarBooksSection extends StatefulWidget {
  final String currentBookId;
  final String category;
  final String? board;
  final String? classYear;

  const SimilarBooksSection({
    super.key,
    required this.currentBookId,
    required this.category,
    this.board,
    this.classYear,
  });

  @override
  State<SimilarBooksSection> createState() => _SimilarBooksSectionState();
}

class _SimilarBooksSectionState extends State<SimilarBooksSection> {
  List<RecordModel> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSimilarBooks();
  }

  Future<void> _fetchSimilarBooks() async {
    try {
      final pb = AuthService().pb;
      String filter = 'id != "${widget.currentBookId}" && status = "active" && category = "${widget.category}"';
      
      if (widget.board != null) filter += ' && board = "${widget.board}"';
      if (widget.classYear != null) filter += ' && class_year = "${widget.classYear}"';

      final result = await pb.collection('books').getList(
        page: 1,
        perPage: 10,
        filter: filter,
        sort: '-is_priority,-created',
        expand: 'seller,school',
      );

      if (mounted) {
        setState(() {
          _books = result.items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading && _books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Similar Books',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 280,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _books.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => SizedBox(
                    width: 180,
                    child: BookCard(
                      book: _books[index],
                      currentUser: AuthService().currentUser,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
