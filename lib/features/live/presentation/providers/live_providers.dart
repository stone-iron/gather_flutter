import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/live_repository.dart';
import '../../domain/live_broadcast.dart';

final liveRepositoryProvider = Provider<LiveRepository>((ref) {
  return LiveRepository(ref.read(dioProvider));
});

final broadcastsProvider =
FutureProvider<List<LiveBroadcast>>((ref) {
  return ref.read(liveRepositoryProvider).getBroadcasts();
});