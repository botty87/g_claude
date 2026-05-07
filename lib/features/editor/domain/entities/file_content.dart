import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_content.freezed.dart';

@freezed
abstract class FileContent with _$FileContent {
  const factory FileContent({required String path, required String content, String? language, required int sizeBytes}) =
      _FileContent;
}
