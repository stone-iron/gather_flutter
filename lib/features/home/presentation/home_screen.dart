import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../group_buy/domain/group_buy_campaign.dart';
import '../../group_buy/presentation/providers/group_buy_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final searchController = TextEditingController();
  String selectedStatus = 'ALL';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campaigns = ref.watch(campaignsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: campaigns.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _ErrorView(
            error: error,
            onRetry: () => ref.invalidate(campaignsProvider),
          ),
          data: (items) => _buildHome(items),
        ),
      ),
    );
  }

  Widget _buildHome(List<GroupBuyCampaign> items) {
    final searchText = searchController.text.trim().toLowerCase();

    final filteredItems = items.where((campaign) {
      final matchesSearch = campaign.productTitle.toLowerCase().contains(
        searchText,
      );

      final matchesStatus =
          selectedStatus == 'ALL' || campaign.status == selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => ref.refresh(campaignsProvider.future),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '여기모여',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '어떤 상품을 함께 살까요?',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8A5B), Color(0xFFFF5C35)],
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '같이 사면 더 좋은 가격',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '목표 수량을 함께 채우고\n공동구매에 참여해 보세요.',
                          style: TextStyle(color: Colors.white, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.groups, size: 72, color: Colors.white),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 42,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                children: [
                  _statusChip('ALL', '전체'),
                  _statusChip('RECRUITING', '모집 중'),
                  _statusChip('GOAL_REACHED', '목표 달성'),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                '진행 중인 공동구매',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (filteredItems.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('조건에 맞는 공동구매가 없습니다.')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return _CampaignCard(campaign: filteredItems[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusChip(String value, String label) {
    final selected = selectedStatus == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            selectedStatus = value;
          });
        },
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final GroupBuyCampaign campaign;

  const _CampaignCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final progress = campaign.goalQuantity == 0
        ? 0.0
        : (campaign.joinedQuantity / campaign.goalQuantity)
              .clamp(0.0, 1.0)
              .toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFF1EB), Color(0xFFFFD8C8)],
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Color(0xFFFF6B35),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Chip(
                    label: Text(campaign.goalReached ? '목표 달성' : '모집 중'),
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
                  campaign.productTitle,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '${campaign.joinedQuantity}/${campaign.goalQuantity}개 참여',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      '${campaign.remainingQuantity}개 남음',
                      style: const TextStyle(
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  campaign.message,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      context.push('/products/${campaign.productId}');
                    },
                    child: const Text('상품 보기'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              '상품을 불러오지 못했습니다.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}
