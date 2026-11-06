import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../widgets/live_chat_panel.dart';

import '../../domain/live_broadcast.dart';
import '../providers/live_providers.dart';

class LiveWatchScreen extends ConsumerWidget {
  final int broadcastId;

  const LiveWatchScreen({
    super.key,
    required this.broadcastId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final broadcasts = ref.watch(broadcastsProvider);

    return broadcasts.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('방송 정보를 불러오지 못했습니다.'),
        ),
      ),
      data: (items) {
        LiveBroadcast? broadcast;

        for (final item in items) {
          if (item.id == broadcastId) {
            broadcast = item;
            break;
          }
        }

        if (broadcast == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('방송 정보를 찾을 수 없습니다.'),
            ),
          );
        }

        return _LivePlayerPage(broadcast: broadcast);
      },
    );
  }
}

class _LivePlayerPage extends StatefulWidget {
  final LiveBroadcast broadcast;

  const _LivePlayerPage({
    required this.broadcast,
  });

  @override
  State<_LivePlayerPage> createState() => _LivePlayerPageState();
}

class _LivePlayerPageState extends State<_LivePlayerPage> {
  VideoPlayerController? controller;
  bool isLoading = true;
  bool isMuted = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    final streamKey =
        widget.broadcast.streamKey ?? 'live-${widget.broadcast.id}';

    final url =
        'https://gather-here.duckdns.org/hls/$streamKey/index.m3u8';

    final videoController = VideoPlayerController.networkUrl(
      Uri.parse(url),
    );

    try {
      await videoController.initialize();
      await videoController.play();

      if (!mounted) {
        await videoController.dispose();
        return;
      }

      setState(() {
        controller = videoController;
        isLoading = false;
      });
    } catch (_) {
      await videoController.dispose();

      if (mounted) {
        setState(() {
          errorMessage = '현재 송출 중인 영상을 찾을 수 없습니다.';
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void togglePlayback() {
    final videoController = controller;

    if (videoController == null) {
      return;
    }

    setState(() {
      if (videoController.value.isPlaying) {
        videoController.pause();
      } else {
        videoController.play();
      }
    });
  }

  void toggleMute() {
    final videoController = controller;

    if (videoController == null) {
      return;
    }

    setState(() {
      isMuted = !isMuted;
      videoController.setVolume(isMuted ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final broadcast = widget.broadcast;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('라이브 방송'),
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.black,
            width: double.infinity,
            height: 250,
            child: _buildPlayer(),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Chip(
                  backgroundColor: Colors.red,
                  label: Text(
                    '● LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  broadcast.title,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${broadcast.seller} · ${broadcast.viewers}명 시청'),
                const SizedBox(height: 16),
                Text(
                  broadcast.description,
                  style: const TextStyle(height: 1.5),
                ),
              ],
            ),
          ),
          LiveChatPanel(
            broadcastId: broadcast.id,
          ),
          const SizedBox(height: 12),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '방송 상품',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text(broadcast.emoji),
                  ),
                  title: Text(broadcast.productTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push(
                      '/products/${broadcast.productId}',
                    );
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      context.push(
                        '/products/${broadcast.productId}',
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: const Text('공동구매 참여하기'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  errorMessage = null;
                  isLoading = true;
                });

                initializePlayer();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('영상 다시 시도'),
            ),
          ],
        ),
      );
    }

    final videoController = controller!;

    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: videoController.value.aspectRatio > 0
                ? videoController.value.aspectRatio
                : 16 / 9,
            child: VideoPlayer(videoController),
          ),
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: IconButton.filled(
            onPressed: togglePlayback,
            icon: Icon(
              videoController.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: IconButton.filled(
            onPressed: toggleMute,
            icon: Icon(
              isMuted ? Icons.volume_off : Icons.volume_up,
            ),
          ),
        ),
      ],
    );
  }
}