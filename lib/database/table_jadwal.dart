import 'package:uts_backend/database/database_service.dart';
import 'package:uts_backend/model/jadwal_model.dart';

class TableJadwal {
  ApiService dbService = ApiService();
 

  Future<List<JadwalModel>> getAll() async {
    try {
      final result = await dbService.getAllJadwal();
      
      if (result['success'] == true) {
        final List<dynamic> data = result['data'];
        return data.map((e) => JadwalModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load jadwal: ${result['message']}');
      }
    } catch (e) {
      throw Exception('Error fetching jadwal: $e');
    }
  }


}
