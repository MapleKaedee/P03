# StudyFlow — Panduan P03 langkah demi langkah

StudyFlow membantu mahasiswa **mencatat, mengatur, memprioritaskan, dan memantau penyelesaian tugas perkuliahan** dalam satu aplikasi Flutter.

Panduan ini mengacu pada [ketentuan P03](<P03_Flutter-Mini-App.md>). Kita membuat versi minimum yang lengkap terlebih dahulu, bukan aplikasi produksi. **Data disimpan di memori**; perubahan akan hilang ketika proses aplikasi dimulai ulang. Database, login, API, dan notifikasi belum diperlukan.

> Hasil panduan: aplikasi Android dengan tiga layar, daftar berbasis data, form tervalidasi, pengurutan prioritas, filter status, dan ringkasan progres. Dokumen ini adalah panduan; berkas aplikasi baru dibuat saat kamu mengikuti langkah-langkahnya. Sesuai fokus saat ini, README, video, dan pengumpulan tidak dibahas.

**Urutan belajarnya:** siapkan proyek → buat model → buat widget kartu → buat form → buat detail → hubungkan dashboard → jalankan dan uji. Kerjakan satu tahap dulu, tidak harus menyalin semuanya sekaligus.

**Status verifikasi:** kode contoh perlu kamu jalankan dengan langkah pemeriksaan di bagian 10–11. Pada penyusunan panduan, analyzer dan tes Flutter belum dijalankan karena toolchain masih memerlukan unduhan.

## 1. Tetapkan fitur dan batas pekerjaan

### Tiga layar

| Layar | Isi | Tindakan pengguna |
|---|---|---|
| Dashboard | Ringkasan progres, filter status, daftar tugas | Melihat tugas, mengganti filter, membuka detail atau form |
| Tambah Tugas | Judul, mata kuliah, prioritas, tenggat | Menyimpan tugas valid atau kembali untuk membatalkan |
| Detail Tugas | Informasi tugas dan status selesai | Mengubah status lalu menyimpan, atau kembali untuk membatalkan |

Alur navigasi:

```text
Dashboard ── tombol + ──> Tambah Tugas
Dashboard <── kembali / simpan ─────┘

Dashboard ── ketuk kartu ──> Detail Tugas
Dashboard <── kembali / simpan ──────┘
```

**Aturan prioritas yang digunakan:** tugas belum selesai ditampilkan dahulu, lalu prioritas Tinggi → Sedang → Rendah, lalu tenggat terdekat untuk prioritas yang sama. Urutan ini adalah keputusan desain StudyFlow, bukan aturan wajib P03. Tugas yang selesai tetap tersedia melalui filter.

### Pemetaan ke ketentuan P03

| Ketentuan | Implementasi StudyFlow |
|---|---|
| Tiga layar, navigasi maju-mundur | Dashboard, Tambah Tugas, Detail Tugas; `Navigator.push` dan `Navigator.pop` |
| Satu daftar berasal dari data | `List<Task>` ditampilkan menggunakan `ListView.builder` |
| `StatefulWidget` dan `setState` nyata | Menambah/memperbarui tugas, mengganti filter, mengubah pilihan form/status |
| Form minimal dua jenis input dan validasi kosong | `TextFormField`, `DropdownButtonFormField`, pemilih tanggal; judul dan mata kuliah wajib diisi |
| Widget buatan sendiri dipakai berulang | `TaskCard` digunakan untuk setiap tugas dengan data berbeda |
| Struktur tidak menumpuk di satu berkas | Model, layar, widget, dan utilitas dipisah |
| `flutter analyze` bersih | Diperiksa setelah implementasi, bukan sekadar diasumsikan |

**Jangan ditambahkan dulu:** autentikasi, sinkronisasi cloud, lampiran, pengingat push, dan manajemen kelompok. Itu bisa menjadi pengembangan capstone setelah P03 selesai.

## 2. Siapkan lingkungan dan buat proyek

### Khusus workspace ini: gunakan lingkungan Nix yang sudah tersedia

Konfigurasi Flutter/Android sudah disediakan melalui [konfigurasi Nix](<flake.nix>) dan [launcher emulator](<scripts/studyflow-emulator.sh>). Buka terminal di **root workspace P03**, lalu jalankan:

```bash
nix develop
flutter --version
flutter doctor
```

Pertama kali dijalankan, Nix mungkin perlu mengunduh toolchain yang cukup besar. Jika muncul error cache Nix `attempt to write a readonly database`, jalankan dari root workspace:

