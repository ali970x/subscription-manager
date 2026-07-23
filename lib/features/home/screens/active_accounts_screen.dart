import 'package:flutter/material.dart';
import '../../../data/models/subscription_model.dart';
import '../widgets/subscription_list_tile.dart';

class ActiveAccountsScreen extends StatelessWidget {
  const ActiveAccountsScreen({super.key, required this.items});
  final List<SubscriptionModel> items;

  @override
  Widget build(BuildContext context) {
    final active = items.where((item) => item.isActive).toList()
      ..sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));
    return Scaffold(
      appBar: AppBar(title: const Text('Active accounts')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5E50E8), Color(0xFF8E64F5)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: Colors.white, size: 34),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    '${active.length} active account${active.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          for (final item in active) SubscriptionListTile(subscription: item),
        ],
      ),
    );
  }
}
