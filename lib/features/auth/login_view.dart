// login_view.dart
import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_controller.dart';
import 'package:logbook_app_001/features/logbook/log_view.dart';
import 'package:logbook_app_001/features/logbook/counter_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // MODIFIKASI TASK 2: Variabel untuk mengatur visibilitas password
  bool _isObscure = true;

  void _handleLogin() {
    String user = _userController.text.trim(); // .trim() untuk hapus spasi tak sengaja
    String pass = _passController.text.trim();

    // MODIFIKASI TASK 2: Validasi Input Kosong
    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username dan Password tidak boleh kosong!"),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop eksekusi agar tidak lanjut login
    }

    bool isSuccess = _controller.login(user, pass);

    if (isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CounterView(username: user),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Gagal! Cek username/password."),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Gatekeeper")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            const SizedBox(height: 10), // Memberi sedikit jarak
            
            // MODIFIKASI TASK 2: TextField Password dengan Icon Mata
            TextField(
              controller: _passController,
              obscureText: _isObscure, // Menggunakan variabel state
              decoration: InputDecoration(
                labelText: "Password",
                // Ikon Mata (Suffix Icon)
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure; // Toggle true/false
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleLogin, 
              child: const Text("Masuk")
            ),
          ],
        ),
      ),
    );
  }
}