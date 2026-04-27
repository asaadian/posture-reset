import 'package:flutter/material.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.title,
    required this.sections,
  });

  final String title;
  final List<String> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('$title Skeleton', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Phase 2 structure placeholder',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          ...sections.map(
            (section) => Card(
              child: ListTile(
                title: Text(section),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
