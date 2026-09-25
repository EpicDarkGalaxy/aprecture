import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:aprecture/services/logger.dart';
import 'package:path_provider/path_provider.dart';

class DownloadSnapshot {
  // Using DownloadSnapshot to track download progress because its easy to me
  final String name;
  final String url;
  final String filePath;
  bool isDownloading = true;
  bool isCompleted = false;
  double progress = 0.0;

  DownloadSnapshot({
    required this.name,
    required this.url,
    required this.filePath,
  });
}

class DownloadService extends ChangeNotifier {
  static final DownloadService _instance = DownloadService._internal();

  factory DownloadService() {
    return _instance;
  }
  DownloadService._internal() : _httpClient = http.Client();

  final http.Client _httpClient;
  final Map<String, DownloadSnapshot> _downloadQueue = {};

  void addToQueue(String packageName, DownloadSnapshot snapshot) {
    _downloadQueue[packageName] = snapshot;
    notifyListeners();
  }

  bool isDownloading(String packageName) {
    return _downloadQueue[packageName]?.isDownloading ?? false;
  }

  bool isCompleted(String packageName) {
    return _downloadQueue[packageName]?.isCompleted ?? false;
  }

  String? getFilePath(String packageName) {
    return _downloadQueue[packageName]?.filePath;
  }

  double getProgress(String packageName) {
    return _downloadQueue[packageName]?.progress ?? 0.0;
  }

  Future<void> downloadApp({
    required String url,
    required String packageName,
  }) async {
    if (isDownloading(packageName)) return; // Already downloading, skip

    final request = http.Request('GET', Uri.parse(url));
    try {
      final response = await _httpClient.send(request);

      final tmpDir = await getTemporaryDirectory();
      final filePath = '${tmpDir.path}/$packageName.apk';
      final sink = File(filePath).openWrite();

      if (response.statusCode != 200) {
        logger.e("Downloading app failed: status code ${response.statusCode}");
        return;
      } else {
        addToQueue(
          packageName,
          DownloadSnapshot(name: packageName, url: url, filePath: filePath),
        );
        logger.i("Downloading app started: $url");
      }

      final contentLength = response.contentLength;
      var downloadedBytes = 0;

      response.stream.listen(
        (List<int> data) {
          if (contentLength != null) {
            downloadedBytes += data.length;
            final progress = downloadedBytes / contentLength;
            _downloadQueue[packageName]?.progress = progress;
            sink.add(data);
            notifyListeners();
          }
        },
        onDone: () {
          // State: Downloading -> Completed
          _downloadQueue[packageName]?.isDownloading = false;
          _downloadQueue[packageName]?.isCompleted = true;
          sink.close();
          logger.d("Downloading app completed: $packageName");
          notifyListeners();
        },
        onError: (e) {
          logger.e("Downloading app failed: $e");
          _downloadQueue[packageName]?.isDownloading = false;
          sink.close();
          notifyListeners();
        },
      );
    } catch (e) {
      logger.e("Downloading app failed: $e");
      return;
    }
  }
}
