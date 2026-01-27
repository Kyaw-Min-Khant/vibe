import 'package:flutter/material.dart';

class RoomUtils {
  static IconData getStatusIcon(String status, dynamic seenAt) {
    switch (status) {
      case 'sent':
        return Icons.check;
      case 'delivered':
        return Icons.done_all;
      default:
        return Icons.check;
    }
  }

  static Color getStatusColor(String status, dynamic seenAt) {
    if (seenAt != null) return Colors.blue;
    if (status == 'delivered') return Colors.white70;
    return Colors.white;
  }

  static String formatTime(dynamic dateTime) {
    if (dateTime == null) return '';
    final dt = DateTime.parse(dateTime).toLocal();
    String period = dt.hour >= 12 ? "PM" : "AM";
    final hour = dt.hour % 12;
    final formattedHour = hour == 0 ? 12 : hour;
    final formattedHourStr = formattedHour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$formattedHourStr:$min $period';
  }
}
