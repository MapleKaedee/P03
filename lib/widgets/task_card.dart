import 'package:flutter/material.dart';

import '../models/task.dart';
import '../utils/date_label.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final priorityColor = switch (task.priority) {
      TaskPriority.high => Colors.red,
      TaskPriority.medium => Colors.orange,
      TaskPriority.low => Colors.green,
    };

    return Card(
      child: ListTile(
        onTap: onTap,
        isThreeLine: true,
        leading: Icon(
          task.isDone ? Icons.check_circle : Icons.pending_actions,
          color: task.isDone ? Colors.green : null,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('${task.course}\nTenggat: ${dateLabel(task.dueDate)}'),
        trailing: Text(
          task.priority.label,
          style: TextStyle(color: priorityColor),
        ),
      ),
    );
  }
}
