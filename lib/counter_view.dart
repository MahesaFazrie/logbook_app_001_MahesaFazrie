import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget{
  const CounterView({super.key});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView>{
  final CounterController _controller = CounterController();

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
                   return Card(
                     color: Colors.grey[100],
                     elevation: 0,
                     child: ListTile(
                       leading: const Icon(Icons.history, color: Colors.deepPurple),
                       title: Text(_controller.history[index]),
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
          onPressed: () => setState(() => _controller.reset()),
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