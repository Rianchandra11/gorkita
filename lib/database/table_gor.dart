import 'package:uts_backend/database/database_service.dart';
import 'package:uts_backend/model/venue_model.dart';

class TableGor {
  ApiService dbService = ApiService();

    Future<List<VenueModel>> getAll() async {
    try {
      final result = await dbService.getVenues();
      
      if (result['success'] == true) {
        final List<dynamic> data = result['data'];
        return data.map((e) => VenueModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load venues: ${result['message']}');
      }
    } catch (e) {
      throw Exception('Error fetching venues: $e');
    }
  }
}
