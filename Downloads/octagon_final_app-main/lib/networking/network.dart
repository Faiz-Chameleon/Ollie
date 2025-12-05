import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:octagon/networking/exception/exception.dart';
import 'package:octagon/screen/common/create_post_controller.dart';

import 'package:octagon/utils/constants.dart';

//This Class is not complete, under modification

class NetworkAPICall {
  /// baseURL Containse Main URL of Api call.
  static final NetworkAPICall _networkAPICall = NetworkAPICall._internal();

  factory NetworkAPICall() {
    return _networkAPICall;
  }

  NetworkAPICall._internal();

  ///multipart api
  Future<dynamic> multiPartPostRequest(String url, dynamic body, bool isToken, String type) async {
    var client = http.Client();
    try {
      var header = isToken
          ? {
              // 'Content-Type': 'application/json',
              'Authorization': 'Bearer ${getUserToken()}'
            }
          : {
              'Content-Type': 'application/json',
            };
      log(" multipart url $url");
      var request = http.MultipartRequest(type, Uri.parse(baseUrl + url));

      request.headers.addAll(header);

      body.forEach((key, value) {
        if (key.toString() != "photoKey" && key.toString().startsWith("photo")) {
          if (value != null) {
            request.files.add(value);
          }
        } else {
          request.fields["$key"] = value.toString();
        }
      });
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));

      var response = await http.Response.fromStream(streamedResponse);

      /// if (response.statusCode == 200) {
      print(response.body);
      return checkResponse(response, url: url);

