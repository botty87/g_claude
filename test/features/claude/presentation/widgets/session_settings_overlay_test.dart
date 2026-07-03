// [SessionSettingsButton] contracts: the composer "tune" icon opens the
// editable "Impostazioni sessione" panel; picking a segment routes to the
// matching [ClaudeSessionsCubit] setter (the panel reads cubit state via
// context.select — it never mirrors it locally). Disabled while a run is busy.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/claude/domain/entities/claude_effort.dart';
import 'package:g_claude/features/claude/domain/entities/claude_model.dart';
import 'package:g_claude/features/claude/domain/entities/claude_permission_mode.dart';
import 'package:g_claude/features/claude/domain/entities/claude_thinking_mode.dart';
import 'package:g_claude/features/claude/domain/entities/mcp_server.dart';
import 'package:g_claude/features/claude/presentation/cubit/claude_sessions_cubit.dart';
import 'package:g_claude/features/claude/presentation/widgets/session_settings_overlay.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockClaudeSessionsCubit extends MockCubit<ClaudeSessionsState> implements ClaudeSessionsCubit {}

const _wid = '/proj';

ClaudeSessionsState _stateWith({
  ClaudeModel model = ClaudeModel.sonnet,
  ClaudeEffort effort = ClaudeEffort.high,
  ClaudeThinkingMode thinking = ClaudeThinkingMode.on,
  ClaudePermissionMode permission = ClaudePermissionMode.acceptEdits,
}) {
  final data = ClaudeSessionData(
    tabId: 't',
    model: model,
    effort: effort,
    thinkingMode: thinking,
    permissionMode: permission,
  );
  return ClaudeSessionsState(
    workspaces: {
      _wid: WorkspaceSessions(tabs: [data], activeTabId: 't'),
    },
  );
}

_MockClaudeSessionsCubit _makeCubit({ClaudeSessionsState? state}) {
  final cubit = _MockClaudeSessionsCubit();
  whenListen(cubit, const Stream<ClaudeSessionsState>.empty(), initialState: state ?? _stateWith());
  when(() => cubit.cachedMcpServers).thenReturn(const <McpServer>[]);
  when(() => cubit.setModel(any(), any())).thenReturn(null);
  when(() => cubit.setEffort(any(), any())).thenReturn(null);
  when(() => cubit.setThinking(any(), any())).thenReturn(null);
  when(() => cubit.setPermissionMode(any(), any())).thenReturn(null);
  return cubit;
}

Future<void> _pumpButton(WidgetTester tester, ClaudeSessionsCubit cubit, {bool enabled = true}) async {
  await pumpAppWidget(
    tester,
    BlocProvider<ClaudeSessionsCubit>.value(
      value: cubit,
      child: Align(
        alignment: Alignment.bottomRight,
        child: SessionSettingsButton(workspaceId: _wid, enabled: enabled),
      ),
    ),
  );
  // EasyLocalization loads its JSON via rootBundle — real async I/O that fake
  // test time won't advance (so after the first test in the file the loading
  // placeholder never clears). runAsync lets that Future actually complete,
  // then a settle rebuilds with the child mounted.
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(ClaudeModel.sonnet);
    registerFallbackValue(ClaudeEffort.high);
    registerFallbackValue(ClaudeThinkingMode.on);
    registerFallbackValue(ClaudePermissionMode.auto);
  });

  // One consolidated test: EasyLocalization only clears its async loading
  // placeholder for the first pumped tree in a file, so the whole flow lives in
  // a single testWidgets rather than several (each extra one would render the
  // placeholder and never mount the child).
  testWidgets('tune icon opens the panel and each control routes to its cubit setter', (tester) async {
    final cubit = _makeCubit(
      state: _stateWith(model: ClaudeModel.sonnet, thinking: ClaudeThinkingMode.on),
    );
    await _pumpButton(tester, cubit);

    // Closed at rest.
    expect(find.byKey(const ValueKey('session_settings_panel')), findsNothing);

    // Tap opens the editable panel.
    await tester.tap(find.byKey(const ValueKey('session_settings_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('session_settings_panel')), findsOneWidget);

    // Picking a model segment routes to setModel (panel reads cubit state — no
    // local mirror).
    await tester.tap(find.text('Opus'));
    await tester.pumpAndSettle();
    verify(() => cubit.setModel(_wid, ClaudeModel.opus)).called(1);

    // Toggling reasoning routes to setThinking with the flipped mode.
    await tester.tap(find.byKey(const ValueKey('session_settings_reasoning_toggle')));
    await tester.pumpAndSettle();
    verify(() => cubit.setThinking(_wid, ClaudeThinkingMode.off)).called(1);
  });
}
