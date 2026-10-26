# P03 — Flutter Mini App

**Minggu**: P03 · **Bobot**: 7,5% · **Sub-CPMK**: 53.1 · **Estimasi**: 3 × 50 menit · **Individual**

## Target

Aplikasi Flutter tiga layar yang berjalan di emulator atau perangkat, dengan navigasi dan state yang berubah karena perbuatan pengguna. Data cukup hidup di memori; hilang saat aplikasi ditutup tidak apa-apa.

**Boleh memakai model domain dari P02**, dan sangat disarankan. Boleh pula menjadikan aplikasi ini cikal bakal capstone Anda — kalau domainnya sudah cocok, pekerjaan P03 tidak terbuang.

## Yang Harus Ada

- **Tiga layar** dengan navigasi maju-mundur yang berfungsi dua arah
- **Satu daftar** yang isinya berasal dari data, bukan widget yang diketik satu per satu
- **Satu `StatefulWidget`** yang benar-benar butuh state, dengan `setState` yang mengubah tampilan
- **Satu form** dengan minimal dua jenis masukan dan validasi yang menolak masukan kosong
- **Satu widget buatan sendiri** yang dipakai lebih dari sekali dengan data berbeda

`flutter analyze` harus bersih.

## Yang Diserahkan

- Repo dengan tag `p03`
- `README.md` setengah halaman: apa aplikasinya, dan **satu bug yang sempat membuat Anda mentok beserta cara Anda menemukannya**
- Video 3 menit (YouTube unlisted): aplikasi dijalankan, ketiga layar dikunjungi, form diisi salah lalu diisi benar

Butir bug di README bukan hiasan. Kemampuan menceritakan proses debug adalah salah satu hal yang paling membedakan orang yang mengerti kodenya dan yang tidak.

## Rubrik

| Dimensi | Bobot | Memenuhi berarti |
|---|---|---|
| Fungsionalitas | 35% | lima butir di atas ada dan berjalan, tidak crash pada pemakaian wajar |
| Struktur | 25% | widget dipecah wajar, data tidak dicampur ke dalam widget, berkas tidak menumpuk di `main.dart` |
| Pemahaman state | 25% | `setState` dipakai di tempat yang benar; tidak ada state yang diletakkan terlalu tinggi atau terlalu rendah |
| Penjelasan | 15% | README dan video menunjukkan penulisnya memahami kodenya |

## Materi Pendukung

Bab 3 (widget, layout, navigasi), bab 4 (struktur proyek), bab 6 bagian form.
