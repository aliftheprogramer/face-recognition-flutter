import 'package:flutter/material.dart';
import '../widget/form_register.dart';
import '../widget/form_login.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _showRegister = true;

  void _toggle() => setState(() => _showRegister = !_showRegister);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFC2D8FC), // warna biru muda atas
          child: Column(
            children: [
              const SizedBox(height: 80),
              // Logo di tengah atas
              Image.asset(
                'face.png',
                width: 103,
                height: 103,
              ),
              const Spacer(),

              // Bagian bawah: form putih melengkung (no animation) — langsung pindah
              _showRegister
                  ? FormRegister(onSwitch: _toggle)
                  : FormLogin(onSwitch: _toggle),
            ],
          ),
        ),
      ),
    );
  }
}
