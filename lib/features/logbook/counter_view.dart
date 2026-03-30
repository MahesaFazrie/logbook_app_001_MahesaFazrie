// import 'package:flutter/material.dart';
// import 'package:logbook_app_001/features/logbook/counter_controller.dart';
// import 'package:logbook_app_001/features/models/log_model.dart';
// import 'package:logbook_app_001/features/onboarding/onboarding_view.dart';

// class CounterView extends StatefulWidget {
//   final String username;

//   const CounterView({super.key, required this.username});

//   @override
//   State<CounterView> createState() => _CounterViewState();
// }

// class _CounterViewState extends State<CounterView> {
//   final CounterController _controller = CounterController();
  
//   // Controller untuk menangkap input di dalam dialog
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _contentController = TextEditingController();

//   @override
//   void dispose() {
//     // Mencegah memory leak sesuai anjuran Troubleshooting Lab
//     _titleController.dispose();
//     _contentController.dispose();
//     super.dispose();
//   }

//   String _welcomeMessage() {
//     final hour = DateTime.now().hour;
//     String greeting;
//     if (hour >= 4 && hour < 11) {
//       greeting = "Selamat Pagi";
//     } else if (hour >= 11 && hour < 15) {
//       greeting = "Selamat Siang";
//     } else if (hour >= 15 && hour < 18) {
//       greeting = "Selamat Sore";
//     } else {
//       greeting = "Selamat Malam";
//     }
//     return "$greeting, ${widget.username}";
//   }

//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Konfirmasi Logout"),
//           content: const Text("Apakah Anda yakin ingin keluar?"),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Batal"),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const OnboardingView(),
//                   ),
//                   (route) => false,
//                 );
//               },
//               child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showAddLogDialog() {
//     _titleController.clear();
//     _contentController.clear();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Tambah Catatan Baru"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: _titleController,
//               decoration: const InputDecoration(hintText: "Judul Catatan"),
//             ),
//             TextField(
//               controller: _contentController,
//               decoration: const InputDecoration(hintText: "Isi Deskripsi"),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Batal"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Mencegah input kosong berjalan
//               if (_titleController.text.isNotEmpty) {
//                 _controller.addLog(
//                   _titleController.text, 
//                   _contentController.text,
//                 );
//                 Navigator.pop(context);
//               }
//             },
//             child: const Text("Simpan"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showEditLogDialog(int index, LogModel log) {
//     _titleController.text = log.title;
//     _contentController.text = log.description;
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Edit Catatan"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(controller: _titleController),
//             TextField(controller: _contentController),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
//           ElevatedButton(
//             onPressed: () {
//               _controller.updateLog(index, _titleController.text, _contentController.text);
//               Navigator.pop(context);
//             },
//             child: const Text("Update"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         title: const Text("Logbook App"),
//         backgroundColor: Colors.indigo,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: _showLogoutDialog,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               _welcomeMessage(),
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               "Daftar Catatan:",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const Divider(),

//             // Menggunakan Expanded dan ValueListenableBuilder
//             Expanded(
//               child: ValueListenableBuilder<List<LogModel>>(
//                 valueListenable: _controller.logsNotifier,
//                 builder: (context, currentLogs, child) {
//                   if (currentLogs.isEmpty) {
//                     return const Center(child: Text("Belum ada catatan logbook.", style: TextStyle(color: Colors.grey)));
//                   }
//                   return ListView.builder(
//                     itemCount: currentLogs.length,
//                     itemBuilder: (context, index) {
//                       final log = currentLogs[index];
//                       // Implementasi bonus Dismissible (Swipe to Delete)
//                       return Dismissible(
//                         key: Key(log.date),
//                         direction: DismissDirection.endToStart,
//                         background: Container(
//                           color: Colors.red,
//                           alignment: Alignment.centerRight,
//                           padding: const EdgeInsets.only(right: 20),
//                           child: const Icon(Icons.delete, color: Colors.white),
//                         ),
//                         onDismissed: (direction) {
//                           _controller.removeLog(index);
//                         },
//                         child: Card(
//                           elevation: 1,
//                           margin: const EdgeInsets.symmetric(vertical: 4),
//                           child: ListTile(
//                             leading: const Icon(Icons.note, color: Colors.indigo),
//                             title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold)),
//                             subtitle: Text(log.description),
//                             trailing: Wrap(
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.edit, color: Colors.blue),
//                                   onPressed: () => _showEditLogDialog(index, log),
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete, color: Colors.red),
//                                   onPressed: () => _controller.removeLog(index),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddLogDialog,
//         backgroundColor: Colors.indigo,
//         foregroundColor: Colors.white,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }