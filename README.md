# Smart Presence - Absen Cerdas dengan Fitur AI

Aplikasi absensi cerdas berbasis Flutter dengan fitur pengenalan wajah menggunakan AI.

## Fitur Utama

### 1. Pengalaman Pengguna (UX) & Autentikasi
- Login/logout dengan sistem keamanan JWT
- Navigasi berbasis peran (siswa/guru)
- Antarmuka responsif untuk berbagai ukuran layar
- Penyimpanan token yang aman menggunakan flutter_secure_storage

### 2. Modul Kamera & AI Interaktif
- Pengambilan gambar menggunakan kamera perangkat
- Deteksi wajah real-time dengan Google ML Kit
- Pengenalan wajah untuk verifikasi identitas
- Kompresi gambar sebelum pengiriman ke server

### 3. Fungsionalitas Absensi Mobile
- Check-in/check-out dengan verifikasi lokasi
- Pencatatan ketidakhadiran oleh guru
- Penyimpanan lokal untuk absensi offline
- Sinkronisasi otomatis ketika koneksi tersedia

### 4. Dasbor & Pemantauan Guru
- Tampilan statistik kehadiran kelas
- Daftar aktivitas terbaru siswa
- Visualisasi data dengan chart
- Pengelolaan status kehadiran siswa

### 5. Pengaturan Lokal & Notifikasi
- Penyimpanan data lokal dengan Hive
- Notifikasi lokal untuk pengingat absensi
- Pengaturan preferensi pengguna
- Enkripsi data sensitif

## Teknologi yang Digunakan

- **Framework**: Flutter
- **State Management**: Riverpod
- **Data Serialization**: Freezed & JSON Serializable
- **Networking**: Dio
- **Storage**: Hive, Shared Preferences, Flutter Secure Storage
- **Camera**: Camera package
- **AI/ML**: Google ML Kit (Face Detection)
- **Location**: Geolocator
- **UI Components**: Flutter Material Design
- **Charts**: FL Chart
- **Image Processing**: Flutter Image Compress

## Struktur Direktori

```
lib/
├── app.dart                 # Entry point aplikasi
├── data/
│   ├── models/              # Data models (User, Attendance, etc.)
│   ├── repositories/        # Repository interfaces and implementations
│   └── providers/           # API clients and data providers
├── presentation/
│   ├── controllers/         # Riverpod controllers
│   ├── screens/             # UI screens
│   └── widgets/             # Reusable widgets
└── utils/                   # Utility functions and helpers
```

## Instalasi

1. Clone repository ini
2. Jalankan `flutter pub get`
3. Jalankan `flutter pub run build_runner build --delete-conflicting-outputs`
4. Jalankan aplikasi dengan `flutter run`

## Kontribusi

1. Fork repository ini
2. Buat branch fitur baru (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan Anda (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buka Pull Request

## Lisensi

Distributed under the MIT License. See `LICENSE` for more information.

## Kontak

Tim Pengembang - [@smartpresence](https://twitter.com/smartpresence)

Project Link: [https://github.com/yourusername/smartone](https://github.com/yourusername/smartone)