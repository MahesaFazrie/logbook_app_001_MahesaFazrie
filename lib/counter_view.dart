import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget{
  const CounterView({super.key});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView>{
  final CounterController _controller = CounterController();

  void _showResetConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Apakah Anda yakin ingin mereset hitungan?'),
        duration: const Duration(seconds: 4), 
        action: SnackBarAction(
          label: 'YA, RESET',
          textColor: Colors.redAccent,
          onPressed: () {
            setState(() {
              _controller.reset();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Adalah Pokoknya"),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Berhitung"),
            Text('${_controller.value}', style: const TextStyle(fontSize: 40)),

            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Step Saat ini',
                prefixIcon: Icon( Icons.numbers),
              ),
              onChanged: (value){
                setState(() {
                  _controller.step = int.tryParse(value) ?? 1;
                });
              },
            ),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Riwayat Aktivitas:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

            Expanded(
                child: ListView.builder(
                  itemCount: _controller.history.length,
                  itemBuilder: (context, index) {
                    String currentHistory = _controller.history[index];
                    
                    // Logika penentuan warna teks
                    Color textColor = Colors.black87; // Warna default
                    if (currentHistory.contains("mengurangi")) {
                      textColor = Colors.red; // Merah jika dikurangi
                    } else if (currentHistory.contains("menambahkan")) {
                      textColor = Colors.green; // Hijau jika ditambah
                    } else if (currentHistory.contains("me-reset")) {
                      textColor = Colors.blueGrey; // Abu-abu kebiruan jika reset
                    }

                    return Card(
                      color: Colors.grey[100],
                      elevation: 0,
                      child: ListTile(
                        leading: Icon(
                          Icons.history, 
                          color: textColor, // Warna ikon juga disamakan
                        ),
                        title: Text(
                          currentHistory,
                          style: TextStyle(
                            color: textColor, 
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),


          ],
        ),
      ),
      persistentFooterButtons: [
        FloatingActionButton(
          onPressed: () => setState(() => _controller.decrement()),
          child: const Icon(Icons.remove),
        ),
        FloatingActionButton(
          onPressed: _showResetConfirmation,
          child: const Icon(Icons.refresh),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _controller.increment()),
        child: const Icon(Icons.add),
        
      ),
      
    );
  }
}