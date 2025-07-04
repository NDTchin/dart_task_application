import 'dart:convert';
import 'dart:io';
import '../models/task.dart';
import '../models/priority.dart';

class TaskManager {
  final List<Task> _tasks = [];
  static const String _dataFile = 'tasks.json';

  List<Task> get tasks => List.unmodifiable(_tasks);

  TaskManager() {
    _loadTasks();
  }

  // Thêm task mới
  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
  }

  // Lấy task theo ID
  Task? getTaskById(int id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  // Xóa task theo ID
  bool removeTask(int id) {
    final initialLength = _tasks.length;
    _tasks.removeWhere((task) => task.id == id);
    if (_tasks.length < initialLength) {
      _saveTasks();
      return true;
    }
    return false;
  }

  // Đánh dấu task hoàn thành
  bool completeTask(int id) {
    final task = getTaskById(id);
    if (task != null) {
      task.isCompleted = true;
      _saveTasks();
      return true;
    }
    return false;
  }

  // Lấy danh sách task đã sắp xếp theo ưu tiên
  List<Task> getSortedTasks() {
    final sortedTasks = List<Task>.from(_tasks);
    sortedTasks.sort((a, b) {
      // Sắp xếp theo ưu tiên (High > Medium > Low)
      final priorityCompare = b.priority.value.compareTo(a.priority.value);
      if (priorityCompare != 0) return priorityCompare;
      
      // Nếu ưu tiên bằng nhau, sắp xếp theo trạng thái (chưa hoàn thành trước)
      final statusCompare = a.isCompleted.toString().compareTo(b.isCompleted.toString());
      if (statusCompare != 0) return statusCompare;
      
      // Cuối cùng sắp xếp theo ID
      return a.id.compareTo(b.id);
    });
    return sortedTasks;
  }

  // Tìm kiếm task theo từ khóa
  List<Task> searchTasks(String keyword) {
    final lowerKeyword = keyword.toLowerCase();
    return _tasks.where((task) =>
      task.title.toLowerCase().contains(lowerKeyword) ||
      task.description.toLowerCase().contains(lowerKeyword)
    ).toList();
  }

  // Lấy task theo trang
  List<Task> getTasksPage(int page, int pageSize) {
    final sortedTasks = getSortedTasks();
    final startIndex = (page - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, sortedTasks.length);
    
    if (startIndex >= sortedTasks.length) return [];
    
    return sortedTasks.sublist(startIndex, endIndex);
  }

  // Lấy tổng số trang
  int getTotalPages(int pageSize) {
    return (_tasks.length / pageSize).ceil();
  }

  // Thống kê task
  Map<String, int> getStatistics() {
    final completed = _tasks.where((task) => task.isCompleted).length;
    final pending = _tasks.length - completed;
    final highPriority = _tasks.where((task) => task.priority == Priority.high).length;
    final mediumPriority = _tasks.where((task) => task.priority == Priority.medium).length;
    final lowPriority = _tasks.where((task) => task.priority == Priority.low).length;
    
    return {
      'total': _tasks.length,
      'completed': completed,
      'pending': pending,
      'high': highPriority,
      'medium': mediumPriority,
      'low': lowPriority,
    };
  }

  // Lưu tasks vào file
  void _saveTasks() {
    try {
      final file = File(_dataFile);
      final tasksJson = _tasks.map((task) => task.toJson()).toList();
      file.writeAsStringSync(jsonEncode(tasksJson));
    } catch (e) {
      print('Lỗi khi lưu dữ liệu: $e');
    }
  }

  // Tải tasks từ file
  void _loadTasks() {
    try {
      final file = File(_dataFile);
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        if (content.isNotEmpty) {
          final List<dynamic> tasksJson = jsonDecode(content);
          _tasks.clear();
          for (final taskJson in tasksJson) {
            _tasks.add(Task.fromJson(taskJson as Map<String, dynamic>));
          }
        }
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu: $e');
    }
  }
}
