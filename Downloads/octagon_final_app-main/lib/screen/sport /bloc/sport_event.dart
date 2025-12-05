


import 'package:equatable/equatable.dart';
import 'package:octagon/networking/model/request_model/save_team_request_model.dart';
import 'package:octagon/networking/model/save_sports_request_model.dart';

abstract class SportScreenEvent extends Equatable {
  @override
  List<Object?> get props => [];
}


class GetSportListEvent extends SportScreenEvent{}

class SaveSportListEvent extends SportScreenEvent{
  List<SaveSport>? sports;
  SaveSportListEvent({this.sports});

  @override
  List<Object?> get props => [sports];
}

class GetTeamListEvent extends SportScreenEvent{
  List<String>? term;
  GetTeamListEvent({this.term});

  @override
  List<Object?> get props => [term];
}

class SaveTeamListEvent extends SportScreenEvent{
  List<SaveTeam>? term;
  SaveTeamListEvent({this.term});

  @override
  List<Object?> get props => [term];
}