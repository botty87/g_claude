import 'dart:async';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as p;

import '../../../../core/error/failures.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../../git/domain/entities/git_branch.dart';
import '../../../git/domain/entities/git_folder_inspection.dart';
import '../../../git/domain/entities/git_worktree.dart';
import '../../../git/domain/worktree_path.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import 'glass_dialog.dart';

/// Two ways to add a worktree: create a new branch (+ its worktree), or open an
/// existing folder on disk (which Clyde inspects — worktree / repo / plain).
enum _Mode { newBranch, openExisting }

Future<void> showNewWorktreeDialog(
  BuildContext context, {
  required String repoRoot,
  required List<GitWorktree> worktrees,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: kGlassDialogBarrier,
    builder: (_) => NewWorktreeDialog(repoRoot: repoRoot, worktrees: worktrees),
  );
}

String _messageOf(Failure f) => switch (f) {
  SubprocessFailure(:final message) => message,
  UnexpectedFailure(:final message) => message,
  NotFoundFailure(:final message) => message,
  _ => f.toString(),
};

class NewWorktreeDialog extends HookWidget {
  const NewWorktreeDialog({super.key, required this.repoRoot, required this.worktrees});

  final String repoRoot;
  final List<GitWorktree> worktrees;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkspacesCubit>();

    final branchesFuture = useMemoized(() => cubit.branchesFor(repoRoot), [repoRoot]);
    final branchesSnap = useFuture(branchesFuture, initialData: const <GitBranch>[]);
    final allBranches = branchesSnap.data ?? const <GitBranch>[];
    // Depends only on the branch list, not on the name being typed — memoize so
    // keystrokes in the name field don't re-partition + re-allocate the items.
    final baseItems = useMemoized(() => _baseRefItems(allBranches), [allBranches]);

    // Repo default branch = the main worktree, always listed first by git.
    final currentBranch = worktrees.firstWhereOrNull((w) => !w.isBare)?.branch;

    final mode = useState(_Mode.newBranch);
    final error = useState<Failure?>(null);
    final busy = useState(false);

    // --- New-branch mode state ---
    final nameController = useTextEditingController();
    final name = useState('');
    useEffect(() {
      void l() => name.value = nameController.text;
      nameController.addListener(l);
      return () => nameController.removeListener(l);
    }, [nameController]);
    // Conventional-commit prefix (key, '' = none); the final branch is
    // `<prefix>/<name>`. Defaults to `feat`.
    final prefix = useState<String>(_CcPrefix.feat.key);

    final baseRef = useState<String?>(currentBranch);
    final pathController = useTextEditingController();
    final pathScrollController = useScrollController();
    final pathText = useState('');
    useEffect(() {
      void l() => pathText.value = pathController.text;
      pathController.addListener(l);
      return () => pathController.removeListener(l);
    }, [pathController]);
    final lastSuggested = useState('');
    final openAfter = useState(true);

