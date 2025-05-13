// components/playlist_view.dart - Playlist view component
import 'package:flutter/material.dart';
import '../models/song.dart';
import 'mini_player.dart';

class PlaylistView extends StatelessWidget {
  final List<Song> songs;
  final int currentSongIndex;
  final bool isPlaying;
  final bool isRefreshing;
  final VoidCallback onBackPressed;
  final VoidCallback onRefresh;
  final Function(int) onSongSelected;
  final VoidCallback onTogglePlayPause;

  const PlaylistView({
    super.key,
    required this.songs,
    required this.currentSongIndex,
    required this.isPlaying,
    required this.isRefreshing,
    required this.onBackPressed,
    required this.onRefresh,
    required this.onSongSelected,
    required this.onTogglePlayPause,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Playlist header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onBackPressed,
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
              ),
              const Text(
                "PLAYLIST",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: AnimatedRotation(
                  turns: isRefreshing ? 1 : 0,
                  duration: const Duration(seconds: 2),
                  child: const Icon(Icons.refresh),
                ),
                color: Colors.white,
              ),
            ],
          ),
        ),

        // Song list
        Expanded(
          child: ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              final isCurrentSong = index == currentSongIndex;

              return ListTile(
                onTap: () => onSongSelected(index),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image(
                    image: AssetImage(song.imageUrl),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  song.title,
                  style: TextStyle(
                    color: isCurrentSong ? Colors.deepPurple.shade200 : Colors.white,
                    fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  song.artist,
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                trailing: isCurrentSong && isPlaying
                    ? const Icon(Icons.volume_up, color: Colors.deepPurple)
                    : null,
              );
            },
          ),
        ),

        // Now playing mini player
        if (isPlaying)
          MiniPlayer(
            currentSong: songs[currentSongIndex],
            isPlaying: isPlaying,
            onTogglePlayPause: onTogglePlayPause,
          ),
      ],
    );
  }
}