import 'package:flutter/material.dart';
import '../services/update_service.dart';
import '../widgets/progress_bar.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  String status = 'Checking for updates...';
  double progress = 0.0;
  bool updateAvailable = false;
  String downloadUrl = '';

  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  void _checkUpdate() async {
    final updateInfo = await UpdateService.checkForUpdate();
    setState(() {
      updateAvailable = updateInfo['updateAvailable'];
      downloadUrl = updateInfo['url'] ?? '';
      status = updateAvailable ? 'Update available!' : 'App is up-to-date ✅';
    });
  }

  void _downloadUpdate() async {
    setState(() {
      status = 'Downloading update...';
      progress = 0.0;
    });

    await UpdateService.downloadUpdate(downloadUrl, (p) {
      setState(() => progress = p);
    });

    setState(() => status = 'Download complete! Please install the update.');
    // Optionally: launch APK installer here
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
              if (updateAvailable && progress == 0.0)
                ElevatedButton(
                  onPressed: _downloadUpdate,
                  child: const Text('Update Now'),
                ),
              if (progress > 0.0)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ProgressBar(progress: progress),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
