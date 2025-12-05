
import 'package:octagon/model/post_response_model.dart';
import 'package:octagon/networking/exception/exception.dart';
import 'package:octagon/networking/model/notification_response.dart';

class TrendingInitialState extends TrendingScreenState {}

class TrendingLoadingBeginState extends TrendingScreenState {}

class TrendingLoadingEndState extends TrendingScreenState {}

abstract class TrendingScreenState {}


class GetTrendingState extends TrendingScreenState{
  PostResponseModel postResponseModel;
  GetTrendingState(this.postResponseModel);
}

class GetNotificationState extends TrendingScreenState{
  NotificationResponse notificationResponse;
  GetNotificationState(this.notificationResponse);
}

class TrendingErrorState extends TrendingScreenState {
  AppException exception;

  TrendingErrorState(this.exception);
}