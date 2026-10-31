import 'package:flutter/material.dart';

class LockedFeatureCard extends StatelessWidget {
  const LockedFeatureCard({
    super.key,
    required this.title,
    required this.message,
    required this.onUpgrade,
    this.icon = Icons.workspace_premium_outlined,
    this.compact = false,
  });

  final String title;
  final String message;
  final VoidCallback onUpgrade;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 18 : 24),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(34),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(34),
        ),
        gradient: const LinearGradient(
          colors: [Color(0xFF142943), Color(0xFF176D69)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/images/premium-badge.png',
                width: compact ? 49 : 64, height: compact ? 49 : 64,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFFFD58A), size: 44)),
              const Spacer(),
              const Text('PREMIUM', style: TextStyle(
                color: Color(0xFF9AE7D3), fontWeight: FontWeight.w800,
                letterSpacing: 1.8, fontSize: 11)),
            ],
          ),
          SizedBox(height: compact ? 12 : 19),
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(
            color: Color(0xFFD4E5E9), height: 1.4)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onUpgrade,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Explore Premium'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF173D4B),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 7),
          const Center(child: Text('One payment · Lifetime access',
            style: TextStyle(color: Color(0xFFA9DBD5), fontSize: 11))),
        ],
      ),
    );
  }
}
