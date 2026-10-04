import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;

bool supportsNativeShare() => web.window.navigator.has('share');
