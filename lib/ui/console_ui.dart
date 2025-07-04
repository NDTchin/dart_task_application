import 'dart:io';
import '../models/task.dart';
import '../models/priority.dart';
import '../services/task_manager.dart';
import '../utils/validator.dart';

class ConsoleUI {
  final TaskManager _taskManager;
  static const int _pageSize = 5;

  ConsoleUI(this._taskManager);

  // Màu sắc cho console
  static const String _reset = '\x1B[0m';
  static const String _bold = '\x1B[1m';
  static const String _underline = '\x1B[4m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';

  void run() {
    _clearScreen();
    _showWelcome();
    
    while (true) {
      _showMainMenu();
      final choice = _readInput('Chọn một tùy chọn: ');
      
      try {
        switch (choice) {
          case '1':
            _addTask();
            break;
          case '2':
            _displayTasks();
            break;
          case '3':
            _completeTask();
            break;
          case '4':
            _deleteTask();
            break;
          case '5':
            _viewTaskDetail();
            break;
          case '6':
            _searchTasks();
            break;
          case '7':
            _showStatistics();
            break;
          case '8':
            _showExit();
            return;
          default:
            _showError('Lựa chọn không hợp lệ. Vui lòng chọn từ 1-8.');
        }
      } catch (e) {
        _showError('Đã xảy ra lỗi: $e');
      }
      
      _pauseForUser();
    }
  }

  void _clearScreen() {
    if (Platform.isWindows) {
      Process.runSync('cls', [], runInShell: true);
    } else {
      Process.runSync('clear', [], runInShell: true);
    }
  }

  void _showWelcome() {
    print('${_cyan}$_bold');
    print('║                                                                                            ║');
    print('║                            🎯 ỨNG DỤNG QUẢN LÝ TASK 🎯                                    ║');
    print('║                                                                                            ║');
    print('║                               Chào mừng bạn đến với                                       ║');
    print('║                            Hệ thống quản lý công việc                                     ║');
    print('║                                                                                            ║');
    print('$_reset');
  }

  void _showMainMenu() {
    print('\\n${_blue}$_bold╔════════════════════════════════════════════════════════════════════════════════════════════╗$_reset');
    print('${_blue}$_bold║                                    MENU CHÍNH                                              ║$_reset');
    print('${_blue}║$_reset ${_yellow}1.$_reset Thêm Task mới');
    print('${_blue}║$_reset ${_yellow}2.$_reset Hiển thị danh sách Task');
    print('${_blue}║$_reset ${_yellow}3.$_reset Đánh dấu Task hoàn thành');
    print('${_blue}║$_reset ${_yellow}4.$_reset Xóa Task');
    print('${_blue}║$_reset ${_yellow}5.$_reset Xem chi tiết Task');
    print('${_blue}║$_reset ${_yellow}6.$_reset Tìm kiếm Task');
    print('${_blue}║$_reset ${_yellow}7.$_reset Xem thống kê');
    print('${_blue}║$_reset ${_yellow}8.$_reset Thoát');
    print('${_blue}$_bold╚════════════════════════════════════════════════════════════════════════════════════════════╝$_reset');
  }

