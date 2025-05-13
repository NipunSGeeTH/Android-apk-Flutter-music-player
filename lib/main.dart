// ignore_for_file: deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'components/Middle_Popup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const MusicPlayerPage(),
    );
  }
}

class Song {
  final String title;
  final String artist;
  final String url;
  final String imageUrl;

  const Song({
    required this.title,
    required this.artist,
    required this.url,
    required this.imageUrl,
  });
}

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

  // Current song index
  int currentSongIndex = 0;

  // List of songs
  List<Song> songs = [];

  Future<void> _fetchSongs() async {
    // List of URLs to try in order
    final List<String> urlsToTry = [
      'https://dms.uom.lk/s/sgCYer8cL7MfssS/download',
      'https://nipunsgeeth.github.io/songs.json',
    ];

    List<Song> allFetchedSongs =
        []; // To accumulate songs from all successful URLs
    bool anySuccess = false; // To track if at least one URL was successful

    // Try each URL in sequence
    for (final url in urlsToTry) {
      try {
        // Try to fetch with a 2-second timeout
        final response = await http
            .get(Uri.parse(url))
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                print('Request timed out for $url');
                return http.Response('Timeout', 408);
              },
            );

        if (response.statusCode == 200) {
          try {
            final List<dynamic> jsonData = json.decode(response.body);
            List<Song> currentUrlSongs =
                jsonData
                    .map(
                      (songData) => Song(
                        title: songData['title'],
                        artist: songData['artist'],
                        url: songData['url'],
                        imageUrl: songData['imageUrl'],
                      ),
                    )
                    .toList();

            if (currentUrlSongs.isNotEmpty) {
              allFetchedSongs.addAll(
                currentUrlSongs,
              ); // Add songs from this URL to the list
              anySuccess = true; // Mark as successful for at least one URL
              print('Successfully loaded songs from $url');
            } else {
              print('No songs found in JSON from $url');
            }
          } catch (e) {
            print('Error parsing JSON from $url: $e');
            // Continue to next URL if JSON parsing fails
          }
        } else {
          print('Failed to load songs from $url: ${response.statusCode}');
          // Continue to next URL if status code is not 200
        }
      } catch (e) {
        print('Error fetching songs from $url: $e');
        // Continue to next URL if request fails
      }
    }

    // After trying all URLs, update the state if any songs were loaded
    if (anySuccess) {
      setState(() {
        songs = allFetchedSongs; // Set songs to all accumulated songs
        _showLoadSuccessMessage();
      });
      _loadCurrentSong(); // Load current song after updating songs list
    } else {
      // If none of the URLs worked, load fallback songs
      print('All URLs failed or returned no songs, loading fallback songs');
      _loadFallbackSongs();
    }
  }

  // Add a fallback method that loads some default songs if API fails
  void _loadFallbackSongs() {
    setState(() {
      songs = [
        const Song(
          title: "Kolompure Nuba Inna Isawwe",
          artist: "Samitha Mudunkotuwa",
          url:
              "https://tg-filetolink.sangeethnipun.workers.dev/?file=MTIzNTkwMjYyNDMwMjM4Ni8zMzc3NDU4&mode=inline",
          imageUrl: "assets/images/logo.png",
        ),
        // Add at least one fallback song
      ];
    });
    _loadCurrentSong();
  }

  Future<void> enableWakelock() async {
    try {
      await WakelockPlus.enable();
      // You can also use this to check if wakelock is enabled
      final isEnabled = await WakelockPlus.enabled;
      print('Wakelock is enabled: $isEnabled');
    } catch (e) {
      print('Error enabling wakelock: $e');
    }
  }

  // Call this when stopping media playback
  Future<void> disableWakelock() async {
    try {
      await WakelockPlus.disable();
    } catch (e) {
      print('Error disabling wakelock: $e');
    }
  }

  void _showLoadSuccessMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(
              milliseconds: 300,
            ), // Shorter duration for smoother appearance
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueAccent.withOpacity(0.9),
                      Colors.purpleAccent.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 15.0,
                      spreadRadius: 2.0,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 60),
                    SizedBox(height: 15),
                    Text(
                      'Song List Updated Successfully!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // Fade out after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

 
  @override
  void initState() {
    super.initState();
    enableWakelock();

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

    // Fetch songs from API
    _loadFallbackSongs();

    // Then try to fetch songs from API
    _fetchSongs();
  }

  bool _isRefreshing = false;
  bool isShuffling = false;
  bool isRepeating = false;

  void _loadCurrentSong() async {
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
          nextIndex =
              (currentSongIndex +
                  1 +
                  (songs.length - 1) *
                      (DateTime.now().millisecond % songs.length)) %
              songs.length;
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

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              Colors
                  .deepPurple
                  .shade400, // Slightly lighter to give a smoother gradient
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween, // Ensure the bottom text is at the bottom
            children: [
              // Main content
              Expanded(
                child:
                    showPlaylist
                        ? _buildPlaylist()
                        : _buildPlayerView(currentSong),
              ),

              // Copyright Text at the Bottom
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 255, 17, 0),
                          const Color.fromARGB(255, 255, 123, 0),
                          Colors.yellow,
                          const Color.fromARGB(255, 1, 255, 10),
                          const Color.fromARGB(255, 40, 0, 185),
                          const Color.fromARGB(255, 142, 0, 88),
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

  Widget _buildPlayerView(Song currentSong) {
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
                  SystemChannels.platform.invokeMethod(
                    'SystemNavigator.pop',
                  ); // Minimizes the app
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
                onPressed: () {
                  setState(() {
                    showPlaylist = true;
                  });
                },
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
            onTap: () {
              // Show popup when the user taps on the album art
              showPopup(context);
            },
            child: RotationTransition(
              turns: _animationController,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4.0,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6.0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14.0,
                  ),
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withOpacity(0.2),
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withOpacity(0.2),
                ),
                child: Slider(
                  value: position.inSeconds.toDouble(),
                  max:
                      duration.inSeconds.toDouble() > 0
                          ? duration.inSeconds.toDouble()
                          : 1.0,
                  onChanged: (value) {
                    _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTime(position),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      formatTime(duration),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  isShuffling = !isShuffling;
                });
              },
              icon: Icon(
                Icons.shuffle,
                color: isShuffling ? Colors.deepPurpleAccent : Colors.white,
              ),
              iconSize: 32,
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: _playPreviousSong,
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
                onPressed: _togglePlayPause,
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.deepPurple,
                ),
                iconSize: 40,
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: _playNextSong,
              icon: const Icon(Icons.skip_next),
              color: Colors.white,
              iconSize: 40,
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () {
                setState(() {
                  isRepeating = !isRepeating;
                });
              },
              icon: Icon(
                Icons.repeat,
                color: isRepeating ? Colors.deepPurpleAccent : Colors.white,
              ),
              iconSize: 32,
            ),
          ],
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildPlaylist() {
    return Column(
      children: [
        // Playlist header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Add this line
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    showPlaylist = false;
                  });
                },
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
                onPressed: () {
                  setState(() {
                    _isRefreshing = true;
                  });
                  _fetchSongs();

                  // Auto-stop the animation after 2 seconds
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                       _isRefreshing = false;
                      });
                    }
                  });
                },
                icon: AnimatedRotation(
                  turns: _isRefreshing ? 1 : 0,
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
                onTap: () => _playSong(index),

                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image(
                    image: AssetImage(
                      song.imageUrl,
                    ), // ✅ Correct instance access
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  song.title,
                  style: TextStyle(
                    color:
                        isCurrentSong
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
                trailing:
                    isCurrentSong && isPlaying
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
                  onPressed: _togglePlayPause,
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
