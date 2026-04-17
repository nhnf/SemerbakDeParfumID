import '../../../domain/entities/price_config_entity.dart';
import '../../../domain/repositories/price_config_repository.dart';
import '../models/price_config_model.dart';
import '../datasources/remote/supabase_datasource.dart';

class PriceConfigRepositoryImpl implements PriceConfigRepository {
  final SupabaseDataSource remoteDataSource;

  PriceConfigRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PriceConfigEntity>> getPriceConfigs() async {
    return await remoteDataSource.getPriceConfigs();
  }

  @override
  Future<void> updatePriceConfig(PriceConfigEntity config) async {
    final model = PriceConfigModel.fromEntity(config);
    await remoteDataSource.updatePriceConfig(model);
  }
}
