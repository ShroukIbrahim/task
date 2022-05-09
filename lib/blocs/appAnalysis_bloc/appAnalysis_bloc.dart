// @dart=2.9

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:grocery_store/models/appAnalysis.dart';
import 'package:grocery_store/repositories/user_data_repository.dart';
import 'package:meta/meta.dart';

part 'appAnalysis_event.dart';
part 'appAnalysis_state.dart';

class AppAnalysisBloc extends Bloc<AppAnalysisEvent, AppAnalysisState> {
  final UserDataRepository userDataRepository;
  StreamSubscription appAnalysisSubscription;

  AppAnalysisBloc({this.userDataRepository}) : super(null);

  @override
  AppAnalysisState get initialState => AppAnalysisInitialState();

  @override
  Future<void> close() {
    print('Closing appAnalysisSubscription BLOC');
    appAnalysisSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<AppAnalysisState> mapEventToState(
      AppAnalysisEvent event,
      ) async* {
    if (event is GetAppAnalysisEvent) {
      yield* mapGetProductAnalyticsEventToState();
    }
    if (event is UpdateAppAnalysisEvent) {
      yield* mapUpdateProductAnalyticsEventToState(event.appAnalysis);
    }

  }

  Stream<AppAnalysisState> mapGetProductAnalyticsEventToState() async* {
    yield GetAppAnalysisInProgressState();

    try {
      appAnalysisSubscription?.cancel();
      appAnalysisSubscription =
          userDataRepository.getAppAnalysis().listen((appAnalysis) {
            add(UpdateAppAnalysisEvent(appAnalysis: appAnalysis));
          }, onError: (err) {
            print(err);
            return GetAppAnalysisFailedState();
          });
    } catch (e) {
      print(e);
      yield GetAppAnalysisFailedState();
    }
  }

  Stream<AppAnalysisState> mapUpdateProductAnalyticsEventToState(
      AppAnalysis appAnalysis) async* {
    yield GetAppAnalysisCompletedState(appAnalysis: appAnalysis);
  }

}
