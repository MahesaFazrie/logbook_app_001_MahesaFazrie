import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/counter_controller.dart'; // Import controller lama Anda
import 'package:logbook_app_001/features/models/log_model.dart';   // Pastikan path ini sesuai
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart'; // Import controller baru yang sudah diperbarui

class LogView extends StatefulWidget {
  final String username;

  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  // Kita tetap menggunakan CounterController karena itu nama file Anda saat ini
  // final CounterController _controller = CounterController();
  late final LogController _logController; 
  bool _isLoading = true;
  
  // Controller untuk Input Text (Sesuai Modul 3 Langkah 4)
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedCategory = "Pribadi"; // Default category
  final List<String> _categories = ['Pekerjaan', 'Pribadi', 'Urgent'];

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pekerjaan':
        return Colors.blue.shade100;
      case 'Urgent':
        return Colors.red.shade100;
      case 'Pribadi':
      default: 
        return Colors.green.shade100;
    }
  }

  @override
  void initState() {
    super.initState();
    _logController = LogController(username: widget.username);
    Future.microtask(() => _initDatabase()); // Inisialisasi LogController dengan username
  }

  Future<void> _initDatabase() async {
    setState(() => _isLoading = true);
    try {
      await MongoService().connect().timeout(
        const Duration(seconds: 15),
      );
      await _logController.loadFromDisk();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Masalah Koneksi: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Logika Pesan Selamat Datang
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

  // LOGIKA LOGOUT
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
                Navigator.pop(context); 
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

  // DIALOG TAMBAH (Create)
void _showAddLogDialog() {
    _selectedCategory = 'Pribadi'; 
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( 
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Tambah Catatan Baru"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(hintText: "Judul Catatan"),
                ),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(hintText: "Isi Deskripsi"),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: "Kategori"),
                  items: _categories.map((String category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) {
                    setStateDialog(() { 
                      _selectedCategory = value!;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty) {
                    _logController.addLog( // Kirim parameter kategori
                      _titleController.text, 
                      _contentController.text,
                      _selectedCategory,
                    );
                    _titleController.clear();
                    _contentController.clear();
                    Navigator.pop(context);
                  }
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        }
      ),
    );
  }

  // DIALOG EDIT (Update)
  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Catatan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController),
            TextField(controller: _contentController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Batal")
          ),
          ElevatedButton(
            onPressed: () {
              _logController.updateLog(index, _titleController.text, _contentController.text, log.category);
              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Logbook App"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header: Greeting
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _welcomeMessage(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: (value) => _logController.searchLog(value),
              decoration: const InputDecoration(
                labelText: "Cari Catatan...",
                prefixIcon: Icon(Icons.search),
              ),
            ),

            const Divider(),

            // List Data (Reactive UI menggunakan ValueListenableBuilder)
            Expanded(
              child: ValueListenableBuilder<List<LogModel>>(
                valueListenable: _logController.filteredLogs,
                builder: (context, currentLogs, child) {
                  if (_isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text("Menghubungkan ke MongoDB Atlas..."),
                        ],
                      ),
                    );
                  }

                  if (currentLogs.isEmpty) {
                    return Center(
                      child: Image.asset(
                        "assets/images/Azka.jpeg", 
                        width: 200,
                        height: 200,
                      )
                    );
                  }
                  return ListView.builder(
                    itemCount: currentLogs.length,
                    itemBuilder: (context, index) {
                      final log = currentLogs[index];
                      // Menampilkan data LogModel ke dalam Card (Langkah 3)
                      return Card(
                        elevation: 2,
                        color: _getCategoryColor( log.category), // Warna berdasarkan kategori
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.note_alt_outlined, color: Colors.indigo),
                          title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(log.description),
                          trailing: Wrap(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEditLogDialog(index, log),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _logController.removeLog(index);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Catatan berhasil dihapus")),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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