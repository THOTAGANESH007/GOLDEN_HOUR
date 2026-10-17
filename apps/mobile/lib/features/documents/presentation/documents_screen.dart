import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/document_models.dart';
import '../domain/document_provider.dart';
import 'document_viewer_screen.dart';
import 'upload_document_bottom_sheet.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final docState = ref.watch(documentNotifierProvider);
    final filteredDocs = docState.filteredDocuments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Documents'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(documentNotifierProvider.notifier).loadDocuments(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => UploadDocumentBottomSheet.show(context),
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Upload Document'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(documentNotifierProvider.notifier).loadDocuments(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Privacy Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_rounded,
                          color: AppColors.info, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Encrypted & Confidential: Uploaded records are strictly private and NEVER exposed on the public QR scan endpoint.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.8),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All Documents'),
                        selected: docState.selectedFilter == 'all',
                        onSelected: (_) => ref
                            .read(documentNotifierProvider.notifier)
                            .setFilter('all'),
                      ),
                      const SizedBox(width: 8),
                      ...DocumentType.values.map((type) {
                        final isSelected =
                            docState.selectedFilter == type.key;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(type.label),
                            selected: isSelected,
                            selectedColor:
                                type.color.withValues(alpha: 0.2),
                            checkmarkColor: type.color,
                            onSelected: (_) => ref
                                .read(documentNotifierProvider.notifier)
                                .setFilter(type.key),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Documents List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saved Documents (${filteredDocs.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (docState.isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                if (filteredDocs.isEmpty && !docState.isLoading)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 36),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.folder_open_rounded,
                              size: 48,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.35),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No Documents Found',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Keep your prescriptions, blood tests, and health insurance cards readily accessible in one secure vault.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.65),
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  UploadDocumentBottomSheet.show(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Upload Your First Document'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredDocs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      return _buildDocumentCard(context, ref, doc);
                    },
                  ),

                const SizedBox(height: 80), // Padding for FAB
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    WidgetRef ref,
    DocumentItem doc,
  ) {
    final theme = Theme.of(context);
    final typeEnum = doc.typeEnum;
    final dateStr = DateFormat('MMM d, yyyy').format(doc.uploadedAt);

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DocumentViewerScreen(document: doc),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: typeEnum.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(typeEnum.icon, color: typeEnum.color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.fileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeEnum.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            typeEnum.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: typeEnum.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${doc.formattedSize} • $dateStr',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Document?'),
                      content: Text(
                        'Are you sure you want to delete "${doc.fileName}"? This cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    ref
                        .read(documentNotifierProvider.notifier)
                        .deleteDocument(doc.id);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
