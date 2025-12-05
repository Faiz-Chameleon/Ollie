import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octagon/networking/exception/exception.dart';
import 'package:octagon/networking/model/resource.dart';
import 'package:octagon/screen/sport%20/bloc/sport_event.dart';
import 'package:octagon/screen/sport%20/bloc/sport_repo.dart';
import 'package:octagon/screen/sport%20/bloc/sport_state.dart';

class SportBloc extends Bloc<SportScreenEvent, SportScreenState> {
  SportBloc() : super(SportInitialState());

  final SportRepository _sportRepository = SportRepository();

  Stream<SportScreenState> mapEventToState(SportScreenEvent event) async* {
    if (event is GetSportListEvent) {
      yield SportLoadingBeginState();
      Resource resource = await _sportRepository.getSport(event);
      if (resource.data != null) {
        yield GetSportListSate(resource.data);
      } else {
        yield SportErrorState(
            AppException.decodeExceptionData(jsonString: resource.error ?? ''));
      }
      yield SportLoadingEndState();
    }

    if (event is SaveSportListEvent) {
      yield SportLoadingBeginState();
      Resource resource = await _sportRepository.saveSport(event);
      if (resource.data != null) {
        yield SaveSportState(resource.data);
      } else {
        yield SportErrorState(
            AppException.decodeExceptionData(jsonString: resource.error ?? ''));
      }
      yield SportLoadingEndState();
    }

    if (event is GetTeamListEvent) {
      yield SportLoadingBeginState();
      Resource resource = await _sportRepository.getTeamList(event);
      if (resource.data != null) {
        yield GetTermListState(resource.data);
      } else {
        yield SportErrorState(
            AppException.decodeExceptionData(jsonString: resource.error ?? ''));
      }
      yield SportLoadingEndState();
    }

    if (event is SaveTeamListEvent) {
      yield SportLoadingBeginState();
      Resource resource = await _sportRepository.saveTeamList(event);
      if (resource.data != null) {
        yield SaveTermListState(resource.data);
      } else {
        yield SportErrorState(
            AppException.decodeExceptionData(jsonString: resource.error ?? ''));
      }
      yield SportLoadingEndState();
    }
  }
}