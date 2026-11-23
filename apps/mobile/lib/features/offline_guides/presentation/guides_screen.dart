import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../data/guide_model.dart';
import '../domain/guide_provider.dart';

IconData getGuideIcon(String iconName) {
  switch (iconName) {
    case 'favorite_rounded':
      return Icons.favorite_rounded;
    case 'air_rounded':
      return Icons.air_rounded;
    case 'water_drop_rounded':
      return Icons.water_drop_rounded;
    case 'accessibility_new_rounded':
      return Icons.accessibility_new_rounded;
    case 'local_fire_department_rounded':
      return Icons.local_fire_department_rounded;
    case 'wb_sunny_rounded':
      return Icons.wb_sunny_rounded;
    case 'shield_rounded':
      return Icons.shield_rounded;
    case 'monitor_heart_rounded':
      return Icons.monitor_heart_rounded;
    default:
      return Icons.menu_book_rounded;
  }
}

Color getCategoryColor(String category) {
  switch (category) {
    case 'Cardiac & Breathing':
      return AppColors.primary;
    case 'Trauma & Wounds':
      return AppColors.error;
    case 'Burns & Heat':
      return AppColors.secondary;
    case 'Environmental':
      return AppColors.warning;
    case 'General Safety':
      return AppColors.info;
    default:
      return AppColors.primary;
  }
}

class GuidesScreen extends ConsumerStatefulWidget {
  const GuidesScreen({super.key});

  @override
  ConsumerState<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends ConsumerState<GuidesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guideState = ref.watch(guideNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Safety Guides'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.offline_pin_rounded, color: AppColors.success, size: 14),
                SizedBox(width: 4),
                Text(
                  '100% Offline',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Filter Chips Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      ref.read(guideNotifierProvider.notifier).search(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search guides (e.g. CPR, bleeding, burns)...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(guideNotifierProvider.notifier)
                                    .clearSearch();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Category Filter Chips
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: guideState.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = guideState.categories[index];
                        final isSelected = guideState.selectedCategory == cat;
                        return FilterChip(
                          selected: isSelected,
                          label: Text(cat),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary),
                          ),
                          selectedColor: AppColors.primary,
                          backgroundColor:
                              isDark ? AppColors.surfaceDark : Colors.white,
                          showCheckmark: false,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.border),
                          ),
                          onSelected: (_) {
                            ref
                                .read(guideNotifierProvider.notifier)
                                .selectCategory(cat);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Guides List View
            Expanded(
              child: guideState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : guideState.filteredGuides.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.search_off_rounded,
                          title: 'No guides found',
                          description: _searchController.text.isNotEmpty
                              ? 'No emergency guides match "${_searchController.text}".'
                              : 'No guides available in this category.',
                          buttonLabel: 'Reset Filters',
                          onButtonPressed: () {
                            _searchController.clear();
                            ref
                                .read(guideNotifierProvider.notifier)
                                .clearSearch();
                            ref
                                .read(guideNotifierProvider.notifier)
                                .selectCategory('All');
                          },
                        )
                      : ListView.separated(
                          padding: AppSpacing.screenPadding,
                          itemCount: guideState.filteredGuides.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final guide = guideState.filteredGuides[index];
                            return _GuideCard(guide: guide);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final EmergencyGuide guide;

  const _GuideCard({required this.guide});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = getCategoryColor(guide.category);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: () {
          context.push('/guides/${guide.id}');
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Icon Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  getGuideIcon(guide.iconName),
                  color: catColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Title, Summary, and Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      guide.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Badges Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            guide.category,
                            style: TextStyle(
                              color: catColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${guide.readTimeMinutes} min read',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
