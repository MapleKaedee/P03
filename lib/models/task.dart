enum TaskPriority {
  low('Rendah', 1),
  medium('Sedang', 2),
  high('Tinggi', 3);

  const TaskPriority(this.label, this.rank);

  final String label;
  final int rank;
}

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.course,
    required this.dueDate,
    required this.priority,
    this.isDone = false,
  });

  final String id;
  final String title;
  final String course;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool isDone;

  Task copyWith({bool? isDone}) {
    return Task(
      id: id,
      title: title,
      course: course,
      dueDate: dueDate,
      priority: priority,
      isDone: isDone ?? this.isDone,
    );
  }
}

int compareTasks(Task a, Task b) {
  if (a.isDone != b.isDone) {
    return a.isDone ? 1 : -1;
  }
  final priorityOrder = b.priority.rank.compareTo(a.priority.rank);
  if (priorityOrder != 0) return priorityOrder;
  final dateOrder = a.dueDate.compareTo(b.dueDate);
  if (dateOrder != 0) return dateOrder;
  return a.title.compareTo(b.title);
}
