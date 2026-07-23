import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SubscriptionLogo extends StatelessWidget {
  const SubscriptionLogo({
    super.key,
    required this.name,
    this.size = 48,
    this.fallback,
    this.showBackground = true,
  });

  final String name;
  final double size;
  final String? fallback;
  final bool showBackground;

  static String? assetFor(String name) {
    final normalized = name.toLowerCase();
    if (normalized.contains('chatgpt')) return 'assets/logos/chatgpt.png';
    if (normalized.contains('canva')) return 'assets/logos/canva.png';
    if (normalized.contains('capcut')) return 'assets/logos/capcut.png';
    if (normalized.contains('gemini')) return 'assets/logos/gemini.png';
    if (normalized.contains('claude')) return 'assets/logos/claude.svg';
    if (normalized.contains('youtube')) return 'assets/logos/youtube.svg';
    if (normalized.contains('netflix')) return 'assets/logos/netflix.svg';
    if (normalized.contains('shahid')) return 'assets/logos/shahid.png';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final asset = assetFor(name);
    final normalized = name.toLowerCase();
    final child = asset != null
        ? Padding(
            padding: EdgeInsets.all(
              asset.endsWith('.svg') ? size * .2 : size * .08,
            ),
            child: asset.endsWith('.svg')
                ? SvgPicture.asset(asset, fit: BoxFit.contain)
                : Image.asset(asset, fit: BoxFit.contain),
          )
        : Center(
            child: Text(
              normalized.contains('zest') ? 'Z' : (fallback ?? '•'),
              style: TextStyle(
                fontSize: size * .45,
                fontWeight: FontWeight.w900,
                color: normalized.contains('zest')
                    ? const Color(0xFFFF7A45)
                    : null,
              ),
            ),
          );

    if (!showBackground) return SizedBox.square(dimension: size, child: child);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * .3),
        border: Border.all(color: Colors.black.withValues(alpha: .06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
