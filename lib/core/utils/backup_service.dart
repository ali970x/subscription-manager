import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/subscription_model.dart';

class BackupService {
  static Future<String> export(List<SubscriptionModel> items) async {
    final directory = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${directory.path}/subscriptions-$stamp.json');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'subscriptions': items.map((e) => e.toJson()).toList(),
      }),
      flush: true,
    );
    await Share.shareXFiles([
      XFile(file.path),
    ], subject: 'SubTrack - subscription backup');
    return file.path;
  }

  static Future<List<SubscriptionModel>?> import() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null) return null;
    final picked = result.files.single;
    final contents = picked.bytes != null
        ? utf8.decode(picked.bytes!)
        : await File(picked.path!).readAsString();
    final decoded = jsonDecode(contents);
    final list = decoded is List ? decoded : (decoded as Map)['subscriptions'];
    if (list is! List) throw const FormatException('Invalid backup file');
    return list
        .map(
          (e) =>
              SubscriptionModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }
}
