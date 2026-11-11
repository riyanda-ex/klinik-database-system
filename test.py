# test.py - Test Otomatis Klinik Database System V2.0
# Cara jalanin: pip install mysql-connector-python
#               python test.py
# Kalau MySQL belum jalan, test akan skip dengan pesan jelas.

import sys
import os

try:
    import mysql.connector
    from mysql.connector import Error
except ImportError:
    print("❌ mysql-connector-python belum terinstall.")
    print("Jalanin dulu: pip install mysql-connector-python")
    sys.exit(1)

# ================= KONFIGURASI =================
# Di laptop: pakai default localhost / root / password kosong
# Di GitHub Actions: dibaca dari env DB_HOST, DB_USER, DB_PASSWORD, DB_NAME
DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "klinik_db")
}

passed = 0
failed = 0
results = []

def test(nama, kondisi, detail=""):
    global passed, failed
    if kondisi:
        passed += 1
        results.append(f"✅ PASS: {nama}")
        print(f"✅ PASS: {nama}")
    else:
        failed += 1
        results.append(f"❌ FAIL: {nama} - {detail}")
        print(f"❌ FAIL: {nama} - {detail}")

def get_tables(cursor):
    cursor.execute("SHOW TABLES")
    return [row[0] for row in cursor.fetchall()]

