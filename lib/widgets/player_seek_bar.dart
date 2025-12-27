import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';

class PlayerSeekBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const PlayerSeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  State<PlayerSeekBar> createState() => _PlayerSeekBarState();
}

class _PlayerSeekBarState extends State<PlayerSeekBar> {
  bool _dragging = false;
  double _dragValue = 0;

  @override
  Widget build(BuildContext context) {
    final max = widget.duration.inSeconds.toDouble();
    final value = _dragging
        ? _dragValue
        : widget.position.inSeconds.clamp(0, max).toDouble();

    // 🚨 AUTO NEXT
    if (!_dragging &&
        widget.duration.inSeconds > 0 &&
        widget.position >= widget.duration) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PlayerProvider>().next();
      });
    }

    return Column(
      children: [
        Slider(
          min: 0,
          max: max > 0 ? max : 1,
          value: value,
          activeColor: Colors.greenAccent,
          inactiveColor: Colors.white38,
          onChangeStart: (v) {
            _dragging = true;
            _dragValue = v;
          },
          onChanged: (v) => setState(() => _dragValue = v),
          onChangeEnd: (v) {
            _dragging = false;
            widget.onSeek(Duration(seconds: v.toInt()));
          },
        ),

        /// TIME LABELS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_format(widget.position),
                  style: const TextStyle(color: Colors.white70)),
              Text(_format(widget.duration),
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ],
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}
