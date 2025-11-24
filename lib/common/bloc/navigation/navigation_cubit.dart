//lib/common/bloc/navigation/navigation_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

part 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState());

  void getNavBarItem(int index) {
    switch (index) {
      case 0:
        emit(const NavigationState(tab: NavigationTab.beranda, index: 0));
        break;
      case 1:
        emit(const NavigationState(tab: NavigationTab.aktivitas, index: 1));
        break;
      case 2:
        emit(const NavigationState(tab: NavigationTab.profil, index: 2));
        break;
    }
  }
}