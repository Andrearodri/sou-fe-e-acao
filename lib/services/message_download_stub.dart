import 'dart:typed_data';

import 'message_share_service.dart';

Future<void> downloadMessagePng(Uint8List bytes, String filename) =>
    const MessageShareService().shareImage(
      bytes,
      filename.replaceAll('.png', ''),
    );
