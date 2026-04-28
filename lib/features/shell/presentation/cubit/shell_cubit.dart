import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'shell_cubit.freezed.dart';
part 'shell_cubit.state.dart';

@lazySingleton
class ShellCubit extends Cubit<ShellState> {
  ShellCubit()
      : super(const ShellState(
          sidePanelOpen: true,
          selectedActivity: ActivityId.explorer,
        ));

  void toggleSidePanel() {
    emit(state.copyWith(sidePanelOpen: !state.sidePanelOpen));
  }

  void setSidePanelOpen(bool value) {
    if (state.sidePanelOpen == value) return;
    emit(state.copyWith(sidePanelOpen: value));
  }

  void selectActivity(ActivityId id) {
    if (state.selectedActivity == id) return;
    emit(state.copyWith(selectedActivity: id));
  }
}
