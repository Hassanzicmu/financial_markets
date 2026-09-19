import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bank_rate.dart';

class BankRatesService {
  // Use your computer's local IP address if testing on a physical Android device.
  // For iOS Simulator or macOS, localhost works fine.
  static const String baseUrl = 'http://192.168.1.4:3000/api/rates';

  Future<List<BankRate>> fetchBankRates(String countryCode) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$countryCode'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> banksJson = data['banks'];
          return banksJson.map((json) => BankRate.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load rates: ${data['error']}');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch bank rates: $e');
    }
  }
}
