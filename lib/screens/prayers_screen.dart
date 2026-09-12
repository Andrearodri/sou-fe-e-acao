import 'package:flutter/material.dart';

import 'bible_screen.dart';

class PrayersScreen extends StatelessWidget {
  const PrayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.volunteer_activism_outlined,
      title: 'Orações',
      description:
          'Aqui você poderá criar e acompanhar suas orações em um espaço '
          'privado, com persistência local segura.',
      note:
          'O CRUD e a persistência ainda não estão disponíveis. Nenhum texto '
          'de oração é coletado nesta versão.',
    );
  }
}
