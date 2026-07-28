import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SalaryFileService {
  static Future<String> shareSalarySlip({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final directory = await getTemporaryDirectory();
    final safeFileName = fileName.toLowerCase().endsWith('.pdf')
        ? fileName
        : '$fileName.pdf';
    final file = File('${directory.path}/$safeFileName');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: safeFileName,
      ),
    );
    return file.path;
  }
}
