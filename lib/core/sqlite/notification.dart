import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Notification{
  final int? id;
  final String date;
  final String text;

  Notification({
    this.id,
    required this.date,
    required this.text,
});

  // Convert a notification into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'text': text,
    };
  }

  // Implement toString to make it easier to see information about
  // each Notification when using the print statement.
  @override
  String toString() {
    return 'Notification{id: $id, date: $date, text: $text}';
  }

// Define a function that inserts notifications into the database
  static Future<void> insertNotification(Notification notification) async {
    // Get a reference to the database.
    final db = await openDatabase(join(await getDatabasesPath(), 'notification_database.db'));

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'notifications',
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}