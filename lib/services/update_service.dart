import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class UpdateService {
  // 👇 Change this if you want to switch between servers
  static const String baseUrl = "https://testupdate-38h1.onrender.com";

  static Future<Map<String, dynamic>> checkForUpdate() async {
    try {
      print('[DEBUG] Starting update check...');
      final response = await http
          .get(Uri.parse('$baseUrl/latest'))
          .timeout(const Duration(seconds: 10));

      print('[DEBUG] HTTP status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final latest = jsonDecode(response.body);
        final current = await PackageInfo.fromPlatform();

        print('[DEBUG] Current version: ${current.version}');
        print('[DEBUG] Latest version: ${latest['version']}');

        // Compare versions ignoring build number
        final currentVersionParts = current.version.split('.');
        final latestVersionParts = (latest['version'] ?? '').split('.');
        bool updateAvailable = false;

        for (int i = 0; i < latestVersionParts.length; i++) {
          final latestNum = int.tryParse(latestVersionParts[i]) ?? 0;
          final currentNum = i < currentVersionParts.length
              ? int.tryParse(currentVersionParts[i]) ?? 0
              : 0;
          if (latestNum > currentNum) {
            updateAvailable = true;
            break;
          } else if (latestNum < currentNum) {
            updateAvailable = false;
            break;
          }
        }

        return {'updateAvailable': updateAvailable, 'url': latest['url'] ?? ''};
      } else {
        print('[DEBUG] Failed to fetch latest version');
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
      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory(); // better for APK access
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      if (dir == null) return null;

      final filePath = '${dir.path}/frostupdate.apk';
      print('[DEBUG] Downloading APK to $filePath');

      await Dio().download(
        url,
        filePath,
        onReceiveProgress: (rec, total) {
          if (total != -1) onProgress(rec / total);
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
