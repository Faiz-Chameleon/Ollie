import 'dart:convert';

import 'package:octagon/model/team_list_response.dart';
import 'package:octagon/networking/model/resource.dart';
import 'package:octagon/networking/model/response_model/save_sports_response_model.dart';
import 'package:octagon/networking/model/response_model/sport_list_response_model.dart';
import 'package:octagon/networking/network.dart';
import 'package:octagon/screen/sport%20/bloc/sport_event.dart';
import 'package:octagon/utils/constants.dart';

import '../../../main.dart';

abstract class ISportRepository {
  Future getSport(GetSportListEvent event);
}
class SportRepository implements ISportRepository {
  static final SportRepository _sportRepository = SportRepository._init();

  factory SportRepository() {
    return _sportRepository;
  }

  SportRepository._init();

  @override
  Future getSport(GetSportListEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      var result = await NetworkAPICall().postApiCall(sportListApiUrl, body, isToken: false);
      SportListResponseModel responseModel = SportListResponseModel.fromJson(result);

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

  @override
  Future saveSport(SaveSportListEvent event)  async {
    Resource? resource;
    try {/*{\"sports\":[{\"sport_id\":11,\"sport_api_id\":112}]}*/
      var body = <String, dynamic>{};
      body["sports"] = json.encode(event.sports!.map((e) => e).toList());
      var result = await NetworkAPICall().multiPartPostRequest(saveUserSportsApiUrl, body, true, "POST");
      SaveSportListResponseModel responseModel = SaveSportListResponseModel.fromJson(result);

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

  @override
  Future getTeamList(GetTeamListEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["sports"] = json.encode(event.term!.map((e) => e).toList());
      body["limit"] = 20000;

      var result = await NetworkAPICall().multiPartPostRequest(teamListApiUrl, body, true, "POST");
      TeamListResponse responseModel = TeamListResponse.fromJson(result);

      if(event.term!=null && event.term!.isNotEmpty){
        storage.write(event.term!.first, teamListResponseToJson(responseModel));
      }

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

  @override
  Future saveTeamList(SaveTeamListEvent event)  async {
    Resource? resource;
    try {
      var body = <String, dynamic>{};
      body["teams"] = json.encode(event.term!.map((e) => e).toList());
      var result = await NetworkAPICall().multiPartPostRequest(saveUserTeamsApiUrl, body, true, "POST");
      SaveSportListResponseModel responseModel = SaveSportListResponseModel.fromJson(result);

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