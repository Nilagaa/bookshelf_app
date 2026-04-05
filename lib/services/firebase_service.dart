import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class FirebaseService {
  // Singleton pattern so only one instance exists
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'books';

  // ─── CREATE ──────────────────────────────────────────────────────────────

  /// Adds a book to Firestore. Throws on failure.
  Future<void> addBook(Book book) async {
    await _db.collection(_collection).add(book.toMap());
  }

  // ─── READ ─────────────────────────────────────────────────────────────────

  /// Returns a real-time stream of all books, ordered by bookName.
  Stream<List<Book>> booksStream() {
    return _db
        .collection(_collection)
        .orderBy('bookName')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Book.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// One-time fetch of all books (no stream).
  Future<List<Book>> fetchBooks() async {
    final snapshot =
        await _db.collection(_collection).orderBy('bookName').get();
    return snapshot.docs
        .map((doc) => Book.fromMap(doc.id, doc.data()))
        .toList();
  }
}
