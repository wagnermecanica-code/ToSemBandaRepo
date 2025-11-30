// Search Service - Handles address search and suggestions
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class SearchService {
  Future<List<Map<String, dynamic>>> fetchAddressSuggestions(
    String query,
  ) async {
    if (query.isEmpty) return [];
    
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5',
    );
    
    final response = await http.get(
      url,
      headers: {'User-Agent': 'to-sem-banda-app'},
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data
          .map<Map<String, dynamic>>((item) => item as Map<String, dynamic>)
          .toList();
    }
    
    return [];
  }

  LatLng? parseAddressCoordinates(Map<String, dynamic> suggestion) {
    final lat = double.tryParse(suggestion['lat']?.toString() ?? '');
    final lon = double.tryParse(suggestion['lon']?.toString() ?? '');
    
    if (lat != null && lon != null && lat != 0.0 && lon != 0.0) {
      return LatLng(lat, lon);
    }
    
    return null;
  }

  String? getDisplayName(Map<String, dynamic> suggestion) {
    return suggestion['display_name'] as String?;
  }
}
