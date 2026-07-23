import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

Future<String?> persistCategoryLogo(PlatformFile file) async {
  final root = await getApplicationDocumentsDirectory();
  final directory = Directory('${root.path}/category_logos');
  await directory.create(recursive: true);
  final logoPath = '${directory.path}/${const Uuid().v4()}.png';
  if (file.bytes != null) {
    await File(logoPath).writeAsBytes(file.bytes!, flush: true);
  } else if (file.path != null) {
    await File(file.path!).copy(logoPath);
  } else {
    return null;
  }
  return logoPath;
}
