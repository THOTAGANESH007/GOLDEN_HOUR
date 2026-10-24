import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class Step2Allergies extends StatefulWidget {
  final List<String> selectedAllergies;
  final ValueChanged<List<String>> onChanged;

  const Step2Allergies({
    super.key,
    required this.selectedAllergies,
    required this.onChanged,
  });

  @override
  State<Step2Allergies> createState() => _Step2AllergiesState();
}

class _Step2AllergiesState extends State<Step2Allergies> {
  final TextEditingController _customController = TextEditingController();

  static const List<String> commonAllergies = [
    'Penicillin',
    'Sulfa Drugs',
    'Aspirin',
    'Ibuprofen / NSAIDs',
    'Peanuts',
    'Tree Nuts',
    'Shellfish',
    'Latex',
    'Contrast Dye',
    'Eggs',
    'Bee Stings',
  ];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _toggleAllergy(String allergy) {
    final list = List<String>.from(widget.selectedAllergies);
    if (list.contains(allergy)) {
      list.remove(allergy);
    } else {
      list.remove('No Known Allergies');
      list.add(allergy);
    }
    widget.onChanged(list);
  }

  void _addCustomAllergy() {
    final text = _customController.text.trim();
    if (text.isEmpty) return;

    final list = List<String>.from(widget.selectedAllergies);
    list.remove('No Known Allergies');
    if (!list.contains(text)) {
      list.add(text);
      widget.onChanged(list);
    }
    _customController.clear();
  }

  void _setNoKnownAllergies() {
    widget.onChanged(['No Known Allergies']);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasNoAllergies =
        widget.selectedAllergies.contains('No Known Allergies');

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Allergies & Reactions',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Prevents fatal anaphylaxis or contraindicated drug delivery',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick button for No Known Allergies
          Builder(
            builder: (context) {
              final isDark = theme.brightness == Brightness.dark;
              final Color activeBg = isDark
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.successLight;
              final Color activeText = isDark
                  ? const Color(0xFF4ADE80)
                  : const Color(0xFF15803D);

              return OutlinedButton.icon(
                onPressed: _setNoKnownAllergies,
                icon: Icon(
                  hasNoAllergies
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  color: hasNoAllergies
                      ? (isDark ? const Color(0xFF4ADE80) : AppColors.success)
                      : null,
                ),
                label: Text(
                  'No Known Drug / Food Allergies (NKDA)',
                  style: TextStyle(
                    color: hasNoAllergies ? activeText : null,
                    fontWeight:
                        hasNoAllergies ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  backgroundColor: hasNoAllergies ? activeBg : null,
                  side: BorderSide(
                    color: hasNoAllergies
                        ? (isDark
                            ? const Color(0xFF22C55E)
                            : AppColors.success)
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: hasNoAllergies ? 1.5 : 1.0,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Custom Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customController,
                  decoration: const InputDecoration(
                    hintText: 'Add custom allergy (e.g. Ciprofloxacin)',
                    prefixIcon: Icon(Icons.add_circle_outline),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _addCustomAllergy(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _addCustomAllergy,
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Common High-Risk Allergies:',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Preset Chips Wrap
          Builder(
            builder: (context) {
              final isDark = theme.brightness == Brightness.dark;
              final Color chipSelectedBg = isDark
                  ? AppColors.error.withValues(alpha: 0.22)
                  : AppColors.errorLight;
              final Color chipSelectedColor =
                  isDark ? const Color(0xFFFCA5A5) : AppColors.error;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: commonAllergies.map((allergy) {
                  final isSelected = widget.selectedAllergies.contains(allergy);
                  return FilterChip(
                    label: Text(allergy),
                    selected: isSelected,
                    selectedColor: chipSelectedBg,
                    checkmarkColor: chipSelectedColor,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? chipSelectedColor
                          : theme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    onSelected: (_) => _toggleAllergy(allergy),
                  );
                }).toList(),
              );
            },
          ),

          if (widget.selectedAllergies.isNotEmpty && !hasNoAllergies) ...[
            const SizedBox(height: 24),
            Text(
              'Selected Allergies (${widget.selectedAllergies.length}):',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final isDark = theme.brightness == Brightness.dark;
                final Color chipBg = isDark
                    ? AppColors.error.withValues(alpha: 0.25)
                    : AppColors.errorLight;
                final Color chipTextColor =
                    isDark ? const Color(0xFFFCA5A5) : AppColors.error;

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.selectedAllergies.map((allergy) {
                    return Chip(
                      label: Text(allergy),
                      backgroundColor: chipBg,
                      labelStyle: TextStyle(
                        color: chipTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                      deleteIcon: const Icon(Icons.close_rounded, size: 16),
                      deleteIconColor: chipTextColor,
                      onDeleted: () => _toggleAllergy(allergy),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
