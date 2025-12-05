

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:octagon/screen/mainFeed/bloc/post_event.dart';
// import 'package:octagon/networking/exception/exception.dart';
// import 'package:octagon/networking/model/resource.dart';
// import 'package:octagon/screen/mainFeed/bloc/post_event.dart';
// import 'package:octagon/screen/mainFeed/bloc/post_repo.dart';
// import 'package:octagon/screen/mainFeed/bloc/post_state.dart';

// import '../../../main.dart';
// import '../../../model/team_list_response.dart';

// class PostBloc extends Bloc<MainFeedScreenEvent, PostScreenState> {
//   PostBloc() : super(PostInitialState());

//   final PostRepository _postRepository = PostRepository();

//   Stream<PostScreenState> mapEventToState(MainFeedScreenEvent event) async* {


//     if (event is GetPostEvent) {
//       yield PostLoadingBeginState();
//       Resource resource = await _postRepository.getPost(event);
//       if (resource.data != null) {
//         yield GetPostState(resource.data);
//       } else {
//         yield PostErrorState(
//             AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield PostLoadingEndState();
//     }

//     if (event is LikePostEvent) {
//       yield PostLoadingBeginState();
//       Resource resource = await _postRepository.likePost(event);
//       if (resource.data != null) {
//         yield LikePostState(resource.data);
//       } else {
//         yield PostErrorState(
//             AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield PostLoadingEndState();
//     }

//     if (event is FollowUserEvent) {
//       yield PostLoadingBeginState();
//       Resource resource = await _postRepository.followUser(event);
//       if (resource.data != null) {
//         yield FollowUserState(resource.data);
//       } else {
//         yield PostErrorState(
//             AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield PostLoadingEndState();
//     }

//     if (event is RemoveFollowUserEvent) {
//       yield PostLoadingBeginState();
//       Resource resource = await _postRepository.removeFollowUser(event);
//       if (resource.data != null) {
//         yield RemoveFollowUserState(resource.data);
//       } else {
//         yield PostErrorState(
//             AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield PostLoadingEndState();
//     }

//     if (event is SavePostEvent) {
//       yield PostLoadingBeginState();
//       Resource resource = await _postRepository.savePost(event);
//       if (resource.data != null) {
//         yield SavePOstState(resource.data);
//       } else {
//         yield PostErrorState(
//             AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield PostLoadingEndState();
//     }

//     if (event is GetPostDetailsEvent) {
//       yield PostLoadingBeginState();
//       Resource resource = await _postRepository.getPostDetails(event);
//       if (resource.data != null) {
//         yield GetPostDetailsState(resource.data);
//       } else {
//         yield PostErrorState(
//             AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield PostLoadingEndState();
//     }

//     if (event is AddCommentEvent) {
//       yield PostLoadingBeginState();
//       Resource resource = await _postRepository.addComment(event);
//       if (resource.data != null) {
//         yield AddCommentState(resource.data);
//       } else {
//         yield PostErrorState(
//             AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield PostLoadingEndState();
//     }

//     if (event is DeleteCommentEvent) {
//       yield PostLoadingBeginState();
//       Resource resource = await _postRepository.deleteComment(event);
//       if (resource.data != null) {
//         yield DeleteCommentState();
//       } else {
//         yield PostErrorState(
//             AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield PostLoadingEndState();
//     }

//     if (event is DeletePostEvent) {
//       yield PostLoadingBeginState();
//       Resource resource = await _postRepository.deletePost(event);
//       if (resource.data != null) {
//         yield DeletePostState();
//       } else {
//         yield PostErrorState(
//             AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield PostLoadingEndState();
//     }

//     if (event is CreatePostEvent) {
//       yield PostLoadingBeginState();
//       Resource resource = await _postRepository.createPost(event);
//       if (resource.data != null) {
//         yield CreatePostState(resource.data);
//       } else {
//         yield PostErrorState(
//             AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield PostLoadingEndState();
//     }

//     if (event is GetOtherProfileEvent) {
//       yield PostLoadingBeginState();
//       Resource resource = await _postRepository.getOtherProfile(event);
//       if (resource.data != null) {
//         yield OtherUserProfileState(resource.data);
//       } else {
//         yield PostErrorState(
//             AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield PostLoadingEndState();
//     }

//     if (event is BlockUnBlockEvent) {
//       yield PostLoadingBeginState();
//       Resource resource = await _postRepository.blockUnBlockUser(event);
//       if (resource.data != null) {
//         yield BlockUnBlockUserState();
//       } else {
//         yield PostErrorState(
//             AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield PostLoadingEndState();
//     }

//     if (event is GetBlockUserEvent) {
//       yield PostLoadingBeginState();
//       Resource resource = await _postRepository.getBlockUserList(event);
//       if (resource.data != null) {
//         yield BlockedUserState(resource.data);
//       } else {
//         yield PostErrorState(
//             AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield PostLoadingEndState();
//     }

//     if (event is GetSavePostEvent) {
//       // yield PostLoadingBeginState();
//       Resource resource = await _postRepository.getSavePost(event);
//       if (resource.data != null) {
//         yield GetSavePostState(resource.data);
//       } else {
//         yield PostErrorState(
//             AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       // yield PostLoadingEndState();
//     }

//     if (event is GetUserProfileEvent) {
//       // yield PostLoadingBeginState();
//       Resource resource = await _postRepository.getUserProfile(event);
//       if (resource.data != null) {
//         yield GetUserProfileState(resource.data);
//       } else {
//         yield PostErrorState(
//             AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       // yield PostLoadingEndState();
//     }

//     if (event is ReportPostEvent) {
//       yield PostLoadingBeginState();
//       Resource resource = await _postRepository.reportPost(event);
//       if (resource.data != null) {
//         yield ReportPostState();
//       } else {
//         yield PostErrorState(
//             AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield PostLoadingEndState();
//     }

//     if (event is GetLiveScoreEvent) {
//       yield PostLoadingBeginState();
//       Resource resource = await _postRepository.getLiveScore(event);
//       if (resource.data != null) {
//         yield GetLiveScoreState(resource.data);
//       } else {
//         yield PostErrorState(
//             AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield PostLoadingEndState();
//     }

//     if (event is UploadFileEvent) {
//       yield PostLoadingBeginState();
//       Resource resource = await _postRepository.uploadFile(event);
//       if (resource.data != null) {
//         yield UploadFileState(resource.data);
//       } else {
//         yield PostErrorState(
//             AppException.decodeExceptionData(jsonString: resource.error ?? ''));
//       }
//       yield PostLoadingEndState();
//     }

//     if (event is GetUserTeamEvent) {
//       List<TeamData> sportInfoData = [];
//       try{

//         var data = storage.read("userDefaultTeamName");
//         if(data!=null){
//           // for (var element in (storage.read(sportInfo) as List)) {
//           sportInfoData.add(TeamData.fromJson(data));
//           // }
//         }
//       } catch(e){
//         sportInfoData = [];
//       }
//      yield UserTeamState(sportInfoData);
//     }

//   }
// }