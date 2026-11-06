import 'package:dio/dio.dart';
import '../domain/group_buy_participation.dart';

import '../domain/group_buy_campaign.dart';

class GroupBuyRepository {
  final Dio dio;

  const GroupBuyRepository(this.dio);

  Future<List<GroupBuyCampaign>> getCampaigns() async {
    final response = await dio.get('/api/group-buys');
    final items = response.data as List;

    return items
        .map(
          (item) => GroupBuyCampaign.fromJson(
        Map<String, dynamic>.from(item as Map),
      ),
    )
        .toList();
  }

  Future<List<GroupBuyParticipation>> getParticipations(
      int memberId,
      ) async {
    final response = await dio.get(
      '/api/group-buys/participations',
      queryParameters: {
        'memberId': memberId,
      },
    );

    final items = response.data as List;

    return items
        .map(
          (item) => GroupBuyParticipation.fromJson(
        Map<String, dynamic>.from(item as Map),
      ),
    )
        .toList();
  }

  Future<GroupBuyCampaign> participate({
    required int productId,
    required int memberId,
    required int quantity,
  }) async {
    try {
      final response = await dio.post(
        '/api/group-buys/$productId/participate',
        data: {
          'memberId': memberId,
          'quantity': quantity,
        },
      );

      return GroupBuyCampaign.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (error) {
      final data = error.response?.data;

      if (data is Map && data['message'] != null) {
        throw GroupBuyException(data['message'].toString());
      }

      throw const GroupBuyException('공동구매 참여 요청에 실패했습니다.');
    }
  }
}

class GroupBuyException implements Exception {
  final String message;

  const GroupBuyException(this.message);

  @override
  String toString() => message;
}