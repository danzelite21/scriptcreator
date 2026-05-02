# ScriptCreator

FiveM admin resource untuk mengelola NPC, Blip, Marker, Item, Image, audit log, dan export Lua.

## Fitur
- Permission admin hanya melalui ACE atau tabel admin MySQL
- CRUD NPC, Blip, Marker, Item, Image
- Render blip dan marker otomatis di dunia permainan
- Integrasi `ox_inventory` untuk memberikan item
- NUI tab interface dengan menu, export, audit log, dan manajemen admin
- Export otomatis ke `scriptcreator_export.lua` saat resource start
- Penyimpanan persisten di MySQL

## Requirement
- `oxmysql`
- `ox_inventory`

## Cara pasang
1. Taruh folder `shared` di dalam folder resource server kamu.
2. Tambahkan resource di `server.cfg`:
   ```txt
   ensure scriptcreator
   ```
3. Tambahkan permission ACE untuk admin di `server.cfg`:
   ```txt
   add_ace group.admin scriptcreator.admin allow
   add_principal identifier.steam:110000112345678 group.admin
   ```
   Atau jalankan file bantuan ACE ini jika ingin menyimpan konfigurasi di resource:
   ```txt
   exec resources/[standalone]/scriptcreator/permissions.cfg
   ```
4. Atau tambahkan admin ke tabel MySQL `scriptcreator_admins` secara manual.

## Perintah
- `/scriptcreator` untuk buka menu
- Tekan `M` untuk buka menu juga

## Catatan database
Skrip akan otomatis membuat tabel MySQL saat resource dijalankan.

## Export
File export Lua akan dibuat/diupdate di root resource dengan nama `scriptcreator_export.lua`.
