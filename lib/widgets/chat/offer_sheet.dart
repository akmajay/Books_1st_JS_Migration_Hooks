import 'package:flutter/material.dart';

class OfferSheet extends StatefulWidget {
  final int originalPrice;
  final String bookTitle;
  final Function(int amount) onSend;

  const OfferSheet({
    super.key,
    required this.originalPrice,
    required this.bookTitle,
    required this.onSend,
  });

  @override
  State<OfferSheet> createState() => _OfferSheetState();
}

class _OfferSheetState extends State<OfferSheet> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Make an Offer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(widget.bookTitle, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Text('Seller\'s price: ₹${widget.originalPrice}', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            autofocus: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
            decoration: const InputDecoration(
              prefixText: '₹',
              hintText: '0',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final amount = int.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  widget.onSend(amount);
                  Navigator.pop(context);
                }
              },
              child: const Text('Send Offer'),
            ),
          ),
        ],
      ),
    );
  }
}
