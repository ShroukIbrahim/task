// @dart=2.9
import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:grocery_store/models/consultPackage.dart';
import 'package:grocery_store/models/consultPackage.dart';
import 'package:grocery_store/models/consultPackage.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/repositories/user_data_repository.dart';
import 'package:meta/meta.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final UserDataRepository userDataRepository;

  AccountBloc({this.userDataRepository}) : super(null);
  @override
  AccountState get initialState => AccountInitial();

  @override
  Stream<AccountState> mapEventToState(
    AccountEvent event,
  ) async* {
    if (event is GetAccountDetailsEvent) {
      yield* mapGetAccountDetailsEventToState(
        uid: event.uid,
      );
    }
    if (event is GetConsultPackagesEvent) {
      yield* mapGetConsultPackagesEventToState(
        uid: event.uid,
      );
    }
    if (event is GetConsultReviewsEvent) {
      yield* mapGetConsultReviewsEventToState(
        uid: event.uid,
      );
    }
    if (event is AddAddressEvent) {
      yield* mapAddAddressEventToState(
        uid: event.uid,
        address: event.address,
        defaultAddress: event.defaultAddress,
      );
    }
    if (event is RemoveAddressEvent) {
      yield* mapRemoveAddressEventToState(
        uid: event.uid,
        address: event.address,
        isDefault: event.isDefault,
      );
    }
    if (event is EditAddressEvent) {
      yield* mapEditAddressEventToState(
        uid: event.uid,
        address: event.address,
        defaultAddress: event.defaultAddress,
      );
    }
    if (event is UpdateAccountDetailsEvent) {
      yield* mapUpdateAccountDetailsEventToState(
        user: event.user,
        profileImage: event.profileImage,
      );
    }
    if (event is getAllConsultationsEvent) {
      yield* mapGetAllConsultationsEventToState( );
    }

  }

  Stream<AccountState> mapGetConsultPackagesEventToState({String uid}) async* {
    yield getConsultPackagesInProgressState();
    try {
      List<consultPackage> packages = await userDataRepository.getConsultPackages(uid);
      if (packages != null) {

        yield getConsultPackagesCompletedState(packages);
      } else {
        yield getConsultPackagesFailedState();
      }
    } catch (e) {
      print(e);
      yield getConsultPackagesFailedState();
    }
  }

  Stream<AccountState> mapGetConsultReviewsEventToState({String uid}) async* {
    yield getConsultReviewsInProgressState();
    try {
      List<ConsultReview> reviews = await userDataRepository.getConsultReviewes(uid);
      if (reviews != null) {

        yield getConsultReviewsCompletedState(reviews);
      } else {
        yield getConsultReviewsFailedState();
      }
    } catch (e) {
      print(e);
      yield getConsultReviewsFailedState();
    }
  }
  Stream<AccountState> mapGetAccountDetailsEventToState({String uid}) async* {
    yield GetAccountDetailsInProgressState();
    try {
      print("GetAccountDetails1");
      GroceryUser user = await userDataRepository.getAccountDetails(uid);
      if (user != null) {
        print("GetAccountDetails2");

        yield GetAccountDetailsCompletedState(user);
      } else {
        print("GetAccountDetails3");

        yield GetAccountDetailsFailedState();
      }
    } catch (e) {
      print(e);
      print("GetAccountDetails4");

      yield GetAccountDetailsFailedState();
    }
  }

  Stream<AccountState> mapAddAddressEventToState({
    String uid,
    List<Address> address,
    int defaultAddress,
  }) async* {
    yield AddAddressInProgressState();
    try {
      print('before await');
      bool isAdded =
          await userDataRepository.addAddress(uid, address, defaultAddress);
      print('after await');
      if (isAdded) {
        yield AddAddressCompletedState();
      } else {
        yield AddAddressFailedState();
      }
    } catch (e) {
      print(e);
      yield AddAddressFailedState();
    }
  }

  Stream<AccountState> mapRemoveAddressEventToState({
    String uid,
    List<Address> address,
    bool isDefault,
  }) async* {
    yield RemoveAddressInProgressState();
    try {
      bool isRemoved =
          await userDataRepository.removeAddress(uid, address, isDefault);
      if (isRemoved) {
        yield RemoveAddressCompletedState();
      } else {
        yield RemoveAddressFailedState();
      }
    } catch (e) {
      print(e);
      yield RemoveAddressFailedState();
    }
  }

  Stream<AccountState> mapEditAddressEventToState({
    String uid,
    List<Address> address,
    int defaultAddress,
  }) async* {
    yield EditAddressInProgressState();
    try {
      bool isAdded =
          await userDataRepository.editAddress(uid, address, defaultAddress);
      if (isAdded) {
        yield EditAddressCompletedState();
      } else {
        yield EditAddressFailedState();
      }
    } catch (e) {
      print(e);
      yield EditAddressFailedState();
    }
  }

  Stream<AccountState> mapUpdateAccountDetailsEventToState(
      {GroceryUser user, File profileImage}) async* {
    yield UpdateAccountDetailsInProgressState();
    try {
      bool isUpdated =
          await userDataRepository.updateAccountDetails(user, profileImage);
      if (isUpdated) {
        yield UpdateAccountDetailsCompletedState();
      } else {
        yield UpdateAccountDetailsFailedState();
      }
    } catch (e) {
      print(e);
      yield UpdateAccountDetailsFailedState();
    }
  }
  Stream<AccountState> mapGetAllConsultationsEventToState()async* {
    yield getAllconsultantsInProgressState();
    try {
      List<GroceryUser> consultantList =
      await userDataRepository.getallConsultant();
      if (consultantList != null) {
        yield getAllconsultantsCompletedState(consultantList);
      } else {
        yield getAllconsultantsFailedState();
      }
    } catch (e) {
      print(e);
      yield getAllconsultantsFailedState();
    }
  }
}
