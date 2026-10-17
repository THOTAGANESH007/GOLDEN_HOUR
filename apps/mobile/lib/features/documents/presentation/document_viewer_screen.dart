import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../data/document_models.dart';

class DocumentViewerScreen extends StatefulWidget {
  final DocumentItem document;

  const DocumentViewerScreen({super.key, required this.document});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  WebViewController? _webViewController;
  bool _isLoadingPdf = true;

  @override
  void initState() {
    super.initState();
    if (widget.document.isPdf && widget.document.publicUrl != null) {
      // Use Google Docs viewer as an ultra-reliable cross-platform fallback for PDF display
      final pdfUrl = widget.document.publicUrl!;
      final gdocsViewerUrl =
          'https://docs.google.com/viewer?embedded=true&url=${Uri.encodeComponent(pdfUrl)}';

      try {
        _webViewController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (_) {
                if (mounted) setState(() => _isLoadingPdf = false);
              },
            ),
          )
          ..loadRequest(Uri.parse(gdocsViewerUrl));
      } catch (_) {
        // Fallback for widget testing or environments without WebViewPlatform
      }
    }
  }

  Future<void> _shareDocument() async {
    final url = widget.document.publicUrl;
    if (url != null && url.isNotEmpty) {
      await Share.share(
        'Medical Document: ${widget.document.fileName}\n$url',
        subject: widget.document.fileName,
      );
    }
  }

  Future<void> _openExternal() async {
    final url = widget.document.publicUrl;
    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;

    return Scaffold(
      appBar: AppBar(
        title: Text(doc.fileName, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (doc.publicUrl != null) ...[
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'Share',
              onPressed: _shareDocument,
            ),
            IconButton(
              icon: const Icon(Icons.open_in_browser_rounded),
              tooltip: 'Open in Browser',
              onPressed: _openExternal,
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: doc.publicUrl == null || doc.publicUrl!.isEmpty
            ? const Center(
                child: Text('Document URL is not available'),
              )
            : doc.isPdf
                ? Stack(
                    children: [
                      if (_webViewController != null)
                        WebViewWidget(controller: _webViewController!),
                      if (_isLoadingPdf)
                        const Center(child: CircularProgressIndicator()),
                    ],
                  )
                : Center(
                    child: InteractiveViewer(
                      panEnabled: true,
                      boundaryMargin: const EdgeInsets.all(20),
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: CachedNetworkImage(
                        imageUrl: doc.publicUrl!,
                        placeholder: (_, __) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (_, __, ___) => const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image_rounded,
                                size: 54, color: AppColors.error),
                            SizedBox(height: 12),
                            Text('Failed to load image preview'),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
