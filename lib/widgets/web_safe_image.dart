import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui' as ui;
import 'dart:html' as html;

class WebSafeImage extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;
  final BoxFit fit;

  const WebSafeImage({
    Key? key,
    required this.imagePath,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<WebSafeImage> createState() => _WebSafeImageState();
}

class _WebSafeImageState extends State<WebSafeImage> {
  String? _viewType;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _registerImageView();
    }
  }

  void _registerImageView() {
    _viewType = 'image-${widget.imagePath.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
    
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      _viewType!,
      (int viewId) {
        final img = html.ImageElement()
          ..src = widget.imagePath
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = widget.fit == BoxFit.cover ? 'cover' : 'contain'
          ..style.display = 'block';
        return img;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && _viewType != null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: HtmlElementView(viewType: _viewType!),
      );
    }
    
    // Fallback for non-web
    return Image.network(
      widget.imagePath,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }
}
