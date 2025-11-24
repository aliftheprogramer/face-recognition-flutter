import 'package:flutter/material.dart';
import 'package:gii_dace_recognition/features/auth/presentation/pages/auth_page.dart';
import 'package:gii_dace_recognition/widget/primary_button.dart';
import 'package:gii_dace_recognition/widget/secondary_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih sesuai desain
      body: SafeArea(
        child: Padding(
          // Memberikan jarak di sisi kiri, kanan, dan bawah
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            children: [
              // Spacer ini mendorong konten logo ke tengah vertikal
              const Spacer(),

              // --- Bagian Logo & Judul ---
              Image.asset(
                'assets/face.png',
                width: 150, // Sesuaikan ukuran dengan preferensi
                height: 150,
              ),
              const SizedBox(height: 32), // Jarak antara gambar dan teks
              const Text(
                'Face Recognition',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Warna teks hitam pekat
                ),
              ),

              // Spacer ini mendorong tombol ke bagian bawah layar
              const Spacer(),

              // --- Bagian Tombol ---

              // Tombol Biru (Scan Wajah)
              PrimaryButton(
                text: 'Masuk dengan scan wajah',
                // Menggunakan ikon bawaan Flutter yang mirip dengan ikon scan
                icon: const Icon(Icons.center_focus_strong_outlined),
                onPressed: () {
                  debugPrint("Tombol Scan Wajah ditekan");
                },
              ),

              const SizedBox(height: 16), // Jarak antar tombol
              // Tombol Outline (Email/Google)
              SecondaryButton(
                text: 'Masuk dengan email',
                // Saya menggunakan ikon email standard.
                // Jika ingin ikon Google warna-warni, kamu perlu menggunakan Image.asset di sini.
                icon: Image.asset(
                  'assets/google_icon.png', // Ganti ini jika kamu punya aset ikon Google
                  height: 20,
                  // Jika tidak punya aset Google, ganti baris ini dengan:
                  // icon: const Icon(Icons.mail_outline),
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.mail_outline),
                ),
                // Menyesuaikan warna border agar biru muda seperti di gambar
                borderColor: const Color(0xFFBFDBFE),
                foregroundColor: const Color(0xFF3B82F6), // Warna teks biru
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AuthPage()),
                  );
                },
              ),

              const SizedBox(height: 24), // Jarak tambahan di paling bawah
            ],
          ),
        ),
      ),
    );
  }
}
