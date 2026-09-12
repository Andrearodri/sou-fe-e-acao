import 'package:flutter/material.dart';

class BibleScreen extends StatelessWidget {
  const BibleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.menu_book_outlined,
      title: 'Bíblia',
      description:
          'O Reader Mode está sendo preparado para leitura local, com uma '
          'tradução licenciada, escolha de livro e capítulo, fonte ajustável '
          'e tema escuro.',
      note:
          'Nesta fase, nenhum texto bíblico completo é incorporado e a leitura '
          'não depende de uma API externa.',
    );
  }
}

class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    required this.icon,
    required this.title,
    required this.description,
    required this.note,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Icon(icon, size: 52,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 18),
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Text(description, textAlign: TextAlign.center),
                  const SizedBox(height: 18),
                  Text(note,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          )),
                  const SizedBox(height: 20),
                  const Chip(
                    avatar: Icon(Icons.construction_outlined, size: 18),
                    label: Text('Em preparação'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
