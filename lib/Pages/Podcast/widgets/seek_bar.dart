import 'package:flutter/material.dart';

/// A reusable seek bar widget that avoids jitter by keeping a local
/// drag state and only calling [onSeek] when the user finishes dragging.
class SeekBar extends StatefulWidget {
  final double current; // seconds
  final double total; // seconds
  final ValueChanged<double>? onSeek;

  const SeekBar({
    super.key,
    required this.current,
    required this.total,
    this.onSeek,
  });

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;
  bool _isDragging = false;

  String _format(double seconds) {
    final d = Duration(milliseconds: (seconds * 1000).toInt());
    twoDigits(int n) => n.toString().padLeft(2, '0');
    final mm = twoDigits(d.inMinutes.remainder(60));
    final ss = twoDigits(d.inSeconds.remainder(60));
    final hh = d.inHours;
    return hh > 0 ? '$hh:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double total = widget.total > 0 ? widget.total : 1.0;
    final double value = _isDragging
        ? (_dragValue ?? widget.current).clamp(0, total).toDouble()
        : widget.current.clamp(0, total).toDouble();

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: Slider(
            value: value,
            max: total,
            min: 0,
            onChangeStart: (v) {
              setState(() {
                _isDragging = true;
                _dragValue = v;
              });
            },
            onChanged: (v) {
              setState(() {
                _dragValue = v;
              });
            },
            onChangeEnd: (v) {
              // Only call seek when user finishes dragging
              widget.onSeek?.call(v);
              setState(() {
                _isDragging = false;
                _dragValue = null;
              });
            },
            activeColor: colorScheme.primary,
            inactiveColor: colorScheme.surfaceContainerHigh,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _format(value),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
            Text(
              _format(total),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
