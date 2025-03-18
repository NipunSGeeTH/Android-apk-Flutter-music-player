import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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

class _MusicPlayerPageState extends State<MusicPlayerPage> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  late AnimationController _animationController;
  bool showPlaylist = false;
  
  // Current song index
  int currentSongIndex = 0;
  
  // List of songs
  final List<Song> songs = [
    const Song(
      title: "Kolompure Nuba Inna Isawwe",
      artist: "Samitha Mudunkotuwa",
      url: "https://songlanka.sgp1.digitaloceanspaces.com/mp3/Kolompure Nuba Inna Isawwe - Samitha Mudunkotuwa [SONG.LK].mp3",
      imageUrl: "assets/images/logo.png",
    ),
    const Song(
      title: "Shape of You",
      artist: "Ed Sheeran",
      url: "https://songlanka.sgp1.digitaloceanspaces.com/mp3/Mal Nani Man - Samitha Mudunkotuwa [SONG.LK].mp3", // Replace with actual URL
      imageUrl: "assets/images/logo.png",
    ),
    const Song(
      title: "Blinding Lights",
      artist: "The Weeknd",
      url: "https://song.lk/mp3/song/getsp.php?song_id=1002", // Replace with actual URL
      imageUrl: "assets/images/logo.png",
    ),
    const Song(
      title: "DMS2",
      artist: "Tones and I",
      url: "https://dms.uom.lk/s/fzi39W4d9YGBdQ4/download", // Replace with actual URL
      imageUrl: "assets/images/logo.png",
    ),
    const Song(
      title: "DMS1",
      artist: "Billie Eilish",
      url: "https://dms.uom.lk/s/7Adqtg5b3QYmZa4/download", // Replace with actual URL
      imageUrl: "assets/images/logo.png",
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for disc rotation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
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
    
    // Load the first song
    _loadCurrentSong();
  }

  void _loadCurrentSong() {
    final Song song = songs[currentSongIndex];
    _audioPlayer.setSourceUrl(song.url);
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
      currentSongIndex = (currentSongIndex + 1) % songs.length;
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
              Colors.deepPurple.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: showPlaylist 
              ? _buildPlaylist() 
              : _buildPlayerView(currentSong),
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
                onPressed: () {},
                icon: const Icon(Icons.arrow_back_ios),
                color: Colors.white,
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
          child: RotationTransition(
            turns: _animationController,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
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
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withOpacity(0.2),
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withOpacity(0.2),
                ),
                child: Slider(
                  value: position.inSeconds.toDouble(),
                  max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
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
              onPressed: () {},
              icon: const Icon(Icons.shuffle),
              color: Colors.white,
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
              onPressed: () {},
              icon: const Icon(Icons.repeat),
              color: Colors.white,
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
                  child: Image.network(
                    song.imageUrl,
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
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                trailing: isCurrentSong && isPlaying
                    ? const Icon(
                        Icons.volume_up,
                        color: Colors.deepPurple,
                      )
                    : null,
              );
            },
          ),
        ),
        
        // Now playing mini player
        if (isPlaying)
          Container(
            color: Colors.black26,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
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