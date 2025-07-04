import 'priority.dart';
import 'package:intl/intl.dart';

class Task {
  static int _nextId = 1;
  
  final int id;
  String title;
  String description;
  Priority priority;
  DateTime? dueDate;
  String? externalLink;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.priority,
    this.dueDate,
    this.externalLink,
    this.isCompleted = false,
  }) : id = _nextId++;

  // Constructor để tạo task với ID cụ thể (dùng khi restore từ database)
  Task.withId({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.dueDate,
    this.externalLink,
    this.isCompleted = false,
  }) {
    if (id >= _nextId) {
      _nextId = id + 1;
    }
  }

  String get formattedDueDate {
    if (dueDate == null) return 'Không có';
    return DateFormat('dd/MM/yyyy HH:mm').format(dueDate!);
  }

  String get statusText {
    return isCompleted ? '✓ Hoàn thành' : '○ Chưa hoàn thành';
  }

  String get priorityColor {
    switch (priority) {
      case Priority.high:
        return '\x1B[31m'; // Red
      case Priority.medium:
        return '\x1B[33m'; // Yellow
      case Priority.low:
        return '\x1B[32m'; // Green
    }
  }

  String get resetColor => '\x1B[0m';

  @override
  String toString() {
    return 'ID: $id | ${priorityColor}[$priority]$resetColor | $title | $statusText';
  }

  String toDetailString() {
    final buffer = StringBuffer();
    buffer.writeln('╔════════════════════════════════════════════════════════════════════════════════════════════╗');
    buffer.writeln('║                                    CHI TIẾT TASK                                           ║');
    buffer.writeln('╠════════════════════════════════════════════════════════════════════════════════════════════╣');
    buffer.writeln('║ ID: $id');
    buffer.writeln('║ Tiêu đề: $title');
    buffer.writeln('║ Mô tả: $description');
    buffer.writeln('║ Mức độ ưu tiên: ${priorityColor}$priority$resetColor');
    buffer.writeln('║ Thời hạn: $formattedDueDate');
    buffer.writeln('║ Liên kết ngoài: ${externalLink ?? 'Không có'}');
    buffer.writeln('║ Trạng thái: $statusText');
    buffer.writeln('╚════════════════════════════════════════════════════════════════════════════════════════════╝');
    return buffer.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'externalLink': externalLink,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task.withId(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      priority: Priority.values.firstWhere((p) => p.name == json['priority']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      externalLink: json['externalLink'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
