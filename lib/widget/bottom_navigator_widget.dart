//lib/features/auth/presentation/cubit/login/login_cubit.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gii_dace_recognition/common/bloc/navigation/navigation_cubit.dart';

class BottomNavigatorWidget extends StatelessWidget {
  const BottomNavigatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        return Container(
          // Memberikan sedikit bayangan (shadow) di atas agar terlihat manis
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
            ],
          ),
          child: BottomNavigationBar(
            // Mengatur tipe agar teks selalu muncul jika diperlukan
            type: BottomNavigationBarType.fixed,
            // Menghilangkan garis batas default di atas bottom bar
            elevation: 0,
            backgroundColor: Colors.white,

            // Mengambil index dari State Cubit kita
            currentIndex: state.index,

            // Warna saat item dipilih (Biru sesuai gambar)
            selectedItemColor: Colors.blue,
            // Warna saat item tidak dipilih (Abu-abu/Biru tua pudar)
            unselectedItemColor: Colors.blueGrey,

            // Ukuran font label
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),

            // Fungsi yang dijalankan saat item diklik
            onTap: (index) {
              context.read<NavigationCubit>().getNavBarItem(index);
            },

            // Daftar Menu
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(
                  Icons.home,
                ), // Ikon saat aktif (opsional bisa dibuat solid)
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_activity_outlined),
                activeIcon: Icon(Icons.local_activity),
                label: 'Aktivitas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }
}
