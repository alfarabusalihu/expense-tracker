import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model representing a single Expense record.
class Expense {
  final String id;
  final String title;
  final int amount; // Stored in smallest minor currency units (e.g., LKR minor units)
  final String category;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert an Expense object into a Firestore Map representation.
  Map<String, dynamic> toMap() {
    return {
      'title': title.trim(),
      'amount': amount,
      'category': category.toLowerCase().trim(),
      'date': Timestamp.fromDate(date),
      'note': note != null && note!.trim().isNotEmpty ? note!.trim() : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create an Expense object from a Firestore Map document.
  factory Expense.fromMap(Map<String, dynamic> map, String documentId) {
    return Expense(
      id: documentId,
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      category: map['category'] as String? ?? 'other',
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      note: map['note'] as String?,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Create a copy with modified fields (immutable helper)
  Expense copyWith({
    String? id,
    String? title,
    int? amount,
    String? category,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
