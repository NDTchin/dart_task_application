class Validator {
  // Kiểm tra string không rỗng
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  // Kiểm tra URL hợp lệ
  static bool isValidUrl(String? url) {
    if (url == null || url.trim().isEmpty) return true; // URL có thể null
    
    try {
      final uri = Uri.parse(url.trim());
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Kiểm tra định dạng ngày
  static DateTime? parseDate(String dateStr) {
    if (dateStr.trim().isEmpty) return null;
    
    try {
      // Thử parse với định dạng dd/MM/yyyy HH:mm
      final parts = dateStr.split(' ');
      if (parts.length == 1) {
        // Chỉ có ngày, thêm giờ mặc định
        dateStr += ' 23:59';
        parts.add('23:59');
      }
      
      final dateParts = parts[0].split('/');
      if (dateParts.length == 3) {
        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);
        
        final timeParts = parts.length > 1 ? parts[1].split(':') : ['23', '59'];
        final hour = int.parse(timeParts[0]);
        final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
        
        return DateTime(year, month, day, hour, minute);
      }
      
      // Thử parse ISO format
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  // Kiểm tra ID hợp lệ
  static int? parseId(String idStr) {
    try {
      final id = int.parse(idStr.trim());
      return id > 0 ? id : null;
    } catch (e) {
      return null;
    }
  }
}
