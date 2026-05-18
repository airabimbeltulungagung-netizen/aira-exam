import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart'; // WebView resmi Android
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Untuk tombol WhatsApp

// ================= TAMBAHAN DOWNLOAD APK =================
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
// =========================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ================= INIT DOWNLOADER =================
  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
  );
  // ==================================================

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIRA EXAM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7)),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
    );
  }
}

// =========================================================================
// 1. HALAMAN UTAMA (WELCOME PAGE DUA TOMBOL + INTEGRASI LOGO AIRA HUB)
// =========================================================================
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _bukaWhatsAppAdmin() async {
    const String nomorWA = "6285704351856";
    const String pesanOtomatis =
        "Halo Admin, saya mau meminta kartu ujian dan token AIRA EXAM.";
    final Uri url = Uri.parse(
        "https://wa.me/$nomorWA?text=${Uri.encodeComponent(pesanOtomatis)}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 20)
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/ic_launcher.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.security_rounded,
                        size: 70,
                        color: Color(0xFF6C5CE7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'AIRA EXAM SYSTEM',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aplikasi Pengaman Ujian Digital AIRA HUB.\nSilakan masuk jika sudah memiliki kartu ujian.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RuangUjianPage()),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white),
                    label: const Text('MULAI UJIAN SEKARANG',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: _bukaWhatsAppAdmin,
                    icon: const Icon(Icons.support_agent,
                        color: Color(0xFF6C5CE7)),
                    label: const Text('HUBUNGI ADMIN / MINTA KARTU',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF2D3436))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// 2. HALAMAN RUANG UJIAN (LOCKDOWN MODE REAL ANDROID + ANTI-CACHE LOGIC)
// =========================================================================
class RuangUjianPage extends StatefulWidget {
  const RuangUjianPage({super.key});

  @override
  State<RuangUjianPage> createState() => _RuangUjianPageState();
}

class _RuangUjianPageState extends State<RuangUjianPage>
    with WidgetsBindingObserver {
  late final WebViewController _webController;
  bool _isLoading = true;

  final Battery _battery = Battery();
  int _batteryLevel = 100;
  String _connectionStatus = 'Online';
  String _timeString = '';
  late Timer _timer;

  // ================= FUNGSI DOWNLOAD APK =================
  Future<void> downloadApk(String url) async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();

    await FlutterDownloader.enqueue(
      url: url,
      savedDir: '/storage/emulated/0/Download',
      fileName: 'AIRA_EXAM.apk',
      showNotification: true,
      openFileFromNotification: true,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'APK sedang didownload...',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }
  // ======================================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _updateTime();
    _getBatteryInfo();
    _checkConnectivity();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());

    // ANTI-CACHE URL: Ditambah parameter waktu acak riil agar ketika admin klik
    // tombol "Restart/Reset" di web cPanel, WebView langsung sinkron memuat halaman login baru tanpa tersangkut sisa error.
    final String antiCacheUrl =
        'https://airabimbel.biz.id/ujian_sekolah/login.php?t=${DateTime.now().millisecondsSinceEpoch}';

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => _isLoading = true),

          onPageFinished: (url) => setState(() => _isLoading = false),

          // ================= DETEKSI LINK APK =================
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.endsWith(".apk")) {
              await downloadApk(request.url);

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          // ====================================================
        ),
      )
      ..loadRequest(Uri.parse(antiCacheUrl));
  }

  void _refreshHalamanWeb() {
    _webController.reload();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF6C5CE7),
        duration: Duration(seconds: 2),
        content: Text('Menyegarkan jaringan dan memuat ulang soal AIRA...'),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // SATPAM UTAMA: Jika siswa meminimize aplikasi / split screen, langsung tendang paksa ke depan!
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            content: Text(
              'ANDA TERDETEKSI CURANG! Keluar dari aplikasi selama ujian dilarang. Sesi Anda hangus!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    }
  }

  void _updateTime() {
    final String formattedDateTime = DateFormat('HH:mm').format(DateTime.now());
    if (mounted) setState(() => _timeString = formattedDateTime);
  }

  void _getBatteryInfo() async {
    try {
      final level = await _battery.batteryLevel;
      if (mounted) setState(() => _batteryLevel = level);
    } catch (_) {}
  }

  void _checkConnectivity() async {
    final List<ConnectivityResult> result =
        await Connectivity().checkConnectivity();
    if (mounted) {
      if (result.contains(ConnectivityResult.none)) {
        setState(() => _connectionStatus = 'Offline');
      } else if (result.contains(ConnectivityResult.wifi)) {
        setState(() => _connectionStatus = 'WiFi');
      } else {
        setState(() => _connectionStatus = 'Online');
      }
    }
  }

  Future<bool> _requestExit() async {
    bool? exitResult = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
              'Apakah Anda yakin ingin keluar dari ruang ujian dan kembali ke halaman utama?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('BATAL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('YA, KELUAR'),
            ),
          ],
        );
      },
    );
    return exitResult ?? false;
  }

  @override
  void dispose() {
    _timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        bool canExit = await _requestExit();
        return canExit;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // STATUS BAR KUSTOM KHAS AIRA EXAM PREMIUM
            Container(
              color: const Color(0xFF1E293B),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        _timeString,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      const SizedBox(width: 15),
                      Icon(
                        _connectionStatus == 'Offline'
                            ? Icons.signal_cellular_connected_no_internet_4_bar
                            : Icons.network_check_rounded,
                        color: _connectionStatus == 'Offline'
                            ? Colors.red
                            : Colors.greenAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _connectionStatus,
                        style: TextStyle(
                            color: _connectionStatus == 'Offline'
                                ? Colors.red
                                : Colors.greenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // TOMBOL REFRESH PINTAR (Penyelamat Sinyal Lemot / RTO)
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded,
                            color: Colors.cyanAccent, size: 18),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        onPressed: _refreshHalamanWeb,
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.battery_4_bar_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$_batteryLevel%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 15),

                      GestureDetector(
                        onTap: () async {
                          bool canExit = await _requestExit();
                          if (canExit && mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red[700],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.power_settings_new_rounded,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text('KELUAR',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _webController),
                  if (_isLoading)
                    const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF6C5CE7)),
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
