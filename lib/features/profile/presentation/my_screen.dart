import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/providers/auth_provider.dart';

class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('마이'), centerTitle: true),
      body: member == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_circle_outlined,
                      size: 90,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '로그인이 필요합니다.',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('로그인하고 공동구매에 참여해 보세요.'),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => context.push('/login'),
                      child: const Text('로그인'),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const CircleAvatar(
                  radius: 42,
                  child: Icon(Icons.person, size: 44),
                ),
                const SizedBox(height: 16),
                Text(
                  member.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Center(child: Chip(label: Text(_roleName(member.role)))),
                const SizedBox(height: 32),
                const Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.favorite_border),
                        title: Text('찜한 상품'),
                        trailing: Icon(Icons.chevron_right),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.receipt_long_outlined),
                        title: Text('공동구매 참여내역'),
                        trailing: Icon(Icons.chevron_right),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.settings_outlined),
                        title: Text('계정 설정'),
                        trailing: Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                  },
                  child: const Text('로그아웃'),
                ),
              ],
            ),
    );
  }

  String _roleName(String role) {
    switch (role) {
      case 'SELLER':
        return '판매자';
      case 'ADMIN':
        return '관리자';
      default:
        return '구매자';
    }
  }
}
