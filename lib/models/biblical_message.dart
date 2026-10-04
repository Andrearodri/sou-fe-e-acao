class BiblicalMessage {
  const BiblicalMessage({
    required this.slug,
    required this.text,
    required this.reference,
    required this.category,
    this.translation = 'BLIVRE',
    this.backgroundUrl,
    this.featured = false,
    this.displayOrder = 0,
  });

  final String slug;
  final String text;
  final String reference;
  final String category;
  final String translation;
  final String? backgroundUrl;
  final bool featured;
  final int displayOrder;

  Uri get uri => Uri.https('soufeeacao.com.br', '/mensagens/$slug');

  String get copyText => '“$text”\n\n$reference\n\n$uri';

  String get shareText => '“$text”\n\n$reference\n\nVeja mais:\n$uri';

  Uri get whatsappUri => Uri.https('wa.me', '/', {'text': shareText});

  factory BiblicalMessage.fromJson(Map<String, dynamic> json) {
    return BiblicalMessage(
      slug: json['slug'] as String,
      text: json['text'] as String,
      reference: json['reference'] as String,
      category: json['category'] as String,
      translation: json['translation'] as String? ?? 'BLIVRE',
      backgroundUrl: json['background_url'] as String?,
      featured: json['featured'] as bool? ?? false,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }
}
