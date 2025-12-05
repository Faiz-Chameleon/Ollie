
import 'package:equatable/equatable.dart';

abstract class TrendingScreenEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetTrendingEvent extends TrendingScreenEvent{
  String? type;
  GetTrendingEvent({this.type});

  @override
  List<Object?> get props => [type];
}

class GetNotificationEvent extends TrendingScreenEvent{}