```bash
XDG_CACHE_HOME="$PWD/.dev/cache" nix develop
```

Periksa bagian Android toolchain dan perangkat. Peringatan platform lain tidak harus diselesaikan jika targetmu Android. Jika Flutter/Android bermasalah, selesaikan sebelum menulis fitur aplikasi.

Di terminal tersebut, buat aplikasi di subdirektori baru:

```bash
flutter create --platforms=android --org com.example studyflow
cd studyflow
flutter pub get
```

Nama paket pada contoh kode adalah `studyflow`; pertahankan nama ini agar import pengujian cocok. Jika direktori tersebut sudah berisi proyek, **jangan membuat ulang di atas pekerjaanmu**; lanjutkan dari proyek yang ada dan sesuaikan struktur.

### Jalankan emulator

Di terminal kedua, masuk **root workspace P03**, bukan subdirektori aplikasi:

```bash
nix develop
studyflow-emulator
```

Jika akselerasi perangkat keras bermasalah:

```bash
studyflow-emulator --software
```

Biarkan terminal emulator tetap berjalan. Mode software bisa sangat lambat. Di terminal pertama, yang berada di direktori aplikasi:

```bash
flutter devices
flutter run -d ID_PERANGKAT
```

Ganti `ID_PERANGKAT` dengan ID yang benar dari `flutter devices`. Android fisik dengan USB debugging juga boleh digunakan. Tunggu perangkat muncul dan selesai boot; jangan menyalin ID contoh yang belum tentu ada.

**Checkpoint:** aplikasi bawaan Flutter tampil pada emulator/perangkat. Hentikan `flutter run` dengan `q` sebelum menjalankan pemeriksaan akhir nanti.

> Jika mengikuti panduan di komputer lain tanpa Nix, gunakan Flutter SDK dan Android SDK lokal yang sudah terpasang, lalu mulai dari `flutter doctor` dan `flutter create`. Tidak perlu memasang Nix hanya untuk mengikuti kode aplikasi.

## 3. Siapkan struktur berkas

Dari direktori aplikasi, buat direktori berikut:

```bash
mkdir -p lib/models lib/screens lib/widgets lib/utils
```

Struktur hasil implementasi:

```text
studyflow/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── task.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── task_form_screen.dart
│   │   └── task_detail_screen.dart
│   ├── widgets/
│   │   └── task_card.dart
│   └── utils/
│       └── date_label.dart
└── test/
    ├── task_test.dart
    └── widget_test.dart
```

Semua blok kode Dart di bawah adalah **isi lengkap** berkas yang disebut pada judul langkahnya. Salin satu per satu. Proyek belum dapat dianalisis sepenuhnya sampai seluruh berkas dan import tersedia.

Tidak ada dependensi tambahan. Jika sudah memiliki model dari P02, kamu boleh menyesuaikannya dengan atribut di langkah berikut, bukan membuat model duplikat.

## 4. Buat model tugas

Buat `lib/models/task.dart`:

```dart
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
```

**Pahami:** model tidak mengimpor Flutter. `TaskPriority` membatasi nilai prioritas, sedangkan `copyWith` menghasilkan tugas baru tanpa mengubah objek lama. `id` tetap sama meskipun statusnya berubah. Pembanding urutan diletakkan di dekat model karena merupakan aturan data, bukan aturan tampilan.

## 5. Buat utilitas tanggal dan widget kartu

Buat `lib/utils/date_label.dart`:

```dart
String dateLabel(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
```

Buat `lib/widgets/task_card.dart`:

```dart
import 'package:flutter/material.dart';

import '../models/task.dart';
import '../utils/date_label.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

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
        subtitle: Text(
          '${task.course}\nTenggat: ${dateLabel(task.dueDate)}',
        ),
        trailing: Text(
          task.priority.label,
          style: TextStyle(color: priorityColor),
        ),
      ),
    );
  }
}
```

**Pahami:** kartu hanya menampilkan data dan meneruskan ketukan melalui `onTap`. Kartu tidak menyimpan daftar tugas atau mengubah status sendiri. Label prioritas tetap ditulis agar makna tidak bergantung pada warna saja.

## 6. Buat layar Tambah Tugas

Buat `lib/screens/task_form_screen.dart`:

