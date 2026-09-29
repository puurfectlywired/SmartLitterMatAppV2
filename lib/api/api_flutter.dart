import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiFlutter {
  
  static const String baseUrl = 'http://192.168.50.141:5000/';
  static Future<bool> getButtonStatus() async {
    
    final response = await http.get(
      Uri.parse('$baseUrl/status'),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['button_pressed'];
    }
    
    throw Exception('Failed to communicate with Raspberry Pi');
  }

// Get current LED status
  static Future<bool> getLedStatus() async {

    final response = await http.get(
      Uri.parse('$baseUrl/status'),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return data['led_on'];
    }

    throw Exception('Failed to get LED status');
  }


  // Tell Raspberry Pi to turn LED on/off
  static Future<bool> setLed(bool turnOn) async {

    final response = await http.post(
      Uri.parse('$baseUrl/led'),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode({
        'led_on': turnOn,
      }),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return data['led_on'];
    }

    throw Exception('Failed to control LED');
  }
}