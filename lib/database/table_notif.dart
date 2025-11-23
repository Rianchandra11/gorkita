import 'package:uts_backend/database/database_service.dart';
import 'package:uts_backend/model/notification_model.dart';

class TableNotif {
  ApiService dbService = ApiService();

  Future<List<NotificationModel>> getAll() async {
    try {
      final result = await dbService.getNotifications();
      
      if (result['success'] == true) {
        final List<dynamic> data = result['data'];
        return data.map((e) => NotificationModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load notifications: ${result['message']}');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      final result = await dbService.deleteNotification(id);
      
      if (result['success'] != true) {
        throw Exception('Failed to delete notification: ${result['message']}');
      }
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }
}