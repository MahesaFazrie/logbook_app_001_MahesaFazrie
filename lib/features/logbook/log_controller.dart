import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import 'package:hive/hive.dart';
import '../models/log_model.dart';
import 'package:logbook_app_001/services/mongo_services.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';

class LogController {
  final String username;
  final String teamId;   // Tambahan Modul 5
  final String authorId; // Tambahan Modul 5
  
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);

  // Instance Hive Box
  late Box<LogModel> _myBox;

  LogController({
    required this.username, 
    this.teamId = 'Default_Team', // Beri default value untuk menghindari error navigasi lama
    this.authorId = 'Default_Author', 
  }) {
    _myBox = Hive.box<LogModel>('offline_logs'); // Akses box lokal
  }

  // 1. LOAD DATA (Offline-First Strategy)
  Future<void> loadFromDisk() async {
    // Langkah 1: Ambil data dari Hive (Sangat Cepat/Instan)
    logsNotifier.value = _myBox.values.toList();
    filteredLogs.value = logsNotifier.value;

    // Langkah 2: Sync dari Cloud (Background)
    try {
      final cloudData = await MongoService().getLogs(teamId);
      
      // Update Hive dengan data terbaru dari Cloud agar sinkron
      await _myBox.clear();
      await _myBox.addAll(cloudData);
      
      // Update UI dengan data Cloud
      logsNotifier.value = cloudData;
      filteredLogs.value = cloudData;
      
      await LogHelper.writeLog("SYNC: Data berhasil diperbarui dari Atlas", level: 2);
    } catch (e) {
      await LogHelper.writeLog("OFFLINE: Menggunakan data cache lokal", level: 2);
    }
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

  // 2. ADD DATA (Instant Local + Background Cloud)
  Future<void> addLog(String title, String desc, String category) async {
    final newLog = LogModel(
      id: ObjectId().oid, // Menggunakan oid (String) untuk Hive
      title: title, 
      description: desc, 
      date: DateTime.now().toString(), 
      category: category,
      authorId: authorId,
      teamId: teamId,
    );

    // ACTION 1: Simpan ke Hive (Instan)
    await _myBox.add(newLog);
    logsNotifier.value = [...logsNotifier.value, newLog];
    filteredLogs.value = logsNotifier.value;

    // ACTION 2: Kirim ke MongoDB Atlas (Background)
    try {
      await MongoService().insertLog(newLog); 
      await LogHelper.writeLog("SUCCESS: Data tersinkron ke Cloud", source: "log_controller.dart", level: 2);
    } catch (e) {
      await LogHelper.writeLog("WARNING: Data tersimpan lokal, akan sinkron saat online", source: "log_controller.dart", level: 1);
    }
  }

  // 3. UPDATE DATA (Instant Local + Background Cloud)
  Future<void> updateLog(int index, String title, String desc, String category) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    final updatedLog = LogModel(
      id: oldLog.id, 
      title: title, 
      description: desc, 
      date: DateTime.now().toString(), 
      category: category,
      authorId: oldLog.authorId, // Pertahankan pembuat asli
      teamId: oldLog.teamId,     // Pertahankan tim asli
    );

    // ACTION 1: Update lokal Hive & UI
    await _myBox.putAt(index, updatedLog);
    currentLogs[index] = updatedLog;
    logsNotifier.value = currentLogs;
    filteredLogs.value = logsNotifier.value;

    // ACTION 2: Update Cloud
    try {
      await MongoService().updateLog(updatedLog); 
      await LogHelper.writeLog("SUCCESS: Sinkronisasi Update Berhasil", source: "log_controller.dart", level: 2);
    } catch (e) {
      await LogHelper.writeLog("WARNING: Update tersimpan lokal", source: "log_controller.dart", level: 1);
    }
  }

  // 4. REMOVE DATA (Instant Local + Background Cloud)
  Future<void> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    // ACTION 1: Hapus lokal Hive & UI
    await _myBox.deleteAt(index);
    currentLogs.removeAt(index);
    logsNotifier.value = currentLogs;
    filteredLogs.value = logsNotifier.value;

    // ACTION 2: Hapus dari Cloud
    try {
      if (targetLog.id != null) {
        await MongoService().deleteLog(targetLog.id!); 
        await LogHelper.writeLog("SUCCESS: Sinkronisasi Hapus Berhasil", source: "log_controller.dart", level: 2);
      }
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal sinkronisasi Hapus Cloud - $e", source: "log_controller.dart", level: 1);
    }
  }
}