import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/biblical_message.dart';
import 'message_share_capability.dart';

class MessageShareService {
  const MessageShareService();

  Future<void> copy(BiblicalMessage message) =>
      Clipboard.setData(ClipboardData(text: message.copyText));

  Future<void> whatsapp(BiblicalMessage message) async {
    if (!await launchUrl(
      message.whatsappUri,
      mode: LaunchMode.externalApplication,
    )) {
      throw StateError('WhatsApp indisponível');
    }
  }

  /// Returns true when the platform share sheet was available.
  Future<bool> share(BiblicalMessage message) async {
    if (!supportsNativeShare()) {
      await copy(message);
      return false;
    }
    try {
      await Share.share(message.shareText);
      return true;
    } catch (_) {
      await copy(message);
      return false;
    }
  }

  Future<void> shareImage(Uint8List png, String slug) async {
    if (!supportsNativeShare()) {
      throw StateError('Compartilhamento de imagem indisponível');
    }
    await Share.shareXFiles([
      XFile.fromData(png, mimeType: 'image/png', name: '$slug.png'),
    ]);
  }
}
