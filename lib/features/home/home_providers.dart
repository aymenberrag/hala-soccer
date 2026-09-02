import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/football_repository.dart';

final footballRepositoryProvider = Provider<FootballRepository>((ref) => FootballRepository());

final homeFeedProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(footballRepositoryProvider).homeFeed();
});
