// screens/music_player_page.dart - Main screen containing player logic
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/song.dart';
import '../services/song_service.dart';
import '../utils/audio_helpers.dart';
import '../components/player_view.dart';
import '../components/playlist_view.dart';
import '../components/success_popup.dart';
import '../components/Middle_Popup.dart'; // Assuming this already exists from your original code

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  late AnimationController _animationController;
  bool showPlaylist = false;
  bool _isRefreshing = false;
  bool isShuffling = false;
  bool isRepeating = false;

  // Current song index
  int currentSongIndex = 0;

  // List of songs
  List<Song> songs = [];

  @override
  void initState() {
    super.initState();
    AudioHelpers.enableWakelock();

    // Initialize animation controller for disc rotation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );

    // Set up audio player
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });

      if (isPlaying) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    // Set up player completion listener to play next song
    _audioPlayer.onPlayerComplete.listen((event) {
      _playNextSong();
    });

    // Load fallback songs first
    _loadFallbackSongs();

    // Then try to fetch songs from API
    _fetchSongs();
  }

  void _fetchSongs() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final fetchedSongs = await SongService.fetchSongs();
      setState(() {
        songs = fetchedSongs;
        _isRefreshing = false;
      });
      _showLoadSuccessMessage();
      _loadCurrentSong();
    } catch (e) {
      print('Error fetching songs: $e');
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _loadFallbackSongs() {
    setState(() {
      songs = SongService.getFallbackSongs();
    });
    _loadCurrentSong();
  }

  void _showLoadSuccessMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SuccessPopup(
          message: 'Song List Updated Successfully!',
          onDismiss: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _loadCurrentSong() async {
    if (songs.isEmpty) return;
    
    final Song song = songs[currentSongIndex];
    await _audioPlayer.setSourceUrl(song.url);

    _audioPlayer.onPlayerComplete.listen((event) {
      if (isRepeating) {
        _loadCurrentSong();
        _audioPlayer.resume();
      } else {
        _playNextSong();
      }
    });
  }

  void _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  void _playNextSong() {
    setState(() {
      if (isRepeating) {
        // Play the same song again
        _loadCurrentSong();
      } else if (isShuffling) {
        int nextIndex;
        do {
          nextIndex = (currentSongIndex + 1 + (songs.length - 1) * 
                      (DateTime.now().millisecond % songs.length)) % songs.length;
        } while (nextIndex == currentSongIndex && songs.length > 1);
        currentSongIndex = nextIndex;
      } else {
        currentSongIndex = (currentSongIndex + 1) % songs.length;
      }
    });

    _audioPlayer.stop();
    _loadCurrentSong();
    _audioPlayer.resume();
  }

  void _playPreviousSong() {
    setState(() {
      currentSongIndex = (currentSongIndex - 1 + songs.length) % songs.length;
    });
    _audioPlayer.stop();
    _loadCurrentSong();
    _audioPlayer.resume();
  }

  void _playSong(int index) {
    setState(() {
      currentSongIndex = index;
      showPlaylist = false;
    });
    _audioPlayer.stop();
    _loadCurrentSong();
    _audioPlayer.resume();
  }

  void _toggleShuffle() {
    setState(() {
      isShuffling = !isShuffling;
    });
  }

  void _toggleRepeat() {
    setState(() {
      isRepeating = !isRepeating;
    });
  }

  void _showPopup(BuildContext context) {
    showPopup(context);
  }

  void _seekTo(double value) {
    _audioPlayer.seek(Duration(seconds: value.toInt()));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    AudioHelpers.disableWakelock();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Handle empty songs list
    if (songs.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final Song currentSong = songs[currentSongIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade600,
              Colors.deepPurple.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Main content
              Expanded(
                child: showPlaylist
                    ? PlaylistView(
                        songs: songs,
                        currentSongIndex: currentSongIndex,
                        isPlaying: isPlaying,
                        isRefreshing: _isRefreshing,
                        onBackPressed: () {
                          setState(() {
                            showPlaylist = false;
                          });
                        },
                        onRefresh: _fetchSongs,
                        onSongSelected: _playSong,
                        onTogglePlayPause: _togglePlayPause,
                      )
                    : PlayerView(
                        currentSong: currentSong,
                        isPlaying: isPlaying,
                        isShuffling: isShuffling,
                        isRepeating: isRepeating,
                        position: position,
                        duration: duration,
                        animationController: _animationController,
                        onTogglePlayPause: _togglePlayPause,
                        onPlayPrevious: _playPreviousSong,
                        onPlayNext: _playNextSong,
                        onToggleShuffle: _toggleShuffle,
                        onToggleRepeat: _toggleRepeat,
                        onShowPlaylist: () {
                          setState(() {
                            showPlaylist = true;
                          });
                        },
                        onShowPopup: () => _showPopup(context),
                        onSeek: _seekTo,
                      ),
              ),

              // Copyright Text at the Bottom
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: const [
                      Color.fromARGB(255, 255, 17, 0),
                      Color.fromARGB(255, 255, 123, 0),
                      Colors.yellow,
                      Color.fromARGB(255, 1, 255, 10),
                      Color.fromARGB(255, 40, 0, 185),
                      Color.fromARGB(255, 142, 0, 88),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    '©NipunSGeeTH',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}