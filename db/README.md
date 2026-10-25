# ORBIT — Database Schema & Migrations

Skema database ORBIT, dirancang untuk jalan di **Supabase sekarang** dan bisa dipindah ke **Postgres self-hosted** nanti tanpa menulis ulang skema. Lihat `1-PRD.md` bagian 7 & 9 untuk requirement sumber, dan plan ERD untuk rasionalnya.

## Struktur folder

```
supabase/migrations/            <- jalankan ini via Supabase CLI sekarang (P0/MVP)
  20261025090000_bootstrap_supabase.sql
  20261025090100_schema.sql
  20261025090200_profiles_identity_supabase.sql
  20261025090300_rls.sql
  20261025090400_triggers.sql
  20261025090500_indexes.sql

db/
  README.md                     <- file ini
  selfhosted-bootstrap/          <- HANYA dipakai kalau pindah ke Postgres sendiri
    000_bootstrap_selfhosted.sql
    015_profiles_identity_selfhosted.sql
  P1/                            <- disiapkan, BELUM dijalankan — aktifkan saat fase P1 dimulai
    100_task_hierarchy.sql
    110_task_dependencies.sql
  P2/                            <- disiapkan, BELUM dijalankan — aktifkan saat fase P2 dimulai
    200_project_hierarchy.sql
```

## Menjalankan di Supabase (sekarang)

Butuh [Supabase CLI](https://supabase.com/docs/guides/cli) dan Docker Desktop terpasang (belum ada di komputer ini saat plan ini dibuat — install dulu sebelum lanjut).

```bash
supabase init        # sekali saja, kalau belum ada folder supabase/ dengan config.toml
supabase start        # menjalankan Postgres lokal via Docker
supabase db reset     # menjalankan semua file di supabase/migrations/ secara berurutan
```

`db reset` menjalankan file di `supabase/migrations/` berurutan sesuai nama (timestamp di depan menjamin urutannya benar). Kelima file di sana **cukup untuk MVP (P0)** — tidak ada file dari `db/P1/` atau `db/P2/` yang ikut jalan, karena keduanya sengaja ditaruh di luar `supabase/migrations/`.

Untuk deploy ke project Supabase cloud:
```bash
supabase link --project-ref <ref-project-anda>
supabase db push
```

## Mengaktifkan P1 / P2 nanti

Saat fase P1 (subtask + dependency) atau P2 (parent project) dimulai:

1. Copy file dari `db/P1/` (atau `db/P2/`) ke `supabase/migrations/`.
2. Beri nama ulang dengan timestamp baru yang **lebih besar** dari migration terakhir (format `YYYYMMDDHHMMSS_nama.sql`), supaya urutannya tetap benar.
3. Jalankan `supabase migration up` (lokal) lalu `supabase db push` (cloud).

File P1/P2 sudah lengkap (tabel, RLS, trigger, index) — tidak perlu ditulis ulang, hanya dipindahkan saat waktunya tiba.

## Kalau nanti pindah ke Postgres self-hosted

Hanya **dua file** yang berbeda antara Supabase dan self-hosted — semua file lain di `supabase/migrations/` dipakai ulang tanpa perubahan:

| Supabase | Self-hosted |
|---|---|
| `supabase/migrations/20261025090000_bootstrap_supabase.sql` | `db/selfhosted-bootstrap/000_bootstrap_selfhosted.sql` |
| `supabase/migrations/20261025090200_profiles_identity_supabase.sql` | `db/selfhosted-bootstrap/015_profiles_identity_selfhosted.sql` |

Playbook migrasi:

1. `pg_dump`/`supabase db dump` schema + data dari Supabase.
2. Restore ke server Postgres baru.
3. Jalankan `db/selfhosted-bootstrap/000_bootstrap_selfhosted.sql` lalu `015_profiles_identity_selfhosted.sql` — **BUKAN** versi Supabase-nya.
4. Jalankan sisa file di `supabase/migrations/` (schema, rls, triggers, indexes) seperti biasa — isinya identik, tidak perlu diubah.
5. Ganti Supabase Auth dengan solusi auth mandiri (NextAuth/Lucia/custom) — ini bagian migrasi terbesar, di luar scope skema ini.
6. Implementasikan wrapper `withUserContext(userId, fn)` di server yang membungkus **setiap** query dengan `BEGIN; SET LOCAL app.current_user_id = $1; ...; COMMIT;` dalam satu koneksi/transaksi (lihat komentar di `000_bootstrap_selfhosted.sql`) — satu-satunya titik yang perlu diaudit ulang sebelum go-live self-hosted.
7. Buat role `app_server` (baris commented-out di `000_bootstrap_selfhosted.sql`) dengan password dari secrets manager, lalu pakai role itu untuk koneksi aplikasi.
8. Update connection string aplikasi. Tidak ada perubahan pada query/ORM layer lain.

## Keamanan — poin penting yang perlu diingat

- **`private.ai_connections` tidak boleh diakses langsung** dari kode aplikasi mana pun — selalu lewat function di `20261025090400_triggers.sql`: `fn_upsert_ai_connection`, `fn_get_decrypt_material`, `fn_delete_ai_connection`, `fn_record_ai_connection_test_result`. Enkripsi/dekripsi AES-256-GCM sendiri terjadi di Node.js server layer, bukan di database — function ini hanya memindahkan ciphertext.
- **`service_role` (Supabase) punya `BYPASSRLS`** — RLS di `private.ai_connections` tidak melindungi dari jalur service_role itu sendiri, hanya dari kesalahan grant ke role lain. Disiplin kode (selalu lewat gateway function) adalah pertahanan yang sesungguhnya.
- **Rate limit AI (10/jam/user)** wajib lewat `fn_check_and_record_ai_request()` + `fn_record_ai_request_outcome()` — jangan hitung-lalu-insert manual di dua statement terpisah di app layer, itu rentan race condition.
- **`security_events`** (schema `private`) otomatis tercatat oleh gateway function di atas untuk lifecycle BYOK. Untuk `account_deletion_requested`/`account_deleted`, panggil `private.fn_log_security_event()` manual dari flow penghapusan akun.

## Verifikasi setelah migration jalan

Lihat plan ERD untuk daftar lengkap test (RLS antar-user, isolasi `private.ai_connections`, trigger hierarki/dependency, rate limit, cascade delete, round-trip enkripsi). Ringkas:

```bash
supabase db reset   # harus sukses tanpa error di seluruh 6 file
```

Lalu uji manual lewat `supabase studio` (atau `psql`) sebagai dua user berbeda untuk memastikan isolasi RLS benar.
