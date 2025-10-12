import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:peoples_book/model/peoples_details.dart';

abstract class Api {
  static final String _baseUrl = "https://randomuser.me";

  // Fetch multiple random users
  static Future<PeoplesDetail?> getPeople({int results = 10}) async {
    try {
      // Fixed: Removed brackets and added results parameter
      final response = await http.get(
        Uri.parse("$_baseUrl/api?results=$results"),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PeoplesDetail.fromJson(jsonData);
      } else {
        print('Failed to load users: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching users: $e');
      return null;
    }
  }

  // Fetch single random user
  static Future<Results?> getSinglePerson() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/api"));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final peopleDetail = PeoplesDetail.fromJson(jsonData);
        return peopleDetail.results?.first;
      }
      return null;
    } catch (e) {
      print('Error fetching single user: $e');
      return null;
    }
  }
}
