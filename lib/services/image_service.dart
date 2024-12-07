import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageService {
  final String apiUrl = 'https://lexica.art/api/v1/search?q=';

  Future<String?> fetchImage(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['images'];
        if (results.isNotEmpty) {
          return results[0]['src'];
        }
      } else {
        print('Erro ao buscar imagem: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      print('Erro ao buscar imagem: $e');
      return null;
    }
  }
}