def main():
    print("=" * 60)
    print("Klinik Database System V2.0 - Test Otomatis (18 Test)")
    print("=" * 60)

    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor(dictionary=True)
        print(f"✅ Terhubung ke MySQL database: {DB_CONFIG['database']}\n")
    except Error as e:
        print(f"❌ Gagal konek ke MySQL: {e}")
        print("\nPastikan:")
        print("1. MySQL sudah jalan (XAMPP / Laragon / MySQL Service)")
        print("2. Database klinik_db sudah dibuat (jalanin schema.sql dulu)")
        print("3. User / password di DB_CONFIG di atas sudah bener")
        sys.exit(1)

    # Bersihin data test lama biar test bisa diulang
    cursor.execute("SET FOREIGN_KEY_CHECKS = 0")
    for t in ["audit_log", "resep", "kunjungan", "pasien", "dokter", "obat"]:
        try:
            cursor.execute(f"TRUNCATE TABLE {t}")
        except:
            pass
    cursor.execute("SET FOREIGN_KEY_CHECKS = 1")
    conn.commit()

    # ---------- TEST 1-6: TABEL ADA ----------
    tables = get_tables(cursor)
    test("1. Tabel pasien ada", "pasien" in tables)
    test("2. Tabel dokter ada", "dokter" in tables)
    test("3. Tabel obat ada", "obat" in tables)
    test("4. Tabel kunjungan ada", "kunjungan" in tables)
    test("5. Tabel resep ada", "resep" in tables)
    test("6. Tabel audit_log ada", "audit_log" in tables, "Tabel audit_log belum dibuat di schema.sql")

    # ---------- TEST 7-9: INSERT DATA DASAR ----------
    try:
        cursor.execute("INSERT INTO pasien (kode_pasien, tanggal_lahir, jenis_kelamin, kode_jaminan) VALUES ('PAS-001', '1990-01-01', 'L', 'UMUM')")
        cursor.execute("INSERT INTO dokter (kode_dokter, nama_samaran, spesialisasi) VALUES ('DOK-001', 'Dr. A', 'Umum')")
        cursor.execute("INSERT INTO obat (kode_obat, nama_obat, stok, stok_minimal, harga, tanggal_expired) VALUES ('OBT-001', 'Paracetamol', 100, 10, 5000, '2027-01-01')")
        conn.commit()
        test("7. Insert pasien + dokter + obat berhasil", True)
    except Exception as e:
        test("7. Insert pasien + dokter + obat berhasil", False, str(e))

    # Ambil ID-nya
    cursor.execute("SELECT id_pasien FROM pasien WHERE kode_pasien='PAS-001'")
    id_pasien = cursor.fetchone()["id_pasien"]
    cursor.execute("SELECT id_dokter FROM dokter WHERE kode_dokter='DOK-001'")
    id_dokter = cursor.fetchone()["id_dokter"]
    cursor.execute("SELECT id_obat FROM obat WHERE kode_obat='OBT-001'")
    id_obat = cursor.fetchone()["id_obat"]

    # ---------- TEST 10-12: KUNJUNGAN + RESEP + ATURAN ----------
    try:
        cursor.execute("INSERT INTO kunjungan (kode_kunjungan, id_pasien, id_dokter, tanggal_kunjungan, diagnosis, kode_icd10) VALUES ('KUN-001', %s, %s, '2026-11-11', 'Demam', 'R50.9')", (id_pasien, id_dokter))
        conn.commit()
        test("8. Insert kunjungan berhasil", True)
    except Exception as e:
        test("8. Insert kunjungan berhasil", False, str(e))

    cursor.execute("SELECT id_kunjungan FROM kunjungan WHERE kode_kunjungan='KUN-001'")
    id_kunjungan = cursor.fetchone()["id_kunjungan"]

    try:
        cursor.execute("INSERT INTO resep (id_kunjungan, id_obat, jumlah) VALUES (%s, %s, 10)", (id_kunjungan, id_obat))
        conn.commit()
        test("9. Insert resep berhasil", True)
    except Exception as e:
        test("9. Insert resep berhasil", False, str(e))

    # Resep duplikat harus ditolak (UNIQUE kunjungan + obat)
    try:
        cursor.execute("INSERT INTO resep (id_kunjungan, id_obat, jumlah) VALUES (%s, %s, 5)", (id_kunjungan, id_obat))
        conn.commit()
        test("10. Resep duplikat ditolak (UNIQUE)", False, "Seharusnya gagal, tapi malah berhasil")
    except:
        conn.rollback()
        test("10. Resep duplikat ditolak (UNIQUE)", True)

    # Stok negatif harus ditolak
    try:
        cursor.execute("UPDATE obat SET stok = -1 WHERE id_obat = %s", (id_obat,))
        conn.commit()
        test("11. Stok negatif ditolak (Trigger)", False, "Seharusnya gagal, tapi malah berhasil")
    except:
        conn.rollback()
        test("11. Stok negatif ditolak (Trigger)", True)

    # Hapus pasien yang masih ada kunjungan harus ditolak (RESTRICT)
    try:
        cursor.execute("DELETE FROM pasien WHERE id_pasien = %s", (id_pasien,))
        conn.commit()
        test("12. Hapus pasien ada kunjungan ditolak (RESTRICT)", False, "Seharusnya gagal, tapi malah berhasil")
    except:
        conn.rollback()
        test("12. Hapus pasien ada kunjungan ditolak (RESTRICT)", True)

    # ---------- TEST 13-15: VIEW ----------
    try:
        cursor.execute("SELECT * FROM v_rekap_harian")
        rows = cursor.fetchall()
        test("13. VIEW v_rekap_harian bisa dibaca", len(rows) >= 1)
    except Exception as e:
        test("13. VIEW v_rekap_harian bisa dibaca", False, str(e))

    try:
        cursor.execute("SELECT * FROM v_stok_kritis")
        cursor.fetchall()
        test("14. VIEW v_stok_kritis bisa dibaca", True)
    except Exception as e:
        test("14. VIEW v_stok_kritis bisa dibaca", False, str(e))

    try:
        cursor.execute("SELECT * FROM v_klaim_perlu_perbaikan")
        cursor.fetchall()
        test("15. VIEW v_klaim_perlu_perbaikan bisa dibaca", True)
    except Exception as e:
        test("15. VIEW v_klaim_perlu_perbaikan bisa dibaca", False, str(e))

    # ---------- TEST 16-18: AUDIT LOG (BARU) ----------
    # 16. Insert kunjungan harus kecatat di audit_log
    try:
        cursor.execute("SELECT COUNT(*) as total FROM audit_log WHERE nama_tabel='kunjungan' AND aksi='INSERT' AND id_record=%s", (id_kunjungan,))
        total = cursor.fetchone()["total"]
        test("16. Audit: INSERT kunjungan tercatat", total >= 1, f"Ditemukan {total}, harusnya >= 1")
    except Exception as e:
        test("16. Audit: INSERT kunjungan tercatat", False, str(e))

    # 17. Update obat harus kecatat di audit_log
    try:
        cursor.execute("UPDATE obat SET stok = 90 WHERE id_obat = %s", (id_obat,))
        conn.commit()
        cursor.execute("SELECT COUNT(*) as total FROM audit_log WHERE nama_tabel='obat' AND aksi='UPDATE' AND id_record=%s", (id_obat,))
        total = cursor.fetchone()["total"]
        test("17. Audit: UPDATE stok obat tercatat", total >= 1, f"Ditemukan {total}, harusnya >= 1")
    except Exception as e:
        test("17. Audit: UPDATE stok obat tercatat", False, str(e))

    # 18. Update pasien harus kecatat di audit_log
    try:
        cursor.execute("UPDATE pasien SET kode_jaminan='JKN-PBI' WHERE id_pasien=%s", (id_pasien,))
        conn.commit()
        cursor.execute("SELECT COUNT(*) as total FROM audit_log WHERE nama_tabel='pasien' AND aksi='UPDATE' AND id_record=%s", (id_pasien,))
        total = cursor.fetchone()["total"]
        test("18. Audit: UPDATE pasien tercatat", total >= 1, f"Ditemukan {total}, harusnya >= 1")
    except Exception as e:
        test("18. Audit: UPDATE pasien tercatat", False, str(e))

    # ---------- HASIL AKHIR ----------
    print("\n" + "=" * 60)
    print(f"HASIL: {passed} PASS, {failed} FAIL dari 18 test")
    if failed == 0:
        print("🎉 SEMUA TEST LULUS! Database kamu standar produksi!")
    else:
        print("⚠️ Ada yang gagal, cek pesan FAIL di atas")
    print("=" * 60)

    cursor.close()
    conn.close()

if __name__ == "__main__":
    main()
