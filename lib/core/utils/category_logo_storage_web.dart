import 'dart:convert';
import 'package:file_picker/file_picker.dart';

Future<String?> persistCategoryLogo(PlatformFile file) async {
  final bytes = file.bytes;
  if (bytes == null) return null;
  return 'data:image/png;base64,${base64Encode(bytes)}';
}
