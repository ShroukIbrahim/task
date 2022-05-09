// @dart=2.9
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/repositories/authentication_repository.dart';
import 'package:grocery_store/repositories/user_data_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthenticationRepository authenticationRepository;
  final UserDataRepository userDataRepository;

  SignupBloc({
    this.authenticationRepository,
    this.userDataRepository,
  }) : super(null);

  SignupState get initialState => SignupInitial();

  @override
  Stream<SignupState> mapEventToState(SignupEvent event) async* {
    print(event);

    if (event is SignupWithphoneNumber) {
      yield* mapSignupWithphoneNumberEventToState(
        phoneNumber: event.phoneNumber,
      );
    } else if (event is SignupWithGoogle) {
      yield* mapSignupWithGoogleEventToState();
    } else if (event is VerifyphoneNumber) {
      yield* mapVerifyphoneNumberToState(event.otp);
    } else if (event is ResendCode) {
      yield* mapSignupWithphoneNumberEventToState(
        phoneNumber: event.phoneNumber,
      );
    } else if (event is SaveUserDetails) {
      yield* mapSaveUserDetailsToState(
        name: event.name,
        countryCode: event.countryCode,
        countryISOCode: event.countryISOCode,
        phoneNumber: event.phoneNumber,
        firebaseUser: event.firebaseUser,
        loggedInVia: event.loggedInVia,
        userType: event.userType,
      );
    }
  }

  Stream<SignupState> mapSignupWithphoneNumberEventToState({
    String phoneNumber,
  }) async* {
    yield VerificationInProgress();

    try {
      bool isSent = await authenticationRepository.signInWithphoneNumber(phoneNumber);
      if (isSent) {
        yield VerificationCompleted();
      } else {
        yield VerificationFailed();
      }
    } catch (e) {
      print('ERROR');
      print(e);
    }
  }

  Stream<SignupState> mapVerifyphoneNumberToState(String otp) async* {
    yield VerifyphoneNumberInProgress();

    try {
      User firebaseUser = await authenticationRepository.signInWithSmsCode(otp);
      print(firebaseUser.phoneNumber);
      if (firebaseUser != null) {
        yield VerifyphoneNumberCompleted(firebaseUser);
      } else {
        yield VerifyphoneNumberFailed();
      }
    } catch (e) {
      yield VerifyphoneNumberFailed();
      print(e);
    }
  }

  Stream<SignupState> mapResendCodeToState(String phoneNumber) async* {
    yield VerificationInProgress();

    try {
      bool isSent = await authenticationRepository.signInWithphoneNumber(phoneNumber);
      if (isSent) {
        yield VerificationCompleted();
      } else {
        yield VerificationFailed();
      }
    } catch (e) {
      print('ERROR');
      print(e);
    }
  }

  Stream<SignupState> mapSignupWithGoogleEventToState() async* {
    yield SignUpInProgress();

    try {
      User firebaseUser = await authenticationRepository.signUpWithGoogle();
      if (firebaseUser != null) {
        yield SignupWithGoogleInitialCompleted(firebaseUser);
      } else {
        yield SignupWithGoogleInitialFailed();
      }
    } catch (e) {
      print(e);
      yield SignupWithGoogleInitialFailed();
    }
  }

  Stream<SignupState> mapSaveUserDetailsToState({
    String name,
    String countryCode,
    String countryISOCode,
    String phoneNumber,
    String email,
    User firebaseUser,
    String loggedInVia,
    String userType,
  }) async* {
    yield SavingUserDetails();
    try {
      GroceryUser user = await userDataRepository.saveUserDetails(
        firebaseUser.uid,
        name,
        email,
        phoneNumber,
        firebaseUser.photoURL,
        '',
        [],
        [],
        loggedInVia,
        userType,
          countryCode,
          countryISOCode
      );

      if (user != null) {
        yield CompletedSavingUserDetails(user);
      } else {
        yield FailedSavingUserDetails();
      }
    } catch (e) {
      print(e);
      yield FailedSavingUserDetails();
    }
  }
}
