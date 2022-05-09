// @dart=2.9
part of 'banner_bloc.dart';

@immutable
abstract class BannerEvent {}

class LoadBannersEvent extends BannerEvent {
  @override
  String toString() => 'LoadBannersEvent';
}

class LoadBannerAllProductsEvent extends BannerEvent {
  final String category;

  LoadBannerAllProductsEvent(this.category);
  @override
  String toString() => 'LoadBannerAllProductsEvent';
}
class getActiveConsultationsEvent extends BannerEvent {
  @override
  String toString() => 'getActiveConsultationsEvent';
}
