import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateService {
  static Future<Map<String, dynamic>> checkForUpdate() async {
    final response = await http.get(
      Uri.parse('https://frostcore.onrender.com/latest'),
    );
    final latest = jsonDecode(response.body);
    final current = await PackageInfo.fromPlatform();

    bool updateAvailable = latest['version'] != current.version;
    return {'updateAvailable': updateAvailable, 'url': latest['url']};
  }

  static Future<void> downloadUpdate(
    String url,
    Function(double) onProgress,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/frostupdate.apk';

    await Dio().download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          onProgress(received / total);
        }
      },
    );

    // Optionally: launch APK installer using open_file package
  }
}
