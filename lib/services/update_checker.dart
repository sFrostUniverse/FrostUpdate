import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const FrostUpdateApp());
}

class FrostUpdateApp extends StatelessWidget {
  const FrostUpdateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FrostUpdate',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isChecking = false;
  double _progress = 0.0;
  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _appVersion = info.version);
  }

  Future<Map<String, dynamic>> fetchLatestUpdate() async {
    final response = await http.get(
      Uri.parse('https://frostcore.onrender.com/latest'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch update info');
    }
  }

  void _checkForUpdates() async {
    setState(() {
      _isChecking = true;
      _progress = 0.0;
    });

    try {
      final latest = await fetchLatestUpdate();
      final current = await PackageInfo.fromPlatform();

      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {
          _progress += 0.05;
          if (_progress >= 1.0) {
            _progress = 1.0;
            _isChecking = false;
            timer.cancel();

            if (latest['version'] != current.version) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Update available! Tap to download.'),
                  action: SnackBarAction(
                    label: 'Download',
                    onPressed: () async {
                      final url = Uri.parse(latest['url']);
                      if (await canLaunchUrl(url)) await launchUrl(url);
                    },
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Your app is up to date! ❄️')),
              );
            }
          }
        });
      });
    } catch (e) {
      setState(() => _isChecking = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error checking updates: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FrostUpdate')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'App Version: $_appVersion',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isChecking ? null : _checkForUpdates,
                  child: const Text('Check for Updates'),
                ),
                const SizedBox(height: 20),
                if (_isChecking)
                  CircularPercentIndicator(
                    radius: 60,
                    lineWidth: 8,
                    percent: _progress,
                    center: Text('${(_progress * 100).toInt()}%'),
                    progressColor: Colors.blue,
                    animation: true,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
