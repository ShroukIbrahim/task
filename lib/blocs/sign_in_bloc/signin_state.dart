// @dart=2.9
part of 'signin_bloc.dart';

@immutable
abstract class SigninState {}

class SigninInitial extends SigninState {
  @override
  String toString() => 'SignInIntialState';
}

class SignInWithGoogleInProgress extends SigninState {
  @override
  String toString() => 'SignInWithGoogleInProgressState';
}

class SignInWithphoneNumberInProgress extends SigninState {
  @override
  String toString() => 'SignInWithphoneNumberInProgressState';
}

class SigninWithGoogleCompleted extends SigninState {
  final String result;
  SigninWithGoogleCompleted(this.result);

  @override
  String toString() => 'SigninWithGoogleCompletedState';
}

class SigninWithphoneNumberCompleted extends SigninState {
  @override
  String toString() => 'SigninWithphoneNumberCompletedState';
}

class SigninWithGoogleFailed extends SigninState {
  @override
  String toString() => 'SigninWithGoogleFailedState';
}

class SigninWithphoneNumberFailed extends SigninState {
  @override
  String toString() => 'SigninWithphoneNumberFailedState';
}

class VerifyphoneNumberInProgress extends SigninState {
  @override
  String toString() => 'VerifyphoneNumberInProgressState';
}

class VerifyphoneNumberCompleted extends SigninState {
  final User firebaseUser;
  VerifyphoneNumberCompleted(this.firebaseUser);

  @override
  String toString() => 'VerifyphoneNumberCompletedState';
}

class VerifyphoneNumberFailed extends SigninState {
  @override
  String toString() => 'VerifyphoneNumberFailedState';
}

class NotSignedupWithphoneNumber extends SigninState {
  @override
  String toString() => 'NotSignedupWithphoneNumberState';
}

class NotSignedupWithGoogle extends SigninState {
  @override
  String toString() => 'NotSignedupWithGoogleState';
}

class LoggedIn extends SigninState {
  @override
  String toString() => 'LoggedInState';
}

class NotLoggedIn extends SigninState {
  @override
  String toString() => 'NotLoggedInState';
}

class FailedToCheckLoggedIn extends SigninState {
  @override
  String toString() => 'FailedToCheckLoggedInState';
}

class CheckIfSignedInCompleted extends SigninState {
  final String res;

  CheckIfSignedInCompleted(this.res);
  @override
  String toString() => 'CheckIfSignedInCompleted';
}

class GetCurrentUserFailed extends SigninState {
  @override
  String toString() => 'GetCurrentUserFailedState';
}

class GetCurrentUserInProgress extends SigninState {
  @override
  String toString() => 'GetCurrentUserInProgressState';
}

class GetCurrentUserCompleted extends SigninState {
  final User firebaseUser;
  GetCurrentUserCompleted(this.firebaseUser);

  @override
  String toString() => 'GetCurrentUserCompletedState';
}

class SignoutInProgress extends SigninState {
  @override
  String toString() => 'SignoutInProgressState';
}

class SignoutCompleted extends SigninState {
  @override
  String toString() => 'SignoutCompletedState';
}

class SignoutFailed extends SigninState {
  @override
  String toString() => 'SignoutFailedState';
}

class CheckIfBlockedInProgress extends SigninState {
  @override
  String toString() => 'CheckIfBlockedInProgressState';
}

class CheckIfBlockedCompleted extends SigninState {
  final String result;

  CheckIfBlockedCompleted(this.result);
  @override
  String toString() => 'CheckIfBlockedCompletedState';
}

class CheckIfBlockedFailed extends SigninState {
  @override
  String toString() => 'CheckIfBlockedFailedState';
}
