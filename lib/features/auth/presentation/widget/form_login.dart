import 'package:flutter/material.dart';

import '../../../../widget/input_field.dart';
import '../../../../widget/primary_button.dart';
import '../../../scan_wajah/presentation/pages/start_scan.dart';

class FormLogin extends StatelessWidget {
  final VoidCallback? onSwitch;

  const FormLogin({super.key, this.onSwitch});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(34),
          topRight: Radius.circular(34),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        
        children: [
          const SizedBox(height: 12),
          const Text(
            'Selamat Datang',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Masukkan detail akunmu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),

          const InputField(
            label: 'Email',
            hintText: 'Masukkan email',
          ),
          const SizedBox(height: 16),
          const InputField(
            label: 'Kata Sandi',
            hintText: 'Masukan kata sandi',
            obscureText: true,
          ),
          const SizedBox(height: 16),
          const InputField(
            label: 'Konfirmasi Kata Sandi',
            hintText: 'Masukan ulang kata sandi',
            obscureText: true,
          ),
          const SizedBox(height: 24),

          // Tombol lanjut
          PrimaryButton(
            text: 'Lanjut',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const StartScan()));
            },
          ),
          const SizedBox(height: 110),

          // Teks login di bawah
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Belum punya akun? '),
              GestureDetector(
                onTap: onSwitch,
                child: const Text(
                  'Buat Akun',
                  style: TextStyle(
                    color: Color(0xFF2D64F0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}