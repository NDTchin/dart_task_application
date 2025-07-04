import 'package:dart_task_application/services/task_manager.dart';
import 'package:dart_task_application/ui/console_ui.dart';

void main(List<String> arguments) {
  try {
    // Khởi tạo Task Manager
    final taskManager = TaskManager();
    
    // Khởi tạo giao diện console
    final consoleUI = ConsoleUI(taskManager);
    
    // Chạy ứng dụng
    consoleUI.run();
  } catch (e) {
    print('Lỗi khởi tạo ứng dụng: $e');
  }
}
