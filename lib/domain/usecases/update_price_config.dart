import '../entities/price_config_entity.dart';
import '../repositories/price_config_repository.dart';

class UpdatePriceConfig {
  final PriceConfigRepository repository;

  UpdatePriceConfig(this.repository);

  Future<void> execute(PriceConfigEntity config) async {
    return await repository.updatePriceConfig(config);
  }
}
