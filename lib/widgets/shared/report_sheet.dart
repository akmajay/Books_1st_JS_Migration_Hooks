import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/pocketbase_service.dart';
import 'package:http/http.dart' as http;

/// Report reasons by type.
const Map<String, List<String>> _reportReasons = {
  'book': [
    'Inappropriate content',
    'Spam / fake listing',
    'Wrong category',
    'Misleading photos',
    'Overpriced',
    'Scam',
  ],
  'user': [
    'Harassment',
    'Scam / fraud',
    'Fake profile',
    'Inappropriate behavior',
    'Spam messaging',
  ],
  'message': [
    'Harassment',
    'Spam',
    'Inappropriate content',
    'Threats',
    'Scam attempt',
  ],
  'transaction': [
    'Book not as described',
    'No-show',
    'Wrong book delivered',
    'Scam',
  ],
};

/// Shows a reusable report bottom sheet for [targetType] and [targetId].
Future<void> showReportSheet(
  BuildContext context, {
  required String targetType,
  required String targetId,
}) async {
  final auth = AuthService();
  if (!auth.isLoggedIn) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please sign in to report.')),
    );
    return;
  }

  // Block self-reporting for users
  if (targetType == 'user' && targetId == auth.currentUser?.id) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You cannot report yourself.')),
    );
    return;
  }

  // Duplicate guard
  final pb = PocketBaseService.instance.pb;
  try {
    final existing = await pb.collection('reports').getList(
      page: 1,
      perPage: 1,
      filter: 'reporter = "${auth.currentUser!.id}" && target_type = "$targetType" && target_id = "$targetId"',
    );
    if (existing.totalItems > 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You\'ve already reported this.')),
        );
      }
      return;
    }
  } catch (_) {}

  if (!context.mounted) return;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _ReportSheetContent(
      targetType: targetType,
      targetId: targetId,
    ),
  );
}

class _ReportSheetContent extends StatefulWidget {
  final String targetType;
  final String targetId;
  const _ReportSheetContent({required this.targetType, required this.targetId});

  @override
  State<_ReportSheetContent> createState() => _ReportSheetContentState();
}

class _ReportSheetContentState extends State<_ReportSheetContent> {
  String? _selectedReason;
  final _detailsController = TextEditingController();
  XFile? _evidence;
  bool _isSubmitting = false;

  List<String> get _reasons => _reportReasons[widget.targetType] ?? [];
  String get _typeLabel {
    switch (widget.targetType) {
      case 'book': return 'Book';
      case 'user': return 'User';
      case 'message': return 'Message';
      case 'transaction': return 'Transaction';
      default: return 'Content';
    }
  }

  Future<void> _pickEvidence() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 1024);
    if (file != null) setState(() => _evidence = file);
  }

  Future<void> _submit() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final pb = PocketBaseService.instance.pb;
      final auth = AuthService();

      final body = <String, dynamic>{
        'reporter': auth.currentUser!.id,
        'target_type': widget.targetType,
        'target_id': widget.targetId,
        'reason': _selectedReason!,
        'details': _detailsController.text.trim(),
        'status': 'pending',
      };

      final files = <http.MultipartFile>[];
      if (_evidence != null) {
        files.add(await http.MultipartFile.fromPath('evidence', _evidence!.path));
      }

      await pb.collection('reports').create(body: body, files: files);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for reporting. We\'ll review this within 24 hours.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Report $_typeLabel',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Help us keep JayGanga Books safe. Select a reason below.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Reason Radio List
            Text('Reason *', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...List.generate(_reasons.length, (i) {
              final reason = _reasons[i];
              final isSelected = _selectedReason == reason;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.red : Colors.grey,
                  size: 22,
                ),
                title: Text(reason, style: const TextStyle(fontSize: 14)),
                onTap: () => setState(() => _selectedReason = reason),
              );
            }),

            const SizedBox(height: 16),

            // Details
            Text('Additional Details', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _detailsController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Tell us more about the issue...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 12),

            // Evidence
            Row(
              children: [
                Text('Evidence (optional)', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _pickEvidence,
                  icon: const Icon(Icons.attach_file, size: 18),
                  label: Text(_evidence != null ? 'Change' : 'Attach Photo'),
                ),
              ],
            ),
            if (_evidence != null)
              Chip(
                label: Text(_evidence!.name, style: const TextStyle(fontSize: 12)),
                onDeleted: () => setState(() => _evidence = null),
              ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
