import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class LiveChatPanel extends ConsumerStatefulWidget {
  final int broadcastId;

  const LiveChatPanel({
    super.key,
    required this.broadcastId,
  });

  @override
  ConsumerState<LiveChatPanel> createState() => _LiveChatPanelState();
}

class _LiveChatPanelState extends ConsumerState<LiveChatPanel> {
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  final messages = <LiveChatMessage>[];
  final receivedIds = <String>{};

  WebSocketChannel? channel;
  StreamSubscription<dynamic>? subscription;
  Timer? reconnectTimer;

  bool connected = false;
  bool disposed = false;

  @override
  void initState() {
    super.initState();
    connect();
  }

  Future<void> connect() async {
    reconnectTimer?.cancel();
    await subscription?.cancel();
    await channel?.sink.close();

    final newChannel = WebSocketChannel.connect(
      Uri.parse(
        'wss://gather-here.duckdns.org/ws/live/${widget.broadcastId}',
      ),
    );

    channel = newChannel;

    try {
      await newChannel.ready;

      if (!mounted || disposed) {
        await newChannel.sink.close();
        return;
      }

      setState(() {
        connected = true;
      });

      subscription = newChannel.stream.listen(
        receiveMessage,
        onError: (_) => handleDisconnect(),
        onDone: handleDisconnect,
      );
    } catch (_) {
      handleDisconnect();
    }
  }

  void receiveMessage(dynamic event) {
    try {
      final json = jsonDecode(event.toString()) as Map<String, dynamic>;
      final message = LiveChatMessage.fromJson(json);

      if (message.id.isEmpty || receivedIds.contains(message.id)) {
        return;
      }

      receivedIds.add(message.id);

      setState(() {
        messages.add(message);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (_) {
      // 잘못된 메시지는 무시하고 연결은 유지합니다.
    }
  }

  void handleDisconnect() {
    if (!mounted || disposed) {
      return;
    }

    setState(() {
      connected = false;
    });

    reconnectTimer?.cancel();
    reconnectTimer = Timer(
      const Duration(seconds: 2),
      connect,
    );
  }

  Future<void> sendMessage() async {
    final member = ref.read(authProvider);
    final text = messageController.text.trim();

    if (member == null) {
      await context.push('/login');
      return;
    }

    if (!connected || channel == null || text.isEmpty) {
      return;
    }

    channel!.sink.add(
      jsonEncode({
        'user': member.name,
        'message': text,
      }),
    );

    messageController.clear();
  }

  @override
  void dispose() {
    disposed = true;
    reconnectTimer?.cancel();
    subscription?.cancel();
    channel?.sink.close();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final member = ref.watch(authProvider);

    return SizedBox(
      height: 380,
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text(
                '실시간 채팅',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: connected ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(connected ? '연결됨' : '연결 중'),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: messages.isEmpty
                  ? const Center(
                child: Text('첫 번째 메시지를 남겨보세요.'),
              )
                  : ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(14),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isMine = member?.name == message.user;

                  return Align(
                    alignment: isMine
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isMine
                            ? const Color(0xFFFFE2D6)
                            : const Color(0xFFF0F1F3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.user,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(message.message),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      enabled: connected,
                      maxLength: 100,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: member == null
                            ? '로그인 후 채팅할 수 있습니다.'
                            : connected
                            ? '메시지를 입력하세요.'
                            : '채팅 서버 연결 중...',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: connected ? sendMessage : null,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LiveChatMessage {
  final String id;
  final String user;
  final String message;
  final int sentAt;

  const LiveChatMessage({
    required this.id,
    required this.user,
    required this.message,
    required this.sentAt,
  });

  factory LiveChatMessage.fromJson(Map<String, dynamic> json) {
    return LiveChatMessage(
      id: json['id']?.toString() ?? '',
      user: json['user']?.toString() ?? '사용자',
      message: json['message']?.toString() ?? '',
      sentAt: (json['sentAt'] as num?)?.toInt() ?? 0,
    );
  }
}