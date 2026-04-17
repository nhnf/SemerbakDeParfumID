import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_price_configs.dart';
import '../../../domain/usecases/update_price_config.dart';
import 'price_config_event.dart';
import 'price_config_state.dart';

class PriceConfigBloc extends Bloc<PriceConfigEvent, PriceConfigState> {
  final GetPriceConfigs getPriceConfigsUseCase;
  final UpdatePriceConfig updatePriceConfigUseCase;

  PriceConfigBloc({
    required this.getPriceConfigsUseCase,
    required this.updatePriceConfigUseCase,
  }) : super(PriceConfigInitial()) {
    on<LoadPriceConfigsEvent>((event, emit) async {
      emit(PriceConfigLoading());
      try {
        final configs = await getPriceConfigsUseCase.execute();
        emit(PriceConfigLoaded(configs));
      } catch (e) {
        emit(PriceConfigError('Gagal memuat konfigurasi harga: ${e.toString()}'));
      }
    });

    on<UpdatePriceConfigEvent>((event, emit) async {
      try {
        await updatePriceConfigUseCase.execute(event.config);
        add(LoadPriceConfigsEvent()); // Reload after update
      } catch (e) {
        // Option 1: Emit error. Option 2: just keep current state or show snackbar from UI
        // We will just print error here to not break full UI state, UI should handle loading.
        print('Error updating price config: $e');
        add(LoadPriceConfigsEvent()); 
      }
    });
  }
}
