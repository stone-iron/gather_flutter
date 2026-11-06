import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/group_buy_participation.dart';

import '../../../../core/network/api_client.dart';
import '../../data/group_buy_repository.dart';
import '../../domain/group_buy_campaign.dart';

final groupBuyRepositoryProvider = Provider<GroupBuyRepository>((ref) {
  return GroupBuyRepository(ref.read(dioProvider));
});

final campaignsProvider = FutureProvider<List<GroupBuyCampaign>>((ref) {
  return ref.read(groupBuyRepositoryProvider).getCampaigns();
});

final participationsProvider =
FutureProvider.family<List<GroupBuyParticipation>, int>(
      (ref, memberId) {
    return ref
        .read(groupBuyRepositoryProvider)
        .getParticipations(memberId);
  },
);
