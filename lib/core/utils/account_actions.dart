import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/subscription_model.dart';

class AccountActions {
  static const _channel = MethodChannel('subtrack/apps');

  static String? packageFor(String name) {
    final value = name.toLowerCase();
    if (value.contains('chatgpt')) return 'com.openai.chatgpt';
    if (value.contains('gemini')) return 'com.google.android.apps.bard';
    if (value.contains('claude')) return 'com.anthropic.claude';
    if (value.contains('netflix')) return 'com.netflix.mediaclient';
    if (value.contains('capcut')) return 'com.lemon.lvoverseas';
    if (value.contains('canva')) return 'com.canva.editor';
    if (value.contains('youtube')) return 'com.google.android.youtube';
    if (value.contains('shahid')) return 'net.mbc.shahid';
    if (value.contains('facebook')) return 'com.facebook.katana';
    return null;
  }

  static Future<bool> openService(SubscriptionModel item) async {
    final package = packageFor(item.name);
    if (!kIsWeb && package != null) {
      try {
        if (await _channel.invokeMethod<bool>('launchApp', package) == true) {
          return true;
        }
      } catch (_) {}
    }
    return open(serviceUrl(item));
  }

  static String? serviceUrl(SubscriptionModel item) {
    if ((item.loginUrl ?? '').isNotEmpty) return item.loginUrl;
    final name = item.name.toLowerCase();
    if (name.contains('chatgpt')) return 'https://chatgpt.com/';
    if (name.contains('gemini')) return 'https://gemini.google.com/';
    if (name.contains('claude')) return 'https://claude.ai/';
    if (name.contains('canva')) return 'https://www.canva.com/';
    if (name.contains('capcut')) return 'https://www.capcut.com/';
    if (name.contains('netflix')) return 'https://www.netflix.com/';
    if (name.contains('shahid')) return 'https://shahid.mbc.net/';
    if (name.contains('youtube')) return 'https://www.youtube.com/';
    if (name.contains('facebook')) return 'https://www.facebook.com/';
    return null;
  }

  static Future<bool> open(String? value) async {
    final uri = Uri.tryParse(value ?? '');
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> copyAll(SubscriptionModel item) => Clipboard.setData(
    ClipboardData(
      text: [
        item.name,
        if ((item.email ?? '').isNotEmpty) 'Email: ${item.email}',
        if ((item.username ?? '').isNotEmpty) 'User: ${item.username}',
        if ((item.password ?? '').isNotEmpty) 'Password: ${item.password}',
        if ((item.pin ?? '').isNotEmpty) 'PIN: ${item.pin}',
        if ((item.loginUrl ?? '').isNotEmpty) 'Link: ${item.loginUrl}',
        if ((item.codeUrl ?? '').isNotEmpty) 'Code link: ${item.codeUrl}',
      ].join('\n'),
    ),
  );

  static void copied(BuildContext context) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Account copied')));
}
