# Catatan Development Environment Nix

Dokumen ini berisi pengaturan Nix untuk kebutuhan pengembangan pribadi di NixOS.
Nix digunakan untuk menyediakan tooling Flutter/Android dan bukan bagian dari
fitur, requirements, atau dependensi aplikasi StudyFlow bagi penggunanya.

## Masuk ke environment

Jalankan dari root project pada NixOS `x86_64-linux`, dengan fitur `nix-command`
dan `flakes` sudah aktif:

```bash
cd /home/kaede/Projects/P03
nix develop
```

Dev shell menyediakan Flutter/Dart, JDK, Android SDK, build-tools, NDK, adb,
emulator, dan satu system image Android. Pemanggilan pertama membutuhkan jaringan,
ruang disk beberapa GB, serta waktu untuk mengunduh dan menyiapkan dependensi.
Tidak diperlukan Android Studio.

Tooling dideklarasikan di `flake.nix` dan revisi nixpkgs dikunci di `flake.lock`.
Tidak ada instalasi melalui `nix profile`, perubahan konfigurasi NixOS/Home
Manager, atau `nixos-rebuild`. Paket tetap tersimpan di `/nix/store` setelah shell
ditutup dan dapat dibersihkan oleh garbage collector Nix ketika tidak lagi dirujuk.

| Komponen | Versi yang dipilih |
| --- | --- |
| Flutter | 3.47.4 (`flutter347`) |
| Dart | 3.13.3, bawaan Flutter |
| JDK | OpenJDK 21 |
| Android platform / image | API 36, `google_apis`, `x86_64` |
| Android build-tools | 36.0.0 |
| Android NDK | 28.2.13676358 |

Versi Android mengikuti default Flutter tersebut. SDK disusun menggunakan
`androidenv.composeAndroidPackages`, dengan penerimaan lisensi SDK Android dan
paket unfree diatur hanya untuk import nixpkgs project ini. Jangan menjalankan
`flutter upgrade` atau memasang komponen dengan `sdkmanager` ke SDK di Nix store;
ubah deklarasi Nix bila membutuhkan versi atau komponen lain.

## Menjalankan emulator

Di dalam dev shell:

```bash
studyflow-emulator
```

Perintah ini membuat AVD bernama `StudyFlow` pada penggunaan pertama, dengan
profil Pixel 6, RAM 2 GB, dan dua CPU virtual. Penggunaan berikutnya memakai AVD
yang sama. Emulator tidak otomatis dijalankan ketika memasuki shell.

Launcher memilih akselerasi CPU KVM jika pemeriksaannya berhasil. Jika tidak,
launcher memakai emulasi CPU software dan renderer GPU SwiftShader. Mode software
bisa dipilih secara eksplisit; boot dan interaksi akan lebih lambat:

```bash
studyflow-emulator --software
```

Untuk pemeriksaan tanpa jendela:

```bash
studyflow-emulator --software -no-window -no-audio
```

Argumen emulator tambahan diteruskan setelah opsi launcher. `--software` harus
menjadi argumen pertama. Lihat `studyflow-emulator --help` untuk ringkasannya.
Launcher selalu memakai cold boot tanpa snapshot agar pergantian mode rendering
tidak memulihkan snapshot yang tidak cocok. Data Android dalam AVD tetap tersimpan.

Buka terminal kedua di root project untuk memeriksa perangkat:

```bash
nix develop
adb devices
flutter devices
```

Setelah kode aplikasi tersedia, `flutter run` dapat dijalankan di terminal kedua.
Environment ini tidak mengubah hak akses perangkat atau mengaktifkan KVM di host.

## Memeriksa tooling

Perintah dapat dijalankan tanpa membuka shell interaktif:

```bash
nix flake check --no-build
nix develop --command flutter --version
nix develop --command dart --version
nix develop --command java -version
nix develop --command adb version
nix develop --command emulator -version
nix develop --command flutter doctor -v
```

`flutter doctor` juga dapat memeriksa target lain seperti Web/Linux desktop atau
Android Studio. Target pengembangan project ini adalah Android melalui CLI;
peringatan target lain perlu dibedakan dari masalah Android toolchain. Build APK,
analisis aplikasi, dan pengujian widget dilakukan setelah kode aplikasi tersedia.