```dart
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
            FilledButton(
              onPressed: _save,
              child: const Text('Simpan tugas'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Pahami dan periksa:**

1. Judul dan mata kuliah kosong, termasuk hanya spasi, ditolak oleh `trim().isEmpty`.
2. Ada input teks dan pilihan prioritas; pemilih tanggal menambah jenis interaksi.
3. Prioritas awal adalah Sedang dan tenggat awal adalah hari ini, sehingga keduanya sudah memiliki nilai valid.
4. `setState` memperbarui pilihan prioritas dan label tanggal.
5. `dispose` melepaskan controller saat layar ditutup.
6. `mounted` diperiksa setelah pemilih tanggal selesai karena layar mungkin sudah ditutup.
7. Menekan Simpan mengembalikan objek `Task`; tombol kembali membatalkan dan menghasilkan `null`.

> Kode memakai API Flutter modern (`initialValue` pada dropdown), sesuai lingkungan Nix workspace. Jika SDK lain tidak mengenalinya, periksa versi Flutter dan gunakan SDK stabil yang mendukung API tersebut sebelum melanjutkan.

## 7. Buat layar Detail Tugas

Buat `lib/screens/task_detail_screen.dart`:

```dart
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
```

**Keputusan UX:** status pada layar detail adalah draf lokal. Perubahan baru diterapkan ke dashboard saat pengguna menekan **Simpan status**. Tombol kembali pada AppBar atau perangkat membatalkan perubahan. Ini sengaja dibuat konsisten dengan form, bukan penyimpanan otomatis.

## 8. Buat dashboard dan hubungkan aliran data

Buat `lib/screens/home_screen.dart`:

```dart
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
    }).toList()
      ..sort(compareTasks);

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
```

Dua tugas awal hanyalah **data contoh** agar pemakaian ulang kartu langsung terlihat. Daftar tetap berasal dari `List<Task>`, bukan dua widget kartu yang diketik manual. Setiap peluncuran proses baru memulai kembali data contoh ini.

### Mengapa state diletakkan di sini?

- Dashboard memiliki `_tasks` karena ringkasan, filter, dan daftar memakai sumber data yang sama.
- Daftar tidak diletakkan di `main.dart` karena tidak dibutuhkan seluruh aplikasi.
- Form menyimpan input sementara; detail menyimpan draf status saja.
- Kedua layar mengembalikan hasil ke dashboard melalui `Navigator.pop(context, hasil)`.
- Dashboard memperbarui `_tasks` di dalam `setState`, sehingga jumlah selesai, urutan, dan kartu berubah bersama.
- Daftar hasil filter dibuat dengan `toList()` sebelum diurutkan; tampilan turunan tidak perlu mengacak daftar sumber.
- Ringkasan dihitung dari seluruh tugas, **bukan hanya tugas yang lolos filter**.

Contoh aliran status:

```text
Ketuk kartu
  → push Detail dengan Task terpilih
  → centang status lokal
  → Simpan status mengembalikan Task baru dengan id yang sama
  → dashboard mencari id tersebut
  → setState mengganti elemen daftar
  → kartu dan progres dibangun ulang
```

**Checkpoint:** jelaskan aliran di atas dengan bahasamu sendiri sebelum melanjutkan. Ini membantu bagian pemahaman state pada rubrik.

## 9. Ganti entry point aplikasi

Ganti isi `lib/main.dart` hasil template dengan:

```dart
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const StudyFlowApp());
}

