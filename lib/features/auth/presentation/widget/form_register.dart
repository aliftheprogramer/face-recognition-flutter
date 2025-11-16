import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../widget/input_field.dart';
import '../../../../widget/primary_button.dart';
import '../../../scan_wajah/presentation/pages/start_scan.dart';
import '../cubit/register/register_cubit.dart';
import '../cubit/register/register_state.dart';

class FormRegister extends StatelessWidget {
  final VoidCallback? onSwitch;

  const FormRegister({super.key, this.onSwitch});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(),
      child: BlocListener<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state.status == RegisterStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.status == RegisterStatus.success) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StartScan()),
            );
          }
        },
        child: Builder(
          builder: (context) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(34),
                    topRight: Radius.circular(34),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: [
                          const SizedBox(height: 8),
                          const Text(
                            'Buat Akunmu',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Masukkan data diri kamu',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Form input
                          InputField(
                            label: 'Nama Pengguna',
                            hintText: 'Masukkan namamu',
                            onChanged: (v) => context
                                .read<RegisterCubit>()
                                .usernameChanged(v),
                          ),
                          const SizedBox(height: 12),
                          InputField(
                            label: 'Email',
                            hintText: 'Masukkan email',
                            onChanged: (v) =>
                                context.read<RegisterCubit>().emailChanged(v),
                          ),
                          const SizedBox(height: 12),
                          InputField(
                            label: 'Kata Sandi',
                            hintText: 'Masukan kata sandi',
                            obscureText: true,
                            onChanged: (v) => context
                                .read<RegisterCubit>()
                                .passwordChanged(v),
                          ),
                          const SizedBox(height: 12),
                          InputField(
                            label: 'Konfirmasi Kata Sandi',
                            hintText: 'Masukan ulang kata sandi',
                            obscureText: true,
                            onChanged: (v) => context
                                .read<RegisterCubit>()
                                .confirmPasswordChanged(v),
                          ),
                          const SizedBox(height: 16),

                          // Tombol lanjut
                          BlocBuilder<RegisterCubit, RegisterState>(
                            builder: (context, state) {
                              return PrimaryButton(
                                text: state.status == RegisterStatus.loading
                                    ? 'Memproses...'
                                    : 'Daftar',
                                onPressed:
                                    state.status == RegisterStatus.loading
                                    ? null
                                    : () {
                                        context.read<RegisterCubit>().submit();
                                      },
                              );
                            },
                          ),
                          const SizedBox(height: 30),

                          // Teks login di bawah
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Sudah punya akun? '),
                          GestureDetector(
                            onTap: onSwitch,
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                color: Color(0xFF2D64F0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
