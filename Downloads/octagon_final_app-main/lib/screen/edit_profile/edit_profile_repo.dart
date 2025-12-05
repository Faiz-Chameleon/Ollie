import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:octagon/utils/constants.dart';
import '../../model/user_data_model.dart';
import '../../model/edit_profile_response_model.dart';

class EditProfileRepo {
  final String baseUrl = 'http://3.134.119.154/api/';

  Future<EditProfileResponseModel> fetchUserDetails(String userId, String token) async {
    final response = await http.post(
      Uri.parse('${baseUrl}user-details'),
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {'user_id': userId},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return EditProfileResponseModel.fromJson(data['success']);
    } else {
      throw Exception('Failed to fetch user: ${response.statusCode}');
    }
  }

  Future<EditProfileResponseModel> updateProfile(String token, Map<String, String> fields, {File? photoFile, File? backgroundFile}) async {
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}user-update'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);
    if (photoFile != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', photoFile.path));
    }
    if (backgroundFile != null) {
      request.files.add(await http.MultipartFile.fromPath('background', backgroundFile.path));
    }
    var response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);
      return EditProfileResponseModel.fromJson(data);
    } else {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
  }
}
