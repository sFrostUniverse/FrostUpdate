import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../services/update_service.dart';
import 'package:open_file/open_file.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  String status = 'Checking for updates...';
  bool updateAvailable = false;
  String downloadUrl = '';
  double progress = 0.0;
  bool downloading = false;

  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  void _checkUpdate() async {
    setState(() {
      status = 'Checking for updates...';
      progress = 0.0;
      downloading = false;
    });

    final updateInfo = await UpdateService.checkForUpdate();

    setState(() {
      updateAvailable = updateInfo['updateAvailable'];
      downloadUrl = updateInfo['url'] ?? '';
      status = updateAvailable ? 'Update available!' : 'App is up-to-date ✅';
    });

    print('[DEBUG] Update available: $updateAvailable');
  }

  void _downloadUpdate() async {
    setState(() {
      status = 'Downloading update...';
      progress = 0.0;
      downloading = true;
    });

    final filePath = await UpdateService.downloadUpdate(downloadUrl, (p) {
      setState(() {
        progress = p;
      });
    });

    setState(() {
      downloading = false;
      status = filePath != null
          ? 'Download complete! Tap below to install.'
          : 'Download failed!';
    });

    if (filePath != null) {
      OpenFile.open(filePath); // opens APK installer
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FrostUpdate')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(status, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),

              // Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (updateAvailable && !downloading)
                    ElevatedButton(
                      onPressed: _downloadUpdate,
                      child: const Text('Update Now'),
                    ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _checkUpdate,
                    child: const Text('Refresh'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Progress Bar
              if (downloading)
                LinearPercentIndicator(
                  width: 250,
                  lineHeight: 14.0,
                  percent: progress,
                  center: Text("${(progress * 100).toStringAsFixed(0)}%"),
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  progressColor: Colors.blue,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
