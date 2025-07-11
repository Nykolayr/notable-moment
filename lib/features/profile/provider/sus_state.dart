class SusState {
  final int daysInARow;
  final int energy;
  final int suscoins;

  const SusState({required this.daysInARow, required this.energy, required this.suscoins});

  factory SusState.initial() => SusState(daysInARow: 0, energy: 0, suscoins: 0);

  SusState copyWith({int? daysInARow, int? energy, int? suscoins}) => SusState(
    daysInARow: daysInARow ?? this.daysInARow,
    energy: energy ?? this.energy,
    suscoins: suscoins ?? this.suscoins,
  );
}
