import 'package:flutter/material.dart';

import '../models/biblical_message.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({
    required this.message,
    required this.isFavorite,
    required this.onOpen,
    required this.onCreateImage,
    required this.onWhatsapp,
    required this.onShare,
    required this.onCopy,
    required this.onFavorite,
    super.key,
  });

  final BiblicalMessage message;
  final bool isFavorite;
  final VoidCallback? onOpen;
  final VoidCallback onCreateImage;
  final VoidCallback onWhatsapp;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.backgroundUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    message.backgroundUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFFE8F0E6),
                      child: Center(
                          child: Icon(Icons.image_not_supported_outlined)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Chip(label: Text(message.category)),
                if (message.featured)
                  const Chip(
                    avatar: Icon(Icons.auto_awesome, size: 18),
                    label: Text('Destaque'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '“${message.text}”',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (onOpen == null)
              Text(
                '${message.reference} · ${message.translation}',
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              TextButton(
                onPressed: onOpen,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                child: Text(
                    'Abrir mensagem: ${message.reference} · ${message.translation}'),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: onCreateImage,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Criar imagem'),
                ),
                TextButton.icon(
                  onPressed: onWhatsapp,
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('WhatsApp'),
                ),
                TextButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Compartilhar'),
                ),
                TextButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copiar'),
                ),
                IconButton(
                  tooltip: isFavorite
                      ? 'Remover ${message.reference} dos favoritos'
                      : 'Favoritar ${message.reference}',
                  onPressed: onFavorite,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  color: isFavorite ? scheme.error : scheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
