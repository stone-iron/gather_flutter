import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/group_buy_repository.dart';
import '../../domain/group_buy_campaign.dart';
import '../providers/group_buy_providers.dart';

class GroupBuyDetailScreen extends ConsumerStatefulWidget {
  final int productId;

  const GroupBuyDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<GroupBuyDetailScreen> createState() =>
      _GroupBuyDetailScreenState();
}

class _GroupBuyDetailScreenState
    extends ConsumerState<GroupBuyDetailScreen> {
  int quantity = 1;
  bool isSubmitting = false;

  Future<void> participate(GroupBuyCampaign campaign) async {
    final member = ref.read(authProvider);

    if (member == null) {
      await context.push('/login');
      return;
    }

    if (!member.isBuyer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('공동구매 참여는 구매자 계정만 가능합니다.'),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final result = await ref
          .read(groupBuyRepositoryProvider)
          .participate(
        productId: campaign.productId,
        memberId: member.id,
        quantity: quantity,
      );

      ref.invalidate(campaignsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
      }
    } on GroupBuyException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaigns = ref.watch(campaignsProvider);

    return campaigns.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('상품을 불러오지 못했습니다.\n$error'),
        ),
      ),
      data: (items) {
        GroupBuyCampaign? campaign;

        for (final item in items) {
          if (item.productId == widget.productId) {
            campaign = item;
            break;
          }
        }

        if (campaign == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('상품 정보를 찾을 수 없습니다.'),
            ),
          );
        }

        return _buildDetail(campaign);
      },
    );
  }

  Widget _buildDetail(GroupBuyCampaign campaign) {
    final progress = campaign.goalQuantity == 0
        ? 0.0
        : (campaign.joinedQuantity / campaign.goalQuantity)
        .clamp(0.0, 1.0)
        .toDouble();

    final percentage = (progress * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('상품 상세'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFF1EB),
                  Color(0xFFFFD8C8),
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 110,
                color: Color(0xFFFF6B35),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(
                  label: Text(
                    campaign.goalReached ? '목표 달성' : '공동구매 모집 중',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  campaign.productTitle,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      '$percentage% 달성',
                      style: const TextStyle(
                        color: Color(0xFFFF6B35),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${campaign.joinedQuantity}/${campaign.goalQuantity}개',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 16),
                Text(
                  '${campaign.remainingQuantity}개 더 모이면 성사돼요.',
                ),
                const SizedBox(height: 28),
                const Text(
                  '참여 수량',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: quantity > 1
                          ? () {
                        setState(() {
                          quantity--;
                        });
                      }
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    SizedBox(
                      width: 64,
                      child: Text(
                        '$quantity개',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: quantity < 3 &&
                          quantity < campaign.remainingQuantity
                          ? () {
                        setState(() {
                          quantity++;
                        });
                      }
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  '참여 신청 단계에서는 결제되지 않으며, '
                      '목표 수량 달성 후 결제 일정을 안내합니다.',
                  style: TextStyle(
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: campaign.goalReached || isSubmitting
                ? null
                : () => participate(campaign!),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
            child: isSubmitting
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(
              campaign.goalReached
                  ? '공동구매 목표 달성'
                  : '$quantity개 공동구매 참여하기',
            ),
          ),
        ),
      ),
    );
  }
}