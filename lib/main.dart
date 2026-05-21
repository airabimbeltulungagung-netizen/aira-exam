import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
  );

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize(
    "0b5ac2da-2c7c-4051-b579-d9efb7ed6609",
  );

  OneSignal.Notifications.requestPermission(true);

  OneSignal.Notifications.addForegroundWillDisplayListener((event) async {
    final title = event.notification.title ?? "Pengumuman AIRA";
    final body = event.notification.body ?? "";

    await ServiceNotifikasiLokal.simpanKeHistori(title, body);
  });

  OneSignal.Notifications.addClickListener((event) async {
    final title = event.notification.title ?? "Pengumuman AIRA";
    final body = event.notification.body ?? "";

    await ServiceNotifikasiLokal.simpanKeHistori(title, body);
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AIRA EXAM",
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
        ),
      ),
      home: const HalamanLoadingAwal(),
    );
  }
}

class HalamanLoadingAwal extends StatefulWidget {
  const HalamanLoadingAwal({super.key});

  @override
  State<HalamanLoadingAwal> createState() => _HalamanLoadingAwalState();
}

class _HalamanLoadingAwalState extends State<HalamanLoadingAwal> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WelcomePage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/ic_launcher.png',
                  width: 115,
                  height: 115,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.shield_rounded,
                      size: 80,
                      color: Color(0xFF6C5CE7),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'AIRA EXAM SYSTEM',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Secure, Integrity, & Professional EdTech',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              color: Color(0xFFFFD200),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int _jumlahNotif = 0;

  @override
  void initState() {
    super.initState();
    _hitungNotif();
  }

  Future<void> _hitungNotif() async {
    final data = await ServiceNotifikasiLokal.ambilHistori();

    if (!mounted) return;

    setState(() {
      _jumlahNotif = data.length;
    });
  }

  Future<void> _bukaWA() async {
    final Uri url = Uri.parse(
      "https://wa.me/6285704351856",
    );

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _bukaWeb() async {
    final Uri url = Uri.parse(
      "https://airabimbel.biz.id",
    );

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<bool> _pakta() async {
    final hasil = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "Konfirmasi Sesi Ujian",
          ),
          content: const Text(
            "Pastikan Anda siap memulai ujian.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("BATAL"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("MULAI"),
            ),
          ],
        );
      },
    );

    return hasil ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFF6C5CE7),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const KotakNotifikasiPage(),
                    ),
                  );

                  _hitungNotif();
                },
              ),
              if (_jumlahNotif > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_jumlahNotif',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                )
            ],
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/ic_launcher.png',
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "AIRA EXAM SYSTEM",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    bool lanjut = await _pakta();

                    if (!lanjut) return;

                    if (!mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HalamanLoadingPortal(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: const Text(
                    "MULAI UJIAN SEKARANG",
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _bukaWA,
                      icon: const Icon(Icons.chat),
                      label: const Text("CHAT ADMIN"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _bukaWeb,
                      icon: const Icon(Icons.language),
                      label: const Text("WEB UTAMA"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HalamanLoadingPortal extends StatefulWidget {
  const HalamanLoadingPortal({super.key});

  @override
  State<HalamanLoadingPortal> createState() => _HalamanLoadingPortalState();
}

class _HalamanLoadingPortalState extends State<HalamanLoadingPortal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  double progress = 0;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    timer = Timer.periodic(
      const Duration(milliseconds: 30),
      (t) {
        if (!mounted) return;

        setState(() {
          progress += 0.01;
        });

        if (progress >= 1) {
          t.cancel();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const RuangUjianPage(),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: Tween<double>(
                  begin: 1,
                  end: 1.08,
                ).animate(_controller),
                child: ClipOval(
                  child: Image.asset(
                    'assets/ic_launcher.png',
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 35),
              const Text(
                "SINKRONISASI PORTAL SECURE",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: progress,
                color: const Color(0xFFFFD200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RuangUjianPage extends StatefulWidget {
  const RuangUjianPage({super.key});

  @override
  State<RuangUjianPage> createState() => _RuangUjianPageState();
}

class _RuangUjianPageState extends State<RuangUjianPage>
    with WidgetsBindingObserver {
  late final WebViewController _webController;

  bool _loading = true;

  final Battery _battery = Battery();

  int batteryLevel = 100;

  String jam = "";

  String koneksi = "Online";

  Timer? timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _loading = true;
              });
            }
          },
          onPageFinished: (_) async {
            if (!mounted) return;

            setState(() {
              _loading = false;
            });

            await _webController.runJavaScript('''
              document.body.style.webkitUserSelect='none';
              document.body.style.userSelect='none';
            ''');
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          'https://airabimbel.biz.id/ujian_sekolah/login.php?t=${DateTime.now().millisecondsSinceEpoch}',
        ),
      );

    _updateJam();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        _updateJam();
      },
    );

    _getBattery();

    _getConnection();
  }

  void _updateJam() {
    jam = DateFormat('HH:mm').format(DateTime.now());

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _getBattery() async {
    try {
      final level = await _battery.batteryLevel;

      if (!mounted) return;

      setState(() {
        batteryLevel = level;
      });
    } catch (_) {}
  }

  Future<void> _getConnection() async {
    final result = await Connectivity().checkConnectivity();

    if (!mounted) return;

    if (result.contains(ConnectivityResult.none)) {
      koneksi = "Offline";
    } else if (result.contains(ConnectivityResult.wifi)) {
      koneksi = "WiFi";
    } else {
      koneksi = "Online";
    }

    setState(() {});
  }

  Future<bool> _confirmExit() async {
    final hasil = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Keluar Ujian?"),
          content: const Text(
            "Yakin ingin keluar?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("BATAL"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("KELUAR"),
            ),
          ],
        );
      },
    );

    return hasil ?? false;
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) async {
        bool keluar = await _confirmExit();

        if (keluar && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Container(
              color: const Color(0xFF1E293B),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          jam,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          koneksi,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '$batteryLevel%',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () async {
                            bool keluar = await _confirmExit();

                            if (keluar && mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "KELUAR",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(
                    controller: _webController,
                  ),
                  if (_loading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KotakNotifikasiPage extends StatefulWidget {
  const KotakNotifikasiPage({super.key});

  @override
  State<KotakNotifikasiPage> createState() => _KotakNotifikasiPageState();
}

class _KotakNotifikasiPageState extends State<KotakNotifikasiPage> {
  List<Map<String, String>> data = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    data = await ServiceNotifikasiLokal.ambilHistori();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kotak Masuk"),
      ),
      body: data.isEmpty
          ? const Center(
              child: Text("Belum ada notifikasi"),
            )
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (_, i) {
                final item = data[i];

                return Card(
                  child: ListTile(
                    title: Text(item['title'] ?? ''),
                    subtitle: Text(item['body'] ?? ''),
                    trailing: Text(item['time'] ?? ''),
                  ),
                );
              },
            ),
    );
  }
}

class ServiceNotifikasiLokal {
  static const String _key = "histori_notif_aira";

  static Future<void> simpanKeHistori(
    String title,
    String body,
  ) async {
    final pref = await SharedPreferences.getInstance();

    List<String> list = pref.getStringList(_key) ?? [];

    final data = {
      "title": title,
      "body": body,
      "time": DateFormat(
        'dd MMM HH:mm',
      ).format(DateTime.now()),
    };

    list.insert(0, jsonEncode(data));

    await pref.setStringList(_key, list);
  }

  static Future<List<Map<String, String>>> ambilHistori() async {
    final pref = await SharedPreferences.getInstance();

    List<String> list = pref.getStringList(_key) ?? [];

    return list.map((e) {
      final Map<String, dynamic> json = jsonDecode(e);

      return json.map(
        (k, v) => MapEntry(
          k,
          v.toString(),
        ),
      );
    }).toList();
  }

  static Future<void> hapusSemua() async {
    final pref = await SharedPreferences.getInstance();

    await pref.remove(_key);
  }
}
