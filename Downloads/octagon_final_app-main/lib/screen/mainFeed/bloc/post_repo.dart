import 'package:octagon/model/comment_response_model.dart';
import 'package:octagon/model/favorite_model.dart';
import 'package:octagon/model/file_upload_response_model.dart';
import 'package:octagon/model/follow_model.dart';
import 'package:octagon/model/live_score_data.dart';
import 'package:octagon/model/post_response_model.dart';
import 'package:octagon/model/user_profile_response.dart';
import 'package:octagon/networking/model/request_model/create_post_request.dart';
import 'package:octagon/networking/model/resource.dart';
import 'package:octagon/networking/network.dart';
import 'package:octagon/screen/common/create_post_controller.dart';
import 'package:octagon/screen/common/create_post_screen.dart';
import 'package:octagon/screen/mainFeed/bloc/post_event.dart';
import 'package:octagon/utils/constants.dart';

import '../../../main.dart';
import '../../../model/block_user.dart';

// abstract class IPostRepository {
//   Future getPost(GetPostEvent event);
// }
// class PostRepository implements IPostRepository {
//   static final PostRepository _postRepository = PostRepository._init();

//   factory PostRepository() {
//     return _postRepository;
//   }

//   PostRepository._init();

//   Future getPost(GetPostEvent event)  async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["type"] = "1";
//       body["page_no"] = "1";//emailOrPhone
//       body["limit"] ="50";
//       if(event.isProfile){
//         body["flag"] = "0";
//         body["user_id"] = event.userId.toString()/*storage.read("current_uid")*//*event.userId.toString()*/;
//       }
//       var result = await NetworkAPICall().multiPartPostRequest(getUserPostApiUrl, body, true,"POST");
//       PostResponseModel responseModel = PostResponseModel.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   Future likePost(LikePostEvent event)  async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["content_id"] = event.contentId;
//       body["like"] = event.isLike;//emailOrPhone
//       body["type"] =event.type;
//       var result = await NetworkAPICall().multiPartPostRequest(likeUserPostApiUrl, body, true,"POST");
//       FavoriteResponseModel responseModel = FavoriteResponseModel.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   Future followUser(FollowUserEvent event)  async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["follow_id"] = event.followId;
//       body["follow"] = event.follow;//emailOrPhone

//       var result = await NetworkAPICall().multiPartPostRequest(followUserApiUrl, body, true,"POST");
//       FollowResponseModel responseModel = FollowResponseModel.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   Future removeFollowUser(RemoveFollowUserEvent event)  async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["following_id"] = event.followingId;

//       var result = await NetworkAPICall().multiPartPostRequest(removeFollowerUrl, body, true,"POST");
//       FollowResponseModel responseModel = FollowResponseModel.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   Future savePost(SavePostEvent event)  async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["post_id"] = event.postId;
//       body["save"] = event.save;//emailOrPhone

//       var result = await NetworkAPICall().multiPartPostRequest(saveUserPostApiUrl, body, true,"POST");
//       FavoriteResponseModel responseModel = FavoriteResponseModel.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   Future getPostDetails(GetPostDetailsEvent event)  async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["post_id"] = event.postId;
//       body["type"] = event.type;//emailOrPhone

//       var result = await NetworkAPICall().multiPartPostRequest(getPostDetailsApiUrl, body, true,"POST");
//       PostResponseModel responseModel = PostResponseModel.fromJsonForCreatePost(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   Future addComment(AddCommentEvent event)  async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["post_id"] = event.postId;
//       body["comment"] = event.comment;
//       body["parent_comment_id"] = "0";

//       var result = await NetworkAPICall().multiPartPostRequest(addCommentApiUrl, body, true,"POST");
//       CommentResponseModel responseModel = CommentResponseModel.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   Future deleteComment(DeleteCommentEvent event)  async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["comment_id"] = event.commentId;

//       var result = await NetworkAPICall().multiPartPostRequest(deleteCommentApiUrl, body, true,"POST");

//       resource = Resource(
//         error: null,
//         data: result,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   Future deletePost(DeletePostEvent event)  async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["post_id"] = event.postId;
//       var result = await NetworkAPICall().multiPartPostRequest(deletePostApiUrl, body, true,"POST");

