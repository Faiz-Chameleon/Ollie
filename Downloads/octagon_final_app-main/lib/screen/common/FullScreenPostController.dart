import 'package:get/get.dart';
import 'package:octagon/model/post_response_model.dart';
import 'package:octagon/networking/model/resource.dart';
import 'package:octagon/screen/mainFeed/bloc/post_repo.dart';

class FullScreenPostController extends GetxController {
  final PostRepository _repo = PostRepository();
  final Rxn<PostResponseModelData> postData = Rxn<PostResponseModelData>();
  final RxBool isLoading = false.obs;

  Future<void> fetchPostDetails(String postId, String type) async {
    try {
      isLoading.value = true;
      final Resource result = await _repo.getPostDetailsByParams(postId: postId, type: type);
      if (result.data != null) {
        postData.value = result.data.successForCreatePost!;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
