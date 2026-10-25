# ORBIT — Product Requirements Document

**Nama produk:** ORBIT (working title)
**Versi:** 1.1
**Status:** Expanded draft untuk review teknis
**Tanggal rilis dokumen:** 25 Oktober 2026
**Platform MVP:** Web responsif
**Model pengembangan:** Solo developer dengan AI coding assistant
**Metode:** PRD lengkap, diturunkan dari Mini PRD v1.0 (24 Oktober 2026)

---

## Document Control

| Versi | Tanggal | Perubahan | Penulis |
|---|---|---|---|
| 1.0 | 24 Oktober 2026 | Draft awal — Mini PRD 6 bagian (ringkasan, user story, FR, NFR, out of scope, roadmap) | Solo developer |
| 1.1 | 25 Oktober 2026 | Dikembangkan menjadi PRD lengkap: menambah Document Control, Executive Summary, Problem Statement, Anti-Persona, User Journey, Acceptance Criteria per modul, Information Architecture, Risk Register, timeline harian, dan Glossary. Isi FR, NFR, Out of Scope, Roadmap, dan Traceability dari v1.0 dipertahankan tanpa perubahan substansi. | Solo developer + AI coding assistant |

**Reviewer yang dituju:** Pembimbing magang / tech lead, dan solo developer sendiri sebagai self-review sebelum implementasi.

**Status persetujuan:** Menunggu review. Dokumen ini adalah living document — pembaruan berikutnya harus menambah baris baru di tabel di atas, bukan menimpa riwayat.

---

## Daftar Isi