  void _addTask() {
    _clearScreen();
    print('${_green}$_bold═══════════════════════════ THÊM TASK MỚI ═══════════════════════════$_reset\\n');

    // Nhập tiêu đề
    String title;
    while (true) {
      title = _readInput('${_cyan}Nhập tiêu đề task:$_reset ');
      if (Validator.isNotEmpty(title)) {
        break;
      }
      _showError('Tiêu đề không được rỗng!');
    }

    // Nhập mô tả
    String description;
    while (true) {
      description = _readInput('${_cyan}Nhập mô tả task:$_reset ');
      if (Validator.isNotEmpty(description)) {
        break;
      }
      _showError('Mô tả không được rỗng!');
    }

    // Nhập mức độ ưu tiên
    Priority priority;
    while (true) {
      print('${_cyan}Chọn mức độ ưu tiên:$_reset');
      print('  ${_red}H$_reset - High (Cao)');
      print('  ${_yellow}M$_reset - Medium (Trung bình)');
      print('  ${_green}L$_reset - Low (Thấp)');
      
      final priorityInput = _readInput('${_cyan}Nhập ưu tiên (H/M/L):$_reset ');
      try {
        priority = Priority.fromString(priorityInput);
        break;
      } catch (e) {
        _showError('Mức độ ưu tiên không hợp lệ! Vui lòng nhập H, M hoặc L.');
      }
    }

    // Nhập thời hạn (tùy chọn)
    DateTime? dueDate;
    final dueDateInput = _readInput('${_cyan}Nhập thời hạn (dd/MM/yyyy HH:mm) [Để trống nếu không có]:$_reset ');
    if (dueDateInput.trim().isNotEmpty) {
      dueDate = Validator.parseDate(dueDateInput);
      if (dueDate == null) {
        _showError('Định dạng ngày không hợp lệ! Sử dụng: dd/MM/yyyy HH:mm');
        return;
      }
    }

    // Nhập liên kết ngoài (tùy chọn)
    String? externalLink;
    final linkInput = _readInput('${_cyan}Nhập liên kết ngoài (URL) [Để trống nếu không có]:$_reset ');
    if (linkInput.trim().isNotEmpty) {
      if (Validator.isValidUrl(linkInput)) {
        externalLink = linkInput.trim();
      } else {
        _showError('URL không hợp lệ!');
        return;
      }
    }

    // Tạo task mới
    final task = Task(
      title: title.trim(),
      description: description.trim(),
      priority: priority,
      dueDate: dueDate,
      externalLink: externalLink,
    );

    _taskManager.addTask(task);
    _showSuccess('✓ Task đã được thêm thành công với ID: ${task.id}');
  }

  void _displayTasks() {
    _clearScreen();
    print('${_green}$_bold═══════════════════════════ DANH SÁCH TASK ═══════════════════════════$_reset\\n');

    final totalTasks = _taskManager.tasks.length;
    if (totalTasks == 0) {
      _showInfo('Không có task nào. Hãy thêm task mới!');
      return;
    }

    final totalPages = _taskManager.getTotalPages(_pageSize);
    int currentPage = 1;

    while (true) {
      _clearScreen();
      print('${_green}$_bold═══════════════════════════ DANH SÁCH TASK ═══════════════════════════$_reset\\n');
      
      final tasks = _taskManager.getTasksPage(currentPage, _pageSize);
      
      if (tasks.isEmpty) {
        _showInfo('Không có task nào trong trang này.');
        return;
      }

      // Hiển thị header
      print('${_blue}$_underline${'ID'.padRight(5)} ${'Ưu tiên'.padRight(12)} ${'Tiêu đề'.padRight(30)} ${'Trạng thái'.padRight(15)} ${'Thời hạn'.padRight(20)}$_reset');
      print('${_blue}${'─' * 80}$_reset');

      // Hiển thị tasks
      for (final task in tasks) {
        final priorityText = '${task.priorityColor}${task.priority}$_reset';
        final title = task.title.length > 28 ? '${task.title.substring(0, 25)}...' : task.title;
        final status = task.isCompleted ? '${_green}Hoàn thành$_reset' : '${_yellow}Chưa xong$_reset';
        final dueDate = task.dueDate != null ? task.formattedDueDate : 'Không có';
        
        print('${task.id.toString().padRight(5)} ${priorityText.padRight(20)} ${title.padRight(30)} ${status.padRight(25)} ${dueDate.padRight(20)}');
      }

      print('\\n${_blue}${'─' * 80}$_reset');
      print('${_cyan}Trang $currentPage/$totalPages | Tổng: $totalTasks task(s)$_reset');

      // Điều hướng trang
      if (totalPages > 1) {
        print('\\n${_yellow}Điều hướng:$_reset');
        if (currentPage > 1) print('  ${_green}P$_reset - Trang trước');
        if (currentPage < totalPages) print('  ${_green}N$_reset - Trang sau');
        print('  ${_green}G$_reset - Đi đến trang cụ thể');
        print('  ${_green}Q$_reset - Quay lại menu chính');

        final navigation = _readInput('\\nChọn hành động: ').toLowerCase();
        switch (navigation) {
          case 'p':
            if (currentPage > 1) currentPage--;
            break;
          case 'n':
            if (currentPage < totalPages) currentPage++;
            break;
          case 'g':
            final pageInput = _readInput('Nhập số trang (1-$totalPages): ');
            final pageNum = Validator.parseId(pageInput);
            if (pageNum != null && pageNum >= 1 && pageNum <= totalPages) {
              currentPage = pageNum;
            } else {
              _showError('Số trang không hợp lệ!');
              _pauseForUser();
            }
            break;
          case 'q':
            return;
          default:
            _showError('Lựa chọn không hợp lệ!');
            _pauseForUser();
        }
      } else {
        break;
      }
    }
  }