    final composedBranch = composeBranchName(prefix.value, name.value.trim());
    final suggested = defaultWorktreePath(repoRoot: repoRoot, branch: composedBranch);
    useEffect(() {
      if (pathController.text.isEmpty || pathController.text == lastSuggested.value) {
        pathController.text = suggested;
        lastSuggested.value = suggested;
      }
      // The interesting part (the branch just typed) is the path's tail; keep it
      // in view without the user scrolling the field by hand. Post-frame so the
      // scroll extent reflects the text set this build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pathScrollController.hasClients) {
          pathScrollController.jumpTo(pathScrollController.position.maxScrollExtent);
        }
      });
      return null;
    }, [suggested]);

    // --- Open-existing mode state ---
    final existingController = useTextEditingController();
    final existingPath = useState('');
    useEffect(() {
      Timer? debounce;
      void l() {
        debounce?.cancel();
        debounce = Timer(const Duration(milliseconds: 350), () => existingPath.value = existingController.text.trim());
      }

      existingController.addListener(l);
      return () {
        debounce?.cancel();
        existingController.removeListener(l);
      };
    }, [existingController]);

    final inspectFuture = useMemoized(
      () => existingPath.value.isEmpty
          ? Future.value(const GitFolderInspection())
          : cubit.inspectFolder(existingPath.value),
      [existingPath.value],
    );
    final inspectSnap = useFuture(inspectFuture, initialData: const GitFolderInspection());
    final inspection = inspectSnap.data ?? const GitFolderInspection();

    final isNew = mode.value == _Mode.newBranch;
    final canConfirm =
        !busy.value &&
        (isNew ? (name.value.trim().isNotEmpty && pathText.value.trim().isNotEmpty) : existingPath.value.isNotEmpty);

    Future<void> pickNewBranchFolder() async {
      final picked = await FilePicker.getDirectoryPath(
        dialogTitle: Locales.Shell.NewWorktree.pathLabel,
        initialDirectory: repoRoot,
      );
      if (picked == null) return;
      final branch = composeBranchName(prefix.value, name.value.trim());
      pathController.text = branch.isEmpty ? picked : p.join(picked, branch);
      lastSuggested.value = '';
    }

    Future<void> pickExistingFolder() async {
      final picked = await FilePicker.getDirectoryPath(
        dialogTitle: Locales.Shell.NewWorktree.cartellaLabel,
        initialDirectory: repoRoot,
      );
      if (picked == null) return;
      existingController.text = picked;
      existingPath.value = picked; // immediate, bypass the type-debounce
    }

    Future<void> confirmNewBranch() async {
      final target = pathController.text.trim();
      if (target.isEmpty) return; // guard: never resolve an empty path to the cwd
      busy.value = true;
      error.value = null;
      final result = await cubit.createWorktree(
        repoRoot: repoRoot,
        targetPath: target,
        newBranch: composeBranchName(prefix.value, name.value.trim()),
        baseRef: baseRef.value,
        openAfter: openAfter.value,
      );
      if (!context.mounted) return;
      result.fold((failure) {
        error.value = failure;
        busy.value = false;
      }, (_) => Navigator.of(context).pop());
    }

    Future<void> openExistingFolder() async {
      busy.value = true;
      error.value = null;
      await cubit.openPath(existingPath.value);
      if (!context.mounted) return;
      Navigator.of(context).pop();
    }

    return GlassDialog(
      width: 480,
      children: [
        GlassDialogHeader(
          icon: isNew ? Symbols.account_tree : Symbols.folder_open,
          iconTint: AppColors.primary,
          title: Locales.Shell.NewWorktree.title,
          onClose: busy.value ? null : () => Navigator.of(context).pop(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: GlassSegmented<_Mode>(
            value: mode.value,
            onChanged: busy.value ? null : (m) => mode.value = m,
            segments: [
              GlassSegment(
                value: _Mode.newBranch,
                label: Locales.Shell.NewWorktree.modeNew,
                icon: Symbols.account_tree,
              ),
              GlassSegment(
                value: _Mode.openExisting,
                label: Locales.Shell.NewWorktree.modeExisting,
                icon: Symbols.folder_open,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNew)
                ..._newBranchFields(
                  context: context,
                  busy: busy.value,
                  nameController: nameController,
                  nameActive: name.value.trim().isNotEmpty,
                  prefix: prefix,
                  baseRef: baseRef,
                  allBranches: allBranches,
                  baseItems: baseItems,
                  pathController: pathController,
                  pathScrollController: pathScrollController,
                  openAfter: openAfter,
                  onPickFolder: busy.value ? null : pickNewBranchFolder,
                )
              else
                ..._openExistingFields(
                  context: context,
                  busy: busy.value,
                  controller: existingController,
                  hasPath: existingPath.value.isNotEmpty,
                  inspection: inspection,
                  onBrowse: busy.value ? null : pickExistingFolder,
                ),
              if (error.value != null) ...[
                const SizedBox(height: 10),
                Text(
                  _messageOf(error.value!),
                  style: AppTypography.navTab.copyWith(fontSize: 12, height: 1.4, color: AppColors.error),
                ),
              ],
            ],
          ),
        ),
        GlassDialogActions(
          cancelLabel: Locales.Shell.NewWorktree.cancel,
          onCancel: busy.value ? null : () => Navigator.of(context).pop(),
          confirmLabel: isNew ? Locales.Shell.NewWorktree.create : Locales.Shell.NewWorktree.openConfirm,
          confirmIcon: isNew ? Symbols.account_tree : Symbols.download,
          confirmKey: const ValueKey('new_worktree_confirm'),
          confirmBusy: busy.value,
          onConfirm: canConfirm ? (isNew ? confirmNewBranch : openExistingFolder) : null,
        ),
      ],
    );
  }
}

