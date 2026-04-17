import '../../../domain/entities/price_config_entity.dart';

abstract class PriceConfigEvent {}

class LoadPriceConfigsEvent extends PriceConfigEvent {}

class UpdatePriceConfigEvent extends PriceConfigEvent {
  final PriceConfigEntity config;
  UpdatePriceConfigEvent(this.config);
}