  void _completeTask() {
    _clearScreen();
    print('${_green}$_bold═══════════════════════ ĐÁNH DẤU HOÀN THÀNH ═══════════════════════$_reset\\n');

    final idInput = _readInput('${_cyan}Nhập ID task cần đánh dấu hoàn thành:$_reset ');
    final id = Validator.parseId(idInput);
    
    if (id == null) {
      _showError('ID không hợp lệ!');
      return;
    }

    final task = _taskManager.getTaskById(id);
    if (task == null) {
      _showError('Không tìm thấy task với ID: $id');
      return;
    }

    if (task.isCompleted) {
      _showInfo('Task này đã được hoàn thành trước đó!');
      return;
    }

    if (_taskManager.completeTask(id)) {
      _showSuccess('✓ Task "${task.title}" đã được đánh dấu hoàn thành!');
    } else {
      _showError('Không thể đánh dấu task hoàn thành!');
    }
  }

  void _deleteTask() {
    _clearScreen();
    print('${_red}$_bold═══════════════════════════ XÓA TASK ═══════════════════════════$_reset\\n');

    final idInput = _readInput('${_cyan}Nhập ID task cần xóa:$_reset ');
    final id = Validator.parseId(idInput);
    
    if (id == null) {
      _showError('ID không hợp lệ!');
      return;
    }

    final task = _taskManager.getTaskById(id);
    if (task == null) {
      _showError('Không tìm thấy task với ID: $id');
      return;
    }

    // Hiển thị thông tin task trước khi xóa
    print('\\n${_yellow}Task sẽ bị xóa:$_reset');
    print('ID: ${task.id}');
    print('Tiêu đề: ${task.title}');
    print('Mô tả: ${task.description}');

    final confirm = _readInput('\\n${_red}Bạn có chắc chắn muốn xóa task này? (y/n):$_reset ').toLowerCase();
    
    if (confirm == 'y' || confirm == 'yes') {
      if (_taskManager.removeTask(id)) {
        _showSuccess('✓ Task đã được xóa thành công!');
      } else {
        _showError('Không thể xóa task!');
      }
    } else {
      _showInfo('Hủy xóa task.');
    }
  }

  void _viewTaskDetail() {
    _clearScreen();
    print('${_blue}$_bold═══════════════════════════ CHI TIẾT TASK ═══════════════════════════$_reset\\n');

    final idInput = _readInput('${_cyan}Nhập ID task cần xem:$_reset ');
    final id = Validator.parseId(idInput);
    
    if (id == null) {
      _showError('ID không hợp lệ!');
      return;
    }

    final task = _taskManager.getTaskById(id);
    if (task == null) {
      _showError('Không tìm thấy task với ID: $id');
      return;
    }

    print('\\n${task.toDetailString()}');

    // Xử lý external link
    if (task.externalLink != null) {
      final openLink = _readInput('\\n${_green}Task có liên kết ngoài. Bạn có muốn mở liên kết này? (y/n):$_reset ').toLowerCase();
      if (openLink == 'y' || openLink == 'yes') {
        _openExternalLink(task.externalLink!);
      }
    }
  }

