

import 'package:octagon/model/team_list_response.dart';
import 'package:octagon/networking/exception/exception.dart';
import 'package:octagon/networking/model/response_model/save_sports_response_model.dart';
import 'package:octagon/networking/model/response_model/sport_list_response_model.dart';

class SportInitialState extends SportScreenState {}

class SportLoadingBeginState extends SportScreenState {}

class SportLoadingEndState extends SportScreenState {}

abstract class SportScreenState {}

class GetSportListSate extends SportScreenState{
  SportListResponseModel sportListResponseModel;
  GetSportListSate(this.sportListResponseModel);
}

class SaveSportState extends SportScreenState{
  SaveSportListResponseModel saveSportListResponseModel;
  SaveSportState(this.saveSportListResponseModel);
}

class GetTermListState extends SportScreenState{
  TeamListResponse teamListResponse;
  GetTermListState(this.teamListResponse);
}

class SaveTermListState extends SportScreenState{
  SaveSportListResponseModel saveSportListResponseModel;
  SaveTermListState(this.saveSportListResponseModel);
}

class SportErrorState extends SportScreenState {
  AppException exception;

  SportErrorState(this.exception);
}