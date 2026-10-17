import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/qr_provider.dart';

class QRPreviewWebview extends ConsumerStatefulWidget {
  final String? initialUid;

  const QRPreviewWebview({super.key, this.initialUid});

  @override
  ConsumerState<QRPreviewWebview> createState() => _QRPreviewWebviewState();
}

class _QRPreviewWebviewState extends ConsumerState<QRPreviewWebview> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _hasError = false;
  late final String _targetUrl;

  @override
  void initState() {
    super.initState();
    final uid = widget.initialUid ??
        ref.read(qrNotifierProvider).qrUid ??
        'sample';
    _targetUrl = '${AppConstants.defaultResponderWebUrl}/$uid';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _loadingProgress = progress);
          },
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _hasError = false;
                _loadingProgress = 0;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loadingProgress = 100);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _hasError = true);
          },
        ),
      )
      ..loadRequest(Uri.parse(_targetUrl));
  }

  Future<void> _openExternalBrowser() async {
    final uri = Uri.parse(_targetUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responder Page Preview'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload',
            onPressed: () => _controller.reload(),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded),
            tooltip: 'Open in Browser',
            onPressed: _openExternalBrowser,
          ),
        ],
        bottom: _loadingProgress < 100 && !_hasError
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3.0),
                child: LinearProgressIndicator(
                  value: _loadingProgress / 100.0,
                  backgroundColor: Colors.transparent,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: _hasError
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          size: 56, color: AppColors.error),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to load responder preview',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Target: $_targetUrl\nPlease verify your internet connection or open in browser.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => _controller.reload(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _openExternalBrowser,
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open in Browser'),
                      ),
                    ],
                  ),
                ),
              )
            : WebViewWidget(controller: _controller),
      ),
    );
  }
}
