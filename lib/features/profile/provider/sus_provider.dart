import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notable_moments/features/profile/provider/sus_state.dart';

final susProvider = StateNotifierProvider<SusNotifier, SusState>((ref) {
  return SusNotifier();
});

class SusNotifier extends StateNotifier<SusState> {
  SusNotifier() : super(SusState.initial()) {
    state = SusState(daysInARow: 3, energy: 1, suscoins: 10);
  }

  Future<void> feed() async {
    if (state.energy == 3) return;
    if (state.suscoins == 0) return;

    state = state.copyWith(suscoins: state.suscoins - 1, energy: state.energy + 1);
  }
}
