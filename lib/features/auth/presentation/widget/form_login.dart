import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../widget/input_field.dart';
import '../../../../widget/primary_button.dart';
import '../../../scan_wajah/presentation/pages/start_scan.dart';
import '../cubit/login/login_cubit.dart';
import '../cubit/login/login_state.dart';

class FormLogin extends StatelessWidget {
  final VoidCallback? onSwitch;

  const FormLogin({super.key, this.onSwitch});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.status == LoginStatus.success) {
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 8),
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
                                  const SizedBox(height: 16),

                                  InputField(
                                    label: 'Email',
                                    hintText: 'Masukkan email',
                                    onChanged: (v) => context
                                        .read<LoginCubit>()
                                        .emailChanged(v),
                                  ),
                                  const SizedBox(height: 12),
                                  InputField(
                                    label: 'Kata Sandi',
                                    hintText: 'Masukan kata sandi',
                                    obscureText: true,
                                    onChanged: (v) => context
                                        .read<LoginCubit>()
                                        .passwordChanged(v),
                                  ),
                                  const SizedBox(height: 16),

                                  // Tombol lanjut
                                  BlocBuilder<LoginCubit, LoginState>(
                                    builder: (context, state) {
                                      return PrimaryButton(
                                        text:
                                            state.status == LoginStatus.loading
                                            ? 'Memproses...'
                                            : 'Masuk',
                                        onPressed:
                                            state.status == LoginStatus.loading
                                            ? null
                                            : () {
                                                context
                                                    .read<LoginCubit>()
                                                    .submit();
                                              },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
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
          },
        ),
      ),
    );
  }
}
