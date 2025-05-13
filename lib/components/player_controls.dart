// components/player_controls.dart - Player control buttons
import 'package:flutter/material.dart';

class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool isShuffling;
  final bool isRepeating;
  final VoidCallback onPlayPrevious;
  final VoidCallback onPlayNext;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onToggleShuffle;
  final VoidCallback onToggleRepeat;

  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.isShuffling,
    required this.isRepeating,
    required this.onPlayPrevious,
    required this.onPlayNext,
    required this.onTogglePlayPause,
    required this.onToggleShuffle,
    required this.onToggleRepeat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onToggleShuffle,
          icon: Icon(
            Icons.shuffle,
            color: isShuffling ? Colors.deepPurpleAccent : Colors.white,
          ),
          iconSize: 32,
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: onPlayPrevious,
          icon: const Icon(Icons.skip_previous),
          color: Colors.white,
          iconSize: 40,
        ),
        const SizedBox(width: 16),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onTogglePlayPause,
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.deepPurple,
            ),
            iconSize: 40,
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: onPlayNext,
          icon: const Icon(Icons.skip_next),
          color: Colors.white,
          iconSize: 40,
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: onToggleRepeat,
          icon: Icon(
            Icons.repeat,
            color: isRepeating ? Colors.deepPurpleAccent : Colors.white,
          ),
          iconSize: 32,
        ),
      ],
    );
  }
}