import 'package:flutter/material.dart';
import 'package:myflutterapp/models/song.dart';
import '../main.dart'; // For Song class. If you move Song to models/song.dart, import that instead.

class PlaylistWidget extends StatelessWidget {
  final List<Song> songs;
  final int currentSongIndex;
  final bool isPlaying;
  final bool isRefreshing;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final Function(int) onSongTap;
  final VoidCallback onPlayPause;

  const PlaylistWidget({
    super.key,
    required this.songs,
    required this.currentSongIndex,
    required this.isPlaying,
    required this.isRefreshing,
    required this.onBack,
    required this.onRefresh,
    required this.onSongTap,
    required this.onPlayPause,
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
                onPressed: onBack,
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
                onTap: () => onSongTap(index),
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
                    color: isCurrentSong
                        ? Colors.deepPurple.shade200
                        : Colors.white,
                    fontWeight:
                        isCurrentSong ? FontWeight.bold : FontWeight.normal,
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
          Container(
            color: Colors.black26,
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    songs[currentSongIndex].imageUrl,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        songs[currentSongIndex].title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        songs[currentSongIndex].artist,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onPlayPause,
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}