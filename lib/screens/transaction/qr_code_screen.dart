import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen_brightness/screen_brightness.dart';
// Removal of unused intl import
import '../../services/transaction_service.dart';

class QrCodeScreen extends StatefulWidget {
  final String transactionId;
  const QrCodeScreen({super.key, required this.transactionId});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  final TransactionService _txnService = TransactionService();
  RecordModel? _txn;
  bool _isLoading = true;
  Timer? _timer;
  String _timeLeft = '';

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resetBrightness();
    super.dispose();
  }

  Future<void> _initScreen() async {
    await _loadTransaction();
    _setBrightness();
    _startTimer();
  }

  Future<void> _loadTransaction() async {
    setState(() => _isLoading = true);
    try {
      final txn = await _txnService.getTransaction(widget.transactionId);
      setState(() {
        _txn = txn;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading transaction: $e');
    }
  }

  Future<void> _setBrightness() async {
    try {
      await ScreenBrightness().setApplicationScreenBrightness(1.0);
    } catch (e) {
      debugPrint('Failed to set brightness: $e');
    }
  }

  Future<void> _resetBrightness() async {
    try {
      await ScreenBrightness().resetApplicationScreenBrightness();
    } catch (e) {
      debugPrint('Failed to reset brightness: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_txn == null || !mounted) return;
      
      final expiryStr = _txn!.get<String>('token_expires_at');
      if (expiryStr.isEmpty) return;

      final expiry = DateTime.parse(expiryStr).toLocal();
      final now = DateTime.now();
      final diff = expiry.difference(now);

      if (diff.isNegative) {
        setState(() => _timeLeft = 'EXPIRED');
        _timer?.cancel();
      } else {
        final hours = diff.inHours;
        final mins = diff.inMinutes.remainder(60);
        final secs = diff.inSeconds.remainder(60);
        setState(() {
          _timeLeft = '${hours}h ${mins}m ${secs}s';
        });
      }
    });
  }

  Future<void> _handleRegenerate() async {
    await _txnService.regenerateToken(widget.transactionId);
    await _loadTransaction();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_txn == null) return const Scaffold(body: Center(child: Text('Error loading transaction')));

    final token = _txn!.get<String>('handover_token');
    final book = _txn!.get<List<RecordModel>>('expand.book').first;
    final buyer = _txn!.get<List<RecordModel>>('expand.buyer').first;

    final qrData = jsonEncode({
      'txn_id': _txn!.id,
      'token': token,
      'expires': _txn!.get<String>('token_expires_at'),
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Handover QR Code')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(40, 40, 40, 10),
              child: Text(
                'Show this code to the buyer to scan and confirm the handover.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            
            if (token.isNotEmpty && _timeLeft != 'EXPIRED') ...[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 30),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 20, spreadRadius: 5)],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 240.0,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: Colors.blue),
                  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Colors.blue),
                ),
              ),
              Text(
                'Expires in: $_timeLeft',
                style: TextStyle(
                  color: _timeLeft.contains('0h 0m') ? Colors.red : Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ] else if (_timeLeft == 'EXPIRED' || token.isEmpty) ...[
              Container(
                height: 240,
                width: 240,
                margin: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24)),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_off_outlined, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Code Expired', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _handleRegenerate,
                icon: const Icon(Icons.refresh),
                label: const Text('Regenerate Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],

            const SizedBox(height: 40),
            _buildInfoCard(book, buyer),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(RecordModel book, RecordModel buyer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildInfoRow('Book', book.get<String>('title')),
          const Divider(height: 24),
          _buildInfoRow('Price', '₹${_txn!.get<int>('agreed_price')}'),
          const Divider(height: 24),
          _buildInfoRow('Buyer', buyer.get<String>('name')),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
