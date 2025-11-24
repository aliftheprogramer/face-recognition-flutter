//lib/common/bloc/navigation/navigation_state.dart

part of 'navigation_cubit.dart';

enum NavigationTab { beranda, aktivitas, profil }

class NavigationState {
  final NavigationTab tab;
  final int index;

  const NavigationState({this.tab = NavigationTab.beranda, this.index = 0});

  NavigationState copyWith({NavigationTab? tab, int? index}) {
    return NavigationState(tab: tab ?? this.tab, index: index ?? this.index);
  }
}
