import '../entities/price_config_entity.dart';

abstract class PriceConfigRepository {
  Future<List<PriceConfigEntity>> getPriceConfigs();
  Future<void> updatePriceConfig(PriceConfigEntity config);
}
