// Rendering utility, run with: flutter test tool/generate_football_icon.dart
// Uses the existing Material icon system; no remote images or image generator.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:basketvibe/core/styles/app_colors.dart';

void main() {
  testWidgets('render Football Day launcher artwork', (tester) async {
    final loader = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await loader.load();
    await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawColor(AppColors.primaryDark, BlendMode.src);
      final painter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(Icons.sports_soccer.codePoint),
          style: const TextStyle(
            fontFamily: 'MaterialIcons',
            fontSize: 680,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset((1024 - painter.width) / 2, (1024 - painter.height) / 2),
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(1024, 1024);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(
        'assets/logo/football_day_logo.png',
      ).writeAsBytes(png!.buffer.asUint8List());
      image.dispose();
      picture.dispose();
      painter.dispose();
    });
  });
}
