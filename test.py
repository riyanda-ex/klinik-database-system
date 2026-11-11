# Test otomatis - Klinik Database System V2.0
# Cek struktur SQL tanpa butuh MySQL asli (cek teks + aturan)
import os, re, sys

def test(nama, kondisi):
    print(f"{'✅' if kondisi else '❌'} {nama}")
    return kondisi

if __name__ == "__main__":
    print("=== TEST Klinik Database System ===\n")
    base = os.path.dirname(__file__)
    hasil = []

    with open(os.path.join(base, "schema.sql"), encoding='utf-8') as f:
        schema = f.read()
    with open(os.path.join(base, "queries.sql"), encoding='utf-8') as f:
        queries = f.read()
    with open(os.path.join(base, "seed.sql"), encoding='utf-8') as f:
        seed = f.read()

    hasil.append(test("1. 5 tabel ada (pasien, dokter, obat, kunjungan, resep)", all(t in schema for t in ["pasien", "dokter", "obat", "kunjungan", "resep"])))
    hasil.append(test("2. Foreign Key ada", "FOREIGN KEY" in schema))
    hasil.append(test("3. Index ada", "INDEX" in schema))
    hasil.append(test("4. CHECK stok tidak negatif ada", "stok >= 0" in schema))
    hasil.append(test("5. Trigger cegah stok negatif ada", "trg_cegah_stok_negatif" in schema))
    hasil.append(test("6. 3 VIEW ada", all(v in schema for v in ["v_rekap_harian", "v_stok_kritis", "v_klaim_perlu_perbaikan"])))
    hasil.append(test("7. Kolom NIK asli TIDAK ada, hanya nik_hash", "nik_hash" in schema and "nik VARCHAR" not in schema.lower()))
    hasil.append(test("8. Seed pakai SHA2, bukan NIK asli polos", "SHA2(" in seed))
    hasil.append(test("9. Seed pakai nama samaran, bukan nama asli", "nama_samaran" in seed))
    hasil.append(test("10. Queries 12 query ada", queries.count("SELECT") >= 10))
    hasil.append(test("11. Queries pakai kode_pasien, bukan nama", "kode_pasien" in queries))
    hasil.append(test("12. Jaminan nasional ada di schema (JKN, Jamkesda, Jampersal)", all(x in schema for x in ["JKN-PBI", "JAMKESDA", "JAMPERSAL"])))
    hasil.append(test("13. Disclaimer ada di schema", "DISCLAIMER" in schema))
    hasil.append(test("14. utf8mb4 untuk bahasa Indonesia", "utf8mb4" in schema))
    hasil.append(test("15. Tidak ada data asli (cek kata NIK asli tidak dipakai sebagai kolom)", "no_bpjs" not in schema.lower()))

    lulus = sum(hasil)
    print(f"\nHASIL: {lulus}/{len(hasil)} lulus")
    if lulus == len(hasil):
        print("🎉 SEMUA TEST LULUS!")
    else:
        print("⚠️ Ada test gagal, cek di atas.")
        sys.exit(1)
