class CounterController 
{
  int _counter = 0; 
  int step = 1;

  final List<String> _history = [];


  int get value => _counter;

  List<String> get history => _history;

  String _getcurrentTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _addToHistory(String logMessage) {
    _history.insert(0, logMessage);
    if (_history.length > 5) {
      _history.removeLast();
    }
  }

  void increment() {
    _counter += step;
    _addToHistory('User menambahkan nilai sebesar $step pada ${_getcurrentTime()}');
  } 
  void decrement() {
    if (_counter >= step) {
      _counter -= step;
      _addToHistory('User mengurangi nilai sebesar $step pada ${_getcurrentTime()}');
    }
    else if (_counter > 0) {
      int sisa = _counter;
      _counter = 0;
      _addToHistory('User mengurangi nilai sebesar $sisa pada ${_getcurrentTime()}');
    }
    else{
      _addToHistory('User gagal mengurangi nilai pada ${_getcurrentTime()} karena nilai sudah 0');
    }
  } 
  void reset() {
    _counter = 0;
    _addToHistory('User mereset nilai pada ${_getcurrentTime()}');
  } 
}