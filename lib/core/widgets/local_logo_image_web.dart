import 'dart:convert';
import 'package:flutter/material.dart';

Widget? localLogoImage(String path, double size) {
  if (!path.startsWith('data:image')) return null;
  final comma = path.indexOf(',');
  if (comma < 0) return null;
  try {
    return Image.memory(
      base64Decode(path.substring(comma + 1)),
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  } catch (_) {
    return null;
  }
}
