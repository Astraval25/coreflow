import 'dart:async';
import 'dart:io';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareIntentService {
  ShareIntentService._();

  static final ShareIntentService instance = ShareIntentService._();

  final StreamController<File> _fileController =
      StreamController<File>.broadcast();
  StreamSubscription<List<SharedMediaFile>>? _subscription;
  bool _initialized = false;

  Stream<File> get fileStream => _fileController.stream;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _subscription = ReceiveSharingIntent.instance.getMediaStream().listen((mediaFiles) {
      final files = _toFiles(mediaFiles);
      for (final file in files) {
        _fileController.add(file);
      }
    }, onError: (_) {});
  }

  Future<List<File>> getInitialFiles() async {
    final mediaFiles = await ReceiveSharingIntent.instance.getInitialMedia();
    return _toFiles(mediaFiles);
  }

  Future<void> clearReceivedFiles() async {
    ReceiveSharingIntent.instance.reset();
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _fileController.close();
  }

  List<File> _toFiles(List<SharedMediaFile> mediaFiles) {
    final files = <File>[];
    for (final media in mediaFiles) {
      final path = media.path;
      if (path.isEmpty) continue;
      final lower = path.toLowerCase();
      if (!_isSupportedFile(lower)) continue;
      files.add(File(path));
    }
    return files;
  }

  bool _isSupportedFile(String path) {
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif') ||
        path.endsWith('.pdf');
  }
}
