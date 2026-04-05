class Book {
  final String? id; // Firestore document ID
  final String bookId;
  final String bookName;
  final String author;
  final String publisher;
  final String datePublished;

  Book({
    this.id,
    required this.bookId,
    required this.bookName,
    required this.author,
    required this.publisher,
    required this.datePublished,
  });

  /// Convert Book to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookName': bookName,
      'author': author,
      'publisher': publisher,
      'datePublished': datePublished,
    };
  }

  /// Create a Book from a Firestore document snapshot
  factory Book.fromMap(String docId, Map<String, dynamic> map) {
    return Book(
      id: docId,
      bookId: map['bookId'] ?? '',
      bookName: map['bookName'] ?? '',
      author: map['author'] ?? '',
      publisher: map['publisher'] ?? '',
      datePublished: map['datePublished'] ?? '',
    );
  }
}
