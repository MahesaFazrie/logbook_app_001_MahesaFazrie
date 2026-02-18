import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logbook_app_001/features/logbook/counter_controller.dart';
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart';

class CounterView extends StatefulWidget {
  final String username;

  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  // Inisialisasi Controller
  final CounterController _controller = CounterController();
  
  // Controller untuk Input Text (Default angka 1)
  final TextEditingController _stepController = TextEditingController(text: "1");

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Fungsi memuat data dari Shared Preferences via Controller
  Future<void> _loadData() async {
    await _controller.loadLastValue();
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
            _controller.reset();
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- BAGIAN 1: Greeting & Angka ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _welcomeMessage(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Nilai Saat Ini:", style: TextStyle(color: Colors.grey)),
            Text(
              '${_controller.value}',
              style: const TextStyle(
                fontSize: 80, 
                fontWeight: FontWeight.bold, 
                color: Colors.indigo
              ),
            ),
            
            const SizedBox(height: 20),

            // --- BAGIAN 2: Input Angka (TextField) ---
            SizedBox(
              width: 150,
              child: TextField(
                controller: _stepController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "Masukkan Angka",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- BAGIAN 3: Tombol Aksi (Row) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tombol Kurang
                FloatingActionButton(
                  heroTag: 'decrement',
                  backgroundColor: Colors.redAccent,
                  onPressed: () {
                    int step = _getStepValue();
                    _controller.decrement(step);
                    _refresh();
                  },
                  child: const Icon(Icons.remove),
                ),
                
                // Tombol Reset (Abu-abu)
                FloatingActionButton(
                  heroTag: 'reset',
                  backgroundColor: Colors.grey,
                  onPressed: _handleReset,
                  child: const Icon(Icons.refresh),
                ),

                // Tombol Tambah
                FloatingActionButton(
                  heroTag: 'increment',
                  backgroundColor: Colors.green,
                  onPressed: () {
                    int step = _getStepValue();
                    _controller.increment(step);
                    _refresh();
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- BAGIAN 4: Riwayat ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Riwayat Aktivitas (Terbaru 5):",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Divider(),

            Expanded(
              child: _controller.history.isEmpty
                  ? const Center(child: Text("Belum ada aktivitas.", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _controller.history.length,
                      itemBuilder: (context, index) {
                        final String entry = _controller.history[index];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Icon(_entryIcon(entry), color: _entryColor(entry)),
                            title: Text(
                              entry,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}