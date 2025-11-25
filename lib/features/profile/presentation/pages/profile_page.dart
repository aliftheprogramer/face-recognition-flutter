import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gii_dace_recognition/features/profile/presentation/widget/item_profile_widget.dart';
import 'dart:convert';
import '../../../../core/services/services_locator.dart';
import '../../../auth/data/source/auth_local_service.dart';
import 'package:gii_dace_recognition/features/scan_wajah/presentation/pages/start_scan.dart';
// Pastikan path import ini sesuai dengan struktur folder kamu
// import 'path/to/item_profile_widget.dart';

// Jika file item_profile_widget.dart berada di folder yang berbeda,
// kamu bisa meng-copy class ItemProfileWidget di atas ke file ini juga sementara waktu agar tidak error.

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userJson = sl<AuthLocalService>().getUserJson();
    Map<String, dynamic>? user;
    if (userJson != null) {
      try {
        user = jsonDecode(userJson) as Map<String, dynamic>;
      } catch (_) {
        user = null;
      }
    }

    final displayName =
        user?['name']?.toString() ??
        user?['fullname']?.toString() ??
        'Nama Pengguna';
    final avatarUrl = user?['avatar'] ?? user?['photo'] ?? user?['photo_url'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- LAYER 1: Header Background ---
          // Bagian atas yang berwarna biru/gambar taman
          Container(
            height: 240,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backgroundprofile.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // --- LAYER 2: Back Button ---
          Positioned(
            top: 50, // Sesuaikan dengan status bar
            left: 24,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF3B82F6), // Tombol biru bulat
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // --- LAYER 3: Konten Putih (Scrollable) ---
          // Menggunakan SingleChildScrollView agar bisa di-scroll
          SingleChildScrollView(
            // Padding top dibuat besar supaya konten mulai DI BAWAH header
            padding: const EdgeInsets.only(top: 200),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // Jarak kosong untuk memberi ruang bagi foto profil yang menumpuk
                  const SizedBox(height: 60),

                  // Nama User
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- GROUP MENU 1 ---
                  _buildMenuContainer(
                    children: [
                      ItemProfileWidget(
                        icon: Icons.person_outline,
                        title: 'Edit Profil',
                        onTap: () {},
                      ),
                      ItemProfileWidget(
                        icon: Icons.location_on_outlined,
                        title: 'Alamat',
                        showDivider: false, // Item terakhir di grup
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- GROUP MENU 2 ---
                  _buildMenuContainer(
                    children: [
                      ItemProfileWidget(
                        icon: Icons.notifications_none_outlined,
                        title: 'Notifikasi',
                        onTap: () {},
                      ),
                      ItemProfileWidget(
                        icon: Icons.vpn_key_outlined, // Ikon kunci/sandi
                        title: 'Sandi',
                        onTap: () {},
                      ),
                      ItemProfileWidget(
                        icon: Icons.translate,
                        title: 'Bahasa',
                        onTap: () {},
                      ),
                      ItemProfileWidget(
                        icon: Icons.logout,
                        title: 'Keluar Akun',
                        showDivider: false,
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 40), // Jarak bawah
                ],
              ),
            ),
          ),

          // --- LAYER 4: Foto Profil ---
          // Diletakkan paling bawah di Stack (artinya paling depan secara visual)
          // tapi posisinya dihitung manual agar pas di tengah garis batas.
          Positioned(
            top: 150, // 200 (mulai box putih) - 50 (setengah tinggi foto)
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  // Lingkaran Foto
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: avatarUrl != null
                          ? Image.network(
                              avatarUrl.toString(),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const ColoredBox(
                                color: Colors.grey,
                                child: Center(
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : const ColoredBox(
                              color: Colors.grey,
                              child: Center(
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                            ),
                    ),
                  ),
                  // Ikon Edit (Pensil)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const StartScan()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper untuk membungkus grup menu (Card Putih dengan Border)
  Widget _buildMenuContainer({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)), // Border abu tipis
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
