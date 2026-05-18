import 'dart:async';
import 'dart:convert'; // Untuk kebutuhan engine histori notifikasi JSON
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// ================= PERLENGKAPAN BENTENG KEAMANAN & NOTIFIKASI =================
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Untuk engine penyimpanan inbox lokal
// =============================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. EMBED FULL SCREEN PROTOKOL (Menghilangkan total bar atas & bawah Android)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // 2. KUNCI ROTASI LAYAR MUTLAK (Mencegah trik bypass split-screen via rotasi otomatis)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 3. INIT ENGINE DOWNLOADER
  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
  );

  // 4. INTEGRASI ONESIGNAL PUSH BROADCAST
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  // 🔥 SILAKAN MASUKKAN NOMOR APP ID ONESIGNAL ASLI KAMU DI SINI:
  OneSignal.initialize("0b5ac2da-2c7c-4051-b579-d9efb7ed6609");

  OneSignal.Notifications.requestPermission(true);

  // 🌟 JALUR FOREGROUND MONITOR: Ambil info siaran OneSignal saat apps terbuka
  OneSignal.Notifications.addForegroundWillDisplayListener((event) async {
    final title = event.notification.title ?? "Pengumuman AIRA";
    final body = event.notification.body ?? "";
    await ServiceNotifikasiLokal.simpanKeHistori(title, body);
  });

  // 🌟 JALUR BACK GROUND/KILLED BYPASS (SOLUSI HEMAT SERVER):
  // Saat HP offline/apps mati, notifikasi di-klik siswa -> Tangkap datanya -> Simpan ke SharedPreferences lokal HP!
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
      title: 'AIRA EXAM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          primary: const Color(0xFF6C5CE7),
          secondary: const Color(0xFFFFD200),
        ),
        useMaterial3: true,
      ),
      // PERUBAHAN GERBANG UTAMA: Langsung diarahkan ke Splash Screen Loading Estetik
      home: const HalamanLoadingAwal(),
    );
  }
}

// =========================================================================
// TAMPILAN BARU: SPLASH SCREEN LOADING AWAL YANG ESTETIK & PREMIUM
// =========================================================================
class HalamanLoadingAwal extends StatefulWidget {
  const HalamanLoadingAwal({super.key});

  @override
  State<HalamanLoadingAwal> createState() => _HalamanLoadingAwalState();
}

class _HalamanLoadingAwalState extends State<HalamanLoadingAwal> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Timer 3 detik untuk loading awal, setelah selesai ganti ke WelcomePage secara mulus
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
          0xFF1E293B), // Background gelap mahal ala EdTech Enterprise
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/ic_launcher.png',
                  width: 115,
                  height: 115,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.shield_rounded,
                    size: 80,
                    color: Color(0xFF6C5CE7),
                  ),
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
                  letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),
            Text(
              'Secure, Integrity, & Professional EdTech',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                  letterSpacing: 0.5),
            ),
            const SizedBox(height: 60),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                color: Color(0xFFFFD200),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 1. GATEWAY HALAMAN UTAMA (STERIL - AMAN DARI PENGUNCIAN AWAL)
