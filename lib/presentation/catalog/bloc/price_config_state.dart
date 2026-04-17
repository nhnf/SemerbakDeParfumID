import '../../../domain/entities/price_config_entity.dart';

abstract class PriceConfigState {}

class PriceConfigInitial extends PriceConfigState {}

class PriceConfigLoading extends PriceConfigState {}

class PriceConfigLoaded extends PriceConfigState {
  final List<PriceConfigEntity> configs;
  PriceConfigLoaded(this.configs);
}

class PriceConfigError extends PriceConfigState {
  final String message;
  PriceConfigError(this.message);
}
