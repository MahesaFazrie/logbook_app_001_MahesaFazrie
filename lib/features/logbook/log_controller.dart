import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/log_model.dart';
import 'package:logbook_app_001/services/mongo_service.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';

class LogController {
  final String username;
  
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);

  // Konstruktor tidak memanggil loadFromDisk langsung, dipindah ke log_view
  LogController({required this.username});

  // Load dari Cloud
  Future<void> loadFromDisk() async {
    final cloudData = await MongoService().getLogs();
    logsNotifier.value = cloudData;
    filteredLogs.value = cloudData;
  }

  void searchLog(String query) {
    if (query.isEmpty) {
      filteredLogs.value = logsNotifier.value;
    } else {
      filteredLogs.value = logsNotifier.value
          .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<void> addLog(String title, String desc, String category) async {
    final newLog = LogModel(
      id: ObjectId(),
      title: title, 
      description: desc, 
      date: DateTime.now().toString(), 
      category: category
    );

    try {
      await MongoService().insertLog(newLog); // Kirim ke cloud
      logsNotifier.value = [...logsNotifier.value, newLog]; // Update UI
      filteredLogs.value = logsNotifier.value;
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal sinkronisasi Add - $e", level: 1);
    }
  }

  Future<void> updateLog(int index, String title, String desc, String category) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    final updatedLog = LogModel(
      id: oldLog.id, // ID MongoDB harus dipertahankan
      title: title, 
      description: desc, 
      date: DateTime.now().toString(), 
      category: category
    );

    try {
      await MongoService().updateLog(updatedLog); // Update di cloud
      currentLogs[index] = updatedLog;
      logsNotifier.value = currentLogs;
      filteredLogs.value = logsNotifier.value;
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal sinkronisasi Update - $e", level: 1);
    }
  }

  Future<void> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    try {
      if (targetLog.id != null) {
        await MongoService().deleteLog(targetLog.id!); // Hapus di cloud
        currentLogs.removeAt(index);
        logsNotifier.value = currentLogs;
        filteredLogs.value = logsNotifier.value;
      }
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal sinkronisasi Hapus - $e", level: 1);
    }
  }
}