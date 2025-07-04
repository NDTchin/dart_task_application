enum Priority {
  high,
  medium,
  low;

  @override
  String toString() {
    switch (this) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }

  static Priority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'high':
      case 'h':
        return Priority.high;
      case 'medium':
      case 'm':
        return Priority.medium;
      case 'low':
      case 'l':
        return Priority.low;
      default:
        throw ArgumentError('Invalid priority: $value');
    }
  }

  int get value {
    switch (this) {
      case Priority.high:
        return 3;
      case Priority.medium:
        return 2;
      case Priority.low:
        return 1;
    }
  }
}
