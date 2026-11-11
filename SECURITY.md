# Keamanan

## Jangan Laporkan Data Pasien Asli di Issue Publik
Jangan pernah upload nama pasien, NIK, No. RM, No. BPJS, backup database, credential DB, file .key / .pem ke GitHub Issue.

## Melaporkan Celah Keamanan
Hubungi pemilik repo melalui GitHub secara privat.
Jelaskan: file yang bermasalah, langkah reproduksi, dan dampaknya.

## Prinsip
- Data pasien asli tidak pernah disimpan di repo ini, hanya kode anonim `PAS-001` + hash SHA-256.
- Backup DB asli diblokir oleh `.gitignore`.
- Produksi RS wajib: enkripsi, audit log, backup terenkripsi, akses berbasis peran (RBAC).
- Skema ini demo portfolio, bukan sistem produksi RS.
