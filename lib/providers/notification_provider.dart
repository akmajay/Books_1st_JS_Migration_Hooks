import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../services/pocketbase_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../controllers/paginated_controller.dart';

class NotificationProvider extends ChangeNotifier {
  final PocketBase _pb = PocketBaseService.instance.pb;
  final AuthService _auth = AuthService();
  
  late final PaginatedController<RecordModel> _controller;
  PaginatedController<RecordModel> get controller => _controller;

  List<RecordModel> get notifications => _controller.items;
  
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;
  
  bool get isLoading => _controller.isLoading;

  StreamSubscription? _subscription;

  NotificationProvider() {
    _initController();
    if (_auth.isLoggedIn) {
      _controller.loadInitial().then((_) => _updateUnreadCount());
      _subscribe();
    }
    _auth.addListener(_onAuthChanged);
  }

  void _initController() {
    _controller = PaginatedController<RecordModel>(
      fetcher: (page, perPage) => _pb.collection('notifications').getList(
        page: page,
        perPage: perPage,
        filter: 'user = "${_auth.currentUser?.id}"',
        sort: '-created',
      ),
      mapper: (record) => record,
    );
  }

  void _onAuthChanged() {
    if (_auth.isLoggedIn) {
      _controller.loadInitial().then((_) => _updateUnreadCount());
      _subscribe();
      NotificationService.instance.updateToken();
    } else {
      _unsubscribe();
      _controller.loadInitial(); // Clear items
      _unreadCount = 0;
      notifyListeners();
    }
  }

  Future<void> fetchNotifications() async {
    await _controller.loadInitial();
    _updateUnreadCount();
  }

  void _subscribe() {
    _subscription?.cancel();
    _pb.collection('notifications').subscribe('*', (e) {
      if (e.action == 'create' && e.record?.get('user') == _auth.currentUser?.id) {
        _controller.insertAtTop(e.record!);
        if (!e.record!.getBoolValue('is_read')) {
          _unreadCount++;
          notifyListeners();
        }
      } else if (e.action == 'update' && e.record?.get('user') == _auth.currentUser?.id) {
        // Find and replace in controller
        // Note: PaginatedController might need an updateItem method if not present
        // But for now we just refresh count if is_read changed
        _updateUnreadCount();
      }
    });
  }

  void _unsubscribe() {
    _pb.collection('notifications').unsubscribe('*');
    _subscription?.cancel();
  }

  Future<void> markAsRead(String notifId) async {
    try {
      await _pb.collection('notifications').update(notifId, body: {'is_read': true});
      _updateUnreadCount();
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final unread = notifications.where((n) => !n.getBoolValue('is_read')).toList();
    if (unread.isEmpty) return;

    try {
      for (var n in unread) {
        await _pb.collection('notifications').update(n.id, body: {'is_read': true});
      }
      await _controller.refresh();
      _updateUnreadCount();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  void _updateUnreadCount() {
    _unreadCount = notifications.where((n) => !n.getBoolValue('is_read')).length;
    notifyListeners();
  }

  @override
  void dispose() {
    _unsubscribe();
    _auth.removeListener(_onAuthChanged);
    _controller.dispose();
    super.dispose();
  }
}
