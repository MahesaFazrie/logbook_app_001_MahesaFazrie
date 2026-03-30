import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import 'package:hive/hive.dart';

part 'log_model.g.dart'; 

@HiveType(typeId: 0)
class LogModel {
  @HiveField(0)
  final String? id; 
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String date;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final String category; 
  @HiveField(5)
  final String authorId; // Tambahan Modul 5
  @HiveField(6)
  final String teamId;   // Tambahan Modul 5

  LogModel({
    this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.category,
    required this.authorId,
    required this.teamId,
  });

  // Konversi Map (JSON/MongoDB) ke Object
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: (map['_id'] as ObjectId?)?.oid, // Convert ObjectId ke String
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Pribadi',
      authorId: map['authorId'] ?? 'unknown_user',
      teamId: map['teamId'] ?? 'no_team',
    );
  }

  // Konversi Object ke Map (JSON) untuk disimpan di MongoDB
  Map<String, dynamic> toMap() {
    return {
      '_id': id != null ? ObjectId.fromHexString(id!) : ObjectId(),
      'title': title,
      'date': date,
      'description': description,
      'category': category,
      'authorId': authorId,
      'teamId': teamId,
    };
  }
}