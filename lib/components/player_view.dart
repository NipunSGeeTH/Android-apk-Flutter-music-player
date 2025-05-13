// components/player_view.dart - Main player view component
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/song.dart';
import 'progress_bar.dart';
import 'player_controls.dart';

class PlayerView extends StatelessWidget {
  final Song currentSong;
  final bool isPlaying;
  final bool isShuffling;
  final bool isRepeating;
  final Duration position;
  final Duration duration;
  final AnimationController animationController;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onPlayPrevious;
  final VoidCallback onPlayNext;
  final VoidCallback onToggleShuffle;
  final VoidCallback onToggleRepeat;
  final VoidCallback onShowPlaylist;
  final VoidCallback onShowPopup;
  final Function(double) onSeek;

  const PlayerView({
    super.key,
    required this.currentSong,
    required this.isPlaying,
    required this.isShuffling,
    required this.isRepeating,
    required this.position,
    required this.duration,
    required this.animationController,
    required this.onTogglePlayPause,
    required this.onPlayPrevious,
    required this.onPlayNext,
    required this.onToggleShuffle,
    required this.onToggleRepeat,
    required this.onShowPlaylist,
    required this.onShowPopup,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop'); // Minimizes the app
                },
                icon: const Icon(Icons.arrow_back_ios),
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
              const Text(
                "NOW PLAYING",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: onShowPlaylist,
                icon: const Icon(Icons.queue_music),
                color: Colors.white,
              ),
            ],
          ),
        ),

        const Spacer(),

        // Album art
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: GestureDetector(
            onTap: onShowPopup,
            child: RotationTransition(
              turns: animationController,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage(currentSong.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),

        const Spacer(),

        // Song info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Text(
                currentSong.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                currentSong.artist,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Progress bar
        ProgressBar(
          position: position,
          duration: duration,
          onChanged: onSeek,
        ),

        const SizedBox(height: 24),

        // Controls
        PlayerControls(
          isPlaying: isPlaying,
          isShuffling: isShuffling,
          isRepeating: isRepeating,
          onPlayPrevious: onPlayPrevious,
          onPlayNext: onPlayNext,
          onTogglePlayPause: onTogglePlayPause,
          onToggleShuffle: onToggleShuffle,
          onToggleRepeat: onToggleRepeat,
        ),
        
        const SizedBox(height: 48),
      ],
    );
  }
}