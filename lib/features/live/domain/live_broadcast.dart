class LiveBroadcast {
  final int id;
  final String title;
  final String seller;
  final int productId;
  final String productTitle;
  final String emoji;
  final String? imageUrl;
  final String status;
  final String scheduledAt;
  final int viewers;
  final String description;
  final String? streamKey;

  const LiveBroadcast({
    required this.id,
    required this.title,
    required this.seller,
    required this.productId,
    required this.productTitle,
    required this.emoji,
    required this.imageUrl,
    required this.status,
    required this.scheduledAt,
    required this.viewers,
    required this.description,
    required this.streamKey,
  });

  factory LiveBroadcast.fromJson(Map<String, dynamic> json) {
    return LiveBroadcast(
      id: (json['id'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      seller: json['seller']?.toString() ?? '',
      productId: (json['productId'] as num).toInt(),
      productTitle: json['productTitle']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '📺',
      imageUrl: json['imageUrl']?.toString(),
      status: json['status']?.toString() ?? '',
      scheduledAt: json['scheduledAt']?.toString() ?? '',
      viewers: (json['viewers'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString() ?? '',
      streamKey: json['streamKey']?.toString(),
    );
  }

  bool get isLive => status == 'live';
  bool get isScheduled => status == 'scheduled';
}