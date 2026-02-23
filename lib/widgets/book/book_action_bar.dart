import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../widgets/login_gate.dart';

class BookActionBar extends StatelessWidget {
  final String bookId;
  final String sellerId;
  final String bookTitle;
  final double price;
  final bool isSold;
  final bool isReserved;

  const BookActionBar({
    super.key,
    required this.bookId,
    required this.sellerId,
    required this.bookTitle,
    required this.price,
    this.isSold = false,
    this.isReserved = false,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final isOwnListing = auth.currentUser?.id == sellerId;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
             // Wishlist / Report
             IconButton(
               icon: const Icon(Icons.favorite_border),
               onPressed: isSold ? null : () {
                 if (!auth.isLoggedIn) {
                   LoginGate.show(context);
                 } else {
                   // Wishlist toggle
                 }
               },
             ),
             IconButton(
               icon: const Icon(Icons.share_outlined),
               onPressed: () {
                 SharePlus.share("Check out '$bookTitle' for ₹${price.toInt()} on JayGanga Books! https://jgbooks.in/book/$bookId");
               },
             ),
             const SizedBox(width: 8),
             
              // Primary Action
              Expanded(
                child: isOwnListing
                ? ElevatedButton.icon(
                    onPressed: () => context.push('/book/$bookId/edit'),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Listing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  )
                : ElevatedButton(
                    onPressed: isSold ? null : () async {
                      if (!auth.isLoggedIn) {
                        LoginGate.show(context);
                      } else {
                        try {
                          final chat = await ChatService.instance.getOrCreateChat(bookId, sellerId);
                          if (chat != null && context.mounted) {
                            context.push('/chat/${chat.id}');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isSold ? 'Sold Out' : 'Chat with Seller'),
                  ),
              ),
             
             if (!isOwnListing)
               PopupMenuButton<String>(
                 icon: const Icon(Icons.more_vert),
                 onSelected: (value) {
                   if (value == 'report') {
                     if (!auth.isLoggedIn) {
                        LoginGate.show(context);
                     } else {
                        // Show report bottom sheet
                     }
                   }
                 },
                 itemBuilder: (context) => [
                   const PopupMenuItem(value: 'report', child: Text('Report Listing')),
                 ],
               ),
          ],
        ),
      ),
    );
  }
}
