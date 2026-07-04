import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'shell_cubit.freezed.dart';
part 'shell_cubit.state.dart';

@lazySingleton
class ShellCubit extends Cubit<ShellState> {
  ShellCubit() : super(const ShellState(selectedActivity: ActivityId.explorer));

  void toggleSidebar() {
    emit(state.copyWith(sidebarCollapsed: !state.sidebarCollapsed));
  }

  void setSidebarCollapsed(bool value) {
    if (state.sidebarCollapsed == value) return;
    emit(state.copyWith(sidebarCollapsed: value));
  }

  void toggleRightPanel() {
    emit(state.copyWith(rightPanelCollapsed: !state.rightPanelCollapsed));
  }

  void setRightPanelCollapsed(bool value) {
    if (state.rightPanelCollapsed == value) return;
    emit(state.copyWith(rightPanelCollapsed: value));
  }

  void selectActivity(ActivityId id) {
    if (state.selectedActivity == id) return;
    emit(state.copyWith(selectedActivity: id));
  }

  void setPaneSizes(Map<String, double> sizes) {
    final next = {...state.paneSizes, ...sizes};
    emit(state.copyWith(paneSizes: next));
  }
}
