// import 'package:equatable/equatable.dart';

// import '../../common/create_post_screen.dart';

// abstract class MainFeedScreenEvent extends Equatable {
//   @override
//   List<Object?> get props => [];
// }


// class GetPostEvent extends MainFeedScreenEvent{
//  int? pageNo;
//  bool isProfile;
//  int userId;

//  GetPostEvent({this.userId = 1,this.isProfile = false,this.pageNo});

//  @override
//  List<Object?> get props => [pageNo, isProfile, userId,];
// }

// class LikePostEvent extends MainFeedScreenEvent{
//   String? contentId;
//   String? isLike;
//   String? type;
//   LikePostEvent({this.type,this.isLike,this.contentId});

//   @override
//   List<Object?> get props => [type,isLike,contentId];
// }

// class FollowUserEvent extends MainFeedScreenEvent{
//   String? followId;
//   String? follow;
//   FollowUserEvent({this.follow,this.followId});

//   @override
//   List<Object?> get props => [follow,followId];
// }

// class RemoveFollowUserEvent extends MainFeedScreenEvent{
//   String? followingId;
//   RemoveFollowUserEvent({this.followingId});

//   @override
//   List<Object?> get props => [followingId];
// }

// class SavePostEvent extends MainFeedScreenEvent{
//   String? postId;
//   String? save;
//   SavePostEvent({this.save,this.postId});

//   @override
//   List<Object?> get props => [save,postId];
// }

// class GetPostDetailsEvent extends MainFeedScreenEvent{
//   String? postId;
//   String? type;
//   GetPostDetailsEvent({this.type,this.postId});

//   @override
//   List<Object?> get props => [type,postId];
// }

// class AddCommentEvent extends MainFeedScreenEvent{
//   String? postId;
//   String? comment;
//   String? parentId;
//   AddCommentEvent({this.comment,this.postId,this.parentId});

//   @override
//   List<Object?> get props => [comment,postId,parentId];
// }

// class CreatePostEvent extends MainFeedScreenEvent{
//   String? postTitle;
//   String? description;
//   int? postType;
//   bool? isCommentEnable;
//   List<PostFile>? photos;
//   List<PostFile>? videos;
//   CreatePostEvent({this.description,this.postTitle,this.postType,this.isCommentEnable,this.photos,this.videos});

//   @override
//   List<Object?> get props => [description,postTitle,postType,isCommentEnable,photos,videos];
// }

// class GetOtherProfileEvent extends MainFeedScreenEvent{
//   String? userId;
//   GetOtherProfileEvent({this.userId});

//   @override
//   List<Object?> get props => [userId];
// }

// class DeleteCommentEvent extends MainFeedScreenEvent{
//   String? commentId;
//   DeleteCommentEvent({this.commentId});

//   @override
//   List<Object?> get props => [commentId];
// }

// class BlockUnBlockEvent extends MainFeedScreenEvent{
//   String? userId;
//   bool? isBlock;
//   BlockUnBlockEvent({this.userId,this.isBlock});

//   @override
//   List<Object?> get props => [userId,isBlock];
// }

// class DeletePostEvent extends MainFeedScreenEvent{
//   String? postId;
//   DeletePostEvent({this.postId});

//   @override
//   List<Object?> get props => [postId];
// }

// class GetSavePostEvent extends MainFeedScreenEvent{
//   String? pageNo;
//   GetSavePostEvent({this.pageNo});

//   @override
//   List<Object?> get props => [pageNo];
// }

// class GetBlockUserEvent extends MainFeedScreenEvent{
//   String? pageNo;
//   GetBlockUserEvent({this.pageNo});

//   @override
//   List<Object?> get props => [pageNo];
// }

// class GetUserTeamEvent extends MainFeedScreenEvent{
//   GetUserTeamEvent();

//   @override
//   List<Object?> get props => [];
// }

// class ReportPostEvent extends MainFeedScreenEvent{
//   String? contentId;
//   String? title;
//   String? type;
//   ReportPostEvent({this.contentId,this.title,this.type});

//   @override
//   List<Object?> get props => [contentId,title,type];
// }

// class UploadFileEvent extends MainFeedScreenEvent {
//   int? postType;
//   List<PostFile>? files;
//   UploadFileEvent({this.postType,this.files});

//   @override
//   List<Object?> get props => [postType,files];

// }
// class GetLiveScoreEvent extends MainFeedScreenEvent{
//   String? sportType;
//   GetLiveScoreEvent({this.sportType});

//   @override
//   List<Object?> get props => [sportType];
// }

// class GetUserProfileEvent extends MainFeedScreenEvent{}


