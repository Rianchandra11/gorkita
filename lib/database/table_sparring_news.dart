import 'package:uts_backend/database/database_service.dart';
import 'package:uts_backend/model/sql_model/sparring_news_model.dart';

class TableSparringNews {
  ApiService dbService = ApiService();

  Future<List<SparringNewsModel>> getAll() async {
    try {
      final result = await dbService.getSparringNews();

      if (result['success'] == true) {
        final List<dynamic> data = result['data'];
        await Future.delayed(Duration(seconds: 3));
        return data.map((e) => SparringNewsModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load sparring news: ${result['message']}');
      }
    } catch (e) {
      throw Exception('Error fetching sparring news: $e');
    }
  }
}
