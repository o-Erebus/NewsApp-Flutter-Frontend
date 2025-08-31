// lib/Pages/_common_widgets/skeleton_loaders/min_display_time_wrapper.dart
import 'package:flutter/material.dart';

/// A widget that ensures its child is displayed for a minimum amount of time
/// to prevent flashing effects during quick loading scenarios
class MinDisplayTimeWrapper extends StatefulWidget {
  final Widget child;
  final Duration minDisplayTime;
  final Duration? actualLoadingTime;

  const MinDisplayTimeWrapper({
    super.key,
    required this.child,
    this.minDisplayTime = const Duration(milliseconds: 500),
    this.actualLoadingTime,
  });

  @override
  State<MinDisplayTimeWrapper> createState() => _MinDisplayTimeWrapperState();
}

class _MinDisplayTimeWrapperState extends State<MinDisplayTimeWrapper> {
  late Future<void> _delayFuture;

  @override
  void initState() {
    super.initState();
    _delayFuture = _createDelayFuture();
  }

  Future<void> _createDelayFuture() async {
    // If we have actual loading time, calculate remaining delay
    if (widget.actualLoadingTime != null) {
      final remainingTime = widget.minDisplayTime - widget.actualLoadingTime!;
      if (remainingTime > Duration.zero) {
        await Future.delayed(remainingTime);
      }
    } else {
      // Otherwise, just wait for the minimum display time
      await Future.delayed(widget.minDisplayTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _delayFuture,
      builder: (context, snapshot) {
        // Always show the child (skeleton loader)
        // The future ensures it stays visible for the minimum time
        return widget.child;
      },
    );
  }
}