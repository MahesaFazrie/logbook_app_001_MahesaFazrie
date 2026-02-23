import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logbook_app_001/features/logbook/counter_controller.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart';
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart';

class LogView extends StatefulWidget {
  final String username;

  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  // Inisialisasi Controller
  final LogController _controller = LogController();
  final CounterController _counterController = CounterController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();


  void _showAddLogDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Catatan Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Agar dialog tidak memenuhi layar
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Judul Catatan"),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(hintText: "Isi Deskripsi"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Tutup tanpa simpan
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              // Jalankan fungsi tambah di Controller
              _controller.addLog(
                _titleController.text, 
                _contentController.text
              );
              
              // Trigger UI Refresh
              setState(() {}); 
              
              // Bersihkan input dan tutup dialog
              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  
  // Controller untuk Input Text (Default angka 1)
  final TextEditingController _stepController = TextEditingController(text: "1");

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Fungsi memuat data dari Shared Preferences via Controller
  Future<void> _loadData() async {
    await _counterController.loadLastValue();
    if (mounted) {
      setState(() {});
    }
  }

  // Helper untuk refresh UI
  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  // Helper mengambil angka dari TextField
  int _getStepValue() {
    return int.tryParse(_stepController.text) ?? 1;
  }

  // Logika Pesan Selamat Datang (Bonus UX)
  String _welcomeMessage() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour >= 4 && hour < 11) {
      greeting = "Selamat Pagi";
    } else if (hour >= 11 && hour < 15) {
      greeting = "Selamat Siang";
    } else if (hour >= 15 && hour < 18) {
      greeting = "Selamat Sore";
    } else {
      greeting = "Selamat Malam";
    }
    return "$greeting, ${widget.username}";
  }

  // LOGIKA LOGOUT (Sesuai permintaan Task 3 & Navigasi)
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                // Navigasi ke Onboarding & Hapus Stack sebelumnya
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnboardingView(),
                  ),
                  (route) => false,
                );
              },
              child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // LOGIKA RESET (Dengan SnackBar Konfirmasi)
  void _handleReset() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Yakin ingin mereset data ke 0?"),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.black87,
        action: SnackBarAction(
          label: "YA, RESET",
          textColor: Colors.redAccent,
          onPressed: () {
            _counterController.reset();
            _refresh();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Data berhasil di-reset!")),
            );
          },
        ),
      ),
    );
  }

  // Logika Warna Riwayat
  Color _entryColor(String entry) {
    if (entry.contains("menambahkan")) return Colors.green;
    if (entry.contains("mengurangi") || entry.contains("gagal")) return Colors.red;
    return Colors.grey; // Default untuk reset
  }

  IconData _entryIcon(String entry) {
    if (entry.contains("menambahkan")) return Icons.arrow_upward;
    if (entry.contains("mengurangi") || entry.contains("gagal")) return Icons.arrow_downward;
    return Icons.refresh;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Agar keyboard tidak menutupi UI saat mengetik angka
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Logbook App"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: ValueListenableBuilder<List<LogModel>>(
  valueListenable: _controller.logsNotifier,
  builder: (context, currentLogs, child) {
    if (currentLogs.isEmpty) return const Center(child: Text("Belum ada catatan."));
    return ListView.builder(
      itemCount: currentLogs.length,
      itemBuilder: (context, index) {
        final log = currentLogs[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.note),
            title: Text(log.title),
            subtitle: Text(log.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), 
                  onPressed: () => _showEditLogDialog(index, log)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), 
                  onPressed: () => _controller.removeLog(index)),
              ],
            ),
          ),
        );
      },
    );
  },
),

    );
  }
}