// @dart=2.9

part of 'appAnalysis_bloc.dart';

@immutable
abstract class AppAnalysisEvent {}

class GetAppAnalysisEvent extends AppAnalysisEvent {
  @override
  String toString() => 'GetAppAnalysisEvent';
}
class UpdateAppAnalysisEvent extends AppAnalysisEvent {
  final AppAnalysis appAnalysis;
  UpdateAppAnalysisEvent({@required this.appAnalysis});

  @override
  String toString() => 'UpdateAppAnalysisEvent';
}