//       resource = Resource(
//         error: null,
//         data: result,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   Future createPost(CreatePostEvent event)  async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["title"] = event.postTitle;
//       body["post"] = event.description;
//       body["type"] = event.postType;
//       body["location"] = event.postTitle;
//       body["comment"] = event;
//       body["photos"] = event.photos;
//       body["video"] = event.videos;
//       var result = await NetworkAPICall().createPostRequest(createPostApiUrl, body, true,"POST");
//       CreatePostResponseModel responseModel = CreatePostResponseModel.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   Future getOtherProfile(GetOtherProfileEvent event)  async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["user_id"] = event.userId; //emailOrPhone

//       var result = await NetworkAPICall().multiPartPostRequest(getOtherUserDetailsUrl, body, true,"POST");
//       UserProfileResponseModel responseModel = UserProfileResponseModel.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   Future getSavePost(GetSavePostEvent event)  async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["page_no"] = event.pageNo; // emailOrPhone
//       body["limit"] = "100";

//       var result = await NetworkAPICall().multiPartPostRequest(getSavePostApiUrl, body, true,"POST");
//       PostResponseModel responseModel = PostResponseModel.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   Future getUserProfile(GetUserProfileEvent event)  async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};

//       var result = await NetworkAPICall().postApiCall(getUserDetailsUrl, body, isToken: true);
//       UserProfileResponseModel responseModel = UserProfileResponseModel.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   Future getLiveScore(GetLiveScoreEvent event)  async {
//     Resource? resource;
//     try {
//       var result = await NetworkAPICall().getLiveData(event.sportType ?? "soccer",);
//       LiveScoreData responseModel = LiveScoreData.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   Future uploadFile(UploadFileEvent event)  async {
//     Resource? resource;
//     try {
//       var result = await NetworkAPICall().uploadFile(postType: event.postType!,file: event.files!);
//       FileUploadResponseModel responseModel = FileUploadResponseModel.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   Future blockUnBlockUser(BlockUnBlockEvent event)  async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["user_id"] = event.userId; //emailOrPhone

//       var result = await NetworkAPICall().multiPartPostRequest(event.isBlock!?userBlockUrl:userUnBlockUrl, body, true,"POST");

//       resource = Resource(
//         error: null,
//         data: true,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   Future getBlockUserList(GetBlockUserEvent event)  async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["page_no"] = event.pageNo; // emailOrPhone
//       body["limit"] = "100";

//       var result = await NetworkAPICall().multiPartPostRequest(blockUserListUrl, body, true,"POST");
//       BlockUserModel responseModel = BlockUserModel.fromJson(result);

//       resource = Resource(
//         error: null,
//         data: responseModel,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

//   Future reportPost(ReportPostEvent event)  async {
//     Resource? resource;
//     try {
//       var body = <String, dynamic>{};
//       body["content_id"] = event.contentId;
//       body["title"] = event.title;
//       body["type"] = event.type;

//       var result = await NetworkAPICall().multiPartPostRequest(reportUserPostApiUrl, body, true,"POST");

//       resource = Resource(
//         error: null,
//         data: true,
//       );
//     } catch (e, stackTrace) {
//       resource = Resource(
//         error: e.toString(),
//         data: null,
//       );
//       // print('ERROR: $e');
//       // print('STACKTRACE: $stackTrace');
//     }
//     return resource;
//   }

// }

class PostRepository {
  static final PostRepository _instance = PostRepository._internal();

  factory PostRepository() => _instance;

  PostRepository._internal();

  final _api = NetworkAPICall();

