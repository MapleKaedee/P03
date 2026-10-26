import 'package:flutter/material.dart';

import '../models/task.dart';
import '../utils/date_label.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courseController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  DateTime _dueDate = DateUtils.dateOnly(DateTime.now());

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bagian ini wajib diisi';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate.isBefore(today) ? today : _dueDate,
      firstDate: today,
      lastDate: DateTime(today.year + 5, 12, 31),
    );
    if (!mounted || picked == null) return;
    setState(() => _dueDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final task = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      course: _courseController.text.trim(),
      dueDate: _dueDate,
      priority: _priority,
    );
    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Tugas')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul tugas'),
              textCapitalization: TextCapitalization.sentences,
              validator: _requiredText,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _courseController,
              decoration: const InputDecoration(labelText: 'Mata kuliah'),
              validator: _requiredText,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Prioritas'),
              items: TaskPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _priority = value);
              },
              validator: (value) => value == null ? 'Pilih prioritas' : null,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_month),
              label: Text('Tenggat: ${dateLabel(_dueDate)}'),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Simpan tugas')),
          ],
        ),
      ),
    );
  }
}