// =========================================================================
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _bukaWhatsAppAdmin() async {
    const String nomorWA = "6285704351856";
    const String pesanOtomatis =
        "Halo Admin, saya mau meminta kartu ujian and token AIRA EXAM.";
    final Uri url = Uri.parse(
        "https://wa.me/$nomorWA?text=${Uri.encodeComponent(pesanOtomatis)}");

    try {
      await launchUrl(url, mode: LaunchMode.externalNonBrowserApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.orange,
            content: Text(
                'Gagal membuka WhatsApp. Pastikan aplikasi WA aktif di HP.'),
          ),
        );
      }
    }
  }

  void _bukaWebsiteAira() async {
    final Uri url = Uri.parse("https://airabimbel.biz.id");
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Gagal memuat peramban luar. Sinyal tidak menentu.'),
          ),
        );
      }
    }
  }

  Future<void> _validasiDanMintaAksesIzin(BuildContext context) async {
    var statusWindow = await Permission.systemAlertWindow.status;
    if (!statusWindow.isGranted) {
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.gavel_rounded, color: Color(0xFF6C5CE7)),
                  SizedBox(
                      width:
                          10), // 🌟 FIX 2: Diubah dari typo SAuthorized kembali ke SizedBox(width: 10)
                  Text("Protokol Ujian",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text(
                "Aplikasi memerlukan otoritas 'Tampilkan di atas aplikasi lain' "
                "agar sistem ruang ujian berjalan steril dari hamparan aplikasi luar. "
                "Silakan berikan izin pada menu setelah ini.",
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white),
                  child: const Text("BUKA PENGATURAN"),
                  onPressed: () async {
                    Navigator.pop(context);
                    await Permission.systemAlertWindow.request();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      // TOMBOL IKON KOTAK MASUK NOTIFIKASI DI BAR ATAS WELCOME PAGE
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_rounded,
                color: Color(0xFF6C5CE7), size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const KotakNotifikasiPage()),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28.0, vertical: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C5CE7).withOpacity(0.2),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/ic_launcher.png',
                          width: 105,
                          height: 105,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.shield_rounded,
                            size: 75,
                            color: Color(0xFF6C5CE7),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'AIRA EXAM SYSTEM',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD200).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'MAXIMUM HARDENING SECURITY v2.5',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4A373)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Portal Penyelenggaraan Ujian Digital Integritas Tinggi.\nPastikan Anda telah menerima token ujian dari panitia.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: Colors.blueGrey, height: 1.5),
                    ),
                    const SizedBox(height: 35),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border:
                            Border.all(color: Colors.black12.withOpacity(0.05)),
                      ),
                      child: const Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.verified_user_rounded,
                                  color: Colors.green, size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                    'Sistem Keamanan Fokus Jendela Native Aktif',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B))),
                              )
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.no_photography_rounded,
                                  color: Colors.redAccent, size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                    'Blokir Total Screenshot & Perekaman Layar OS',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B))),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _validasiDanMintaAksesIzin(context);
                          var isWindowOk =
                              await Permission.systemAlertWindow.isGranted;

                          if (isWindowOk) {
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RuangUjianPage()),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.amber,
                                  content: Text(
                                      'Seluruh izin wajib diaktifkan demi integritas ujian!',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.login_rounded,
                            color: Colors.white),
                        label: const Text('MULAI UJIAN SEKARANG',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 1)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C5CE7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          shadowColor: const Color(0xFF6C5CE7).withOpacity(0.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        // 🌟 FIX 1: Kata 'const' dihapus dari baris Row ini agar element list-nya tidak memicu eror non_constant_list_element
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: _bukaWhatsAppAdmin,
                              icon: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: Colors.green,
                                  size: 18),
                              label: const Text('CHAT ADMIN',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF1E293B))),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Colors.green, width: 1.2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: _bukaWebsiteAira,
                              icon: const Icon(Icons.language_rounded,
                                  color: Color(0xFF6C5CE7), size: 18),
                              label: const Text('WEB UTAMA',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF1E293B))),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color(0xFF6C5CE7), width: 1.2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// 2. RUANG UJIAN HARDENING (BENTENG UTAMA SEKARANG UTUH & PRESISI)
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
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // [BENTENG 1]: LAYAR FULL SECURE WINDOW DIRECT NATIVE
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemLauncher.setWindowSecure(true);

    _updateTime();
    _getBatteryInfo();
    _checkConnectivity();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());

    final String antiCacheUrl =
        'https://airabimbel.biz.id/ujian_sekolah/login.php?t=${DateTime.now().millisecondsSinceEpoch}';

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => _isLoading = true),
          onPageFinished: (url) {
            setState(() => _isLoading = false);

            // [BENTENG 2]: INJEKSI JAVASCRIPT ANTI SELEKSI / TRANS-COPY
            _webController.runJavaScript('''
              document.body.style.webkitUserSelect = "none";
              document.body.style.userSelect = "none";
              document.addEventListener('contextmenu', event => event.preventDefault());
              document.addEventListener('selectstart', event => event.preventDefault());
              document.addEventListener('copy', event => event.preventDefault());
              document.addEventListener('cut', event => event.preventDefault());
              document.addEventListener('paste', event => event.preventDefault());
            ''');
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.endsWith(".apk")) {
              await downloadApk(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(antiCacheUrl));
  }

  void _refreshHalamanWeb() {
    _webController.reload();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // [BENTENG 3]: SATPAM LIFE-CYCLE MONITORING INTEGRITAS TINGGI JIKA APPS PINDAH LAYER
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      if (mounted) {
        WebViewCookieManager().clearCookies();
        SystemLauncher.setWindowSecure(false);

        Navigator.of(context).popUntil((route) => route.isFirst);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            duration: Duration(seconds: 8),
            content: Text(
              'STRUKTUR JENDELA TERGANGGU / PINDAH FOKUS LAYAR TERDETEKSI! SESI ANDA DIHANGUSKAN UTOMATIS!',
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

  Future<void> _eksekusiKeluarResmi() async {
    await WebViewCookieManager().clearCookies();
    SystemLauncher.setWindowSecure(false);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<bool> _requestExit() async {
    bool? exitResult = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Batalkan Sesi Ujian?',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
              'Keluar membuat token Anda hangus otomatis demi menjaga kerahasiaan materi soal.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('BATALKAN'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context, true);
              },
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
    // SUNTIKAN BENTENG 4: POPSCOPE TERBARU (MENGUNCI PHYSICAL BACK BUTTON HP MUTLAK)
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final bool kuduKeluar = await _requestExit();
        if (kuduKeluar) {
          await _eksekusiKeluarResmi();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              color: const Color(0xFF1E293B),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(_timeString,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      const SizedBox(width: 14),
                      Icon(
                        _connectionStatus == 'Offline'
                            ? Icons.signal_cellular_connected_no_internet_4_bar
                            : Icons.wifi_protected_setup_rounded,
                        color: _connectionStatus == 'Offline'
                            ? Colors.red
                            : Colors.greenAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(_connectionStatus,
                          style: TextStyle(
                              color: _connectionStatus == 'Offline'
                                  ? Colors.red
                                  : Colors.greenAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.sync_rounded,
                            color: Colors.cyanAccent, size: 20),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        onPressed: _refreshHalamanWeb,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.battery_charging_full_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text('$_batteryLevel%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () async {
                          final bool kuduKeluar = await _requestExit();
                          if (kuduKeluar) {
                            await _eksekusiKeluarResmi();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.red[600],
                              borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            children: [
                              Icon(Icons.disabled_by_default_rounded,
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
                        child: CircularProgressIndicator(
                            color: Color(0xFF6C5CE7))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SystemLauncher {
  static const MethodChannel _channel = MethodChannel('aira.exam/launch');
  static Future<void> setWindowSecure(bool secure) async {
    try {
      await _channel.invokeMethod('setWindowSecure', {'secure': secure});
    } catch (_) {}
  }
}

// =========================================================================
// TAMPILAN BARU: TAB HISTORI KOTAK MASUK NOTIFIKASI (INBOX) SISWA
// =========================================================================
class KotakNotifikasiPage extends StatefulWidget {
  const KotakNotifikasiPage({super.key});

  @override
  State<KotakNotifikasiPage> createState() => _KotakNotifikasiPageState();
}

class _KotakNotifikasiPageState extends State<KotakNotifikasiPage> {
  List<Map<String, String>> _listNotif = [];

  @override
  void initState() {
    super.initState();
    _muatDaftarNotifikasi();
  }

  Future<void> _muatDaftarNotifikasi() async {
    final data = await ServiceNotifikasiLokal.ambilHistori();
    setState(() {
      _listNotif = data;
    });
  }

  Future<void> _bersihkanSemuaHistori() async {
    await ServiceNotifikasiLokal.hapusSemua();
    setState(() {
      _listNotif.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      appBar: AppBar(
        title: const Text('Kotak Masuk Pengumuman',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (_listNotif.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded,
                  color: Colors.redAccent, size: 26),
              onPressed: _bersihkanSemuaHistori,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _listNotif.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail_outline_rounded,
                      size: 60, color: Colors.black26),
                  SizedBox(height: 12),
                  Text('Belum ada pengumuman masuk dari Admin.',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _listNotif.length,
              itemBuilder: (context, index) {
                final item = _listNotif[index];
                return Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Colors.black12, width: 0.5),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF6C5CE7),
                      child: Icon(Icons.campaign_rounded, color: Colors.white),
                    ),
                    title: Text(item['title'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B))),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(item['body'] ?? '',
                            style: const TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 13,
                                height: 1.4)),
                        const SizedBox(height: 8),
                        Text(item['time'] ?? '',
                            style: const TextStyle(
                                color: Colors.black26,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// =========================================================================
// ENGINE SISTEM PENYIMPANAN NOTIFIKASI KE MEMORI LOKAL HP (SHARED PREF)
// =========================================================================
class ServiceNotifikasiLokal {
  static const String _keyNotif = "histori_notif_aira";

  static Future<void> simpanKeHistori(String title, String body) async {
    final pref = await SharedPreferences.getInstance();
    List<String> listMentah = pref.getStringList(_keyNotif) ?? [];

    final waktuSekarang = DateFormat('dd MMM, HH:mm').format(DateTime.now());

    Map<String, String> dataBaru = {
      "title": title,
      "body": body,
      "time": waktuSekarang
    };

    listMentah.insert(
        0, jsonEncode(dataBaru)); // Pesan paling baru nangkring paling atas
    await pref.setStringList(_keyNotif, listMentah);
  }

  static Future<List<Map<String, String>>> ambilHistori() async {
    final pref = await SharedPreferences.getInstance();
    List<String> listMentah = pref.getStringList(_keyNotif) ?? [];

    return listMentah.map((item) {
      final Map<String, dynamic> peta = jsonDecode(item);
      return peta.map((kunci, nilai) => MapEntry(kunci, nilai.toString()));
    }).toList();
  }

  static Future<void> hapusSemua() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(_keyNotif);
  }
}
