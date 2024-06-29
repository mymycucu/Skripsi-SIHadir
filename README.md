# Skripsi-SIHadir
Repository ini merupakan dokumentasi dari Skripsi **"Automatic Student Attendance Recording and Monitoring System based-on iBeacon"**.  
- Disusun oleh: Muhammad Hilmy Noerfatih - 2006597512 
- Dibimbing oleh: Made Harta Dwijaksara, S.T., M.Sc., Ph.D.

## Penjelasan Apps dan Document
Terdapat berapa Apps dan Document yang berada pada repository ini. berikut ini merupakan penjelasan untuk masing-masing apps dan document:
- **SiHadir** : Aplikasi yang menjadi hasil implementasi sistem dimana aplikasi ini yang akan di install oleh mahasiswa
- **SiHadirDataGethering** : Aplikasi ini digunakan oleh developer dalam pengembangan sistem. aplikasi ini berguna untuk mendapatkan data kalibrasi dan juga pole yang kemudian akan dibuat kedalam model.
- **RawData** : File ini berisi data yang telah dikumpulkan untuk dapat menghasilkan dan mengimplementasikan sistem.

## Cara Penggunaan

### SiHadir
1. Melakukan konfigurasi Database Attendance
2. Melakukan iBeacon placement didalam kelas
3. Melakukan import semua model dari masing masing kelas
4. Melakukan installasi kedalam perangkat iOS
5. Menjalankan Aplikasi sesuai dengan kelasnya

### SiHadirDataGethering
1. Melakukan konfigurasi Database Calibration dan juga placement_pattern
2. Melakukan Kalibrasi terhadap iBeacon yang digunakan dengan cara meletakan iBeacon pada LOS dengan Device pada beberapa jarak tertentu
3. Melakukan Peletakan iBeacon sesuai dengan tempatnya didalam kelas
4. Melakukan recording pada setiap pola yang diharapkan
5. Melakukan save dan post data ke database
6. Mengulagi pola yang sama beberapa kali untuk mendapatkan gambaran pola secara keseluruhan
