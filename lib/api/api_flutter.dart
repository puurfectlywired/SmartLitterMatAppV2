import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiFlutter {
  
  static const String baseUrl = 'http://172.20.10.10:5000/';
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

//get current LED status
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


  //tell pi to turn LED on/off
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