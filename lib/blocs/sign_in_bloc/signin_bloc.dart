// @dart=2.9
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:grocery_store/blocs/sign_up_bloc/signup_bloc.dart';
import 'package:grocery_store/repositories/authentication_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'signin_event.dart';
part 'signin_state.dart';

class SigninBloc extends Bloc<SigninEvent, SigninState> {
  final AuthenticationRepository authenticationRepository;

  SigninBloc({this.authenticationRepository}) : super(null);

  SigninState get initialState => SigninInitial();

  @override
  Stream<SigninState> mapEventToState(
    SigninEvent event,
  ) async* {
    if (event is SignInWithGoogle) {
      yield* mapSignInWithGoogleToState();
    }
    if (event is SignInWithphoneNumber) {
      yield* mapSignInWithphoneNumberToState(event.phoneNumber);
    }
    if (event is CheckIfBlocked) {
      yield* mapCheckIfBlockedToState(event.phoneNumber);
    }
    if (event is CheckIfSignedIn) {
      yield* mapCheckIfSignedInToState();
    }
    if (event is GetCurrentUser) {
      yield* mapGetCurrentUserToState();
    }
    if (event is SignoutEvent) {
      yield* mapSignoutEventToState();
    }
    if (event is VerifyphoneNumber) {
      yield* mapVerifyphoneNumberToState(event.otp);
    }
  }

  Stream<SigninState> mapSignInWithGoogleToState() async* {
    yield SignInWithGoogleInProgress();

    try {
      String res = await authenticationRepository.signInWithGoogle();
      if (res != null) {
        yield SigninWithGoogleCompleted(res);
      } else {
        yield SigninWithGoogleFailed();
      }
    } catch (e) {
      print(e);
      yield SigninWithGoogleFailed();
    }
  }

  Stream<SigninState> mapSignInWithphoneNumberToState(String phoneNumber) async* {
    yield SignInWithphoneNumberInProgress();

    try {
      bool isSent = await authenticationRepository.signInWithphoneNumber(phoneNumber);
      if (isSent) {
        yield SigninWithphoneNumberCompleted();
      } else {
        yield SigninWithphoneNumberFailed();
      }
    } catch (e) {
      print('ERROR');
      print(e);
      yield SigninWithphoneNumberFailed();
    }
  }

  Stream<SigninState> mapCheckIfBlockedToState(String phoneNumber) async* {
    yield CheckIfBlockedInProgress();

    try {
      String res = await authenticationRepository.checkIfBlocked(phoneNumber);
      if (res != null) {
        yield CheckIfBlockedCompleted(res);
      } else {
        yield CheckIfBlockedFailed();
      }
    } catch (e) {
      print(e);
      yield CheckIfBlockedFailed();
    }
  }

  Stream<SigninState> mapCheckIfSignedInToState() async* {
    try {
      print("signinBloc1");
      String res = await authenticationRepository.isLoggedIn();
      if (res != null) {
        print("signinBloc2");
        yield CheckIfSignedInCompleted(res);
      } else {
        print("signinBloc3");
        yield FailedToCheckLoggedIn();
      }
    } catch (e) {
      print(e);
      print("signinBloc4");

      yield FailedToCheckLoggedIn();
    }
  }

  Stream<SigninState> mapGetCurrentUserToState() async* {
    try {
      User currentUser = await authenticationRepository.getCurrentUser();
      if (currentUser != null) {
        yield GetCurrentUserCompleted(currentUser);
      } else {
        yield GetCurrentUserFailed();
      }
    } catch (e) {
      print(e);
      yield GetCurrentUserFailed();
    }
  }

  Stream<SigninState> mapSignoutEventToState() async* {
    yield SignoutInProgress();
    try {
      bool isSignedOut = await authenticationRepository.signOutUser();
      if (isSignedOut) {
        yield SignoutCompleted();
      } else {
        yield SignoutFailed();
      }
    } catch (e) {
      print(e);
      yield SignoutFailed();
    }
  }

  Stream<SigninState> mapVerifyphoneNumberToState(String otp) async* {
    yield VerifyphoneNumberInProgress();
    try {
      User user = await authenticationRepository.signInWithSmsCode(otp);
      if (user != null) {
        yield VerifyphoneNumberCompleted(user);
      } else {
        yield VerifyphoneNumberFailed();
      }
    } catch (e) {
      print(e);
      yield VerifyphoneNumberFailed();
    }
  }
}