1. [Executive Summary](#1-executive-summary)
2. [Problem Statement](#2-problem-statement)
3. [Visi & Tujuan Produk](#3-visi--tujuan-produk)
4. [User Persona](#4-user-persona)
5. [User Journey](#5-user-journey)
6. [User Stories & Kriteria Penerimaan](#6-user-stories--kriteria-penerimaan)
7. [Functional Requirements](#7-functional-requirements)
8. [Information Architecture](#8-information-architecture)
9. [Non-Functional Requirements](#9-non-functional-requirements)
10. [Out of Scope & Dependensi](#10-out-of-scope--dependensi)
11. [Risk Register](#11-risk-register)
12. [Roadmap, Timeline & Keputusan](#12-roadmap-timeline--keputusan)
13. [Glossary](#13-glossary)
14. [Lampiran: Traceability](#14-lampiran-traceability)
15. [Pertanyaan Terbuka & Next Steps](#15-pertanyaan-terbuka--next-steps)

---

## 1. Executive Summary

ORBIT adalah aplikasi produktivitas pribadi untuk freelancer, kreator, dan solo founder yang mengelola pekerjaan sendirian tanpa tim atau asisten. Produk ini menjawab satu masalah inti: pekerjaan yang tersebar di banyak tempat (chat klien, catatan, spreadsheet, kepala sendiri) membuat pengguna sulit menjawab pertanyaan sederhana — *"apa yang paling penting saya kerjakan sekarang?"*

ORBIT menjawabnya lewat lima pilar:

1. **Task & Project Management** — satu tempat untuk mencatat tugas dan mengelompokkannya per proyek/klien.
2. **Daily Focus** — rekomendasi maksimal tiga tugas per hari, lengkap dengan alasan yang bisa diperiksa (bukan kotak hitam).
3. **AI Task Breakdown (opsional)** — memecah tujuan besar menjadi draft tugas, yang hanya tersimpan setelah disetujui pengguna.
4. **BYOK (Bring Your Own Key)** — pengguna memakai API key OpenAI miliknya sendiri; key dienkripsi dan tidak pernah ditampilkan kembali.
5. **AI opsional secara struktural** — seluruh alur inti (task, project, Daily Focus) berfungsi 100% tanpa konfigurasi AI apa pun.

**Keputusan arsitektur paling penting:** todo list tidak dibuat sebagai entitas terpisah dari task. Inbox adalah status, bukan tabel baru. Ini mencegah duplikasi data dan memastikan Daily Focus selalu melihat seluruh pekerjaan pengguna, bukan sebagian.

**Lingkup MVP:** dikerjakan dalam 5 hari oleh satu developer dibantu AI coding assistant, mencakup FR-01 sampai FR-20. Hierarki task (subtask), dependency antar task, dan AI Task Decomposer (task → subtask) sengaja ditunda ke P1 agar model data dan UI MVP tetap sederhana dan bisa diselesaikan tepat waktu.

**Siapa yang perlu membaca dokumen ini:** solo developer (sebagai spesifikasi implementasi), pembimbing/reviewer (sebagai dasar evaluasi), dan versi masa depan dari developer yang sama saat memutuskan apakah suatu fitur P1/P2 sudah waktunya dikerjakan.

---

## 2. Problem Statement

### 2.1 Masalah yang divalidasi lewat persona

Freelancer dan solo founder menjalankan peran yang biasanya dipegang oleh tim: pengerjaan, administrasi, pemasaran, dan perencanaan — sendirian. Tiga simtom yang muncul berulang di kedua persona (lihat [Bagian 4](#4-user-persona)):

- **Prioritas tidak terlihat.** Permintaan yang paling berisik (chat klien yang baru masuk) menang melawan pekerjaan yang paling penting (deliverable besar, portofolio, mencari klien baru). Tidak ada mekanisme yang memaksa pengguna berhenti dan bertanya "apa yang sebenarnya paling penting hari ini?"
- **Pekerjaan tersebar di banyak permukaan.** Tugas hidup di chat, catatan, dan spreadsheet yang tidak saling bicara. Setiap kali berpindah alat, ada risiko kehilangan konteks atau item yang terlupa.
- **Tujuan besar terasa abstrak sampai tidak dikerjakan.** "Luncurkan fitur baru" atau "revisi deliverable klien X" adalah pernyataan niat, bukan langkah kerja. Tanpa pemecahan menjadi langkah kecil, tujuan besar cenderung ditunda karena tidak jelas harus mulai dari mana.

### 2.2 Mengapa solusi yang ada belum cukup

- **To-do list generik** (misalnya catatan atau papan kanban sederhana) mencatat tugas tapi tidak menjawab "mana yang paling penting hari ini" — pengguna tetap harus memutuskan sendiri setiap pagi.
- **Tool manajemen proyek tim** (Asana, Trello, Linear, dkk.) dirancang untuk koordinasi antar-orang; fitur seperti assignee, komentar, dan notifikasi tim menjadi beban kognitif yang tidak relevan untuk pengguna solo.
- **Asisten AI generik** (ChatGPT, dkk.) bisa membantu memecah tujuan dalam percakapan, tetapi hasilnya tidak terhubung ke sistem pencatatan tugas pengguna — pengguna harus menyalin manual, dan tidak ada riwayat yang terstruktur.
- **Produk AI "agentic"** yang mengeksekusi tindakan otomatis berisiko menghapus kendali pengguna atas data dan biaya — sesuatu yang eksplisit dihindari ORBIT lewat prinsip *human-in-control* dan BYOK.

### 2.3 Pernyataan masalah

> Freelancer, kreator, dan solo founder yang mengelola pekerjaan sendirian kesulitan menentukan dan mempertahankan fokus harian karena tugas tersebar di banyak alat dan tujuan besar terasa terlalu abstrak untuk langsung dikerjakan, sementara alat yang ada dirancang untuk tim atau tidak terhubung dengan sistem pencatatan tugas mereka.

### 2.4 Mengapa sekarang, dan mengapa dengan AI opsional

Model bahasa sudah cukup andal untuk membantu tugas penataan teks terstruktur (memecah tujuan menjadi langkah) tanpa perlu dipercaya untuk mengeksekusi tindakan. Pola **BYOK + draft yang butuh approval** memungkinkan ORBIT menawarkan manfaat AI tanpa menanggung biaya inferensi (model bisnis belum perlu divalidasi di MVP) dan tanpa memaksa pengguna mempercayakan data ke penyedia pilihan ORBIT. Prinsip ini juga membuat produk tetap berguna dan dapat dijual nilainya bahkan untuk pengguna yang skeptis terhadap AI.

---

## 3. Visi & Tujuan Produk

### Visi Produk

ORBIT adalah ruang kerja pribadi yang membantu freelancer, kreator, dan solo founder mengubah pekerjaan yang berantakan menjadi langkah nyata. Alih-alih menambah daftar tugas, ORBIT membantu pengguna menentukan apa yang paling penting hari ini, memahami alasan di baliknya, dan mulai mengerjakan — dengan AI yang dapat dikendalikan dan tetap opsional.

### North Star Metric

**Jumlah tugas yang diselesaikan dari rekomendasi Daily Focus per pengguna aktif per minggu.** Metrik ini dipilih karena menggabungkan dua sinyal sekaligus: pengguna percaya pada rekomendasi (mau mengikutinya) dan rekomendasi itu benar (tugasnya memang bisa diselesaikan). Metrik lain di bawah ini adalah pendukung (leading indicators) terhadap North Star Metric ini.

### Tujuan Utama

1. **Menyatukan pekerjaan pribadi** — pengguna dapat membuat proyek, tugas, tenggat, dan status dalam satu tempat. Indikator: tugas pertama dapat dibuat dalam waktu kurang dari 2 menit setelah onboarding.
2. **Menentukan fokus harian** — Daily Focus menampilkan maksimal tiga rekomendasi beserta alasannya. Indikator: pengguna menyelesaikan minimal satu tugas dari Daily Focus per sesi aktif.
3. **Memecah tujuan besar** — AI Task Breakdown menghasilkan draft yang dapat diedit dan disetujui. Indikator: minimal 70% draft disetujui atau diedit lalu disimpan sebagai tugas.
4. **Memberi kendali penuh atas AI** — pengguna menghubungkan API key sendiri melalui BYOK. Indikator: pengguna berhasil menghubungkan, menguji, dan menghapus key tanpa bantuan.
5. **Tetap berguna tanpa AI** — seluruh alur inti berjalan saat AI nonaktif. Indikator: 100% alur task, project, dan Daily Focus berfungsi tanpa konfigurasi AI.

### Value Proposition

- **Fokus yang bisa dijelaskan** — setiap rekomendasi disertai alasan yang dapat diperiksa, bukan kotak hitam.
- **AI yang berhenti di draft** — hasil AI tidak pernah mengubah data penting tanpa persetujuan pengguna.
- **BYOK** — pengguna memakai key dan kuota AI miliknya sendiri; key tidak pernah ditampilkan kembali atau disimpan sebagai teks biasa.
- **AI opsional** — fitur inti tidak bergantung pada penyedia AI mana pun.

### Prinsip Desain Produk

Keempat prinsip ini mengikat setiap keputusan fitur di dokumen ini, dan menjadi alat uji saat menilai fitur baru di P1/P2:

| Prinsip | Arti praktis |
|---|---|
| **Human-in-control** | AI tidak pernah menulis ke database tanpa langkah approval eksplisit dari pengguna. |
| **Explainable by default** | Setiap rekomendasi otomatis (Daily Focus) harus bisa menunjukkan faktor penyebabnya dalam bahasa yang dipahami pengguna. |
| **AI opsional, bukan inti** | Menghapus konfigurasi AI tidak boleh mendegradasi fitur inti manapun. |
| **Kesederhanaan data di atas kelengkapan model** | Saat ragu antara model data yang lebih lengkap tapi kompleks vs. yang lebih sederhana, MVP memilih sederhana dan menunda kelengkapan ke P1/P2 (lihat [Keputusan Produk](#124-keputusan-produk)). |

---

## 4. User Persona

### Persona 1: Rina — Freelancer Multi-Klien

- **Usia/Pekerjaan:** 28 tahun, freelance web designer dengan 3–5 klien aktif.
- **Level Teknis:** Menengah. Nyaman memakai SaaS, tetapi tidak ingin mengelola tool yang rumit.
- **Tujuan:** Menyelesaikan deliverable klien tepat waktu tanpa mengorbankan pekerjaan penting seperti portofolio, administrasi, dan mencari klien baru.
- **Pain Points:**
  - Permintaan mendesak klien menenggelamkan pekerjaan yang lebih strategis.
  - Tugas tersebar di chat, catatan, dan spreadsheet.
  - Deliverable besar sulit dipecah menjadi langkah yang bisa langsung dikerjakan.
  - Rencana harian berantakan begitu satu revisi masuk.
- **Motivasi:** Ingin satu tempat yang menunjukkan prioritas hari ini beserta alasannya, dan mampu memecah deliverable menjadi langkah kecil tanpa harus menyusun ulang semuanya secara manual.
- **Fitur yang paling bernilai baginya:** Daily Focus (menyaring kebisingan klien) dan Project Management (mengelompokkan per klien).

### Persona 2: Adit — Solo Founder dan Kreator

- **Usia/Pekerjaan:** 32 tahun, solo founder produk digital yang juga membuat konten.
- **Level Teknis:** Mahir. Sudah memiliki API key OpenAI dan memahami biaya inference.
- **Tujuan:** Meluncurkan serta mengembangkan produk sambil mengelola pengembangan, pemasaran, dan operasional sendirian.
- **Pain Points:**
  - Terlalu banyak ide dan prioritas yang saling bersaing.
  - Sering berpindah konteks dan kehilangan momentum.
  - Tidak ada tim yang membantu mengorganisasi pekerjaan.
  - Rencana cepat usang ketika ada tugas yang tertunda.
- **Motivasi:** Ingin AI yang membantu memecah tujuan dan menyusun fokus, tetapi tetap memegang kendali atas model, biaya, dan data melalui BYOK.
- **Fitur yang paling bernilai baginya:** AI Task Breakdown (mengubah ide abstrak menjadi langkah) dan BYOK (kendali biaya dan data).

Catatan: persona kreator individual tercakup dalam Persona 2. MVP memprioritaskan dua profil ini agar scope tetap terkendali.

### Anti-Persona (siapa yang *belum* dilayani MVP)

Mendefinisikan siapa yang tidak dilayani sama pentingnya dengan mendefinisikan persona, agar permintaan fitur di luar scope bisa ditolak dengan alasan yang jelas:

- **Tim dan organisasi** — siapa pun yang butuh assignee, komentar, atau visibilitas lintas anggota tim. ORBIT MVP adalah alat single-player; kolaborasi ada di P2 ([Bagian 10](#10-out-of-scope--dependensi)).
- **Pengguna yang butuh mobile native/offline-first** — pekerja lapangan tanpa koneksi internet stabil tidak terlayani baik di MVP (lihat [Asumsi](#104-asumsi) dan [NFR Kompatibilitas](#9-non-functional-requirements)).
- **Pengguna enterprise dengan kebutuhan kepatuhan** — data medis, keuangan, atau regulasi khusus eksplisit di luar asumsi desain ([Asumsi](#104-asumsi)).
- **Pengguna yang ingin AI mengeksekusi tindakan otomatis** (auto-scheduling, auto-reply, agen yang bertindak tanpa approval) — bertentangan dengan prinsip *human-in-control* dan tidak direncanakan di roadmap manapun.

---

## 5. User Journey

Journey ini menggambarkan alur ujung-ke-ujung memakai FR yang relevan, untuk memverifikasi bahwa requirement di [Bagian 7](#7-functional-requirements) benar-benar menyatu menjadi pengalaman yang koheren — bukan daftar fitur lepas.

### 5.1 Journey Rina: dari onboarding sampai menyelesaikan tugas klien pertama

| Langkah | Aksi pengguna | Sistem (FR terkait) | Yang dirasakan Rina |
|---|---|---|---|
| 1 | Daftar dengan email dan password | FR-01 | Masuk tanpa friksi, tidak perlu verifikasi email saat demo |
| 2 | Login pertama kali | FR-02 | Diarahkan langsung ke Daily Focus (kosong) |
| 3 | Buat proyek "Klien A — Redesign Website" | FR-09 | Punya tempat mengelompokkan semua tugas klien ini |
| 4 | Tambah 5 tugas cepat ke Inbox: "Revisi homepage", "Kirim invoice", dst. | FR-04 | Semua pekerjaan tercatat tanpa harus mengisi form panjang |
| 5 | Pindahkan sebagian tugas ke proyek dan isi tenggat/prioritas | FR-06 | Inbox mengosong, tugas penting punya konteks proyek |
| 6 | Buka Daily Focus | FR-11 | Melihat 3 tugas teratas + alasan ("tenggat besok", "prioritas tinggi") — bukan 5 tugas yang membingungkan |
| 7 | Tekan "Mulai" pada tugas pertama, lalu "Selesai" | FR-12 | Progres terasa nyata tanpa pindah halaman |
| 8 | Mengabaikan satu rekomendasi karena klien baru kirim revisi mendesak di luar ORBIT | FR-13 | Fokus tetap fleksibel, tugas tidak hilang — hanya disembunyikan hari ini |
| 9 | Esok harinya, tugas yang diabaikan muncul lagi otomatis | FR-13 (reset harian) | Tidak perlu mengingat untuk membuka kembali tugas yang tertunda |

### 5.2 Journey Adit: dari ide besar sampai draft tugas tersimpan

| Langkah | Aksi pengguna | Sistem (FR terkait) | Yang dirasakan Adit |
|---|---|---|---|
| 1 | Buka Settings → AI, masukkan provider `openai`, model, dan API key miliknya | FR-16 | Key disimpan terenkripsi; tidak pernah melihatnya lagi setelah submit |
| 2 | Tekan "Test Connection" | FR-17 | Tahu dalam hitungan detik apakah key valid, tanpa menebak-nebak |
| 3 | Buka AI Task Breakdown, tulis "Luncurkan fitur onboarding baru bulan ini" | FR-14 | AI mengusulkan 8 langkah kerja konkret dalam <30 detik |
| 4 | Edit dua langkah yang kurang relevan, hapus satu, ubah estimasi | FR-14 (draft sebelum simpan) | Tetap merasa memegang kendali — AI hanya mengusulkan |
| 5 | Tekan "Simpan sebagai tugas" | FR-15 | 7 tugas baru muncul di proyek terkait, status `inbox`, siap diprioritaskan |
| 6 | Esok harinya cek Daily Focus | FR-11 | Tiga dari tujuh tugas tersebut sudah masuk rekomendasi berdasarkan tenggat yang ia set |

### 5.3 Journey kegagalan yang disengaja diuji (negative path)

Bagian ini memastikan tim QA/self-test memvalidasi bukan hanya jalur sukses:

- **AI mati/limit tercapai di tengah hari kerja** → task/project/Daily Focus tetap berfungsi penuh (FR-11 "tidak memakai AI"; NFR Reliabilitas "gangguan OpenAI tidak menghentikan pengelolaan tugas").
- **Key BYOK salah dimasukkan** → Test Connection mengembalikan status `invalid` dengan pesan aman, key tidak terhapus otomatis (FR-17).
- **Pengguna menghapus proyek yang masih berisi tugas aktif** → tugas tidak ikut terhapus, hanya kehilangan tautan proyek (FR-10).
- **Draft AI Breakdown gagal tersimpan di tengah proses** (koneksi putus) → input pengguna (tujuan yang ditulis) tidak hilang, bisa dicoba ulang (FR-14 "error tidak menghapus input pengguna").

---

## 6. User Stories & Kriteria Penerimaan

User story mengikuti format `Sebagai [peran], saya ingin [aksi], agar [manfaat]`. Setiap story kritikal dilengkapi kriteria penerimaan Given-When-Then agar tidak ambigu saat diimplementasikan atau diuji.

### Modul 1: Autentikasi

1. Sebagai pengguna baru, saya ingin mendaftar dengan email dan password, agar dapat mulai menggunakan ORBIT.
2. Sebagai pengguna terdaftar, saya ingin login, agar dapat mengakses tugas dan proyek milik saya.
3. Sebagai pengguna, saya ingin logout, agar data saya tetap aman saat perangkat dipakai bersama.

**Kriteria penerimaan — Registrasi (story 1, FR-01):**
- **Given** pengguna baru mengisi email valid dan password ≥8 karakter, **when** submit, **then** akun tercipta dan pengguna diarahkan ke Daily Focus/onboarding.
- **Given** email sudah terdaftar, **when** submit, **then** muncul pesan error generik tanpa membocorkan bahwa email tersebut sudah ada di sistem pihak lain.
- **Given** password kurang dari 8 karakter, **when** submit, **then** form menolak sebelum request terkirim ke server.

### Modul 2: Task Management

4. Sebagai pengguna, saya ingin menambahkan tugas ke Inbox dengan cepat, agar ide dan pekerjaan tidak hilang.
5. Sebagai pengguna, saya ingin mengedit atau menghapus detail tugas, agar daftar tetap akurat dan relevan.
6. Sebagai pengguna, saya ingin mengubah status tugas dari Inbox hingga Done, agar progres pekerjaan terlihat.

**Kriteria penerimaan — Quick add (story 4, FR-04):**
- **Given** pengguna mengisi hanya judul tugas, **when** submit, **then** tugas tersimpan dengan status `inbox` dan prioritas default `medium`, tanpa field lain wajib diisi.
- **Given** judul kosong, **when** submit, **then** tugas ditolak dengan pesan validasi yang jelas.

**Kriteria penerimaan — Ubah status (story 6, FR-08):**
- **Given** tugas berstatus `in_progress`, **when** pengguna memilih `done`, **then** `completed_at` terisi dan Daily Focus dihitung ulang pada permintaan berikutnya.
- **Given** tugas berstatus `done`, **when** pengguna mengubah ke status lain, **then** `completed_at` dikosongkan kembali.

### Modul 3: Project Management

7. Sebagai freelancer, saya ingin membuat proyek dan menautkan tugas ke dalamnya, agar pekerjaan per klien terkelompok.
8. Sebagai pengguna, saya ingin menghapus proyek tanpa menghapus tugas di dalamnya, agar tidak kehilangan pekerjaan secara tidak sengaja.

**Kriteria penerimaan — Hapus proyek (story 8, FR-10):**
- **Given** proyek memiliki 5 tugas aktif, **when** pengguna menghapus proyek dan mengonfirmasi, **then** proyek hilang dari daftar dan kelima tugas tetap ada dengan `project_id = null`.
- **Given** dialog konfirmasi hapus proyek, **when** ditampilkan, **then** teksnya secara eksplisit menyatakan tugas tidak akan ikut terhapus.

### Modul 4: Daily Focus

9. Sebagai pengguna, saya ingin melihat maksimal tiga prioritas hari ini beserta alasannya, agar saya tahu harus mulai dari mana.
10. Sebagai pengguna, saya ingin memulai dan menyelesaikan tugas langsung dari Daily Focus, agar saya bisa bergerak tanpa berpindah halaman.
11. Sebagai pengguna, saya ingin mengabaikan rekomendasi hari ini, agar fokus dapat disesuaikan tanpa menghapus tugas.

**Kriteria penerimaan — Rekomendasi (story 9, FR-11):**
- **Given** pengguna memiliki lebih dari tiga tugas aktif dengan tenggat berbeda, **when** Daily Focus dimuat, **then** maksimal tiga tugas ditampilkan, diurutkan oleh skor deterministik, masing-masing dengan alasan berbasis faktor dominan (contoh: "tenggat 1 hari lagi").
- **Given** pengguna tidak memiliki tugas aktif, **when** Daily Focus dimuat, **then** tampil empty state yang mengarahkan ke pembuatan tugas pertama, bukan halaman kosong tanpa penjelasan.

**Kriteria penerimaan — Dismiss (story 11, FR-13):**
- **Given** tugas diabaikan hari ini, **when** pengguna membuka Daily Focus lagi di hari yang sama, **then** tugas tersebut tidak muncul, tetapi muncul kembali keesokan harinya di timezone profil pengguna.

### Modul 5: AI Task Breakdown

12. Sebagai pengguna, saya ingin memasukkan tujuan besar dalam bahasa alami, agar AI mengusulkan langkah-langkah yang lebih kecil.
13. Sebagai pengguna, saya ingin meninjau, mengedit, dan menyetujui draft hasil AI, agar tugas hanya tersimpan setelah saya setuju.

**Kriteria penerimaan — Generate & approve (story 12–13, FR-14/FR-15):**
- **Given** pengguna dengan BYOK terverifikasi menulis tujuan 50 karakter, **when** submit generate, **then** draft maksimal 15 langkah muncul dalam <30 detik, belum tersimpan ke database manapun.
- **Given** draft ditampilkan, **when** pengguna mengedit satu judul langkah dan menghapus satu langkah lain lalu menekan simpan, **then** hanya versi yang telah diedit yang tersimpan sebagai tugas baru.
- **Given** rate limit 10 permintaan/jam sudah tercapai, **when** pengguna mencoba generate lagi, **then** muncul pesan limit yang jelas, input tujuan yang sudah ditulis tidak hilang.

### Modul 6: BYOK dan Pengaturan AI

14. Sebagai pengguna dengan API key sendiri, saya ingin menyimpan provider, model, dan key lalu menguji koneksinya, agar saya tahu konfigurasi AI berfungsi tanpa key ditampilkan kembali.
15. Sebagai pengguna, saya ingin menghapus konfigurasi AI, agar key saya tidak lagi tersimpan di ORBIT.

**Kriteria penerimaan — Test connection (story 14, FR-17):**
- **Given** key valid dan memiliki kuota, **when** Test Connection dijalankan, **then** status berubah menjadi `verified` dalam <10 detik.
- **Given** key tidak valid, **when** Test Connection dijalankan, **then** status menjadi `invalid` dengan pesan yang membedakan kegagalan autentikasi dari gangguan layanan, tanpa menampilkan key apa pun.

**Kriteria penerimaan — Hapus konfigurasi (story 15, FR-18):**
- **Given** konfigurasi AI tersimpan, **when** pengguna menghapus dan mengonfirmasi, **then** baris `ai_connections` hilang, fitur AI nonaktif, dan seluruh task/project tetap berfungsi normal.

Catatan: user story untuk fitur P1 (subtask, dependency, dan dekomposisi task) akan ditambahkan saat fase P1 dimulai, memakai format dan tingkat kedetailan kriteria penerimaan yang sama seperti di atas.

---

## 7. Functional Requirements

**Prioritas:** FR-01 sampai FR-20 adalah MVP. FR-21 sampai FR-23 adalah P1 dan tidak termasuk MVP 5 hari.

### Modul 1: Autentikasi

**FR-01: Registrasi Pengguna**
- **Input:** Email dan password.
- **Proses:** Validasi format email dan kekuatan password, cek duplikasi, buat akun melalui Supabase Auth, buat profil dengan timezone default `Asia/Jakarta`.
- **Output:** Akun terdaftar dan pengguna diarahkan ke onboarding atau Daily Focus.
- **Aturan Bisnis:** Email unik dan valid; password minimal 8 karakter; verifikasi email mengikuti konfigurasi lingkungan (wajib di produksi, dapat dinonaktifkan untuk demo); pesan error jelas tanpa membocorkan detail internal.

**FR-02: Login Pengguna**
- **Input:** Email dan password.
- **Proses:** Verifikasi kredensial melalui Supabase Auth, buat sesi berbasis cookie `httpOnly`.
- **Output:** Sesi aktif dan redirect ke Daily Focus.
- **Aturan Bisnis:** Pesan gagal bersifat generik; rate limit mengikuti Supabase Auth; password tidak pernah disimpan atau dicatat aplikasi; cookie `SameSite=Lax`.

**FR-03: Logout**
- **Input:** Aksi logout.
- **Proses:** Hapus sesi dan cookie autentikasi.
- **Output:** Redirect ke halaman login.
- **Aturan Bisnis:** Data tetap tersimpan; logout hanya berlaku untuk perangkat tersebut; sesi lain tidak terpengaruh.

### Modul 2: Task Management

**FR-04: Membuat Tugas**
- **Input:** Judul wajib; deskripsi, proyek, prioritas, tenggat, dan estimasi opsional.
- **Proses:** Validasi input, ambil `user_id` dari sesi, set status `inbox`, simpan ke database.
- **Output:** Tugas muncul di Inbox dan daftar terkait.
- **Aturan Bisnis:** Judul 1–200 karakter; deskripsi maksimal 2.000 karakter; prioritas default `medium`; estimasi 5–480 menit; `user_id` tidak boleh berasal dari client; proyek harus milik pengguna.

**FR-05: Melihat Daftar Tugas**
- **Input:** Konteks tampilan: Inbox, All Tasks, atau detail proyek.
- **Proses:** Query dengan Row Level Security, urutkan berdasarkan status, tenggat, prioritas, lalu tanggal dibuat.
- **Output:** Daftar tugas dengan status, tenggat, prioritas, dan proyek.
- **Aturan Bisnis:** Hanya tugas milik pengguna; Inbox hanya menampilkan status `inbox`; detail proyek hanya menampilkan tugas proyek tersebut; tugas `done` tetap terlihat di All Tasks.

**FR-06: Mengedit Tugas**
- **Input:** ID tugas dan field yang diubah.
- **Proses:** Validasi kepemilikan, validasi field, update data, perbarui `updated_at`.
- **Output:** Perubahan tersimpan dan langsung terlihat.
- **Aturan Bisnis:** `user_id` tidak dapat diubah; proyek tujuan harus milik pengguna; status `done` wajib mengisi `completed_at`; keluar dari `done` mengosongkan `completed_at`.

**FR-07: Menghapus Tugas**
- **Input:** ID tugas dan konfirmasi.
- **Proses:** Validasi kepemilikan, hapus tugas beserta catatan dismissal terkait.
- **Output:** Tugas hilang dari seluruh tampilan.
- **Aturan Bisnis:** Konfirmasi eksplisit; penghapusan permanen; pengguna tidak dapat menghapus tugas milik pengguna lain.

**FR-08: Mengubah Status Tugas**
- **Input:** ID tugas dan status baru: `inbox`, `next`, `in_progress`, atau `done`.
- **Proses:** Validasi status, update, sinkronkan `completed_at`, hitung ulang progres proyek.
- **Output:** Status dan progres diperbarui.
- **Aturan Bisnis:** Hanya status yang valid; `done` hanya melalui aksi eksplisit; `completed_at` harus konsisten dengan status; rekomendasi Daily Focus dihitung ulang.

### Modul 3: Project Management

**FR-09: Membuat dan Melihat Proyek**
- **Input:** Nama wajib; deskripsi dan tenggat opsional.
- **Proses:** Validasi, simpan dengan `user_id` dari sesi dan status `active`.
- **Output:** Proyek muncul di daftar dengan progres awal 0%.
- **Aturan Bisnis:** Nama 1–120 karakter; tenggat opsional; progres dihitung dari jumlah tugas `done` dibagi total tugas; hanya proyek milik pengguna yang terlihat.

**FR-10: Menghapus Proyek**
- **Input:** ID proyek dan konfirmasi.
- **Proses:** Hapus proyek; tugas terkait dipertahankan dengan `project_id` menjadi `null`.
- **Output:** Proyek hilang; tugas tetap tersedia tanpa proyek.
- **Aturan Bisnis:** Konfirmasi menjelaskan bahwa tugas tidak ikut dihapus; hanya proyek milik pengguna; penghapusan tidak dapat dibatalkan.

### Modul 4: Daily Focus

**FR-11: Rekomendasi Fokus Harian**
- **Input:** Tugas aktif pengguna, tanggal lokal berdasarkan timezone profil, dan daftar dismissal hari ini.
- **Proses:** Hitung skor deterministik dari tenggat, prioritas manual, status, tenggat proyek, dan umur tugas; ambil maksimal tiga teratas; susun alasan dari faktor dominan.
- **Output:** Maksimal tiga kartu prioritas dengan alasan dan total estimasi beban kerja.
- **Aturan Bisnis:** Tugas `done` dan yang diabaikan hari ini tidak direkomendasikan; tie-break deterministik; tidak memakai AI; jika data minim, tampilkan keterbatasan rekomendasi; jika tidak ada tugas, tampilkan empty state. Pada P1, hanya leaf task yang direkomendasikan dan task yang diblokir tidak masuk tiga teratas.

**FR-12: Aksi Mulai dan Selesai dari Daily Focus**
- **Input:** ID tugas dan aksi `start` atau `done`.
- **Proses:** Ubah status menjadi `in_progress` atau `done`, isi `completed_at` bila selesai, hitung ulang fokus.
- **Output:** Status tugas berubah tanpa berpindah halaman.
- **Aturan Bisnis:** Aksi bersifat idempotent; `start` hanya untuk tugas aktif; `done` dapat dibatalkan melalui edit status. Pada P1, task yang masih diblokir tidak dapat dimulai sampai blocker selesai.

**FR-13: Mengabaikan Rekomendasi**
- **Input:** ID tugas dan tanggal lokal pengguna.
- **Proses:** Simpan catatan dismissal unik per pengguna, tugas, dan tanggal.
- **Output:** Tugas hilang dari Daily Focus hari itu; tersedia aksi undo.
- **Aturan Bisnis:** Tidak menghapus tugas; dismissal berlaku sampai pergantian hari di timezone pengguna; dapat dibatalkan sebelum hari berakhir.

### Modul 5: AI Task Breakdown

**FR-14: Generate Draft Breakdown**
- **Input:** Tujuan dalam bahasa alami (1–2.000 karakter) dan proyek opsional.
- **Proses:** Autentikasi, rate limit 10 permintaan per jam, ambil dan dekripsi API key, panggil OpenAI dengan structured output, validasi Zod, clamp jumlah dan panjang item.
- **Output:** Draft maksimal 15 langkah berisi judul, deskripsi, estimasi, dan urutan; belum disimpan.
- **Aturan Bisnis:** Key harus terverifikasi; timeout 30 detik; retry maksimal sekali untuk gangguan jaringan atau 5xx; error tidak menghapus input pengguna; output AI tidak dipercaya sebagai perintah database; hanya konteks yang relevan yang dikirim ke penyedia. MVP hanya mendukung mode **project → tasks**. Mode **task → subtasks** ada di FR-23 (P1).

**FR-15: Review dan Simpan Draft AI**
- **Input:** Draft yang sudah diedit pengguna dan proyek tujuan.
- **Proses:** Validasi ulang di server, cek kepemilikan proyek, simpan seluruh tugas dalam satu operasi atomik.
- **Output:** Tugas baru dengan status `inbox` dan prioritas `medium`.
- **Aturan Bisnis:** Penyimpanan hanya setelah persetujuan eksplisit; tidak mengubah atau menghapus tugas lama; maksimal 15 tugas; batas panjang field sama dengan FR-04; `user_id` berasal dari sesi.

### Modul 6: BYOK dan AI Studio

**FR-16: Menyimpan Konfigurasi BYOK**
- **Input:** Provider `openai`, model, dan API key.
- **Proses:** Validasi, enkripsi key dengan AES-256-GCM, simpan ciphertext dan versi key; key tidak pernah dikembalikan ke client.
- **Output:** Konfigurasi tersimpan dengan status awal `unverified`.
- **Aturan Bisnis:** Satu koneksi per provider per pengguna; key tidak disimpan di `localStorage`, log, analitik, atau pesan error; hanya modul server yang dapat membaca ciphertext; pengguna dapat mengganti model atau key.

**FR-17: Test Connection**
- **Input:** Aksi uji koneksi.
- **Proses:** Dekripsi key, panggil endpoint models penyedia, klasifikasikan hasil.
- **Output:** Status `verified` atau `invalid` beserta pesan aman.
- **Aturan Bisnis:** Rate limit per pengguna; key tidak ditampilkan; bedakan error autentikasi, kuota, rate limit, dan gangguan layanan bila informasi tersedia; kegagalan tidak menghapus konfigurasi.

**FR-18: Menghapus Konfigurasi AI**
- **Input:** Aksi hapus dan konfirmasi.
- **Proses:** Hapus baris koneksi AI milik pengguna.
- **Output:** Fitur AI nonaktif; pengelolaan tugas tetap berjalan.
- **Aturan Bisnis:** Key tidak dapat dipulihkan setelah dihapus; konfirmasi eksplisit; tugas dan proyek tidak terpengaruh.

### Modul 7: Pengaturan dan Privasi

**FR-19: Mengatur Timezone**
- **Input:** Timezone dalam format IANA.
- **Proses:** Validasi nilai, update profil pengguna.
- **Output:** Daily Focus dan tenggat memakai timezone tersebut.
- **Aturan Bisnis:** Default `Asia/Jakarta`; hanya timezone valid; perubahan berlaku setelah data dimuat ulang.

**FR-20: Menghapus Akun dan Data**
- **Input:** Konfirmasi eksplisit dari pengguna.
- **Proses:** Hapus akun melalui admin API, cascade ke profil, proyek, tugas, dismissal, koneksi AI, dan riwayat permintaan AI.
- **Output:** Akun dan seluruh data pengguna terhapus; sesi berakhir.
- **Aturan Bisnis:** Tidak dapat dibatalkan; konfirmasi wajib; API key ikut terhapus; pengguna diarahkan ke halaman login.

### Modul 8: P1 — Hierarki dan Relasi

**FR-21: Subtask (P1)**
- **Input:** ID parent task, judul, deskripsi, estimasi, dan status subtask.
- **Proses:** Validasi parent milik pengguna, kedalaman maksimal dua level, tidak ada siklus, simpan `parent_task_id`.
- **Output:** Subtask tampil di detail task; progres parent dihitung dari subtask.
- **Aturan Bisnis:** Parent yang memiliki subtask dianggap container dan tidak direkomendasikan Daily Focus; Daily Focus hanya merekomendasikan leaf task; penghapusan parent mempromosikan subtask menjadi task mandiri dengan konfirmasi; semua relasi harus berada dalam user yang sama.

**FR-22: Dependency Task (P1)**
- **Input:** ID task dan ID task yang memblokir (`blocked_by_task_id`).
- **Proses:** Validasi kepemilikan, tidak ada self-link, tidak ada siklus, simpan relasi dependency.
- **Output:** Detail task menampilkan daftar "Blocked by" dan "Blocks"; Daily Focus menampilkan task yang diblokir di bagian "Menunggu".
- **Aturan Bisnis:** Task yang diblokir tidak masuk tiga rekomendasi utama; task tetap dapat dibuka dan diedit; dependency dihapus bila blocker dihapus; dependency project ke project tidak termasuk.

**FR-23: AI Task Decomposer — Task ke Subtask (P1)**
- **Input:** ID task beserta judul dan deskripsinya.
- **Proses:** Autentikasi, rate limit, ambil dan dekripsi key, panggil OpenAI dengan structured output, validasi Zod, batasi maksimal 10–15 subtask dan kedalaman satu level.
- **Output:** Draft subtask yang belum disimpan.
- **Aturan Bisnis:** Penyimpanan hanya setelah persetujuan; tidak mengubah task lama; tidak rekursif; `parent_task_id` diisi saat simpan; validasi sama dengan FR-15; mode project → sub-project tidak termasuk.

### Model Data Konseptual

| Entitas | Field Kunci | Invariant |
|---|---|---|
| `profiles` | `id` (= `auth.users.id`), `timezone` | Cascade saat user dihapus |
| `projects` | `id`, `user_id`, `name`, `description`, `status`, `due_date` | `unique(user_id, id)`; hanya proyek milik user |
| `tasks` | `id`, `user_id`, `project_id`, `parent_task_id` (P1), `title`, `description`, `status`, `priority`, `due_date`, `estimated_minutes`, `completed_at` | `unique(user_id, id)`; composite FK ke project dan parent; `completed_at` konsisten dengan status; parent dan child harus satu user; maksimal dua level; tanpa siklus |
| `task_dependencies` (P1) | `user_id`, `task_id`, `blocked_by_task_id` | Tidak ada self-link; tanpa siklus; satu user |
| `focus_ignored` | `user_id`, `task_id`, `ignored_on` | Unik per user, task, dan tanggal |
| `ai_connections` | `id`, `user_id`, `provider`, `model`, `encrypted_key`, `key_version`, `status`, `last_tested_at` | Satu koneksi per provider per user; tidak dapat diakses client |
| `ai_requests` | `id`, `user_id`, `kind`, `status`, `created_at` | Index untuk rate limit dan metrik |
| `projects.parent_project_id` (P2) | `parent_project_id` | Opsional; satu level; satu user; tanpa siklus |

---

## 8. Information Architecture

### 8.1 Peta halaman (MVP)

```
/login                      — form login
/register                   — form registrasi
/focus                      — Daily Focus (halaman default setelah login)
/inbox                      — daftar tugas status `inbox`
/tasks                      — All Tasks (seluruh tugas, filter dasar by status)
/tasks/:id                  — detail & edit tugas
/projects                   — daftar proyek + progres
/projects/:id               — detail proyek (tugas di dalamnya, form hapus proyek)
/ai/breakdown                — form AI Task Breakdown + area review draft
/settings                   — timezone, disclosure AI, hapus akun
/settings/ai                — BYOK: simpan konfigurasi, test connection, hapus konfigurasi
```

### 8.2 Navigasi utama

Navigasi primer (sidebar atau bottom nav di mobile) berisi empat tujuan: **Daily Focus**, **Inbox**, **All Tasks/Projects**, **Settings**. AI Task Breakdown diakses dari dalam konteks proyek (tombol "Breakdown dengan AI" di halaman detail proyek) maupun dari menu utama, agar pengguna yang belum mengatur BYOK tetap bisa menemukannya dan diarahkan ke `/settings/ai` saat mencoba memakainya.

### 8.3 Komponen lintas halaman

- **Quick add bar** — tersedia secara global (atau minimal di Inbox dan Daily Focus) untuk memenuhi tujuan "tugas pertama dibuat <2 menit" (FR-04).
- **AI disclosure banner** — muncul di mana pun fitur AI ditawarkan tapi BYOK belum dikonfigurasi, menjelaskan bahwa fitur ini opsional dan butuh API key milik pengguna sendiri.
- **Empty state** — wajib ada di Daily Focus (tidak ada tugas), Inbox (kosong), dan All Tasks (belum ada tugas sama sekali), masing-masing dengan call-to-action yang relevan.

---

## 9. Non-Functional Requirements

### Performa

| Metrik | Target MVP | Cara Verifikasi |
|---|---|---|
| LCP halaman Daily Focus | < 2,5 detik (p75, 4G, Android mid-range) | Lighthouse |
| TTFB halaman aplikasi | < 800 ms (p75) | Log Vercel |
| Respons server untuk CRUD tugas/proyek | < 500 ms (p95) | Log durasi Server Action |
| Test Connection AI | < 10 detik atau error yang jelas | Integration test |
| AI Task Breakdown | < 30 detik, lalu timeout | Integration test |
| Loading state | Muncul < 300 ms untuk aksi > 1 detik | Manual |

- SDK AI tidak dimuat di bundle halaman inti.
- Halaman Daily Focus tetap dapat digunakan saat permintaan AI sedang berjalan.

### Keamanan dan Privasi

- HTTPS wajib di seluruh lingkungan; cookie sesi `httpOnly`, `Secure`, dan `SameSite=Lax`.
- Autentikasi memakai Supabase Auth; password di-hash oleh penyedia dan tidak pernah dicatat aplikasi.
- Otorisasi berbasis kepemilikan data melalui RLS pada seluruh tabel pengguna. Tidak ada role admin di MVP.
- Service role hanya dipakai di modul server; `ai_connections` tidak dapat diakses client.
- API key dienkripsi AES-256-GCM saat disimpan, tidak pernah dikembalikan API, tidak masuk log, analitik, atau pesan error.
- Validasi input di server memakai Zod; output AI divalidasi sebelum dipakai.
- Server Actions memakai pemeriksaan origin; cookie `SameSite=Lax` mengurangi risiko CSRF.
- Rate limit AI 10 permintaan per jam per pengguna; input tujuan maksimal 2.000 karakter; maksimal 15 tugas per draft.
- Pesan error tidak membocorkan key, token, email pengguna lain, atau detail internal.
- Data hanya dikirim ke OpenAI setelah pengguna memicu aksi AI, dengan konteks minimum dan penjelasan yang jelas.
- Penghapusan konfigurasi AI dan penghapusan akun tersedia; penghapusan akun menghapus seluruh data terkait.
- Secret hanya berada di environment variable; `.env.example` tidak memuat nilai asli.
- Tidak ada analitik pihak ketiga atau pelacakan perilaku pada MVP.

### Integritas Hierarki dan Dependency

- Relasi `parent_task_id` dan `task_dependencies` wajib divalidasi di server dan, bila memungkinkan, di database.
- Tidak boleh ada siklus, self-link, atau relasi lintas pengguna.
- Kedalaman hierarki task maksimal dua level pada P1.
- Task yang memiliki subtask diperlakukan sebagai container; Daily Focus hanya merekomendasikan leaf task.
- Task yang masih diblokir tidak masuk tiga rekomendasi utama.
- Penghapusan parent task memakai `SET NULL` agar subtask tidak hilang, dengan konfirmasi pengguna.

### Skalabilitas dan Ketersediaan

- Target desain MVP: 100 pengguna bersamaan dan 1.000 akun terdaftar. Angka ini belum divalidasi melalui load test.
- Next.js bersifat stateless di Vercel sehingga penskalaan horizontal ditangani platform.
- Koneksi database memakai connection pooler Supabase.
- Index wajib: `tasks(user_id, status, due_date)`, `tasks(user_id, project_id)`, `tasks(user_id, parent_task_id)` (P1), `projects(user_id)`, dan `ai_requests(user_id, created_at)`.
- Sharding dan multi-region tidak termasuk MVP.
- Ketersediaan mengikuti Vercel dan Supabase; tidak ada SLA formal pada MVP.
- Backup mengikuti paket Supabase. Prosedur restore didokumentasikan dengan target RPO 24 jam dan RTO 4 jam.
- Gangguan OpenAI tidak menghentikan pengelolaan tugas, proyek, dan Daily Focus.

### Usability dan Aksesibilitas

- Bahasa antarmuka: Indonesia.
- Alur inti memenuhi dasar WCAG 2.1 AA: navigasi keyboard, fokus terlihat, kontras teks minimal 4,5:1, label form, dan status tidak disampaikan hanya melalui warna.
- Responsif pada lebar 360–1440 px, mobile-first, dengan target sentuh minimal 44 px.
- Loading, empty, dan error state tersedia untuk setiap alur inti.
- Input yang belum tersimpan tidak hilang saat permintaan AI gagal.
- Onboarding maksimal tiga langkah.
- Dark mode, PWA, dan offline mode tidak termasuk MVP.

### Reliabilitas

- CRUD tugas dan proyek tetap berfungsi tanpa konfigurasi AI.
- Permintaan AI memiliki timeout 30 detik dan retry maksimal satu kali untuk gangguan jaringan atau 5xx.
- Aksi status bersifat idempotent; `completed_at` selalu konsisten dengan status.
- Penghapusan proyek tidak menghasilkan tugas yatim; `project_id` menjadi `null`.
- Log server memakai request ID dan tidak mencatat isi tujuan, API key, atau data pribadi.
- Monitoring MVP memakai log Vercel dan Supabase; error tracking eksternal ditunda.
- Migration database disimpan di repositori dan diuji melalui reset lokal sebelum diterapkan ke cloud.

### Kompatibilitas

- Dua versi terakhir Chrome, Edge, Firefox, dan Safari.
- Mobile web pada iOS Safari dan Android Chrome.
- Desktop dan mobile web; aplikasi native tidak termasuk MVP.
- Dependensi utama: Supabase, OpenAI, Vercel, dan browser modern.

### Batasan NFR MVP

- Tidak ada klaim dukungan 10.000 pengguna aktif atau sharding.
- Tidak ada jaminan uptime formal.
- Tidak ada PWA, offline mode, dark mode, atau pelacakan analitik.
- Performa diuji pada perangkat dan preview deployment, bukan load test produksi.

---

## 10. Out of Scope & Dependensi

### Out of Scope (Tidak Dikerjakan di V1)

| Fitur | Alasan | Ditunda ke |
|---|---|---|
| Todo list sebagai entitas terpisah | Inbox sudah menjadi permukaan quick-capture; memisahkan entitas akan menduplikasi data | Tidak direncanakan |
| Kolaborasi tim dan organisasi | MVP ditujukan untuk individu | P2 |
| Aplikasi native iOS/Android | Web responsif sudah cukup untuk validasi | P2 |
| PWA dan offline mode | Belum menjadi kebutuhan inti | P1 |
| Multi-provider AI | Fokus pada satu integrasi yang stabil | P1 |
| Penjadwalan ulang otomatis saat tugas tertunda | Butuh mesin perencanaan dan dependency | P1 |
| Tampilan kalender | Daily Focus lebih penting untuk validasi | P1 |
| Pencarian dan filter lanjutan | Belum perlu pada volume tugas awal | P1 |
| Ringkasan progres mingguan | Menunggu bukti retensi pengguna | P1 |
| Subtask, dependency task, dan task decomposer | Menambah kompleksitas model, UI, dan AI | P1 |
| Dependency graph visual | Bukan kebutuhan awal; dependency list sudah cukup | P2 |
| Preferensi kapasitas harian | Estimasi tugas sudah cukup untuk MVP | P1 |
| Notifikasi dan pengingat | Butuh infrastruktur email/push | P1 |
| Export/import data | Belum menjadi pain point utama | P1 |
| Project-to-project link (parent project) | Hierarki proyek jarang dibutuhkan solo user; gunakan task sebagai fase | P2 |
| Project dependency | Proyek adalah container, bukan unit terjadwal | Tidak direncanakan |
| Related task link | Asosiasi lemah; tag/label lebih murah bila dibutuhkan | P2 |
| Recursive decomposition | Risiko over-planning dan biaya AI | P2 |
| Project → sub-project decomposition | Gunakan task sebagai fase dan subtask sebagai langkah | Tidak direncanakan |
| Dark mode | Fokus pada identitas visual utama | P2 |
| Billing dan pembayaran | Model bisnis belum divalidasi | P2 |
| Marketplace plugin atau agen AI | Di luar fokus produk | P2 |
| Integrasi kalender dan aplikasi pihak ketiga | Risiko dan biaya integrasi tinggi | P2 |
| Gamifikasi kompleks | Tidak menyelesaikan masalah prioritas | P2 |
| Analitik pengawasan atau pelacakan aktivitas | Bertentangan dengan prinsip privasi | Tidak direncanakan |
| AI yang menjalankan tindakan tanpa persetujuan | Melanggar prinsip human-in-control | Tidak direncanakan |
| Reset password dan verifikasi email produksi | Demo memakai konfigurasi tanpa verifikasi | Wajib sebelum produksi |
| Role admin dan panel administrasi | Belum ada kebutuhan operasional | P2 |

### Dependensi

| Dependensi | Fungsi | Risiko |
|---|---|---|
| Next.js dan TypeScript | Framework aplikasi dan keamanan tipe | Perubahan versi mayor |
| Tailwind CSS, shadcn/ui, Motion | Antarmuka dan animasi | Perubahan API komponen |
| Supabase Auth | Registrasi, login, sesi | Rate limit dan konfigurasi email |
| Supabase Postgres dan RLS | Penyimpanan data dan isolasi pengguna | Kesalahan kebijakan akses |
| Supabase CLI dan Docker | Development lokal dan migration | Perbedaan versi lokal/cloud |
| OpenAI API dan SDK | AI Task Breakdown dan test connection | Kuota, biaya, perubahan model, gangguan layanan |
| Zod | Validasi input dan output AI | Tidak ada |
| Vercel | Hosting dan deployment | Batas waktu serverless |
| Vitest dan Playwright | Unit, integration, dan E2E test | Waktu setup |
| Node.js Crypto | Enkripsi AES-256-GCM untuk API key | Pengelolaan secret environment |

**Dependensi organisasi:**
- Akun Supabase cloud dan Vercel.
- API key OpenAI milik pengguna untuk demo AI.
- Persetujuan CV Smart Global Nusantara untuk menyimpan key terenkripsi dan mengirim konteks terpilih ke OpenAI.
- Ketersediaan waktu review dari pembimbing magang.

### Asumsi

- Pengguna memiliki koneksi internet yang stabil.
- Pengguna memiliki email aktif dan menggunakan browser modern.
- Pengguna yang mengaktifkan AI sudah memiliki API key OpenAI dengan kuota tersedia.
- Biaya pemakaian AI ditanggung pengguna sesuai kebijakan akun OpenAI mereka.
- Satu akun digunakan oleh satu pengguna; tidak ada sharing akun.
- Data yang dimasukkan bukan data medis, keuangan, atau data regulasi lain yang membutuhkan kepatuhan khusus.
- Timezone pengguna tersedia dalam format IANA.
- Demo menggunakan data dummy, bukan data pelanggan nyata.
- Verifikasi email dinonaktifkan untuk demo dan wajib diaktifkan sebelum produksi.
- Output AI dapat salah dan selalu memerlukan persetujuan pengguna.
- Timeline 5 hari mengasumsikan solo developer dibantu AI coding assistant dan tidak menyertakan pengujian pengguna formal.

---

## 11. Risk Register

Risiko dinilai dengan skala Dampak × Kemungkinan (Rendah/Sedang/Tinggi). Risiko ini melengkapi tabel Dependensi di [Bagian 10](#10-out-of-scope--dependensi) dengan fokus pada mitigasi konkret, bukan sekadar daftar ketergantungan teknis.

| # | Risiko | Dampak | Kemungkinan | Mitigasi |
|---|---|---|---|---|
| R1 | Timeline 5 hari tergelincir karena scope creep di fitur AI | Tinggi | Sedang | FR-14/FR-15 dibatasi ketat ke mode project→tasks saja; subtask/dependency/decomposer eksplisit didorong ke P1 ([Bagian 12.2](#122-timeline-harian-mvp-5-hari)) |
| R2 | Biaya atau kuota OpenAI pengguna demo habis saat presentasi | Sedang | Sedang | BYOK memindahkan risiko biaya ke pengguna; siapkan key demo cadangan dengan kuota kecil yang sudah diverifikasi sebelum sesi review |
| R3 | RLS Supabase salah konfigurasi membocorkan data antar pengguna | Tinggi | Rendah | Index dan policy RLS diuji lewat integration test per tabel sebelum deploy; service role hanya dipakai di modul server (NFR Keamanan) |
| R4 | Output AI (structured output) tidak sesuai skema Zod dan merusak draft | Sedang | Sedang | Validasi Zod wajib sebelum render draft; kegagalan validasi menampilkan error tanpa menyimpan apa pun ke database (FR-14) |
| R5 | Enkripsi API key salah implementasi (key bisa dibaca ulang) | Tinggi | Rendah | AES-256-GCM dengan key_version; code review khusus modul `ai_connections` sebelum FR-16 dianggap selesai; unit test memastikan ciphertext tidak dapat didekripsi oleh modul client |
| R6 | Algoritma skor Daily Focus menghasilkan rekomendasi yang terasa salah/tidak masuk akal bagi pengguna | Sedang | Sedang | Alasan rekomendasi harus selalu ditampilkan (explainability) agar kesalahan mudah terdeteksi dan diperbaiki lewat tuning bobot skor, bukan black-box model |
| R7 | Pengujian pengguna formal tidak dilakukan dalam timeline 5 hari | Sedang | Tinggi | Diterima secara sadar sebagai asumsi ([Asumsi](#104-asumsi)); mitigasi lanjutan adalah menjadwalkan validasi pengguna di awal P1 |
| R8 | Reset password dan verifikasi email belum ada, menghambat transisi dari demo ke produksi nyata | Sedang | Tinggi | Sudah ditandai "Wajib sebelum produksi" di tabel Out of Scope; dimasukkan sebagai item pertama roadmap P1 |
| R9 | Load sesungguhnya melebihi target desain 100 pengguna bersamaan | Sedang | Rendah | Target desain dinyatakan belum divalidasi load test (NFR Skalabilitas); mitigasi adalah connection pooler Supabase dan index wajib yang sudah didefinisikan |

---

## 12. Roadmap, Timeline & Keputusan

### 12.1 MVP (P0) — 5 hari

- Autentikasi: registrasi, login, logout, proteksi sesi, hapus akun.
- Task management: quick add, detail/edit, Inbox, All Tasks, status, prioritas, tenggat, estimasi, hapus, tautan proyek.
- Project management: buat, daftar/detail, progres, hapus aman.
- Daily Focus: skor deterministik, top 3, alasan, beban kerja, start/done, dismiss/undo, empty state.
- AI Task Breakdown: project → tasks, draft, review/edit, approval, simpan, error/limit.
- BYOK: OpenAI, model, simpan key terenkripsi, test connection, hapus konfigurasi.
- Settings: timezone, disclosure AI, hapus akun.
- Fondasi: responsif, aksesibilitas, keamanan, error/loading/empty, performa, deployment.

### 12.2 Timeline Harian MVP (5 hari)

Pemetaan indikatif FR ke hari kerja, disusun agar modul yang paling banyak dependensi diselesaikan lebih dulu dan setiap hari menghasilkan sesuatu yang bisa didemokan:

| Hari | Fokus | FR yang diselesaikan | Keluaran yang bisa didemokan |
|---|---|---|---|
| 1 | Fondasi + Autentikasi | Setup Next.js/Supabase/RLS, migration dasar, FR-01, FR-02, FR-03 | Pengguna bisa daftar, login, logout |
| 2 | Task & Project core | FR-04 s/d FR-10 | CRUD tugas dan proyek penuh, Inbox dan All Tasks berfungsi |
| 3 | Daily Focus | FR-11, FR-12, FR-13 | Rekomendasi 3 tugas teratas dengan alasan, start/done/dismiss berfungsi tanpa AI |
| 4 | BYOK + AI Task Breakdown | FR-16, FR-17, FR-18, FR-14, FR-15 | Pengguna menghubungkan key sendiri, generate draft, approve jadi tugas |
| 5 | Settings, polish, hardening, deploy | FR-19, FR-20; NFR keamanan/aksesibilitas/performa; testing; deployment | Aplikasi lengkap FR-01–FR-20 live di Vercel, siap didemokan end-to-end |

Catatan: urutan ini sengaja menunda AI ke hari ke-4 agar seluruh alur inti (hari 1–3) sudah terbukti berfungsi 100% tanpa AI sebelum kompleksitas BYOK dan integrasi eksternal ditambahkan — selaras dengan prinsip "AI opsional, bukan inti" di [Bagian 3](#3-visi--tujuan-produk).

### 12.3 P1

- Subtask dan hierarki task maksimal dua level.
- Dependency task dan tampilan "Menunggu" di Daily Focus.
- AI Task Decomposer mode task → subtasks.
- Daily Focus hanya merekomendasikan leaf task dan menghormati blocker.
- Multi-provider AI.
- Rescheduling saat tugas tertunda.
- Calendar view, search/filter, weekly summary.
- PWA dan offline terbatas.
- Notifikasi/pengingat.
- Export/import data.
- Focus preferences: kapasitas harian dan jam kerja.
- Email verification dan reset password sebelum produksi.
- Profile management: nama, avatar, ubah email/password.
- AI cost/usage dan model discovery.

### 12.4 P2

- Project parent-child (parent project) satu level.
- Related task link dan graph view.
- Recursive decomposition.
- Kolaborasi tim.
- Aplikasi native.
- Integrasi kalender.
- Voice-to-task.
- Cross-project context.
- Workflow automation.
- Marketplace plugin.
- Gamifikasi.
- Billing.
- Admin panel.
- AI chat/iterative refinement.
- Dark mode.
- Localization.
- 2FA, audit log, session management.

### 12.5 Keputusan Produk

1. **Todo list bukan entitas terpisah.** Inbox adalah permukaan quick-capture; task adalah sumber data utama. Ini mencegah duplikasi data dan menjaga Daily Focus tetap melihat seluruh pekerjaan.
2. **Linking harus eksplisit.** Gunakan subtask untuk hierarki, dependency untuk urutan, dan related link hanya jika terbukti dibutuhkan. Tabel link polimorfik tidak dipakai.
3. **Prioritas relasi:** subtask dan dependency masuk P1; related link dan graph view masuk P2; project dependency tidak direncanakan.
4. **Project decomposer memiliki dua mode:** project → tasks (MVP) dan task → subtasks (P1). Project → sub-project dan recursive decomposition tidak termasuk.
5. **Project-to-project link ditunda.** Untuk kebutuhan proyek besar, gunakan task sebagai fase dan subtask sebagai langkah.
6. **Daily Focus P1:** hanya leaf task yang direkomendasikan; task yang diblokir tidak masuk tiga teratas dan ditampilkan sebagai "Menunggu".
7. **Invariant hierarki:** satu user, maksimal dua level, tanpa siklus, tanpa self-link. Penghapusan parent memakai `SET NULL` agar subtask tidak hilang.

---

## 13. Glossary

| Istilah | Definisi |
|---|---|
| **BYOK (Bring Your Own Key)** | Model di mana pengguna menyediakan API key AI miliknya sendiri; ORBIT menyimpan key terenkripsi dan tidak menanggung biaya inferensi. |
| **Daily Focus** | Halaman/fitur yang menampilkan maksimal tiga rekomendasi tugas harian beserta alasannya, dihitung secara deterministik tanpa AI. |
| **Inbox** | Status tugas (`inbox`), bukan entitas terpisah — permukaan quick-capture untuk tugas yang belum dikategorikan. |
| **Leaf task** | Task yang tidak memiliki subtask di bawahnya; satu-satunya jenis task yang direkomendasikan Daily Focus pada P1. |
| **Container task** | Task yang memiliki satu atau lebih subtask; tidak direkomendasikan langsung oleh Daily Focus karena progresnya diwakili oleh subtask-nya. |
| **Dismissal / Ignore** | Aksi mengabaikan satu rekomendasi Daily Focus untuk hari itu saja, tanpa menghapus tugasnya (`focus_ignored`). |
| **Draft (AI)** | Hasil keluaran AI (breakdown atau decomposer) yang belum tersimpan ke database dan masih bisa diedit/dibatalkan oleh pengguna. |
| **Human-in-control** | Prinsip desain: AI tidak pernah menulis ke data penting tanpa langkah approval eksplisit dari pengguna. |
| **RLS (Row Level Security)** | Mekanisme Supabase/Postgres yang membatasi akses baris data berdasarkan identitas pengguna yang melakukan query. |
| **Structured output** | Mode API AI (OpenAI) yang memaksa jawaban model mengikuti skema data tertentu, divalidasi ulang dengan Zod di server ORBIT. |
| **Dependency (task)** | Relasi `blocked_by_task_id` pada P1 yang menandai satu task harus menunggu task lain selesai sebelum bisa dikerjakan/direkomendasikan. |
| **RPO/RTO** | Recovery Point Objective/Recovery Time Objective — target maksimal data yang boleh hilang dan waktu maksimal untuk memulihkan layanan setelah insiden. |
| **p75 / p95** | Persentil ke-75/95 dari distribusi pengukuran (misalnya latensi); dipakai sebagai target performa agar tidak hanya mengandalkan rata-rata. |
| **North Star Metric** | Satu metrik utama yang paling mewakili nilai inti produk bagi pengguna, dipakai sebagai acuan tertinggi di atas metrik pendukung lain. |

---

## 14. Lampiran: Traceability

| Masalah | Fitur MVP | Metrik |
|---|---|---|
| Sulit menentukan prioritas | Daily Focus | Minimal satu tugas dari Daily Focus diselesaikan per sesi aktif |
| Tujuan besar terasa abstrak | AI Task Breakdown | Minimal 70% draft disetujui atau diedit lalu disimpan |
| Rencana cepat usang | Daily Focus dan perubahan status | Fokus dihitung ulang setelah status berubah |
| AI terpisah dari alur kerja | AI Breakdown dengan approval | Tugas AI hanya tersimpan setelah persetujuan |
| Ketergantungan pada satu penyedia | BYOK | Pengguna dapat menghubungkan, menguji, dan menghapus key |
| Pencatatan tugas yang terlalu berat | Inbox quick capture | Tugas pertama dibuat kurang dari 2 menit |
| Pekerjaan besar sulit dipecah | Subtask dan task decomposer (P1) | Pengguna menyetujui minimal satu draft subtask |
| Pekerjaan terhambat tugas lain | Dependency dan Daily Focus (P1) | Task yang diblokir tidak muncul di tiga rekomendasi utama |

---

## 15. Pertanyaan Terbuka & Next Steps

### Pertanyaan Terbuka

- Apakah tombol "Start Focus" memerlukan timer, atau cukup perubahan status?
- Apakah perlu toggle aktif/nonaktif AI selain menghapus konfigurasi?
- Apakah onboarding perlu menjadi fitur eksplisit dengan dua atau tiga langkah?
- Apakah draft AI perlu fitur urutkan ulang sebelum disimpan?
- Apakah reset password dan verifikasi email masuk sebelum demo atau hanya sebelum produksi?
- Apakah search/filter dasar perlu masuk MVP atau cukup P1?
- Apakah penghapusan parent task sebaiknya `SET NULL` (rekomendasi) atau cascade?
- Apakah project parent-child benar-benar dibutuhkan setelah validasi pengguna?

### Next Steps

1. **Review dokumen ini** dengan pembimbing/reviewer sebelum hari implementasi pertama dimulai; prioritaskan menjawab pertanyaan terbuka yang berdampak pada model data (parent task deletion, project parent-child) karena perubahan di sana paling mahal bila diputuskan belakangan.
2. **Turunkan dokumen desain teknis** (schema SQL, kebijakan RLS per tabel, kontrak Server Action) langsung dari [Bagian 7](#7-functional-requirements) dan [Model Data Konseptual](#model-data-konseptual) — PRD ini menjadi sumber kebenaran tunggal untuk requirement, bukan desain implementasi.
3. **Eksekusi timeline 5 hari** sesuai [Bagian 12.2](#122-timeline-harian-mvp-5-hari), dengan checklist harian dicocokkan ke FR yang tercantum.
4. **Siapkan key demo OpenAI cadangan** sebelum sesi presentasi untuk memitigasi R2 di [Risk Register](#11-risk-register).
5. **Setelah MVP live**, jadwalkan validasi pengguna singkat terhadap North Star Metric sebelum mengurutkan ulang backlog P1 — supaya urutan P1 (saat ini: email/reset password dan hierarki task) tetap berdasar bukti, bukan asumsi.

---

**Akhir dokumen.**
