import 'package:flutter/widgets.dart';

/// Small lifecycle helper that delegates app lifecycle events to callbacks.
class LifecycleHandler extends StatefulWidget {
  final Widget child;
  final VoidCallback? onResume;
  final VoidCallback? onPause;
  final VoidCallback? onDispose;

  const LifecycleHandler({
    required this.child,
    this.onResume,
    this.onPause,
    this.onDispose,
    super.key,
  });

  @override
  State<LifecycleHandler> createState() => _LifecycleHandlerState();
}

class _LifecycleHandlerState extends State<LifecycleHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      widget.onPause?.call();
    } else if (state == AppLifecycleState.resumed) {
      widget.onResume?.call();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