## State lokal dan pembaruan

Selalu masuk dari root project. Shell mengarahkan state berikut ke `.dev/`, yang
diabaikan Git:

- `cache/` dan `config/`: cache serta konfigurasi tooling berbasis XDG.
- `pub-cache/` dan `gradle/`: cache paket Dart dan Gradle.
- `android/avd/`: definisi dan disk AVD; state Android lain ada di `android/`.

SDK dan JDK tetap berasal dari Nix store. `ANDROID_HOME`, `ANDROID_SDK_ROOT`,
`ANDROID_NDK_ROOT`, `JAVA_HOME`, dan override `aapt2` disediakan shell. File
`android/local.properties` yang nantinya dibuat Flutter bersifat lokal dan
diabaikan Git karena memuat path SDK mesin tersebut.

Untuk memperbarui dependensi secara sengaja:

```bash
nix flake update nixpkgs
```

Tinjau perubahan versi Flutter, Dart, dan Android; sesuaikan deklarasi SDK serta
tabel versi di `nix.md`, kemudian ulangi pemeriksaan tooling. Commit `flake.nix`
dan `flake.lock` bersama kode project. Sebelum memakai flake dari repositori Git,
pastikan `flake.nix`, `flake.lock`, dan script launcher sudah ditambahkan ke Git.

Untuk folder yang belum menjadi repositori Git, gunakan `git init`, lalu
`git add .gitignore flake.nix flake.lock scripts nix.md README.md P03_Flutter-Mini-App.md`
sebelum pemakaian rutin. Dalam repositori Git, Nix mengambil file yang dilacak;
tanpa Git, sumber flake berbasis path dapat ikut menyalin `.dev/` beserta disk
emulator yang besar ke Nix store. Environment tetap dapat dijalankan tanpa Git.

## Status verifikasi

Diperiksa pada 18 Oktober 2026:

- Evaluasi `nix flake check --no-build` berhasil.
- Perintah `nix develop --command ...` dari root project berhasil menyediakan
  Flutter 3.47.4, Dart 3.13.3, OpenJDK 21.0.12.1, adb 37.0.1, dan emulator 37.1.11.
- `flutter doctor -v` menyatakan Flutter dan Android toolchain siap, dengan seluruh
  lisensi Android diterima. Pemeriksaan Chrome/Web dan toolchain Linux desktop
  masih memberi peringatan karena keduanya tidak disediakan dalam shell Android.
- `aapt2` berhasil dijalankan; NDK dan host engine untuk pengujian Flutter tersedia.
- AVD berhasil dibuat di `.dev/android/avd/`. Dengan KVM dan GPU software,
  emulator headless berhasil boot Android 16 sampai `sys.boot_completed=1` dan
  terdeteksi oleh `flutter devices`.
- Mode CPU/GPU software tetap berjalan selama pemeriksaan startup 20 detik.
  Boot penuh pada mode software dan interaksi GUI belum diverifikasi.
- Proses emulator pengujian telah dihentikan; AVD lokal tetap tersedia.

Bug konfigurasi yang ditemukan: `flutter doctor` awalnya melaporkan lisensi belum
lengkap meskipun `android_sdk.accept_license` aktif. Pemeriksaan `sdkmanager
--licenses` dengan menolak setiap prompt menunjukkan bahwa CLI juga memeriksa
lisensi katalog untuk paket yang tidak dipasang. Daftar tersebut kemudian
dideklarasikan melalui `extraLicenses` pada komposisi SDK, dan pemeriksaan ulang
Android toolchain berhasil. Tidak ada penerimaan manual yang menulis ke SDK.

Belum ada kode aplikasi StudyFlow, build APK aplikasi, atau pengujian widget.

## Referensi

- [NixOS & Flakes Book — development environments](https://nixos-and-flakes.thiscute.world/development/intro)
- [Nixpkgs — Android SDK dan emulator](https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/android.section.md)
- [Default Android Flutter 3.47.4](https://github.com/flutter/flutter/blob/3.47.4/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt)
