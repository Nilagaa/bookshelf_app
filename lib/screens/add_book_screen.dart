import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/book.dart';
import '../services/firebase_service.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  final _bookIdController = TextEditingController();
  final _bookNameController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _dateController = TextEditingController();

  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _bookIdController.dispose();
    _bookNameController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(1000),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A237E),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MMMM d, yyyy').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final book = Book(
        bookId: _bookIdController.text.trim(),
        bookName: _bookNameController.text.trim(),
        author: _authorController.text.trim(),
        publisher: _publisherController.text.trim(),
        datePublished: _dateController.text.trim(),
      );

      await FirebaseService.instance.addBook(book);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving book: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF43E97B).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF43E97B),
                size: 52,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Book Added!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '"${_bookNameController.text.trim()}" has been saved successfully.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              _clearForm();
            },
            child: const Text('Add Another'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(); // go back to menu
            },
            child: const Text('Back to Menu'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _formKey.currentState!.reset();
    _bookIdController.clear();
    _bookNameController.clear();
    _authorController.clear();
    _publisherController.clear();
    _dateController.clear();
    setState(() => _selectedDate = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text('Add New Book',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Icon header
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.add_box_rounded,
                  color: Color(0xFF1A237E),
                  size: 40,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fill in the book details below',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 24),
              _buildCard(
                children: [
                  _buildField(
                    controller: _bookIdController,
                    label: 'Book ID',
                    hint: 'e.g. ISBN-978-3-16-148410-0',
                    icon: Icons.tag_rounded,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Book ID is required' : null,
                  ),
                  _buildDivider(),
                  _buildField(
                    controller: _bookNameController,
                    label: 'Book Name',
                    hint: 'Enter the book title',
                    icon: Icons.book_rounded,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Book name is required' : null,
                  ),
                  _buildDivider(),
                  _buildField(
                    controller: _authorController,
                    label: 'Author',
                    hint: 'e.g. J.K. Rowling',
                    icon: Icons.person_rounded,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Author is required' : null,
                  ),
                  _buildDivider(),
                  _buildField(
                    controller: _publisherController,
                    label: 'Publisher',
                    hint: 'e.g. Penguin Books',
                    icon: Icons.business_rounded,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Publisher is required' : null,
                  ),
                  _buildDivider(),
                  _buildField(
                    controller: _dateController,
                    label: 'Date Published',
                    hint: 'Tap to pick a date',
                    icon: Icons.calendar_today_rounded,
                    readOnly: true,
                    onTap: _pickDate,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Date published is required' : null,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isLoading ? 'Saving...' : 'Save Book',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _clearForm,
                child: const Text(
                  'Clear Form',
                  style: TextStyle(color: Colors.black38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() =>
      const Divider(height: 1, thickness: 1, indent: 56, color: Color(0xFFEEEEEE));

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1A237E), size: 22),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        labelStyle: const TextStyle(color: Colors.black54),
        hintStyle: const TextStyle(color: Colors.black26),
        errorStyle: const TextStyle(fontSize: 11),
      ),
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    );
  }
}
