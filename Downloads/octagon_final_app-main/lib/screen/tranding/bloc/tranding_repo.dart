import 'package:octagon/model/post_response_model.dart';
import 'package:octagon/networking/model/notification_response.dart';
import 'package:octagon/networking/model/resource.dart';
import 'package:octagon/networking/network.dart';
import 'package:octagon/screen/tranding/bloc/tranding_event.dart';
import 'package:octagon/utils/constants.dart';

abstract class ITrendingRepository {
  Future getTrending(GetTrendingEvent event);
}

class TrendingRepository implements ITrendingRepository {
  static final TrendingRepository _postRepository = TrendingRepository._init();

  factory TrendingRepository() {
    return _postRepository;
  }

  TrendingRepository._init();

  @override
  Future getTrending(GetTrendingEvent event) async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["type"] = event.type;
      body["page_no"] = "1";
      body["limit"] = "50";

      print('🔍 Trending API Call - URL: $getTrendingListApiUrl');
      print('🔍 Trending API Call - Full URL: $baseUrl$getTrendingListApiUrl');
      print('🔍 Trending API Call - Body: $body');
      print('🔍 Trending API Call - Token: ${getUserToken()}');

      var result = await NetworkAPICall()
          .multiPartPostRequest(getTrendingListApiUrl, body, true, "POST");

      print('🔍 Trending API Response Type: ${result.runtimeType}');
      print('🔍 Trending API Response: $result');

      if (result is Map<String, dynamic>) {
        print('🔍 Trending API Response Keys: ${result.keys.toList()}');
        if (result.containsKey('success')) {
          print(
              '🔍 Trending API Success Data Type: ${result['success'].runtimeType}');
          print('🔍 Trending API Success Data: ${result['success']}');
        }
      }

      PostResponseModel responseModel = PostResponseModel.fromJson(result);

      print(
          '🔍 Trending Parsed Response - Success Count: ${responseModel.success?.length ?? 0}');
      if (responseModel.success != null) {
        print(
            '🔍 Trending Posts: ${responseModel.success!.map((e) => 'ID: ${e.id}, Title: ${e.title}').toList()}');
      }

      resource = Resource(
        error: null,
        data: responseModel,
      );
    } catch (e, stackTrace) {
      print('❌ Trending API Error: $e');
      print('❌ Trending API Stack Trace: $stackTrace');

      resource = Resource(
        error: e.toString(),
        data: null,
      );
    }
    return resource;
  }

  @override
  Future getNotification(GetNotificationEvent event) async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      var result = await NetworkAPICall()
          .postApiCall(notificationUrl, body, isToken: true);
      NotificationResponse responseModel =
          NotificationResponse.fromJson(result);

      resource = Resource(
        error: null,
        data: responseModel,
      );
    } catch (e, stackTrace) {
      resource = Resource(
        error: e.toString(),
        data: null,
      );
      // print('ERROR: $e');
      // print('STACKTRACE: $stackTrace');
    }
    return resource;
  }
}
