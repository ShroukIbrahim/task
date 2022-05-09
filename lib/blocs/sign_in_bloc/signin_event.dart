// @dart=2.9
part of 'signin_bloc.dart';

@immutable
abstract class SigninEvent {}

class SignInWithGoogle extends SigninEvent {
  @override
  String toString() => 'SignInWithGoogleEvent';
}

class SignInWithphoneNumber extends SigninEvent {
  final String phoneNumber;

  SignInWithphoneNumber(this.phoneNumber);
  @override
  String toString() => 'SignInWithGoogleEvent';
}

class VerifyphoneNumber extends SigninEvent {
  final String otp;

  VerifyphoneNumber(this.otp);
  @override
  String toString() => 'VerifyphoneNumberEvent';
}

class CheckIfSignedIn extends SigninEvent {
  @override
  String toString() => 'CheckIfSignedInEvent';
}

class GetCurrentUser extends SigninEvent {
  @override
  String toString() => 'GetCurrentUserEvent';
}

class SignoutEvent extends SigninEvent {
  @override
  String toString() => 'SignoutEvent';
}

class CheckIfBlocked extends SigninEvent {
  final String phoneNumber;

  CheckIfBlocked(this.phoneNumber);
  @override
  String toString() => 'CheckIfBlockedEvent';
}
