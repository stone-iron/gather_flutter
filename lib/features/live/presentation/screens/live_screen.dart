import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/live_broadcast.dart';
import '../providers/live_providers.dart';

class LiveScreen extends ConsumerWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final broadcasts = ref.watch(broadcastsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('라이브커머스'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: () {
              ref.invalidate(broadcastsProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: broadcasts.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('라이브 방송을 불러오지 못했습니다.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  ref.invalidate(broadcastsProvider);
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.live_tv_outlined,
                    size: 76,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '예정된 라이브 방송이 없습니다.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('새로운 방송이 승인되면 이곳에 표시됩니다.'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(
              broadcastsProvider.future,
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  '라이브 일정',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '판매자와 소통하며 공동구매 상품을 만나보세요.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ...items.map(
                      (broadcast) => _LiveCard(
                    broadcast: broadcast,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LiveCard extends StatelessWidget {
  final LiveBroadcast broadcast;

  const _LiveCard({
    required this.broadcast,
  });

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage = broadcast.imageUrl != null &&
        broadcast.imageUrl!.startsWith('http');

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 190,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasNetworkImage)
                  Image.network(
                    broadcast.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        _fallbackImage(),
                  )
                else
                  _fallbackImage(),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Chip(
                    backgroundColor: broadcast.isLive
                        ? Colors.red
                        : Colors.white,
                    label: Text(
                      broadcast.isLive ? '● LIVE' : '방송 예정',
                      style: TextStyle(
                        color: broadcast.isLive
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (broadcast.isLive)
                  Positioned(
                    right: 14,
                    bottom: 14,
                    child: Chip(
                      label: Text(
                        '시청 ${broadcast.viewers}명',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  broadcast.seller,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  broadcast.title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${broadcast.emoji} ${broadcast.productTitle}'),
                const SizedBox(height: 8),
                Text(
                  broadcast.scheduledAt,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: broadcast.isLive
                      ? FilledButton.icon(
                    onPressed: () {
                      context.push('/live/${broadcast.id}');
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('방송 보기'),
                  )
                      : OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text('알림을 신청했습니다.'),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_none,
                    ),
                    label: const Text('알림 받기'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: const Color(0xFF252525),
      alignment: Alignment.center,
      child: Text(
        broadcast.emoji,
        style: const TextStyle(fontSize: 72),
      ),
    );
  }
}