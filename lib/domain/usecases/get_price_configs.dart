import '../entities/price_config_entity.dart';
import '../repositories/price_config_repository.dart';

class GetPriceConfigs {
  final PriceConfigRepository repository;

  GetPriceConfigs(this.repository);

  Future<List<PriceConfigEntity>> execute() async {
    return await repository.getPriceConfigs();
  }
}
