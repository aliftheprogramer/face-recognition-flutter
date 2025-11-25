import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gii_dace_recognition/features/profile/presentation/widget/item_profile_widget.dart';
import 'dart:convert';
import '../../../../core/services/services_locator.dart';
import '../../../auth/data/source/auth_local_service.dart';
import '../../../auth/data/source/auth_api_service.dart';
import '../../../../core/constant/api_urls.dart';
import 'package:gii_dace_recognition/features/scan_wajah/presentation/pages/start_scan.dart';
// Pastikan path import ini sesuai dengan struktur folder kamu
// import 'path/to/item_profile_widget.dart';

// Jika file item_profile_widget.dart berada di folder yang berbeda,
// kamu bisa meng-copy class ItemProfileWidget di atas ke file ini juga sementara waktu agar tidak error.

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _user;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    // Load cached user immediately and then fetch fresh profile
    final userJson = sl<AuthLocalService>().getUserJson();
    if (userJson != null) {
      try {
        _user = jsonDecode(userJson) as Map<String, dynamic>;
      } catch (_) {
        _user = null;
      }
      _computeAvatarFromUser();
    }
    _fetchProfile();
  }

  void _computeAvatarFromUser() {
    if (_user == null) return;
    // prefer avatar/photo fields, otherwise check faces array
    final avatar = _user!['avatar'] ?? _user!['photo'] ?? _user!['photo_url'];
    if (avatar != null && avatar is String && avatar.isNotEmpty) {
      _avatarUrl = avatar;
      return;
    }
    try {
      final faces = _user!['faces'];
      if (faces is List && faces.isNotEmpty) {
        final first = faces.first;
        final fp = first['filepath'] as String?;
        if (fp != null && fp.isNotEmpty) {
          final base = ApiUrls.baseUrl.replaceFirst('/api/v1', '');
          _avatarUrl = fp.startsWith('http') ? fp : '$base/$fp';
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchProfile() async {
    try {
      final api = sl<AuthApiService>();
      final res = await api.getProfile();
      final data = res.data;
      if (data is Map) {
        // The API returns user object as shown in sample. Save and use it.
        _user = Map<String, dynamic>.from(data);
        _computeAvatarFromUser();
        // persist locally so other parts can read cached user
        try {
          await sl<AuthLocalService>().saveUserJson(jsonEncode(_user));
        } catch (_) {}
        if (mounted) setState(() {});
      }
    } catch (e) {
      // ignore errors and keep cached user
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        _user?['username']?.toString() ??
        _user?['name']?.toString() ??
        _user?['fullname']?.toString() ??
        'Nama Pengguna';
    final avatarUrl = _avatarUrl;

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
          // Menggunakan RefreshIndicator + SingleChildScrollView agar bisa di-pull-to-refresh
          RefreshIndicator(
            onRefresh: _fetchProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
