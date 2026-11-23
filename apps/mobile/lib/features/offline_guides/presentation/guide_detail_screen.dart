import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/guide_model.dart';
import '../domain/guide_provider.dart';
import 'guides_screen.dart';

class GuideDetailScreen extends ConsumerStatefulWidget {
  final String guideId;

  const GuideDetailScreen({
    super.key,
    required this.guideId,
  });

  @override
  ConsumerState<GuideDetailScreen> createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends ConsumerState<GuideDetailScreen> {
  EmergencyGuide? _guide;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGuide();
  }

  Future<void> _loadGuide() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final guide = await ref
        .read(guideNotifierProvider.notifier)
        .loadGuideDetail(widget.guideId);

    if (mounted) {
      setState(() {
        _guide = guide;
        _isLoading = false;
        if (guide == null) {
          _errorMessage = 'Guide not found';
        }
      });
    }
  }

  Future<void> _callEmergency() async {
    final uri = Uri.parse('tel:112');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open phone dialer for 112.'),
          ),
        );
      }
    }
  }

  void _shareGuide() {
    if (_guide == null) return;
    Share.share(
      '${_guide!.title}\n\n${_guide!.summary}\n\n(Offline Emergency Safety Guide — Golden Hour ICE)',
      subject: _guide!.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _guide?.title ?? 'Emergency Guide',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_guide != null)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share Guide',
              onPressed: _shareGuide,
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Back to Guides'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _callEmergency,
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                  label: const Text('Call 112'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _loadGuide,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Guide Header Card
                      _buildHeaderCard(context, _guide!, isDark),
                      const SizedBox(height: 16),

                      // Emergency Disclaimer Banner
                      _buildEmergencyBanner(context, isDark),
                      const SizedBox(height: 16),

                      // Markdown Guide Content
                      _buildMarkdownRenderer(context, _guide!.content ?? '', isDark),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    EmergencyGuide guide,
    bool isDark,
  ) {
    final catColor = getCategoryColor(guide.category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              getGuideIcon(guide.iconName),
              color: catColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guide.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        guide.category,
                        style: TextStyle(
                          color: catColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${guide.readTimeMinutes} min read',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.primary,
            size: 22,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'EMERGENCY NOTICE: If this is an active life-threatening crisis, call emergency services (112 / 911 / 108) immediately. Follow these instructions as bystander guidance while help is en route.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownRenderer(
    BuildContext context,
    String content,
    bool isDark,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: textTheme.bodyMedium?.copyWith(
          color: primaryColor,
          height: 1.5,
          fontSize: 14,
        ),
        h1: textTheme.headlineSmall?.copyWith(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        h2: textTheme.titleLarge?.copyWith(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        h3: textTheme.titleMedium?.copyWith(
          color: primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        h4: textTheme.titleSmall?.copyWith(
          color: primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        strong: TextStyle(
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        em: TextStyle(
          fontStyle: FontStyle.italic,
          color: primaryColor,
        ),
        blockquote: textTheme.bodyMedium?.copyWith(
          color: primaryColor,
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            left: BorderSide(color: AppColors.primary, width: 4),
          ),
        ),
        code: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          backgroundColor: isDark ? AppColors.borderDark : AppColors.border,
          fontSize: 12,
        ),
        tableHead: TextStyle(
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        tableBody: TextStyle(
          color: primaryColor,
        ),
        tableBorder: TableBorder.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
        listBullet: TextStyle(
          color: secondaryColor,
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

