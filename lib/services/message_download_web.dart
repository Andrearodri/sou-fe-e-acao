import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

Future<void> downloadMessagePng(Uint8List bytes, String filename) async {
  final blob =
      web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: 'image/png'));
  final url = web.URL.createObjectURL(blob);
  try {
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = filename;
    final body = web.document.body;
    if (body == null) throw StateError('Documento indisponível');
    body.appendChild(anchor);
    try {
      anchor.click();
    } finally {
      body.removeChild(anchor);
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
  } finally {
    web.URL.revokeObjectURL(url);
  }
}