List<Widget> _newBranchFields({
  required BuildContext context,
  required bool busy,
  required TextEditingController nameController,
  required bool nameActive,
  required ValueNotifier<String> prefix,
  required ValueNotifier<String?> baseRef,
  required List<GitBranch> allBranches,
  required List<DropdownMenuItem<String?>> baseItems,
  required TextEditingController pathController,
  required ScrollController pathScrollController,
  required ValueNotifier<bool> openAfter,
  required VoidCallback? onPickFolder,
}) {
  final hasPrefix = prefix.value.isNotEmpty;
  return [
    GlassFieldLabel(Locales.Shell.NewWorktree.branchNameLabel),
    GlassField(
      active: nameActive,
      child: Row(
        children: [
          // The branch icon doubles as the always-reachable prefix picker, so a
          // `(nessuno)` selection (which hides the chip + `/`) is never a trap.
          _PrefixDropdown(prefix: prefix, enabled: !busy),
          if (hasPrefix) ...[const SizedBox(width: 6), Text('/', style: _monoInput.copyWith(color: AppColors.outline))],
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              key: const ValueKey('new_worktree_branch_name'),
              controller: nameController,
              enabled: !busy,
              style: _monoInput,
              cursorColor: AppColors.brandIndigo,
              decoration: _fieldInputDecoration(Locales.Shell.NewWorktree.branchNameHint),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 14),
    GlassFieldLabel(Locales.Shell.NewWorktree.baseRefLabel),
    GlassField(
      child: _GlassDropdown<String?>(
        fieldKey: const ValueKey('new_worktree_base_ref'),
        value: baseRef.value,
        onChanged: busy
            ? null
            : (v) {
                baseRef.value = v;
                // Basing on a remote (`origin/foo`) with no name typed yet:
                // suggest the local branch name `foo` (strip the remote prefix).
                if (v == null || nameController.text.trim().isNotEmpty) return;
                final picked = allBranches.firstWhereOrNull((b) => b.name == v);
                if (picked != null && picked.isRemote && v.contains('/')) {
                  // The remote name already carries its own structure — don't
                  // wrap it in a conventional-commit prefix.
                  prefix.value = '';
                  nameController.text = v.substring(v.indexOf('/') + 1);
                }
              },
        items: baseItems,
      ),
    ),
    const SizedBox(height: 14),
    GlassFieldLabel(Locales.Shell.NewWorktree.pathLabel),
    GlassField(
      height: 44,
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Row(
        children: [
          const Icon(Symbols.folder, size: 16, color: AppColors.secondary),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              key: const ValueKey('new_worktree_path'),
              controller: pathController,
              scrollController: pathScrollController,
              enabled: !busy,
              style: _monoInput.copyWith(fontSize: 11.5, color: AppColors.onSurfaceVariant),
              cursorColor: AppColors.brandIndigo,
              decoration: _fieldInputDecoration(null),
            ),
          ),
          const SizedBox(width: 8),
          _BrowseButton(
            buttonKey: const ValueKey('new_worktree_pick_folder'),
            onTap: onPickFolder,
            label: Locales.Shell.NewWorktree.pickFolder,
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),
    Hoverable(
      cursor: busy ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onTap: busy ? null : () => openAfter.value = !openAfter.value,
      builder: (context, hover) => Row(
        children: [
          GlassSwitch(key: const ValueKey('new_worktree_open_after'), value: openAfter.value),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              Locales.Shell.NewWorktree.openAfter,
              style: AppTypography.navTab.copyWith(fontSize: 12.5, color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    ),
  ];
}

List<Widget> _openExistingFields({
  required BuildContext context,
  required bool busy,
  required TextEditingController controller,
  required bool hasPath,
  required GitFolderInspection inspection,
  required VoidCallback? onBrowse,
}) {
  return [
    GlassFieldLabel(Locales.Shell.NewWorktree.cartellaLabel),
    GlassField(
      height: 44,
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Row(
        children: [
          const Icon(Symbols.folder, size: 16, color: AppColors.secondary),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              key: const ValueKey('new_worktree_existing_path'),
              controller: controller,
              enabled: !busy,
              style: _monoInput.copyWith(fontSize: 11.5, color: AppColors.onSurfaceVariant),
              cursorColor: AppColors.brandIndigo,
              decoration: _fieldInputDecoration(Locales.Shell.NewWorktree.cartellaHint),
            ),
          ),
          const SizedBox(width: 8),
          _BrowseButton(
            buttonKey: const ValueKey('new_worktree_existing_browse'),
            onTap: onBrowse,
            label: Locales.Shell.NewWorktree.pickFolder,
          ),
        ],
      ),
    ),
    if (hasPath && inspection.isGit) ...[const SizedBox(height: 14), _DetectionCard(inspection: inspection)],
    const SizedBox(height: 12),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Symbols.info, size: 15, color: AppColors.outline),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            Locales.Shell.NewWorktree.fallbackInfo,
            style: AppTypography.navTab.copyWith(fontSize: 11.5, height: 1.5, color: AppColors.outline),
          ),
        ),
      ],
    ),
  ];
}