      /// } else {
      ///   print(response.reasonPhrase);
      /// }
    } catch (exception) {
      client.close();
      rethrow;
    }
  }

  Future<dynamic> getLiveData(String sportsType) async {
    var responseJson;
    try {
      var response;

      response = await http.get(Uri.parse("https://livescore6.p.rapidapi.com/matches/v2/list-live?Category=$sportsType"),
          headers: {HttpHeaders.contentTypeHeader: "application/json", "X-RapidAPI-Key": "3dbff851cemsh5e01b9da5e4ff25p1e63d4jsn06dc492f3ac1"});

      print(response.request);
      responseJson = response.body.toString();
    } on SocketException {
      throw AppException.exceptionHandler("No Internet connection");
    }
    return responseJson;
  }

  Future<dynamic> createPostRequest(String url, dynamic body, bool isToken, String type) async {
    var client = http.Client();
    try {
      var header = isToken
          ? {
              // 'Content-Type': 'application/json',
              'Authorization': 'Bearer ${getUserToken()}'
            }
          : {
              'Content-Type': 'application/json',
            };

      print('Headers: $header');

      var request = http.MultipartRequest(type, Uri.parse(baseUrl + url));

      request.headers.addAll(header);

      if (body["title"].isNotEmpty) {
        request.fields["title"] = body["title"].toString();
      }
      if (body["post"].isNotEmpty) {
        request.fields["post"] = body["post"].toString();
      }
      if (body["type"].toString().isNotEmpty) {
        request.fields["type"] = body["type"].toString();
      }
      if (body["location"].isNotEmpty) {
        request.fields["location"] = body["location"].toString();
      }
      if (body["comment"].toString().isNotEmpty) {
        // Convert integer to boolean: 1 = true, 0 = false
        final commentValue = body["comment"] == 1 || body["comment"] == true;
        request.fields["comment"] = commentValue ? "1" : "0";
      }

      print('Request fields: ${request.fields}');
      // request.fields["tag_people"] = postTitle;

      try {
        if (body["photo[]"] != null && body["photo[]"].isNotEmpty) {
          print('Processing photos: ${body["photo[]"].length}');
          Future<List<http.MultipartFile>> convert(List<dynamic> files, String field) async {
            List<http.MultipartFile> multipartFiles = [];

            for (var file in files) {
              String path = file is String ? file : file.filePath; // support List<String> or List<CustomFile>
              multipartFiles.add(await http.MultipartFile.fromPath(field, path));
            }

            return multipartFiles;
          }
        }

        if (body["video[]"] != null && body["video[]"].isNotEmpty) {
          print('Processing videos: ${body["video[]"].length}');
          List<http.MultipartFile> data = await convert(body["video[]"].toList(), "video[]");
          request.files.addAll(data);
          print('Added ${data.length} video files');
        }
      } catch (e) {
        print('Error processing files: $e');
      }

      print('Total files to upload: ${request.files.length}');

      final streamedResponse = await request.send().timeout(const Duration(minutes: 2));

      var response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      /// if (response.statusCode == 200) {
      ///  print(response.body);
      final result = checkResponse(response, url: url);
      print('=== CREATE POST REQUEST END ===');
      return result;

      /// } else {
      ///   print(response.reasonPhrase);
      /// }
    } catch (exception) {
      print('=== CREATE POST REQUEST ERROR ===');
      print('Exception: $exception');
      client.close();
      rethrow;
    }
  }

  Future<dynamic> editProfileApi(String url, dynamic body, bool isToken, String type) async {
    var client = http.Client();
    try {
      var header = isToken
          ? {
              // 'Content-Type': 'application/json',
              'Authorization': 'Bearer ${getUserToken()}'
            }
          : {
              'Content-Type': 'application/json',
            };

      var request = http.MultipartRequest(type, Uri.parse(baseUrl + url));
      request.headers.addAll(header);

      if (body["name"] != null && body["name"].isNotEmpty) {
        request.fields["name"] = body["name"].toString();
      }
      if (body["bio"] != null && body["bio"].isNotEmpty) {
        request.fields["bio"] = body["bio"];
      }
      if (body["dob"] != null && body["dob"].isNotEmpty) {
        request.fields["dob"] = body["dob"];
      }
      if (body["country"] != null && body["country"].isNotEmpty) {
        request.fields["country"] = body["country"];
      }
      if (body["bgPic"] != null && body["bgPic"].isNotEmpty && !"${body["bgPic"]}".contains("http")) {
        request.files.add(await http.MultipartFile.fromPath('background', body["bgPic"]));
      }
      if (body["profilePic"] != null && body["profilePic"].isNotEmpty && !"${body["profilePic"]}".contains("http")) {
        request.files.add(await http.MultipartFile.fromPath('photo', body["profilePic"]));
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      ;

      var response = await http.Response.fromStream(streamedResponse);

      /// if (response.statusCode == 200) {
      ///  print(response.body);
      return checkResponse(response, url: url);

      /// } else {
      ///   print(response.reasonPhrase);
      /// }
    } catch (exception) {
      client.close();
      rethrow;
    }
  }

  Future<List<http.MultipartFile>> convert(List<PostFile> files, String fileName) async {
    List<http.MultipartFile> multipartImageList = <http.MultipartFile>[];
    if (files.isNotEmpty) {
      for (PostFile imagePath in files) {
        print('Trying to add file: \\${imagePath.filePath}');
        if (imagePath.filePath.isNotEmpty && await File(imagePath.filePath).exists()) {
          http.MultipartFile data = await http.MultipartFile.fromPath(fileName, imagePath.filePath);
          multipartImageList.add(data);
          print('Added file: \\${imagePath.filePath}');
        } else {
          print('File does not exist or path is empty: \\${imagePath.filePath}');
        }
      }
    }
    return multipartImageList;
  }

  Future<dynamic> uploadFile({int postType = 0, List<PostFile>? file}) async {
    var client = http.Client();
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl + uploadFileApiUrl));
      request.headers.addAll({
        'Accept': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
        "Authorization": "Bearer ${getUserToken()}",
      });

      request.fields["type"] = "$postType";

      try {
        if (file != null && file.isNotEmpty) {
          List<http.MultipartFile> data = await convert(file.toList(), "files");
          request.files.addAll(data);
        }
      } catch (e) {
        print(e);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return checkResponse(response, url: uploadFileApiUrl);
    } catch (exception) {
      client.close();
      rethrow;
    }
  }

  ///get api
  Future<dynamic> getApiCall(String apiUrl, {bool isToken = true}) async {
    final client = http.Client();
    try {
      Map<String, String> header;
      header = isToken
          ? {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${getUserToken()}' /*${getFCMToken()}*/
            }
          : {'Content-Type': 'application/json'};

      var uri = Uri.parse(baseUrl + apiUrl);
      var response = await client.get(uri, headers: header).timeout(const Duration(seconds: 30));

      return checkResponse(response, url: apiUrl);
    } catch (exception) {
      client.close();
      throw AppException.exceptionHandler(exception);
    }
  }

  ///post api
  Future<dynamic> postApiCall(
    String apiName,
    dynamic request, {
    bool isToken = true,
  }) async {
    var client = http.Client();
    try {
      Map<String, String> header;
      dynamic postBodyRequest;

      header = isToken ? {'Content-Type': 'application/json', 'Authorization': 'Bearer ${getUserToken()}'} : {'Content-Type': 'application/json'};

      /// postBodyRequest -> Declared request Parameter to send in API calling.
      /// This is basically comes from repository file while call API
      postBodyRequest = json.encode(request);
      log(" post url $apiName");
      var response = await http.post(Uri.parse("$baseUrl$apiName"), body: postBodyRequest, headers: header).timeout(const Duration(seconds: 30));
      log(response.statusCode.toString(), name: 'Response statusCode');
      return checkResponse(response, url: apiName);
    } catch (exception) {
      client.close();
      throw AppException.exceptionHandler(exception);
    }
  }

  ///put api
  Future<dynamic> putApiCall(
    String apiName,
    dynamic request, {
    bool isToken = true,
  }) async {
    var client = http.Client();
    try {
      Map<String, String> header;
      dynamic postBodyRequest;

      header = isToken ? {'Content-Type': 'application/json', 'Authorization': 'Bearer ${getUserToken()}'} : {'Content-Type': 'application/json'};

      /// postBodyRequest -> Declared request Parameter to send in API calling.
      /// This is basically comes from repository file while call API
      /*isDecoded
          ?*/
      postBodyRequest = json.encode(request);
      /*: postBodyRequest = request;*/

      var response = await http.put(Uri.parse(baseUrl + apiName), body: postBodyRequest).timeout(const Duration(seconds: 30));
      log(response.statusCode.toString(), name: 'Response statusCode');
      return checkResponse(response, url: apiName);
    } catch (exception) {
      client.close();
      throw AppException.exceptionHandler(exception);
    }
  }

  Future<dynamic> uploadFileWithFields({
    required String url,
    required Map<String, String> fields,
    required String fileKey,
    http.MultipartFile? file,
    bool isTokenRequired = true,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(baseUrl + url));

    if (isTokenRequired) {
      request.headers['Authorization'] = 'Bearer ${getUserToken()}';
    }

    request.fields.addAll(fields);

    if (file != null) {
      request.files.add(http.MultipartFile(fileKey, file.finalize(), file.length, filename: file.filename));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return checkResponse(response, url: url);
  }

  dynamic checkResponse(http.Response response, {required String? url}) {
    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          var json = jsonDecode(utf8.decode(response.body.toString().codeUnits));
          var jsonz = jsonDecode(response.body);
          log("Response:---> $url--- $jsonz");
          if (json is List<dynamic>) {
            return json;
          }
          if (json['status'] == 'error') {
            throw AppException(message: json['message'], errorCode: response.statusCode);
          }
          return jsonz;
        } catch (e, stackTrace) {
          throw AppException.exceptionHandler(e, stackTrace);
        }
      case 400:
        var json = jsonDecode(response.body);
        throw AppException(message: json['message'], errorCode: json['statusCode']);
      case 404:
        var json = jsonDecode(response.body);

      // throw AppException(
      //     message: json['message'], errorCode: json['statusCode']);
      case 409:
        var json = jsonDecode(response.body);
        throw AppException(message: json['message'], errorCode: json['statusCode']);
      case 401:
        throw AppException(
          message: "unauthorized",
          errorCode: response.statusCode,
        );
      case 422:
        throw AppException(
            message: "Looks like our server is down for maintenance,"
                r'''\n\n'''
                "Please try again later.",
            errorCode: response.statusCode);
      case 500:
      case 502:
        // var json = jsonDecode(response.body);
        // throw AppException(
        //     message: "Looks like our server is down for maintenance,"
        //         r'''\n\n'''
        //         "Please try again later.",
        //     errorCode: response.statusCode);
        // Added detailed error logging for debugging 500 errors
        print("[ERROR 500] URL: $url");
        print("[ERROR 500] Status Code: " + response.statusCode.toString());
        print("[ERROR 500] Response Body: " + response.body);
        throw AppException(message: "Server error 500. Raw response: ${response.body}", errorCode: response.statusCode);
      default:
        throw AppException(
            message: "Unable to communicate with the server at the moment."
                r'''\n\n'''
                "Please try again later",
            errorCode: response.statusCode);
    }
  }

  // Fetch group members with group_id in form data (POST)
  Future<Map<String, dynamic>> getGroupMembers(String groupId) async {
    final url = Uri.parse("${baseUrl}groups-member-get");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${getUserToken()}',
          // 'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'group_id': groupId},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load members: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Remove a group member
  Future<dynamic> removeMember({required int userId, required int groupId}) async {
    final url = Uri.parse('${baseUrl}groups-member-delete');
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer ${getUserToken()}';
      request.fields['user_id'] = userId.toString();
      request.fields['group_id'] = groupId.toString();
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to remove member: \\${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Fetch users for invite (not in group)
  Future<List<dynamic>> getUsersForGroupInvite(String groupId) async {
    final url = Uri.parse('${baseUrl}user-groups-list');
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer ${getUserToken()}';
      request.fields['group_id'] = groupId;
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != null && data['success'] is List) {
          return data['success'];
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to fetch users: \\${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Invite a user to the group
  Future<dynamic> inviteUserToGroup({required String groupId, required int userId}) async {
    final url = Uri.parse('${baseUrl}groups-member-create');
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer ${getUserToken()}';
      request.fields['group_id'] = groupId;
      request.fields['user_id'] = userId.toString();
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to invite user: \\${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
