import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:aprecture/services/logger.dart';
import 'package:path_provider/path_provider.dart';

part 'download_service.g.dart';

class DownloadSnapshot {
  final String name;
  final String url;
  final String filePath;
  final bool isDownloading;
  final bool isLoading;
  final bool isCompleted;
  final double progress;

  DownloadSnapshot({
    required this.name,
    required this.url,
    required this.filePath,
    this.isDownloading = true,
    this.isLoading = true,
    this.isCompleted = false,
    this.progress = 0.0,
  });

  DownloadSnapshot copyWith({
    bool? isDownloading,
    bool? isLoading,
    bool? isCompleted,
    double? progress,
  }) {
    return DownloadSnapshot(
      name: name,
      url: url,
      filePath: filePath,
      isDownloading: isDownloading ?? this.isDownloading,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
    );
  }
}

@riverpod
bool isDownloading(Ref ref, String packageName) {
  final downloadsMap = ref.watch(downloadServiceProvider);
  return downloadsMap[packageName]?.isDownloading ?? false;
}

@riverpod
bool isLoading(Ref ref, String packageName) {
  final downloadsMap = ref.watch(downloadServiceProvider);
  return downloadsMap[packageName]?.isLoading ?? false;
}

@riverpod
bool isCompleted(Ref ref, String packageName) {
  final downloadsMap = ref.watch(downloadServiceProvider);
  return downloadsMap[packageName]?.isCompleted ?? false;
}

@riverpod
double downloadProgress(Ref ref, String packageName) {
  final downloadsMap = ref.watch(downloadServiceProvider);
  return downloadsMap[packageName]?.progress ?? 0.0;
}

@riverpod
class DownloadService extends _$DownloadService {
  late final http.Client _httpClient;

  @override
  Map<String, DownloadSnapshot> build() {
    _httpClient = http.Client();
    return {};
  }

  void _updateSnapshot(String packageName, DownloadSnapshot snapshot) {
    state = {...state, packageName: snapshot};
  }

  Future<void> downloadApp({
    required String url,
    required String packageName,
    required String name,
  }) async {
    if (state[packageName]?.isDownloading ?? false) return;

    try {
      final tmpDir = await getTemporaryDirectory();
      final filePath = '${tmpDir.path}/$packageName.apk';

      // 1. Initialize snapshot in state
      final initialSnapshot = DownloadSnapshot(
        name: name,
        url: url,
        filePath: filePath,
        isDownloading: true,
        isCompleted: false,
        isLoading: true,
        progress: 0.0,
      );
      _updateSnapshot(packageName, initialSnapshot);

      final request = http.Request('GET', Uri.parse(url));
      final response = await _httpClient.send(request);

      if (response.statusCode != 200) {
        logger.e("Download failed with status: ${response.statusCode}");
        _updateSnapshot(
          packageName,
          initialSnapshot.copyWith(isDownloading: false),
        );
        return;
      }

      final file = File(filePath);
      final sink = file.openWrite();
      final contentLength = response.contentLength ?? 0;
      var downloadedBytes = 0;

      await for (final chunk in response.stream) {
        downloadedBytes += chunk.length;
        sink.add(chunk);

        if (contentLength > 0) {
          final progress = downloadedBytes / contentLength;
          final current = state[packageName];
          if (current != null) {
            _updateSnapshot(
              packageName,
              current.copyWith(progress: progress, isLoading: false),
            );
          }
        }
      }

      await sink.flush();
      await sink.close();

      // 2. Mark download complete
      final finalSnapshot = state[packageName];
      if (finalSnapshot != null) {
        _updateSnapshot(
          packageName,
          finalSnapshot.copyWith(
            isDownloading: false,
            isCompleted: true,
            progress: 1.0,
          ),
        );
      }
      logger.i("Download complete: $packageName");
    } catch (e, stack) {
      logger.e("Download error: $e", stackTrace: stack);
      final current = state[packageName];
      if (current != null) {
        _updateSnapshot(packageName, current.copyWith(isDownloading: false));
      }
    }
  }
}
