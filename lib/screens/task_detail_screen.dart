import 'package:flutter/material.dart';

import '../models/task.dart';
import '../utils/date_label.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, required this.task});

  final Task task;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late bool _isDone;

  @override
  void initState() {
    super.initState();
    _isDone = widget.task.isDone;
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tugas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text('Mata kuliah: ${task.course}'),
          Text('Prioritas: ${task.priority.label}'),
          Text('Tenggat: ${dateLabel(task.dueDate)}'),
          const SizedBox(height: 16),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tugas selesai'),
            value: _isDone,
            onChanged: (value) {
              if (value != null) setState(() => _isDone = value);
            },
          ),
          const Text('Tekan Simpan status untuk menerapkan perubahan.'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, task.copyWith(isDone: _isDone));
            },
            child: const Text('Simpan status'),
          ),
        ],
      ),
    );
  }
}
