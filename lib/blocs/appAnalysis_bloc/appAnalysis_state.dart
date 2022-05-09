// @dart=2.9

part of 'appAnalysis_bloc.dart';

@immutable
abstract class AppAnalysisState {}


class AppAnalysisInitialState extends AppAnalysisState {
  @override
  String toString() => 'AppAnalysisInitialState';
}

class GetAppAnalysisCompletedState extends AppAnalysisState {
  final AppAnalysis appAnalysis;

  GetAppAnalysisCompletedState({
    @required this.appAnalysis,
  });

  String toString() => 'GetAppAnalysisCompletedState';
}

class GetAppAnalysisFailedState extends AppAnalysisState {
  String toString() => 'GetAppAnalysisFailedState';
}

class GetAppAnalysisInProgressState extends AppAnalysisState {
  String toString() => 'GetAppAnalysisInProgressState';
}