  void _searchTasks() {
    _clearScreen();
    print('${_magenta}$_bold═══════════════════════════ TÌM KIẾM TASK ═══════════════════════════$_reset\\n');

    final keyword = _readInput('${_cyan}Nhập từ khóa tìm kiếm:$_reset ');
    if (keyword.trim().isEmpty) {
      _showError('Từ khóa không được rỗng!');
      return;
    }

    final results = _taskManager.searchTasks(keyword);
    
    if (results.isEmpty) {
      _showInfo('Không tìm thấy task nào với từ khóa: "$keyword"');
      return;
    }

    print('\\n${_green}Tìm thấy ${results.length} task(s) với từ khóa "$keyword":$_reset\\n');
    
    // Hiển thị header
    print('${_blue}$_underline${'ID'.padRight(5)} ${'Ưu tiên'.padRight(12)} ${'Tiêu đề'.padRight(30)} ${'Trạng thái'.padRight(15)}$_reset');
    print('${_blue}${'─' * 60}$_reset');

    // Hiển thị kết quả
    for (final task in results) {
      final priorityText = '${task.priorityColor}${task.priority}$_reset';
      final title = task.title.length > 28 ? '${task.title.substring(0, 25)}...' : task.title;
      final status = task.isCompleted ? '${_green}Hoàn thành$_reset' : '${_yellow}Chưa xong$_reset';
      
      print('${task.id.toString().padRight(5)} ${priorityText.padRight(20)} ${title.padRight(30)} ${status.padRight(15)}');
    }
  }

  void _showStatistics() {
    _clearScreen();
    print('${_cyan}$_bold═══════════════════════════ THỐNG KÊ TASK ═══════════════════════════$_reset\\n');

    final stats = _taskManager.getStatistics();
    
    print('╔════════════════════════════════════════════════════════════════════════════════════════════╗');
    print('║                                    THỐNG KÊ TỔNG QUAN                                     ║');
    print('╠════════════════════════════════════════════════════════════════════════════════════════════╣');
    print('║ 📊 Tổng số task:              ${stats['total'].toString().padLeft(3)} task(s)');
    print('║ ✅ Task đã hoàn thành:        ${stats['completed'].toString().padLeft(3)} task(s)');
    print('║ ⏳ Task chưa hoàn thành:      ${stats['pending'].toString().padLeft(3)} task(s)');
    print('║');
    print('║ 🔴 Ưu tiên cao (High):        ${stats['high'].toString().padLeft(3)} task(s)');
    print('║ 🟡 Ưu tiên trung bình (Medium): ${stats['medium'].toString().padLeft(3)} task(s)');
    print('║ 🟢 Ưu tiên thấp (Low):        ${stats['low'].toString().padLeft(3)} task(s)');
    print('╚════════════════════════════════════════════════════════════════════════════════════════════╝');

    // Hiển thị tỷ lệ hoàn thành
    if (stats['total']! > 0) {
      final completionRate = (stats['completed']! / stats['total']! * 100).toStringAsFixed(1);
      print('\\n${_green}💯 Tỷ lệ hoàn thành: $completionRate%$_reset');
      
      // Thanh progress bar
      final progressBarLength = 50;
      final completedBars = (stats['completed']! / stats['total']! * progressBarLength).round();
      final progressBar = '█' * completedBars + '░' * (progressBarLength - completedBars);
      print('   [$progressBar]');
    }
  }

  void _openExternalLink(String url) {
    try {
      if (Platform.isWindows) {
        Process.runSync('start', [url], runInShell: true);
      } else if (Platform.isMacOS) {
        Process.runSync('open', [url]);
      } else {
        Process.runSync('xdg-open', [url]);
      }
      _showSuccess('✓ Liên kết đã được mở trong trình duyệt!');
    } catch (e) {
      _showError('Không thể mở liên kết: $e');
    }
  }

  void _showExit() {
    _clearScreen();
    print('${_magenta}$_bold');
    print('║                                                                                            ║');
    print('║                              🙏 CẢM ỠN BẠN ĐÃ SỬ DỤNG! 🙏                                ║');
    print('║                               Hẹn gặp lại bạn lần sau!                                    ║');
    print('║                                                                                            ║');
    print('$_reset');
  }

  String _readInput(String prompt) {
    stdout.write(prompt);
    return stdin.readLineSync() ?? '';
  }

  void _showError(String message) {
    print('\\n${_red}❌ Lỗi: $message$_reset');
  }

  void _showSuccess(String message) {
    print('\\n${_green}$message$_reset');
  }

  void _showInfo(String message) {
    print('\\n${_blue}ℹ️  $message$_reset');
  }

  void _pauseForUser() {
    print('\\n${_yellow}Nhấn Enter để tiếp tục...$_reset');
    stdin.readLineSync();
  }
}
