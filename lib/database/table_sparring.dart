import 'package:uts_backend/database/database_service.dart';
import 'package:uts_backend/model/sparring_model.dart';

class TableSparring {
  ApiService dbService = ApiService();

  Future<List<SparringModel>> getAll() async {
    try {
      final result = await dbService.getSparring();
      
      if (result['success'] == true) {
        final List<dynamic> data = result['data'];
        await Future.delayed(Duration(seconds: 3)); 
        return data.map((e) => SparringModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load sparring: ${result['message']}');
      }
    } catch (e) {
      throw Exception('Error fetching sparring: $e');
    }
  }
}