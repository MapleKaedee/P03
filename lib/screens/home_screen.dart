import 'package:flutter/material.dart';

import '../models/task.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

enum TaskFilter { all, pending, done }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> _tasks = [];
  TaskFilter _filter = TaskFilter.all;

  @override
  void initState() {
    super.initState();
    final today = DateUtils.dateOnly(DateTime.now());
    _tasks.addAll([
      Task(
        id: 'sample-1',
        title: 'Laporan praktikum',
        course: 'Pemrograman Mobile',
        dueDate: today.add(const Duration(days: 2)),
        priority: TaskPriority.high,
      ),
      Task(
        id: 'sample-2',
        title: 'Ringkasan bab 3',
        course: 'Basis Data',
        dueDate: today.add(const Duration(days: 4)),
        priority: TaskPriority.medium,
      ),
    ]);
  }

  Future<void> _addTask() async {
    final task = await Navigator.push<Task>(
      context,
      MaterialPageRoute<Task>(builder: (_) => const TaskFormScreen()),
    );
    if (!mounted || task == null) return;
    setState(() => _tasks.add(task));
  }

  Future<void> _openDetail(Task task) async {
    final updated = await Navigator.push<Task>(
      context,
      MaterialPageRoute<Task>(builder: (_) => TaskDetailScreen(task: task)),
    );
    if (!mounted || updated == null) return;
    final index = _tasks.indexWhere((item) => item.id == updated.id);
    if (index == -1) return;
    setState(() => _tasks[index] = updated);
  }

  @override
  Widget build(BuildContext context) {
    final completed = _tasks.where((task) => task.isDone).length;
    final progress = _tasks.isEmpty ? 0.0 : completed / _tasks.length;
    final visibleTasks = _tasks.where((task) {
      return switch (_filter) {
        TaskFilter.all => true,
        TaskFilter.pending => !task.isDone,
        TaskFilter.done => task.isDone,
      };
    }).toList()..sort(compareTasks);

    return Scaffold(
      appBar: AppBar(title: const Text('StudyFlow')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Tambah tugas',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Selesai $completed dari ${_tasks.length} tugas'),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 16),
                DropdownButton<TaskFilter>(
                  value: _filter,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: TaskFilter.all,
                      child: Text('Semua tugas'),
                    ),
                    DropdownMenuItem(
                      value: TaskFilter.pending,
                      child: Text('Belum selesai'),
                    ),
                    DropdownMenuItem(
                      value: TaskFilter.done,
                      child: Text('Selesai'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _filter = value);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: visibleTasks.isEmpty
                ? const Center(child: Text('Tidak ada tugas pada filter ini.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                    itemCount: visibleTasks.length,
                    itemBuilder: (context, index) {
                      final task = visibleTasks[index];
                      return TaskCard(
                        key: ValueKey(task.id),
                        task: task,
                        onTap: () => _openDetail(task),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
