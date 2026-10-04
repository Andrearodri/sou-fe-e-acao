import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../models/biblical_message.dart';
import '../services/message_download.dart';
import '../services/message_share_service.dart';

class MessageImageComposer extends StatefulWidget {
  const MessageImageComposer({required this.message, super.key});
  final BiblicalMessage message;

  @override
  State<MessageImageComposer> createState() => _MessageImageComposerState();
}

class _MessageImageComposerState extends State<MessageImageComposer> {
  final _boundaryKey = GlobalKey();
  int _background = 0;
  TextAlign _alignment = TextAlign.center;
  bool _busy = false;

  static const _backgrounds = <({String name, List<Color> colors})>[
    (name: 'Oliva', colors: [Color(0xFF233B32), Color(0xFF668376)]),
    (name: 'Aurora', colors: [Color(0xFF804C53), Color(0xFFC4956A)]),
    (name: 'Mar', colors: [Color(0xFF1C4554), Color(0xFF6F9CA5)]),
    (name: 'Noite', colors: [Color(0xFF262840), Color(0xFF696587)]),
  ];

  void _feedback(String text) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }

  Future<Uint8List> _renderPng() async {
    final boundary = _boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null || boundary.size.width <= 0) {
      throw StateError('Arte indisponível');
    }
    if (_fittingFontSize(
            widget.message.text, boundary.size.width, TextScaler.noScaling) ==
        null) {
      throw const _MessageTooLongException();
    }
    final image = await boundary.toImage(
      pixelRatio: 1080 / boundary.size.width,
    );
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('PNG indisponível');
      return data.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  Future<void> _export({required bool share}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final png = await _renderPng();
      if (share) {
        await const MessageShareService().shareImage(png, widget.message.slug);
        if (mounted) _feedback('Imagem enviada ao compartilhamento.');
      } else {
        await downloadMessagePng(png, '${widget.message.slug}.png');
        if (mounted) _feedback('Imagem pronta para baixar.');
      }
    } on _MessageTooLongException {
      if (mounted) {
        _feedback('Esta mensagem é longa demais para caber na arte.');
      }
    } catch (_) {
      if (mounted) {
        _feedback(
          share
              ? 'Não foi possível compartilhar a imagem. Tente baixar o PNG.'
              : 'Não foi possível baixar a imagem. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar imagem')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Sua mensagem em arte',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Escolha um fundo e o alinhamento. A arte será exportada em 1080 × 1080 px.',
              ),
              const SizedBox(height: 20),
              RepaintBoundary(
                key: _boundaryKey,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _MessageArt(
                    message: widget.message,
                    colors: _backgrounds[_background].colors,
                    alignment: _alignment,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Fundo', style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < _backgrounds.length; i++)
                    ChoiceChip(
                      label: Text(_backgrounds[i].name),
                      selected: _background == i,
                      onSelected: (_) => setState(() => _background = i),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Alinhamento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (final alignment in [
                    TextAlign.left,
                    TextAlign.center,
                    TextAlign.right,
                  ])
                    ChoiceChip(
                      label: Text(switch (alignment) {
                        TextAlign.left => 'Esquerda',
                        TextAlign.center => 'Centro',
                        _ => 'Direita',
                      }),
                      selected: _alignment == alignment,
                      onSelected: (_) => setState(() => _alignment = alignment),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _busy ? null : () => _export(share: false),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Baixar PNG'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _export(share: true),
                icon: const Icon(Icons.share_outlined),
                label: const Text('Compartilhar imagem'),
              ),
              if (_busy)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageArt extends StatelessWidget {
  const _MessageArt({
    required this.message,
    required this.colors,
    required this.alignment,
  });
  final BiblicalMessage message;
  final List<Color> colors;
  final TextAlign alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fontSize = _fittingFontSize(
          message.text,
          width,
          TextScaler.noScaling,
        );
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -width * .12,
                right: -width * .12,
                child: Container(
                  width: width * .55,
                  height: width * .55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .08),
                  ),
                ),
              ),
              Positioned(
                bottom: -width * .1,
                left: -width * .13,
                child: Container(
                  width: width * .62,
                  height: width * .62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .07),
                  ),
                ),
              ),
              Container(color: Colors.black.withValues(alpha: .20)),
              Padding(
                padding: EdgeInsets.all(width * .12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.spa_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                    SizedBox(height: width * .065),
                    SizedBox(
                      height: width * .39,
                      child: Center(
                        child: Text(
                          fontSize == null
                              ? 'Esta mensagem é longa demais para caber na arte.'
                              : '“${message.text}”',
                          maxLines: 8,
                          textScaler: TextScaler.noScaling,
                          textAlign: alignment,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize ?? width * .032,
                            fontWeight: FontWeight.w600,
                            height: 1.28,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: width * .065),
                    Text(
                      message.reference,
                      textAlign: TextAlign.center,
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * .045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: width * .03),
                    Text(
                      'SOU FÉ E AÇÃO  ·  ${message.translation}',
                      textAlign: TextAlign.center,
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * .026,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MessageTooLongException implements Exception {
  const _MessageTooLongException();
}

double? _fittingFontSize(String text, double width, TextScaler scaler) {
  final minimum = width * .032;
  final maximum = width * .065;
  for (var size = maximum; size >= minimum; size -= 1) {
    final painter = TextPainter(
      text: TextSpan(
        text: '“$text”',
        style: TextStyle(
            fontSize: size, fontWeight: FontWeight.w600, height: 1.28),
      ),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 8,
    )..layout(maxWidth: width * .76);
    if (!painter.didExceedMaxLines && painter.height <= width * .37) {
      painter.dispose();
      return size;
    }
    painter.dispose();
  }
  return null;
}
