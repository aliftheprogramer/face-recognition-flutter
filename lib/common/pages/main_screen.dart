
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gii_dace_recognition/common/bloc/navigation/navigation_cubit.dart';
import 'package:gii_dace_recognition/widget/bottom_navigator_widget.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita bungkus dengan BlocProvider agar BottomNavigatorWidget bisa akses Cubitnya
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: Scaffold(
        // Body akan berubah sesuai state index
        body: BlocBuilder<NavigationCubit, NavigationState>(
          builder: (context, state) {
            if (state.tab == NavigationTab.beranda) {
              return const Center(child: Text("Halaman Beranda"));
            } else if (state.tab == NavigationTab.aktivitas) {
              return const Center(child: Text("Halaman Aktivitas"));
            } else {
              return const Center(child: Text("Halaman Profil"));
            }
          },
        ),
        // Ini Widget Navigasi yang baru kita buat
        bottomNavigationBar: const BottomNavigatorWidget(),
      ),
    );
  }
}
