import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/subscription_model.dart';
import '../../../providers/subscription_provider.dart';

class JsonSubscriptionImporter extends ConsumerStatefulWidget {
  const JsonSubscriptionImporter({super.key});

  @override
  ConsumerState<JsonSubscriptionImporter> createState() =>
      _JsonSubscriptionImporterState();
}

class _JsonSubscriptionImporterState
    extends ConsumerState<JsonSubscriptionImporter> {
  final controller = TextEditingController();
  String? error;
  bool saving = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  DateTime _date(dynamic value, DateTime fallback) => value == null
      ? fallback
      : (DateTime.tryParse(value.toString()) ?? fallback);

  String _category(String name, dynamic supplied) {
    if (supplied != null && supplied.toString().isNotEmpty) {
      return supplied.toString();
    }
    final value = name.toLowerCase();
    if (['chatgpt', 'gemini', 'claude'].any(value.contains)) return 'ai_tools';
    if (['canva', 'capcut'].any(value.contains)) return 'design_editing';
    if (['netflix', 'shahid', 'youtube'].any(value.contains)) {
      return 'entertainment';
    }
    return 'others';
  }

  Future<void> import() async {
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final decoded = jsonDecode(controller.text);
      final raw = decoded is List
          ? decoded
          : decoded is Map && decoded['subscriptions'] is List
          ? decoded['subscriptions'] as List
          : [decoded];
      for (final value in raw) {
        final map = Map<String, dynamic>.from(value as Map);
        final name = (map['name'] ?? map['subscription'] ?? map['service'])
            .toString();
        if (name.isEmpty || name == 'null') throw const FormatException('name');
        final start = _date(
          map['startDate'] ?? map['start_date'],
          DateTime.now(),
        );
        final expiry = _date(
          map['nextRenewalDate'] ??
              map['expiryDate'] ??
              map['expired_date'] ??
              map['validUntil'],
          DateTime(start.year, start.month + 1, start.day),
        );
        final priceValue = map['price'] ?? map['cost'] ?? 0;
        final item = SubscriptionModel(
          id: const Uuid().v4(),
          name: name,
          category: _category(name, map['category']),
          price: priceValue is num
              ? priceValue.toDouble()
              : double.tryParse(priceValue.toString()) ?? 0,
          currency: (map['currency'] ?? 'USD').toString(),
          billingCycle: (map['billingCycle'] ?? map['cycle'] ?? 'monthly')
              .toString(),
          startDate: start,
          nextRenewalDate: expiry,
          colorHex: (map['colorHex'] ?? '#6C63FF').toString(),
          email: map['email']?.toString(),
          username: (map['username'] ?? map['user'])?.toString(),
          password: (map['password'] ?? map['pass'])?.toString(),
          pin: map['pin']?.toString(),
          loginUrl: (map['loginUrl'] ?? map['link'])?.toString(),
          codeUrl: (map['codeUrl'] ?? map['code_link'])?.toString(),
          notes: map['notes']?.toString(),
          isPaid: map['isPaid'] as bool? ?? false,
          paymentMethod: map['paymentMethod']?.toString(),
          autoPaidOn: _dateOrNull(map['autoPaidOn'] ?? map['auto_paid_on']),
        );
        await ref.read(subscriptionsProvider.notifier).save(item);
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() {
        saving = false;
        error = 'Invalid JSON. Include at least a subscription name.';
      });
    }
  }

  DateTime? _dateOrNull(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add from AI JSON'),
    content: SizedBox(
      width: 520,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Paste one JSON object, a list, or {"subscriptions": [...]}.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            minLines: 8,
            maxLines: 14,
            autocorrect: false,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              hintText:
                  '{"name":"Gemini","email":"...","price":19,"startDate":"2026-07-01","expiryDate":"2028-01-01"}',
              errorText: error,
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton.icon(
        onPressed: saving ? null : import,
        icon: const Icon(Icons.auto_awesome_rounded),
        label: const Text('Create'),
      ),
    ],
  );
}
