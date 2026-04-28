import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_node.freezed.dart';

@freezed
abstract class FileNode with _$FileNode {
  const factory FileNode({
    required String name,
    required String path,
    required bool isDir,
  }) = _FileNode;
}