/// Base-ref dropdown items: local branches, then only the remote-tracking
/// branches with NO local counterpart, each group under a non-selectable
/// header. When a branch exists both locally and on origin we keep just the
/// local (default local) and collapse the `origin/<name>` twin: a remote earns
/// its own row only when there's no local branch to base on. A remote base
/// creates a tracking local branch (`worktree add -b <local> <path> origin/x`).
List<DropdownMenuItem<String?>> _baseRefItems(List<GitBranch> branches) {
  final locals = branches.where((b) => !b.isRemote).toList(growable: false);
  final localNames = locals.map((b) => b.name).toSet();
  final remoteOnly = branches
      .where((b) => b.isRemote && !localNames.contains(_bareBranchName(b.name)))
      .toList(growable: false);
  return [
    if (locals.isNotEmpty) _dropdownHeader(Locales.Shell.NewWorktree.baseLocalGroup, ':local'),
    for (final b in locals)
      DropdownMenuItem(
        value: b.name,
        child: Text(b.name, style: _monoInput),
      ),
    if (remoteOnly.isNotEmpty) _dropdownHeader(Locales.Shell.NewWorktree.baseRemoteGroup, ':remote'),
    for (final b in remoteOnly)
      DropdownMenuItem(
        value: b.name,
        child: Row(
          children: [
            const Icon(Symbols.cloud, size: 12, color: AppColors.outline),
            const SizedBox(width: 6),
            Expanded(
              child: Text(b.name, style: _monoInput, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
  ];
}

/// The branch name a remote-tracking ref maps to, minus its remote prefix:
/// `origin/main` -> `main`, `origin/feature/x` -> `feature/x`.
String _bareBranchName(String remoteRef) {
  final i = remoteRef.indexOf('/');
  return i < 0 ? remoteRef : remoteRef.substring(i + 1);
}

/// A disabled group label inside a dropdown. [sentinel] is a value that can
/// never equal a branch name, so it never matches the selected `value`.
DropdownMenuItem<String?> _dropdownHeader(String label, String sentinel) => DropdownMenuItem<String?>(
  enabled: false,
  value: sentinel,
  child: Text(
    label,
    style: AppTypography.navTab.copyWith(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.outline),
  ),
);

/// Composes the final branch name from a conventional-commit [prefix] key and
/// the free-text [name]: `feat` + `nuovo-flusso` → `feat/nuovo-flusso`. An empty
/// prefix (the "(none)" option) — or an empty name — yields just the name, so a
/// branch like `main`/`develop` carries no prefix.
@visibleForTesting
String composeBranchName(String prefix, String name) => (prefix.isEmpty || name.isEmpty) ? name : '$prefix/$name';

/// Conventional-commit prefixes offered in the branch-name field. [key] is the
/// literal git prefix (`feat`, `fix`, …); the empty [key] is "(none)" → the
/// branch gets no prefix. Colors map to Glass Graphite tokens (design 6b).
enum _CcPrefix {
  none(''),
  feat('feat'),
  fix('fix'),
  refactor('refactor'),
  chore('chore'),
  docs('docs'),
  test('test'),
  hotfix('hotfix');

  const _CcPrefix(this.key);
  final String key;

  String get description => switch (this) {
    _CcPrefix.none => Locales.Shell.NewWorktree.ccPrefixNoneDesc,
    _CcPrefix.feat => Locales.Shell.NewWorktree.ccPrefixFeatDesc,
    _CcPrefix.fix => Locales.Shell.NewWorktree.ccPrefixFixDesc,
    _CcPrefix.refactor => Locales.Shell.NewWorktree.ccPrefixRefactorDesc,
    _CcPrefix.chore => Locales.Shell.NewWorktree.ccPrefixChoreDesc,
    _CcPrefix.docs => Locales.Shell.NewWorktree.ccPrefixDocsDesc,
    _CcPrefix.test => Locales.Shell.NewWorktree.ccPrefixTestDesc,
    _CcPrefix.hotfix => Locales.Shell.NewWorktree.ccPrefixHotfixDesc,
  };

  /// Text shown in the chip / menu key column ("(none)" for [none], else [key]).
  String get label => this == _CcPrefix.none ? Locales.Shell.NewWorktree.ccPrefixNoneLabel : key;

  Color get color => switch (this) {
    _CcPrefix.feat => AppColors.primary,
    _CcPrefix.hotfix => AppColors.tertiary,
    _CcPrefix.none => AppColors.outline,
    _ => AppColors.secondary,
  };
}

/// The conventional-commit prefix picker inside the branch-name field: a compact
/// chip (branch icon + colored key + chevron) opening a menu of keyed options
/// with descriptions. The branch icon is always present, so selecting "(none)"
/// — which hides the key text and the `/` separator — never traps the user.
class _PrefixDropdown extends StatelessWidget {
  const _PrefixDropdown({required this.prefix, required this.enabled});

  final ValueNotifier<String> prefix;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final current = _CcPrefix.values.firstWhere((t) => t.key == prefix.value, orElse: () => _CcPrefix.none);
    final hasPrefix = current != _CcPrefix.none;
    return PopupMenuButton<_CcPrefix>(
      key: const ValueKey('new_worktree_branch_prefix'),
      enabled: enabled,
      tooltip: '',
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      color: AppColors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      onSelected: (t) => prefix.value = t.key,
      itemBuilder: (context) => [
        for (final t in _CcPrefix.values)
          PopupMenuItem(
            value: t,
            height: 40,
            child: Row(
              children: [
                SizedBox(
                  width: 74,
                  child: Text(t.label, style: _monoInput.copyWith(color: t.color, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.description,
                    style: AppTypography.navTab.copyWith(fontSize: 11.5, color: AppColors.onSurfaceVariant),
                  ),
                ),
                if (t.key == prefix.value) ...[
                  const SizedBox(width: 8),
                  const Icon(Symbols.check, size: 14, color: AppColors.primary),
                ],
              ],
            ),
          ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Symbols.account_tree, size: 14, color: hasPrefix ? current.color : AppColors.brandIndigo),
          if (hasPrefix) ...[
            const SizedBox(width: 5),
            Text(current.key, style: _monoInput.copyWith(color: current.color)),
          ],
          const Icon(Symbols.expand_more, size: 14, color: AppColors.outline),
        ],
      ),
    );
  }
}

/// Green card summarizing a detected git repo/worktree before opening it.
class _DetectionCard extends StatelessWidget {
  const _DetectionCard({required this.inspection});

  final GitFolderInspection inspection;

  @override
  Widget build(BuildContext context) {
    final dirty = inspection.dirtyCount;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.agentRunning.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.agentRunning.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Symbols.check_circle, size: 16, color: AppColors.agentRunning),
              const SizedBox(width: 8),
              Text(
                inspection.isWorktree
                    ? Locales.Shell.NewWorktree.detectedWorktree
                    : Locales.Shell.NewWorktree.detectedRepo,
                style: AppTypography.navTab.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          _row(Locales.Shell.NewWorktree.fieldRepository, inspection.repoName ?? '—', AppColors.onSurfaceVariant),
          const SizedBox(height: 6),
          _row(Locales.Shell.NewWorktree.fieldBranch, inspection.branch ?? '—', AppColors.primary),
          const SizedBox(height: 6),
          _row(
            Locales.Shell.NewWorktree.fieldStatus,
            dirty == 0
                ? Locales.Shell.NewWorktree.cleanStatus
                : Locales.Shell.NewWorktree.dirtyChanges(count: '$dirty'),
            dirty == 0 ? AppColors.secondary : AppColors.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 74,
          child: Text(label, style: AppTypography.navTab.copyWith(fontSize: 11.5, color: AppColors.outline)),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.terminalCode.copyWith(fontSize: 11.5, height: 1.3, color: valueColor),
          ),
        ),
      ],
    );
  }
}

final TextStyle _monoInput = AppTypography.terminalCode.copyWith(
  fontSize: 12.5,
  height: 1.2,
  color: AppColors.onSurface,
);

InputDecoration _fieldInputDecoration(String? hint) => InputDecoration(
  isDense: true,
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  contentPadding: EdgeInsets.zero,
  hintText: hint,
  hintStyle: _monoInput.copyWith(color: AppColors.outline),
);

/// Borderless dropdown that fills a [GlassField], with a Symbols expand icon.
class _GlassDropdown<T> extends StatelessWidget {
  const _GlassDropdown({
    required this.fieldKey,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  final Key fieldKey;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onChanged == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          key: fieldKey,
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          isDense: true,
          hint: hint == null ? null : Text(hint!, style: _monoInput.copyWith(color: AppColors.outline)),
          icon: const Icon(Symbols.expand_more, size: 16, color: AppColors.outline),
          dropdownColor: AppColors.surfaceContainerHigh,
          style: _monoInput,
          borderRadius: BorderRadius.circular(9),
        ),
      ),
    );
  }
}

class _BrowseButton extends StatelessWidget {
  const _BrowseButton({required this.buttonKey, required this.onTap, required this.label});

  final Key buttonKey;
  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: Hoverable(
        key: buttonKey,
        cursor: onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
        onTap: onTap,
        builder: (context, hover) => Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hover && onTap != null ? AppColors.surfaceContainerHighest : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(label, style: AppTypography.navTab.copyWith(fontSize: 12, color: AppColors.onSurface)),
        ),
      ),
    );
  }
}