class StudyFlowApp extends StatelessWidget {
  const StudyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
```

**Checkpoint:** jalankan kembali `flutter run -d ID_PERANGKAT`. Coba tambah tugas, buka detail, ubah status, dan lihat progres berubah. Bila aplikasi masih berjalan, lakukan hot restart setelah perubahan struktur besar. Hot reload tidak selalu mengulang `initState`.

## 10. Tambahkan pengujian otomatis

Pengujian berikut adalah rekomendasi untuk membantu menemukan bug; P03 secara eksplisit mewajibkan analyzer bersih dan demonstrasi aplikasi berjalan.

### Uji aturan prioritas

Buat `test/task_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/models/task.dart';

void main() {
  test('Belum selesai, prioritas, lalu tenggat menentukan urutan', () {
    Task makeTask(
      String id,
      TaskPriority priority,
      int day, {
      bool isDone = false,
    }) {
      return Task(
        id: id,
        title: id,
        course: 'Mobile',
        dueDate: DateTime(2026, 11, day),
        priority: priority,
        isDone: isDone,
      );
    }

    final tasks = [
      makeTask('done', TaskPriority.high, 1, isDone: true),
      makeTask('low', TaskPriority.low, 1),
      makeTask('high-later', TaskPriority.high, 5),
      makeTask('high-sooner', TaskPriority.high, 2),
    ]..sort(compareTasks);

    expect(
      tasks.map((task) => task.id).toList(),
      ['high-sooner', 'high-later', 'low', 'done'],
    );
  });

  test('copyWith mengubah status tanpa mengubah objek asal', () {
    final original = Task(
      id: '1',
      title: 'Laporan',
      course: 'Mobile',
      dueDate: DateTime(2026, 11, 1),
      priority: TaskPriority.high,
    );
    final updated = original.copyWith(isDone: true);

    expect(original.isDone, isFalse);
    expect(updated.isDone, isTrue);
    expect(updated.id, original.id);
  });
}
```

### Ganti pengujian bawaan counter

Ganti **seluruh isi** `test/widget_test.dart` dari template. Jika tidak diganti, pengujian masih mencari counter atau kelas `MyApp` yang sudah tidak digunakan.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/main.dart';

void main() {
  testWidgets('Form menolak kosong, menerima tugas, dan menyimpan status', (
    tester,
  ) async {
    Future<void> tapVisible(Finder target) async {
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      await tester.tap(target);
    }

    await tester.pumpWidget(const StudyFlowApp());
    expect(find.text('Selesai 0 dari 2 tugas'), findsOneWidget);

    await tapVisible(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tapVisible(find.text('Simpan tugas'));
    await tester.pumpAndSettle();
    expect(find.text('Bagian ini wajib diisi'), findsNWidgets(2));

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Latihan pengujian',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Mobile');
    await tapVisible(find.text('Simpan tugas'));
    await tester.pumpAndSettle();
    expect(find.text('Latihan pengujian'), findsOneWidget);
    expect(find.text('Selesai 0 dari 3 tugas'), findsOneWidget);

    await tapVisible(find.text('Latihan pengujian'));
    await tester.pumpAndSettle();
    await tapVisible(find.byType(CheckboxListTile));
    await tester.pump();
    await tapVisible(find.text('Simpan status'));
    await tester.pumpAndSettle();
    expect(find.text('Selesai 1 dari 3 tugas'), findsOneWidget);
  });
}
```

Jalankan dari direktori aplikasi di dalam lingkungan Flutter:

```bash
dart format lib test
flutter analyze
flutter test
```

**Target:** analyzer melaporkan tidak ada masalah dan semua tes lulus. Jangan mematikan lint hanya agar output terlihat bersih; perbaiki penyebabnya. Tes otomatis tidak menggantikan demonstrasi pada emulator/perangkat.

## 11. Uji manual dengan skenario nyata

| No. | Tindakan | Hasil yang diharapkan |
|---|---|---|
| 1 | Buka aplikasi | Dua tugas contoh dan progres 0 dari 2 muncul |
| 2 | Tambah tugas lalu Simpan tanpa input | Pesan wajib diisi muncul; layar tidak tertutup |
| 3 | Isi judul atau mata kuliah hanya spasi | Tetap ditolak |
| 4 | Isi judul, mata kuliah, prioritas Tinggi, pilih tanggal, Simpan | Kembali ke dashboard; jumlah tugas bertambah |
| 5 | Tambah tugas dengan prioritas berbeda | Tugas belum selesai berprioritas Tinggi tampil lebih dahulu |
| 6 | Buat dua tugas prioritas sama dengan tenggat berbeda | Tenggat lebih dekat berada di atas |
| 7 | Buka detail lalu kembali tanpa perubahan | Kembali ke dashboard tanpa crash |
| 8 | Centang selesai lalu tekan Simpan status | Ringkasan, garis progres, dan tampilan kartu berubah |
| 9 | Centang/ubah status lalu kembali tanpa Simpan | Perubahan dibatalkan; status lama dipertahankan |
| 10 | Ganti filter Semua / Belum selesai / Selesai | Daftar sesuai filter; ringkasan keseluruhan tetap sama |
| 11 | Pilih filter Selesai sebelum ada tugas selesai | Pesan kosong muncul, bukan layar crash |
| 12 | Batalkan form dengan tombol kembali | Tidak ada tugas kosong baru |
| 13 | Buka tugas selesai, hapus centang, Simpan | Jumlah selesai berkurang |
| 14 | Isi judul panjang, buka keyboard, gulir form | Form tetap bisa digulir dan disimpan |
| 15 | Hentikan lalu jalankan proses aplikasi kembali | Kembali ke dua tugas contoh; hilangnya perubahan memang sesuai lingkup P03 |

Untuk memeriksa kondisi daftar sumber kosong, kamu bisa sementara menonaktifkan pengisian data contoh di `initState`, menjalankan ulang, lalu memastikan pesan kosong dan progres 0 tidak crash. Pulihkan data contoh sebelum demonstrasi jika ingin langsung memperlihatkan dua kartu.

**Catatan filter:** jika kamu menambah tugas saat filter Selesai aktif, tugas baru tidak langsung terlihat karena status awalnya belum selesai. Ubah ke Semua tugas atau Belum selesai. Itu perilaku filter yang disengaja.

## 12. Debug secara sadar, bukan sekadar menyalin

Saat menemukan masalah:

1. Catat langkah yang bisa mengulanginya.
2. Baca pesan pertama yang relevan dari Debug Console atau terminal.
3. Periksa apakah penyebab ada pada data, perubahan state, atau navigasi.
4. Pasang breakpoint atau gunakan `debugPrint` sementara untuk memeriksa nilai.
5. Perbaiki penyebab, ulangi langkah yang sama, lalu jalankan analyzer dan tes.
6. Catat singkat penyebab dan perbaikannya agar kamu memahami kode yang dibuat.

Contoh diagnosis yang mungkin membantu:

| Gejala | Hal yang diperiksa |
|---|---|
| Daftar tidak berubah setelah Simpan | Apakah `Task` dikembalikan melalui `pop` dan ditambahkan dalam `setState`? |
| Checkbox kembali ke nilai awal setiap rebuild | Apakah draf status keliru diinisialisasi di `build`, bukan `initState`? |
| Analyzer mengeluh tentang `MyApp` | Apakah tes bawaan sudah diganti? |
| `setState() called after dispose()` | Apakah ada pemeriksaan `mounted` setelah `await` sebelum memakai state/context? |
| Filter Selesai terlihat kosong setelah menambah tugas | Periksa status awal dan filter; belum tentu bug |
| Perubahan data contoh tidak muncul | Coba hot restart; hot reload tidak menjalankan ulang `initState` |

## 13. Checklist aplikasi sudah siap dipakai

### Fungsionalitas — 35%

- [ ] Aplikasi berjalan di emulator atau perangkat Android.
- [ ] Ketiga layar dikunjungi dan navigasi kembali berfungsi.
- [ ] Daftar dibangun dari data, bukan kumpulan kartu manual.
- [ ] Form menolak input kosong dan spasi; input valid menambah tugas.
- [ ] `TaskCard` tampil berulang dengan data berbeda.
- [ ] Status, filter, urutan prioritas, dan progres bekerja tanpa crash.

### Struktur — 25%

- [ ] Model, layar, utilitas, dan widget dipisahkan secara wajar.
- [ ] Entry point tidak berisi seluruh implementasi aplikasi.
- [ ] Controller dibersihkan dengan `dispose`.

### Pemahaman state — 25%

- [ ] Bisa menjelaskan pemilik daftar tugas dan alasan penempatannya.
- [ ] Bisa menjelaskan perubahan apa yang memerlukan `setState`.
- [ ] Bisa menjelaskan hasil navigasi, pembatalan, dan draf status.
- [ ] Bisa menjelaskan bahwa data hanya hidup selama proses aplikasi.

### Pemeriksaan akhir aplikasi

- [ ] `flutter analyze` bersih dan hasil tes sudah diperiksa.
- [ ] Semua skenario uji manual utama sudah dicoba di emulator/perangkat.
- [ ] Tidak ada error runtime pada penggunaan normal.

Panduan ini berhenti pada aplikasi yang berjalan. README, video, dan proses pengumpulan sengaja ditunda.

## Saran pembagian waktu

Estimasi tugas resmi adalah **3 × 50 menit**. Jika lingkungan Flutter sudah siap, gunakan pembagian berikut sebagai target belajar, bukan jaminan waktu:

1. **Sesi 1:** pahami kebutuhan, buat struktur, model, utilitas, kartu, dan form.
2. **Sesi 2:** buat detail dan dashboard, hubungkan navigasi, jalankan aplikasi.
3. **Sesi 3:** uji alur aplikasi, perbaiki bug, jalankan analyzer dan tes, lalu rapikan tampilan.

Instalasi SDK/emulator dapat membutuhkan waktu tambahan. Setelah versi P03 stabil, barulah pertimbangkan penyimpanan lokal, edit/hapus tugas, penanda terlambat, dan notifikasi sebagai pengembangan lanjutan.
