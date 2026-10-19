// Capture màn hình S15–S28 (tách từ capture_all_42_screens_test.dart).
//
// Nội dung test giữ nguyên; setup chung nằm ở `visual_harness.dart`.
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/features/discover/hot_screen.dart';
import 'package:openflix/features/discover/movie_grid_screen.dart';
import 'package:openflix/features/discover/top10_screen.dart';
import 'package:openflix/features/library/continue_watching_screen.dart';
import 'package:openflix/features/library/liked_movies_screen.dart';
import 'package:openflix/features/library/my_list_screen.dart';
import 'package:openflix/features/library/watch_history_screen.dart';
import 'package:openflix/features/watch/detail_screen.dart';
import 'package:openflix/features/watch/episodes_screen.dart';
import 'package:openflix/features/watch/reviews_screen.dart';
import 'package:openflix/features/watch/similar_movies_screen.dart';
import 'package:openflix/features/watch/trailer_screen.dart';
import 'package:openflix/features/watch/write_review_screen.dart';
import 'package:openflix/screens/player_screen.dart';

import 'visual_harness.dart';

void main() {
  setUpVisualHarness();

  group('Capture 42 Screens - True Mobile Portrait 1080x2316', () {
    testWidgets('S15: See All Movie Grid', (tester) async {
      await captureScreenWidget(tester, const MovieGridScreen(title: 'Tất Cả Phim Chiếu Rạp', category: 'Chiếu rạp'), 'S15_see_all.png');
    });

    testWidgets('S16: Hot & New Screen', (tester) async {
      await captureScreenWidget(tester, const HotScreen(), 'S16_hot.png');
    });

    testWidgets('S17: Top 10 Screen', (tester) async {
      await captureScreenWidget(tester, const Top10Screen(), 'S17_top10.png');
    });

    testWidgets('S18: Movie Detail Screen', (tester) async {
      await captureScreenWidget(tester, const DetailScreen(movieId: 'sample1'), 'S18_detail.png');
    });

    testWidgets('S19: Trailer Screen', (tester) async {
      await captureScreenWidget(tester, const TrailerScreen(movieId: 'sample1'), 'S19_trailer.png');
    });

    testWidgets('S20: Player Screen', (tester) async {
      await captureScreenWidget(tester, PlayerScreen(movie: sampleMovie), 'S20_player.png');
    });

    testWidgets('S21: Episodes Screen', (tester) async {
      await captureScreenWidget(tester, const EpisodesScreen(movieId: 'sample1'), 'S21_episodes.png');
    });

    testWidgets('S22: Similar Movies Screen', (tester) async {
      await captureScreenWidget(tester, const SimilarMoviesScreen(movieId: 'sample1'), 'S22_similar_movies.png');
    });

    testWidgets('S23: Reviews Screen', (tester) async {
      await captureScreenWidget(tester, const ReviewsScreen(movieId: 'sample1'), 'S23_reviews.png');
    });

    testWidgets('S24: Write Review Screen', (tester) async {
      await captureScreenWidget(tester, const WriteReviewScreen(movieId: 'sample1'), 'S24_write_review.png');
    });

    testWidgets('S25: My List Screen', (tester) async {
      await captureScreenWidget(tester, const MyListScreen(), 'S25_my_list.png');
    });

    testWidgets('S26: Continue Watching Screen', (tester) async {
      await captureScreenWidget(tester, const ContinueWatchingScreen(), 'S26_continue_watching.png');
    });

    testWidgets('S27: Watch History Screen', (tester) async {
      await captureScreenWidget(tester, const WatchHistoryScreen(), 'S27_watch_history.png');
    });

    testWidgets('S28: Liked Movies Screen', (tester) async {
      await captureScreenWidget(tester, const LikedMoviesScreen(), 'S28_liked_movies.png');
    });
  });
}
