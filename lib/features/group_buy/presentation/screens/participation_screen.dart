import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/group_buy_participation.dart';
import '../providers/group_buy_providers.dart';

class ParticipationScreen extends ConsumerWidget {
  const ParticipationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(authProvider);

    if (member == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('참여내역'),
          centerTitle: true,
        ),
        body: Center(
          child: FilledButton(
            onPressed: () => context.push('/login'),
            child: const Text('로그인하고 참여내역 보기'),
          ),
        ),
      );
    }

    final participations = ref.watch(
      participationsProvider(member.id),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('참여내역'),
        centerTitle: true,
      ),
      body: participations.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('참여내역을 불러오지 못했습니다.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  ref.invalidate(
                    participationsProvider(member.id),
                  );
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
                    Icons.shopping_bag_outlined,
                    size: 72,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '아직 참여한 공동구매가 없습니다.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(
              participationsProvider(member.id).future,
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _ParticipationCard(
                  participation: items[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ParticipationCard extends StatelessWidget {
  final GroupBuyParticipation participation;

  const _ParticipationCard({
    required this.participation,
  });

  @override
  Widget build(BuildContext context) {
    final progress = participation.goalQuantity == 0
        ? 0.0
        : (participation.joinedQuantity /
        participation.goalQuantity)
        .clamp(0.0, 1.0)
        .toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push(
            '/products/${participation.productId}',
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(
                      participation.goalReached
                          ? '목표 달성'
                          : '모집 중',
                    ),
                  ),
                  const Spacer(),
                  Text('${participation.quantity}개 신청'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                participation.productTitle,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(20),
              ),
              const SizedBox(height: 10),
              Text(
                participation.goalReached
                    ? '목표를 달성했습니다. 결제 안내를 기다려 주세요.'
                    : '목표까지 ${participation.remainingQuantity}개 남았습니다.',
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(participation.participatedAt),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    return '${local.year}.${local.month.toString().padLeft(2, '0')}.'
        '${local.day.toString().padLeft(2, '0')} 참여';
  }
}