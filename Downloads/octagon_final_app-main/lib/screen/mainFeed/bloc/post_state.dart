// import 'package:octagon/model/comment_response_model.dart';
// import 'package:octagon/model/favorite_model.dart';
// import 'package:octagon/model/file_upload_response_model.dart';
// import 'package:octagon/model/follow_model.dart';
// import 'package:octagon/model/live_score_data.dart';
// import 'package:octagon/model/post_response_model.dart';
// import 'package:octagon/model/user_profile_response.dart';
// import 'package:octagon/networking/exception/exception.dart';
// import 'package:octagon/networking/model/request_model/create_post_request.dart';

// import '../../../model/block_user.dart';
// import '../../../model/team_list_response.dart';

// class PostInitialState extends PostScreenState {}

// class PostLoadingBeginState extends PostScreenState {}

// class PostLoadingEndState extends PostScreenState {}

// abstract class PostScreenState {}

// ///get post
// class GetPostState extends PostScreenState{
//   PostResponseModel postResponseModel;
//   GetPostState(this.postResponseModel);
// }

// ///post like
// class LikePostState extends PostScreenState{
//   FavoriteResponseModel favoriteResponseModel;
//   LikePostState(this.favoriteResponseModel);
// }

// ///follow user
// class FollowUserState extends PostScreenState{
//   FollowResponseModel followResponseModel;
//   FollowUserState(this.followResponseModel);
// }

// ///remove follow user
// class RemoveFollowUserState extends PostScreenState{
//   FollowResponseModel followResponseModel;
//   RemoveFollowUserState(this.followResponseModel);
// }


// ///save post user
// class SavePOstState extends PostScreenState{
//   FollowResponseModel followResponseModel;
//   SavePOstState(this.followResponseModel);
// }

// ///get post details
// class GetPostDetailsState extends PostScreenState{
//   PostResponseModel postResponseModel;
//   GetPostDetailsState(this.postResponseModel);
// }

// ///add comment
// class AddCommentState extends PostScreenState{
//   CommentResponseModel commentResponseModel;
//   AddCommentState(this.commentResponseModel);
// }

// ///delete comment
// class DeleteCommentState extends PostScreenState{}

// ///create post
// class CreatePostState extends PostScreenState{
//   CreatePostResponseModel createPostResponseModel;
//   CreatePostState(this.createPostResponseModel);
// }

// ///get other profile
// class OtherUserProfileState extends PostScreenState{
//   UserProfileResponseModel userProfileResponseModel;
//   OtherUserProfileState(this.userProfileResponseModel);
// }

// ///block and unblock user
// class BlockUnBlockUserState extends PostScreenState{
// }

// ///block and unblock user
// class BlockedUserState extends PostScreenState{
//   BlockUserModel blockUserModel;
//   BlockedUserState(this.blockUserModel);
// }

// ///delete post
// class DeletePostState extends PostScreenState{}

// ///get save post
// class GetSavePostState extends PostScreenState{
//   PostResponseModel postResponseModel;
//   GetSavePostState(this.postResponseModel);
// }

// ///get profile
// class GetUserProfileState extends PostScreenState{
//   UserProfileResponseModel userProfileResponseModel;
//   GetUserProfileState(this.userProfileResponseModel);
// }

// ///report post
// class ReportPostState extends PostScreenState{}

// class PostErrorState extends PostScreenState {
//   AppException exception;

//   PostErrorState(this.exception);
// }

// ///get live score
// class GetLiveScoreState extends PostScreenState{
//   LiveScoreData liveScoreData;
//   GetLiveScoreState(this.liveScoreData);
// }

// ///upload file
// class UploadFileState extends PostScreenState{
//   FileUploadResponseModel fileUploadResponseModel;
//   UploadFileState(this.fileUploadResponseModel);
// }

// class UserTeamState extends PostScreenState {
//   List<TeamData> data;

//   UserTeamState(this.data);
// }