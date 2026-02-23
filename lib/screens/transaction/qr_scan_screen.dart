import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';
import '../../services/transaction_service.dart';

class QrScanScreen extends StatefulWidget {
  final String transactionId;
  const QrScanScreen({super.key, required this.transactionId});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final TransactionService _txnService = TransactionService();
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  bool _isProcessing = false;
  bool _showSuccess = false;
  bool _isCameraDenied = false;

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _showSuccess) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        debugPrint('Barcode found! $code');
        try {
          final data = jsonDecode(code);
          if (data['txn_id'] == widget.transactionId) {
            _verify(data['token']);
          } else {
            _showError('This QR code is for a different transaction.');
          }
        } catch (e) {
          // If not JSON, maybe it's the raw token?
          _verify(code);
        }
      }
    }
  }

  Future<void> _verify(String token) async {
    setState(() => _isProcessing = true);
    try {
      await _txnService.verifyHandover(widget.transactionId, token);
      setState(() {
        _isProcessing = false;
        _showSuccess = true;
      });
      _confettiController.play();
    } catch (e) {
      setState(() => _isProcessing = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) return _buildSuccessView();

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Handover Code')),
      body: Stack(
        children: [
          _isCameraDenied ? _buildManualEntry() : _buildScanner(),
          if (_isProcessing)
            Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              MobileScanner(
                onDetect: _onDetect,
              ),
              _buildOverlay(),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              children: [
                const Text('Point your camera at the seller\'s QR code', textAlign: TextAlign.center),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() => _isCameraDenied = true),
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Enter code manually'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 4),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _buildManualEntry() {
    final controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.vpn_key_outlined, size: 64, color: Colors.blue),
          const SizedBox(height: 24),
          const Text('Camera access denied or unavailable', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Please enter the handover code provided by the seller manually.', textAlign: TextAlign.center),
          const SizedBox(height: 32),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Handover Code',
              border: OutlineInputBorder(),
              hintText: 'Enter 32-character code',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _verify(controller.text.trim()),
              child: const Text('Confirm Handover'),
            ),
          ),
          TextButton(onPressed: () => setState(() => _isCameraDenied = false), child: const Text('Try Camera Again')),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 100, color: Colors.green),
                const SizedBox(height: 24),
                const Text('Handover Confirmed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text(
                  'The transaction is now complete. The book is officially yours!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => context.pushReplacement('/transaction/${widget.transactionId}/review'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: const Text('Leave a Review', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
