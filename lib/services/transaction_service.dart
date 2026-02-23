import 'dart:convert';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'pocketbase_service.dart';
import 'auth_service.dart';
import '../config/env.dart';

class TransactionService {
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

  PocketBase get _pb => PocketBaseService.instance.pb;

  /// Fetch a single transaction by ID
  Future<RecordModel> getTransaction(String id) async {
    return await _pb.collection('transactions').getOne(id, expand: 'book,buyer,seller');
  }

  /// Fetch my transactions (paginated)
  Future<ResultList<RecordModel>> getMyTransactions({int page = 1, int perPage = 20}) async {
    final userId = AuthService().currentUser?.id;
    if (userId == null) return ResultList(items: [], page: 1, perPage: perPage, totalItems: 0, totalPages: 0);

    return await _pb.collection('transactions').getList(
      page: page,
      perPage: perPage,
      filter: 'buyer = "$userId" || seller = "$userId"',
      sort: '-created',
      expand: 'book,buyer,seller',
    );
  }

  /// Initiate transaction (called on seller accepting offer)
  Future<RecordModel> initiateTransaction({
    required String chatId,
    required String bookId,
    required String buyerId,
    required String sellerId,
    required int amount,
  }) async {
    final data = {
      'chat': chatId,
      'book': bookId,
      'buyer': buyerId,
      'seller': sellerId,
      'agreed_price': amount,
      'status': 'initiated',
    };
    
    final txn = await _pb.collection('transactions').create(body: data);
    
    // Reservation logic handled by transaction_hooks or here manually
    await _pb.collection('books').update(bookId, body: {'status': 'reserved'});
    
    return txn;
  }

  /// Buyer confirms deal -> moves to handover_pending
  Future<void> confirmDeal(String txnId) async {
    await _pb.collection('transactions').update(txnId, body: {
      'status': 'handover_pending',
      'handover_token': '', // Clear to ensure hook triggers or resets
    });
  }

  /// Regenerate token (Seller side)
  Future<void> regenerateToken(String txnId) async {
    await _pb.collection('transactions').update(txnId, body: {
      'handover_token': '',
    });
  }

  /// Verify handover token (QR scan)
  Future<void> verifyHandover(String txnId, String token) async {
    final response = await http.post(
      Uri.parse('${Env.pocketbaseUrl}/api/transactions/$txnId/verify-handover'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': _pb.authStore.token,
      },
      body: jsonEncode({'token': token}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['error'] ?? 'Handover verification failed';
      throw Exception(error);
    }
  }

  /// Submit review
  Future<void> submitReview({
    required String txnId,
    required String reviewedUserId,
    required double rating,
    String? comment,
    List<String>? tags,
  }) async {
    final userId = AuthService().currentUser?.id;
    if (userId == null) throw Exception('Must be logged in to review');

    final data = {
      'reviewer': userId,
      'reviewed_user': reviewedUserId,
      'transaction': txnId,
      'rating': rating,
      'comment': comment ?? '',
      'tags': tags ?? [],
    };

    await _pb.collection('reviews').create(body: data);
  }

  /// Dispute transaction
  Future<void> createDispute(String txnId, String reason) async {
    await _pb.collection('transactions').update(txnId, body: {
      'status': 'disputed',
      'dispute_reason': reason,
    });

    // Create a report record for admin visibility
    await _pb.collection('reports').create(body: {
      'type': 'transaction',
      'target_type': 'transactions',
      'target_id': txnId,
      'reason': reason,
      'sender': AuthService().currentUser?.id,
    });
  }
}
