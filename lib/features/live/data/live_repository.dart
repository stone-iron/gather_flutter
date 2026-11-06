import 'package:dio/dio.dart';

import '../domain/live_broadcast.dart';

class LiveRepository {
  final Dio dio;

  const LiveRepository(this.dio);

  Future<List<LiveBroadcast>> getBroadcasts() async {
    final response = await dio.get('/api/live-broadcasts');
    final items = response.data as List;

    return items
        .map(
          (item) => LiveBroadcast.fromJson(
        Map<String, dynamic>.from(item as Map),
      ),
    )
        .where(
          (broadcast) =>
      broadcast.isLive || broadcast.isScheduled,
    )
        .toList();
  }
}