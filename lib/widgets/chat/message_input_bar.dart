import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'offer_sheet.dart';

class MessageInputBar extends StatefulWidget {
  final Function(String text) onSend;
  final Function(XFile file) onSendImage;
  final Function(int amount) onSendOffer;
  final int bookPrice;
  final String bookTitle;
  final bool showQuickReplies;
  final bool isSold;

  const MessageInputBar({
    super.key,
    required this.onSend,
    required this.onSendImage,
    required this.onSendOffer,
    required this.bookPrice,
    required this.bookTitle,
    this.showQuickReplies = false,
    this.isSold = false,
  });

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _textController.clear();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 70);
    if (image != null) {
      widget.onSendImage(image);
    }
  }

  void _showOfferSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => OfferSheet(
        originalPrice: widget.bookPrice,
        bookTitle: widget.bookTitle,
        onSend: widget.onSendOffer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSold) {
      return Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16),
        child: const Center(child: Text('This book has been sold. Trading is closed.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showQuickReplies) _buildQuickReplies(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4, offset: const Offset(0, -2))]),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.camera_alt_outlined, color: Colors.blue), onPressed: () => _pickImage(ImageSource.camera)),
              IconButton(icon: const Icon(Icons.photo_outlined, color: Colors.blue), onPressed: () => _pickImage(ImageSource.gallery)),
              IconButton(icon: const Icon(Icons.sell_outlined, color: Colors.green), onPressed: _showOfferSheet),
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: _handleSend,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickReplies() {
    final replies = [
      'Hi, is this book still available?',
      'Can you reduce the price?',
      'Where can we meet for handover?',
      'Is the condition as described?',
    ];

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: replies.map((msg) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ActionChip(
            label: Text(msg, style: const TextStyle(fontSize: 12)),
            onPressed: () {
              _textController.text = msg;
              _handleSend();
            },
          ),
        )).toList(),
      ),
    );
  }
}
