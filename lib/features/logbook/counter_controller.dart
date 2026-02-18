import 'package:shared_preferences/shared_preferences.dart';

class CounterController 
{
  int _counter = 0; 
  final List<String> _history = [];

  int get value => _counter;
  List<String> get history => _history;

  static const String _keyCounter = 'last_counter_value';

  String _getcurrentTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _addToHistory(String logMessage) {
    _history.insert(0, logMessage);
    // UBAH: Batasi riwayat hanya 5 data terbaru
    if (_history.length > 5) { 
      _history.removeLast();
    }
  }

  Future<void> loadLastValue() async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt(_keyCounter) ?? 0;
  }

  Future<void> _saveLastValue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCounter, _counter);
  }

  void increment(int amount) {
    _counter += amount;
    _addToHistory('User menambahkan nilai sebesar $amount pada ${_getcurrentTime()}');
    _saveLastValue();
  } 

  void decrement(int amount) {
    if (_counter >= amount) {
      _counter -= amount;
      _addToHistory('User mengurangi nilai sebesar $amount pada ${_getcurrentTime()}');
    }
    else if (_counter > 0) {
      int sisa = _counter;
      _counter = 0;
      _addToHistory('User mengurangi nilai sebesar $sisa pada ${_getcurrentTime()}');
    }
    else{
      _addToHistory('User gagal mengurangi nilai pada ${_getcurrentTime()} (Nilai 0)');
    }
    _saveLastValue();
  } 

  void reset() {
    _counter = 0;
    _addToHistory('User mereset nilai pada ${_getcurrentTime()}');
    _saveLastValue();
  } 
}