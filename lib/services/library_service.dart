import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchProgressItem {
  final String movieId;
  final int positionSeconds;
  final int durationSeconds;
  final DateTime updatedAt;

  WatchProgressItem({
    required this.movieId,
    required this.positionSeconds,
    required this.durationSeconds,
    required this.updatedAt,
  });

  double get progressRatio => durationSeconds > 0
      ? (positionSeconds / durationSeconds).clamp(0.0, 1.0)
      : 0.0;

  Map<String, dynamic> toJson() => {
    'movie_id': movieId,
    'position_seconds': positionSeconds,
    'duration_seconds': durationSeconds,
    'updated_at': updatedAt.toIso8601String(),
  };

  factory WatchProgressItem.fromJson(Map<String, dynamic> json) =>
      WatchProgressItem(
        movieId: json['movie_id'] ?? '',
        positionSeconds: json['position_seconds'] ?? 0,
        durationSeconds: json['duration_seconds'] ?? 1,
        updatedAt:
            DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      );
}

class LibraryService extends ChangeNotifier {
  static final LibraryService instance = LibraryService._internal();

  LibraryService._internal() {
    _loadFromPrefs();
  }

  final Set<String> _myList = {};
  final Set<String> _likedMovies = {};
  final Map<String, WatchProgressItem> _progressMap = {};

  Set<String> get myListIds => Set.unmodifiable(_myList);
  Set<String> get likedMovieIds => Set.unmodifiable(_likedMovies);
  Map<String, WatchProgressItem> get progressMap =>
      Map.unmodifiable(_progressMap);

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedList = prefs.getStringList('lib_my_list');
      if (savedList != null) {
        _myList.addAll(savedList);
      } else {
        // Dữ liệu mẫu ban đầu cho sinh động
        _myList.addAll(['mock_1', 'mock_2', 'mock_9', 'mock_10']);
      }

      final savedLikes = prefs.getStringList('lib_likes');
      if (savedLikes != null) {
        _likedMovies.addAll(savedLikes);
      } else {
        _likedMovies.addAll(['mock_1', 'mock_3', 'mock_11']);
      }

      final savedProgress = prefs.getString('lib_progress');
      if (savedProgress != null) {
        final decoded = jsonDecode(savedProgress) as Map<String, dynamic>;
        for (var entry in decoded.entries) {
          _progressMap[entry.key] = WatchProgressItem.fromJson(
            entry.value as Map<String, dynamic>,
          );
        }
      } else {
        // Dữ liệu mẫu đang xem dở
        _progressMap['mock_1'] = WatchProgressItem(
          movieId: 'mock_1',
          positionSeconds: 390,
          durationSeconds: 600,
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        );
        _progressMap['mock_2'] = WatchProgressItem(
          movieId: 'mock_2',
          positionSeconds: 270,
          durationSeconds: 900,
          updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        );
        _progressMap['mock_3'] = WatchProgressItem(
          movieId: 'mock_3',
          positionSeconds: 580,
          durationSeconds: 720,
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi tải dữ liệu thư viện cá nhân: $e');
    }
  }

  bool isInMyList(String movieId) => _myList.contains(movieId);

  Future<void> toggleMyList(String movieId) async {
    if (_myList.contains(movieId)) {
      _myList.remove(movieId);
    } else {
      _myList.add(movieId);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('lib_my_list', _myList.toList());
  }

  bool isLiked(String movieId) => _likedMovies.contains(movieId);

  Future<void> toggleLike(String movieId) async {
    if (_likedMovies.contains(movieId)) {
      _likedMovies.remove(movieId);
    } else {
      _likedMovies.add(movieId);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('lib_likes', _likedMovies.toList());
  }

  WatchProgressItem? getProgress(String movieId) => _progressMap[movieId];

  Future<void> saveProgress(
    String movieId,
    int positionSeconds,
    int durationSeconds,
  ) async {
    _progressMap[movieId] = WatchProgressItem(
      movieId: movieId,
      positionSeconds: positionSeconds,
      durationSeconds: durationSeconds,
      updatedAt: DateTime.now(),
    );
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _progressMap.map((key, value) => MapEntry(key, value.toJson())),
    );
    await prefs.setString('lib_progress', encoded);
  }

  Future<void> removeProgress(String movieId) async {
    _progressMap.remove(movieId);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _progressMap.map((key, value) => MapEntry(key, value.toJson())),
    );
    await prefs.setString('lib_progress', encoded);
  }

  Future<void> clearAll() async {
    _myList.clear();
    _likedMovies.clear();
    _progressMap.clear();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lib_my_list');
    await prefs.remove('lib_likes');
    await prefs.remove('lib_progress');
  }
}
