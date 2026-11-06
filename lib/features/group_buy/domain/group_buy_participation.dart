class GroupBuyParticipation {
  final int id;
  final int productId;
  final String productTitle;
  final int quantity;
  final DateTime participatedAt;
  final int goalQuantity;
  final int joinedQuantity;
  final int remainingQuantity;
  final bool goalReached;
  final String status;

  const GroupBuyParticipation({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.quantity,
    required this.participatedAt,
    required this.goalQuantity,
    required this.joinedQuantity,
    required this.remainingQuantity,
    required this.goalReached,
    required this.status,
  });

  factory GroupBuyParticipation.fromJson(Map<String, dynamic> json) {
    return GroupBuyParticipation(
      id: (json['id'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      productTitle: json['productTitle']?.toString() ?? '',
      quantity: (json['quantity'] as num).toInt(),
      participatedAt: DateTime.parse(json['participatedAt'].toString()),
      goalQuantity: (json['goalQuantity'] as num).toInt(),
      joinedQuantity: (json['joinedQuantity'] as num).toInt(),
      remainingQuantity: (json['remainingQuantity'] as num).toInt(),
      goalReached: json['goalReached'] as bool? ?? false,
      status: json['status']?.toString() ?? '',
    );
  }
}