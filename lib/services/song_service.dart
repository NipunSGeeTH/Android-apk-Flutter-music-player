// services/song_service.dart - Handles fetching songs from API
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';

class SongService {
  // List of URLs to try in order
  static final List<String> _urlsToTry = [
    'https://dms.uom.lk/s/sgCYer8cL7MfssS/download',
    'https://nipunsgeeth.github.io/songs.json',
  ];

  // Fallback songs when API fails
  static List<Song> getFallbackSongs() {
    return [
      const Song(
        title: "Kolompure Nuba Inna Isawwe",
        artist: "Samitha Mudunkotuwa",
        url: "https://tg-filetolink.sangeethnipun.workers.dev/?file=MTIzNTkwMjYyNDMwMjM4Ni8zMzc3NDU4&mode=inline",
        imageUrl: "assets/images/logo.png",
      ),
      // Add more fallback songs here
    ];
  }

  // Fetch songs from API
  static Future<List<Song>> fetchSongs() async {
    List<Song> allFetchedSongs = []; // To accumulate songs from all successful URLs
    bool anySuccess = false; // To track if at least one URL was successful

    // Try each URL in sequence
    for (final url in _urlsToTry) {
      try {
        // Try to fetch with a timeout
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
            List<Song> currentUrlSongs = jsonData
                .map((songData) => Song.fromJson(songData))
                .toList();

            if (currentUrlSongs.isNotEmpty) {
              allFetchedSongs.addAll(currentUrlSongs); // Add songs from this URL to the list
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

    // If any URL was successful, return the fetched songs
    if (anySuccess) {
      return allFetchedSongs;
    } else {
      // If all URLs failed, return fallback songs
      print('All URLs failed or returned no songs, loading fallback songs');
      return getFallbackSongs();
    }
  }
}