  Future<Resource<PostResponseModel>> getPosts({
    int pageNo = 1,
    bool isProfile = false,
    String? userId,
  }) async {
    try {
      final body = {
        "type": "1",
        "page_no": "$pageNo",
        "limit": "10",
        if (isProfile) ...{
          "flag": 0,
          "user_id": userId ?? (storage.read("current_uid")?.toString() ?? ""),
        }
      };
      print('getPosts API call with body: $body');

      final result = await _api.multiPartPostRequest(getUserPostApiUrl, body, true, "POST");

      print('getPosts API raw result: $result');
      print('getPosts API result type: ${result.runtimeType}');

      final postResponse = PostResponseModel.fromJson(result);
      print('PostResponseModel created successfully');
      print('Posts count in response: ${postResponse.success?.length ?? 0}');

      return Resource(data: postResponse);
    } catch (e) {
      print('Error in getPosts: $e');
      print('Error stack trace: ${StackTrace.current}');
      return Resource(error: e.toString());
    }
  }

  // ✅ New method for GetX
  Future<Resource<PostResponseModel>> getPostDetailsByParams({
    required String postId,
    required String type,
  }) async {
    final body = {
      "post_id": postId,
      "type": type,
    };
    try {
      final result = await _api.multiPartPostRequest(getPostDetailsApiUrl, body, true, "POST");
      return Resource(data: PostResponseModel.fromJson(result));
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource<FavoriteResponseModel>> favoritePost({
    required String postId,
    required String favorite,
  }) async {
    try {
      final body = {
        "post_id": postId,
        "favorite": favorite,
      };
      final result = await _api.multiPartPostRequest(saveUserFavoriteApiUrl, body, true, "POST");
      return Resource(data: FavoriteResponseModel.fromJson(result));
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource<PostResponseModel>> getFavoritePosts(int pageNo) async {
    try {
      final body = {"page_no": "$pageNo", "limit": "100"};
      final result = await _api.multiPartPostRequest(getUserFavoriteApiUrl, body, true, "POST");
      return Resource(data: PostResponseModel.fromJson(result));
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource<PostResponseModel>> getLikedPosts(int pageNo) async {
    try {
      final body = {"page_no": "$pageNo", "limit": "100"};
      final result = await _api.multiPartPostRequest(likeUserPostApiUrl, body, true, "POST");
      return Resource(data: PostResponseModel.fromJson(result));
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource<FavoriteResponseModel>> likePost({
    required String contentId,
    required String isLike,
    required String type,
  }) async {
    try {
      final body = {
        "content_id": contentId,
        "like": isLike,
        "type": type,
      };
      final result = await _api.multiPartPostRequest(likeUserPostApiUrl, body, true, "POST");
      return Resource(data: FavoriteResponseModel.fromJson(result));
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  // Future<Resource<FollowResponseModel>> followUser(
  //   FollowUserEvent followUserEvent, {
  //   required String followId,
  //   required String follow,
  // }) async {
  //   try {
  //     final body = {
  //       "follow_id": followId,
  //       "follow": follow,
  //     };
  //     final result = await _api.multiPartPostRequest(followUserApiUrl, body, true, "POST");
  //     return Resource(data: FollowResponseModel.fromJson(result));
  //   } catch (e) {
  //     return Resource(error: e.toString());
  //   }
  // }
  // Make sure you have the followUser method too:
  // Future<Resource> followUser({required String followId, required String follow}) async {
  //   try {
  //     final response = await _api.post(
  //       'follow-user-endpoint', // <-- Replace with your actual endpoint
  //       body: {
  //         'follow_id': followId,
  //         'follow': follow,
  //       },
  //     );
  //     return Resource.completed(response);
  //   } catch (e) {
  //     return Resource.error(e.toString());
  //   }
  // }
  Future<Resource<FollowResponseModel>> followUser({
    required String followId,
    required String follow,
  }) async {
    try {
      final body = {
        "follow_id": followId,
        "follow": follow,
      };
      final result = await _api.multiPartPostRequest(followUserApiUrl, body, true, "POST");
      return Resource(data: FollowResponseModel.fromJson(result));
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource<FavoriteResponseModel>> savePost({
    required String postId,
    required String save,
  }) async {
    try {
      final body = {
        "post_id": postId,
        "save": save,
      };
      final result = await _api.multiPartPostRequest(saveUserPostApiUrl, body, true, "POST");
      return Resource(data: FavoriteResponseModel.fromJson(result));
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource<FollowResponseModel>> removeFollowUser(String followingId) async {
    try {
      final body = {"following_id": followingId};
      final result = await _api.multiPartPostRequest(removeFollowerUrl, body, true, "POST");
      return Resource(data: FollowResponseModel.fromJson(result));
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource<PostResponseModel>> getPostDetails({
    required String postId,
    required String type,
  }) async {
    try {
      final body = {
        "post_id": postId,
        "type": type,
      };
      final result = await _api.multiPartPostRequest(getPostDetailsApiUrl, body, true, "POST");
      return Resource(data: PostResponseModel.fromJsonForCreatePost(result));
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource<CommentResponseModel>> addComment({
    required String postId,
    required String comment,
  }) async {
    try {
      final body = {"post_id": postId, "comment": comment, "parent_comment_id": "0"};
      final result = await _api.multiPartPostRequest(addCommentApiUrl, body, true, "POST");
      return Resource(data: CommentResponseModel.fromJson(result));
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource> deleteComment(String commentId) async {
    try {
      final body = {"comment_id": commentId};
      final result = await _api.multiPartPostRequest(deleteCommentApiUrl, body, true, "POST");
      return Resource(data: result);
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource> deletePost(String postId) async {
    try {
      final body = {"post_id": postId};
      final result = await _api.multiPartPostRequest(deletePostApiUrl, body, true, "POST");
      return Resource(data: result);
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource<CreatePostResponseModel>> createPost(var request) async {
    try {
      final body = {
        "title": request.success?.title,
        "post": request.success?.post,
        "type": request.success?.type,
        "location": request.success?.location,
        "comment": request.success?.comment,
        "photos": request.success.photos,
        "video": request.videos,
      };
      final result = await _api.createPostRequest(createPostApiUrl, body, true, "POST");
      return Resource(data: CreatePostResponseModel.fromJson(result));
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource<UserProfileResponseModel>> getOtherProfile(String userId) async {
    try {
      final body = {"user_id": userId};
      final result = await _api.multiPartPostRequest(getOtherUserDetailsUrl, body, true, "POST");
      return Resource(data: UserProfileResponseModel.fromJson(result));
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource<PostResponseModel>> getSavedPosts(int pageNo) async {
    try {
      final body = {"page_no": "$pageNo", "limit": "100"};
      final result = await _api.multiPartPostRequest(getSavePostApiUrl, body, true, "POST");
      return Resource(data: PostResponseModel.fromJson(result));
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource<UserProfileResponseModel>> getUserProfile() async {
    try {
      final result = await _api.postApiCall(getUserDetailsUrl, {}, isToken: true);
      return Resource(data: UserProfileResponseModel.fromJson(result));
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource<LiveScoreData>> getLiveScore(String sportType) async {
    try {
      final result = await _api.getLiveData(sportType);
      return Resource(data: LiveScoreData.fromJson(result));
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource<FileUploadResponseModel>> uploadFile(int postType, List<PostFile> files) async {
    try {
      final result = await _api.uploadFile(postType: postType, file: files);
      return Resource(data: FileUploadResponseModel.fromJson(result));
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource> blockUnblockUser({required String userId, required bool isBlock}) async {
    try {
      final body = {"user_id": userId};
      final result = await _api.multiPartPostRequest(
        isBlock ? userBlockUrl : userUnBlockUrl,
        body,
        true,
        "POST",
      );
      return Resource(data: true);
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource<BlockUserModel>> getBlockedUsers(int pageNo) async {
    try {
      final body = {"page_no": "$pageNo", "limit": "100"};
      final result = await _api.multiPartPostRequest(blockUserListUrl, body, true, "POST");
      return Resource(data: BlockUserModel.fromJson(result));
    } catch (e) {
      return Resource(error: e.toString());
    }
  }

  Future<Resource> reportPost({
    required String contentId,
    required String title,
    required String type,
  }) async {
    try {
      final body = {
        "content_id": contentId,
        "title": title,
        "type": type,
      };
      final result = await _api.multiPartPostRequest(reportUserPostApiUrl, body, true, "POST");
      return Resource(data: true);
    } catch (e) {
      return Resource(error: e.toString());
    }
  }
}
