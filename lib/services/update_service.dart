import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateService {
  static Future<Map<String, dynamic>> checkForUpdate() async {
    try {
      print('[DEBUG] Starting update check...');
      final response = await http
          .get(Uri.parse('https://frostcore.onrender.com/latest'))
          .timeout(const Duration(seconds: 10));

      print('[DEBUG] HTTP status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final latest = jsonDecode(response.body);
        final current = await PackageInfo.fromPlatform();
        print('[DEBUG] Current version: ${current.version}');
        print('[DEBUG] Latest version: ${latest['version']}');

        bool updateAvailable = latest['version'] != current.version;
        return {'updateAvailable': updateAvailable, 'url': latest['url']};
      } else {
        return {'updateAvailable': false, 'url': ''};
      }
    } catch (e) {
      print('[DEBUG] Error fetching update: $e');
      return {'updateAvailable': false, 'url': ''};
    }
  }

  static Future<String?> downloadUpdate(
    String url,
    Function(double) onProgress,
  ) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/frostupdate.apk';
      print('[DEBUG] Downloading APK to $filePath');

      await Dio().download(
        url,
        filePath,
        onReceiveProgress: (rec, total) {
          if (total != -1) {
            onProgress(rec / total);
          }
        },
      );

      print('[DEBUG] Download complete');
      return filePath;
    } catch (e) {
      print('[DEBUG] Download failed: $e');
      return null;
    }
  }
}
