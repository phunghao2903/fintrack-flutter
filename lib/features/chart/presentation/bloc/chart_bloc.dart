import 'package:bloc/bloc.dart';
import '../../domain/usecases/get_chart_data_usecase.dart';
import '../../domain/entities/chart.dart';

part 'chart_event.dart';
part 'chart_state.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {
  final GetChartDataUseCase getChartDataUseCase;
  ChartBloc({required this.getChartDataUseCase}) : super(ChartState.initial()) {
    on<LoadChartDataEvent>(_onLoadData);
    on<ChangeFilterEvent>(_onChangeFilter);
  }

  Future<void> _onLoadData(
    LoadChartDataEvent event,
    Emitter<ChartState> emit,
  ) async {
    final data = await getChartDataUseCase(state.selectedFilter);
    final incomeChange = calculateChange(data.map((e) => e.income).toList());
    final expenseChange = calculateChange(data.map((e) => e.expense).toList());

    emit(
      state.copyWith(
        chartData: data,
        incomeChangePercent: incomeChange,
        expenseChangePercent: expenseChange,
      ),
    );
  }

  Future<void> _onChangeFilter(
    ChangeFilterEvent event,
    Emitter<ChartState> emit,
  ) async {
    final data = await getChartDataUseCase(event.filter);
    final incomeChange = calculateChange(data.map((e) => e.income).toList());
    final expenseChange = calculateChange(data.map((e) => e.expense).toList());
    emit(
      state.copyWith(
        selectedFilter: event.filter,
        chartData: data,
        incomeChangePercent: incomeChange,
        expenseChangePercent: expenseChange,
      ),
    );
  }

  double calculateChange(List<double> values) {
    if (values.length < 2) return 0;

    final oldValue = values[values.length - 2];
    final newValue = values.last;

    if (oldValue == 0) {
      if (newValue == 0)
        return 0;
      else
        return 100;
    }

    return ((newValue - oldValue) / oldValue) * 100;
  }
}
