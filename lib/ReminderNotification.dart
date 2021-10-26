import 'package:meta/meta.dart';

class ReminderNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReminderNotification({
      this.id,
     this.title,
     this.body,
     this.payload,
  });
}