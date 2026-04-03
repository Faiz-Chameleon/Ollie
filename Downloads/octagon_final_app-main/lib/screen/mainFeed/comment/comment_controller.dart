import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:octagon/model/post_response_model.dart';
import 'package:octagon/model/user_data_model.dart';
import 'package:octagon/screen/mainFeed/bloc/post_repo.dart';

class CommentController extends GetxController {
  final postRepo = PostRepository();

  var postData = Rxn<PostResponseModelData>();
  var usersList = <Users>[].obs;
  var isLoading = false.obs;
  dynamic myId;
  String? _loadedPostKey;

  final commentTextController = Rx<TextEditingController>(TextEditingController());
  final replyTextController = Rx<TextEditingController>(TextEditingController());

  void loadPostDetails(String postId, String type, {bool force = false}) async {
    final requestKey = "$postId-$type";
    if (!force && _loadedPostKey == requestKey && postData.value != null) {
      return;
    }

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
        data.comments = _normalizeComments(data.comments ?? []);
        postData.value = data;
        _loadedPostKey = requestKey;
        usersList.clear();

        for (final comment in data.comments ?? <SuccessComment>[]) {
          _collectUsers(comment);
        }
      }
    }
  }

  List<SuccessComment> _normalizeComments(List<SuccessComment> comments) {
    final orderedComments = <SuccessComment>[];
    final commentsById = <int, SuccessComment>{};

    void collect(List<SuccessComment> source) {
      for (final comment in source) {
        final nestedComments = List<SuccessComment>.from(comment.comments ?? const <SuccessComment>[]);
        final commentId = comment.id;

        if (commentId != null && commentsById.containsKey(commentId)) {
          final existingComment = commentsById[commentId]!;
          existingComment.userId ??= comment.userId;
          existingComment.postId ??= comment.postId;
          existingComment.comment ??= comment.comment;
          existingComment.parentCommentId ??= comment.parentCommentId;
          existingComment.createdAt ??= comment.createdAt;
          existingComment.users ??= comment.users;
        } else {
          comment.comments = <SuccessComment>[];
          if (commentId != null) {
            commentsById[commentId] = comment;
          }
          orderedComments.add(comment);
        }

        if (nestedComments.isNotEmpty) {
          collect(nestedComments);
        }
      }
    }

    collect(comments);

    final rootComments = <SuccessComment>[];
    for (final comment in orderedComments) {
      final parentId = comment.parentCommentId;
      if (parentId != null && parentId != 0 && commentsById.containsKey(parentId)) {
        commentsById[parentId]!.comments ??= <SuccessComment>[];
        commentsById[parentId]!.comments!.add(comment);
      } else {
        rootComments.add(comment);
      }
    }

    return rootComments;
  }

  void _collectUsers(SuccessComment comment) {
    if (comment.users != null && !usersList.any((user) => user.id == comment.users!.id)) {
      usersList.add(comment.users!);
    }

    for (final child in comment.comments ?? <SuccessComment>[]) {
      _collectUsers(child);
    }
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
      parentId: parentId,
    );

    loadPostDetails(postId, postData.value?.type ?? "0", force: true);
  }

  Future<void> deleteComment(String commentId) async {
    await postRepo.deleteComment(commentId);
    loadPostDetails(postData.value!.id!.toString(), postData.value!.type ?? "0", force: true);
  }
}
