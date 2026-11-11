# ERD - Klinik Database System V2.0

## Diagram Relasi (Entity Relationship Diagram)

```
pasien (1) ----< kunjungan (N) >---- (1) dokter
                  |
                  | (1)
                  |
                  v (N)
                 resep (N) >---- (1) obat
```

## Penjelasan Relasi

| Dari | Ke | Jenis | Keterangan |
| --- | --- | --- | --- |
| pasien | kunjungan | 1 ke N | 1 pasien bisa punya banyak kunjungan |
| dokter | kunjungan | 1 ke N | 1 dokter bisa melayani banyak kunjungan |
| kunjungan | resep | 1 ke N | 1 kunjungan bisa punya banyak resep obat |
| obat | resep | 1 ke N | 1 obat bisa diresepkan di banyak kunjungan |

## Kenapa Tidak Ada Relasi Langsung pasien ke resep?

Ini sengaja. Ini namanya Normalisasi 3NF.
Kalau resep langsung nyambung ke pasien, kita tidak tau resep itu dari kunjungan tanggal berapa, dokter siapa, diagnosis apa.
Dengan lewat kunjungan, semua tercatat rapi:
pasien -> kunjungan (tanggal, dokter, diagnosis) -> resep (obat, jumlah)

## Kunci (Keys)

### Primary Key (PK)
- pasien.id_pasien
- dokter.id_dokter
- obat.id_obat
- kunjungan.id_kunjungan
- resep.id_resep

### Foreign Key (FK)
- kunjungan.id_pasien -> pasien.id_pasien
- kunjungan.id_dokter -> dokter.id_dokter
- resep.id_kunjungan -> kunjungan.id_kunjungan
- resep.id_obat -> obat.id_obat

### Unique Key
- pasien.kode_pasien - contoh: PAS-001
- dokter.kode_dokter - contoh: DOK-001
- obat.kode_obat - contoh: OBT-001
- kunjungan.kode_kunjungan - contoh: KUN-001
- resep (id_kunjungan, id_obat) - 1 kunjungan tidak boleh resep obat yang sama 2x

## Aturan Penghapusan (Delete Rules)

| Jika Dihapus | Yang Terjadi | Alasan |
| --- | --- | --- |
| pasien | DITOLAK jika masih ada kunjungan | ON DELETE RESTRICT - riwayat pasien tidak boleh hilang |
| dokter | DITOLAK jika masih ada kunjungan | ON DELETE RESTRICT - riwayat dokter tidak boleh hilang |
| kunjungan | resep ikut terhapus | ON DELETE CASCADE - resep tanpa kunjungan tidak ada artinya |
| obat | DITOLAK jika masih ada di resep | ON DELETE RESTRICT - obat yang pernah diresepkan tidak boleh hilang |

## VIEW Yang Ada Di Atas Tabel Ini

| VIEW | Fungsi | Tabel Sumber |
| --- | --- | --- |
| v_rekap_harian | Rekap kunjungan per hari | kunjungan |
| v_stok_kritis | Obat expired / menipis / habis | obat |
| v_klaim_perlu_perbaikan | Klaim BPJS yang perlu diperbaiki | kunjungan + pasien |
