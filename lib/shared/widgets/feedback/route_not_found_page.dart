// lib/shared/widgets/feedback/route_not_found_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_text.dart';

class RouteNotFoundPage extends StatelessWidget {
  const RouteNotFoundPage({super.key, this.attemptedLocation});

  final String? attemptedLocation;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.routeNotFoundTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.routeNotFoundTitle,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.routeNotFoundSubtitle,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (attemptedLocation != null &&
                        attemptedLocation!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SelectableText(
                        attemptedLocation!,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => context.go('/app/dashboard'),
                      child: Text(t.commonBackHome),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
