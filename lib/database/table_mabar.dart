import 'package:uts_backend/database/database_service.dart';
import 'package:uts_backend/model/mabar_model.dart'; 

class TableMabar {
  ApiService dbService = ApiService();

  Future<List<MabarModel>> getAll() async {
    try {
      final result = await dbService.getMabarList();
      
      if (result['success'] == true) {
        final List<dynamic> data = result['data'];
        return data.map((e) => MabarModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load mabar: ${result['message']}');
      }
    } catch (e) {
      throw Exception('Error fetching mabar: $e');
    }
  }
}