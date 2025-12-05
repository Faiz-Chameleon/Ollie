import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:octagon/model/post_model.dart';

class Posts with ChangeNotifier {
  List<PostModel> _postList = [
    PostModel(
      //dateTime: DateTime.now(),
      mediaUrl:
          "https://images.unsplash.com/photo-1516705346105-1604914311cc?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1000&q=80",
      username: "rinku_s",
      description: "nice weather indeed!",
    ),
    PostModel(
      //dateTime: DateTime.now(),
      mediaUrl:
          "https://pbs.twimg.com/profile_images/1003539736152031233/lsCeD5pq_400x400.jpg",
      username: "utpal_barman",
      description: "nice weather indeed!",
    ),
    PostModel(
      //dateTime: DateTime.now(),
      mediaUrl:
          "https://media.geeksforgeeks.org/wp-content/uploads/first_run_vscode_gfg.png",
      username: "_utpal_",
      description: "i love to do some coding",
    ),
  ];

  List<PostModel> get postList => [..._postList];



  Future<void> fetchAndSetData() async {
    try {
      /*final url =
          "https://photome-16521.firebaseio.com/posts.json?auth=$_authToken";

      final response = await http.get(Uri.parse(url));
*/
      final List<PostModel> loadedData = [];

      final extractedData = postList as Map<String, dynamic>;

      print(extractedData);

      extractedData.forEach(
            (id, dynamicData) => loadedData.add(
          PostModel(
            //timestamp: null,
            mediaUrl: dynamicData["imgUrl"],
            username: dynamicData["name"],
            description: dynamicData["post"],
          ),
        ),
      );
      _postList = loadedData;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> writeData() async {
    const url = "https://photome-16521.firebaseio.com/posts.json";

    await http.post(Uri.parse(url),
        body: json.encode({
          'imgUrl':
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ_1QxBTLmtXdVh2WuTOmFycAxVqQ9Do8xRXOz5sNjDWy6kfkb3&s",
          'name': "utpal_s",
          'post': "flutter is awesome",
        }));

    notifyListeners();
  }
}