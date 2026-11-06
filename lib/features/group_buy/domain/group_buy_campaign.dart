class GroupBuyCampaign {
  final int productId;
  final String productTitle;
  final int goalQuantity;
  final int joinedQuantity;
  final int remainingQuantity;
  final bool goalReached;
  final String status;
  final String message;

  const GroupBuyCampaign({
    required this.productId,
    required this.productTitle,
    required this.goalQuantity,
    required this.joinedQuantity,
    required this.remainingQuantity,
    required this.goalReached,
    required this.status,
    required this.message,
  });

  factory GroupBuyCampaign.fromJson(Map<String, dynamic> json) {
    return GroupBuyCampaign(
      productId: (json['productId'] as num).toInt(),
      productTitle: json['productTitle']?.toString() ?? '',
      goalQuantity: (json['goalQuantity'] as num).toInt(),
      joinedQuantity: (json['joinedQuantity'] as num).toInt(),
      remainingQuantity: (json['remainingQuantity'] as num).toInt(),
      goalReached: json['goalReached'] as bool? ?? false,
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}
