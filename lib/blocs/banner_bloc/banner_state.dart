// @dart=2.9
part of 'banner_bloc.dart';

@immutable
abstract class BannerState {}

class BannerInitialState extends BannerState {
  @override
  String toString() => 'BannerInitialState';
}

class LoadBannersInProgressState extends BannerState {
  @override
  String toString() => 'LoadBannersInProgressState';
}

class LoadBannersCompletedState extends BannerState {
  final Banner banner;
  LoadBannersCompletedState(this.banner);

  @override
  String toString() => 'LoadBannersInProgressState';
}

class LoadBannersFailedState extends BannerState {
  @override
  String toString() => 'LoadBannersFailedState';
}

class LoadBannerAllProductsInProgressState extends BannerState {
  @override
  String toString() => 'LoadBannerAllProductsInProgressState';
}

class LoadBannerAllProductsCompletedState extends BannerState {
  final List<Product> products;

  LoadBannerAllProductsCompletedState(this.products);

  @override
  String toString() => 'LoadBannerAllProductsInProgressState';
}

class LoadBannerAllProductsFailedState extends BannerState {
  @override
  String toString() => 'LoadBannerAllProductsFailedState';
}
class getActiveconsultantsInProgressState extends BannerState {
  @override
  String toString() => 'getActiveconsultantsInProgressState';
}

class getActiveconsultantsFailedState extends BannerState {
  @override
  String toString() => 'getActiveconsultantsFailedState';
}

class getActiveconsultantsCompletedState extends BannerState {
  final List<GroceryUser> consultants;

  getActiveconsultantsCompletedState(this.consultants);
  @override
  String toString() => 'getActiveconsultantsCompletedState';
}
