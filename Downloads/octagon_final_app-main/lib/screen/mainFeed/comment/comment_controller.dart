import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:octagon/model/post_response_model.dart';
import 'package:octagon/model/user_data_model.dart';
import 'package:octagon/screen/mainFeed/bloc/post_repo.dart';
import 'package:octagon/networking/model/resource.dart';

class CommentController extends GetxController {
  final postRepo = PostRepository();

  var postData = Rxn<PostResponseModelData>();
  var usersList = <Users>[].obs;
  var isLoading = false.obs;
  var myId;

  final commentTextController = Rx<TextEditingController>(TextEditingController());
  final replyTextController = Rx<TextEditingController>(TextEditingController());

  void loadPostDetails(String postId, String type) async {
    isLoading.value = true;
    myId = GetStorage().read("current_uid") ?? "";

    final response = await postRepo.getPostDetails(
      postId: postId,
      type: type,
    );
    isLoading.value = false;

    if (response.data != null) {
      final data = response.data!.successForCreatePost;
      if (data != null) {
        postData.value = data;
        usersList.clear();

        // Flatten nested comments and extract users
        for (var comment in data.comments ?? []) {
          usersList.addIf(!usersList.contains(comment.users), comment.users!);
          _flattenNestedComments(comment, comment.id);
        }
      }
    }
  }

  void _flattenNestedComments(SuccessComment comment, int? parentId) {
    final nested = <SuccessComment>[];

    void recurse(SuccessComment parent) {
      if (parent.comments != null) {
        for (var child in parent.comments!) {
          child.parentCommentId = parentId;
          child.id = parentId;
          if (!nested.any((e) => e.id == child.id)) {
            nested.add(child);
            usersList.addIf(!usersList.contains(child.users), child.users!);
          }
          if (child.comments != null) {
            recurse(child);
          }
        }
        parent.comments!.addAll(nested);
      }
    }

    recurse(comment);
  }

  void toggleShowReplies(SuccessComment comment) {
    comment.isShowMore = !(comment.isShowMore);
    postData.refresh();
  }

  Future<void> addComment(String postId, String comment, {String? parentId}) async {
    if (comment.trim().isEmpty) return;

    await postRepo.addComment(
      postId: postId,
      comment: comment,
    );

    loadPostDetails(postId, postData.value?.type ?? "0");
  }

  Future<void> deleteComment(String commentId) async {
    await postRepo.deleteComment(commentId);
    loadPostDetails(postData.value!.id!.toString(), postData.value!.type ?? "0");
  }
}
