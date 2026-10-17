import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class Step3Conditions extends StatefulWidget {
  final List<String> selectedConditions;
  final ValueChanged<List<String>> onChanged;

  const Step3Conditions({
    super.key,
    required this.selectedConditions,
    required this.onChanged,
  });

  @override
  State<Step3Conditions> createState() => _Step3ConditionsState();
}

class _Step3ConditionsState extends State<Step3Conditions> {
  final TextEditingController _customController = TextEditingController();

  static const List<String> commonConditions = [
    'Diabetes (Type 1)',
    'Diabetes (Type 2)',
    'Hypertension',
    'Asthma / COPD',
    'Epilepsy / Seizures',
    'Coronary Artery Disease',
    'Chronic Kidney Disease',
    'Bleeding Disorder',
    'Pacemaker / ICD Implant',
    'Thyroid Disorder',
    'Organ Transplant Recipient',
  ];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _toggleCondition(String condition) {
    final list = List<String>.from(widget.selectedConditions);
    if (list.contains(condition)) {
      list.remove(condition);
    } else {
      list.remove('None');
      list.add(condition);
    }
    widget.onChanged(list);
  }

  void _addCustomCondition() {
    final text = _customController.text.trim();
    if (text.isEmpty) return;

    final list = List<String>.from(widget.selectedConditions);
    list.remove('None');
    if (!list.contains(text)) {
      list.add(text);
      widget.onChanged(list);
    }
    _customController.clear();
  }

  void _setNone() {
    widget.onChanged(['None']);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasNone = widget.selectedConditions.contains('None');

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.secondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chronic Conditions',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Helps emergency doctors rule out hypoglycemic or cardiac shock',
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

          // Quick None button
          OutlinedButton.icon(
            onPressed: _setNone,
            icon: Icon(
              hasNone
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: hasNone ? AppColors.success : null,
            ),
            label: const Text('No Pre-existing Chronic Conditions'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              backgroundColor: hasNone ? AppColors.successLight : null,
              side: BorderSide(
                color: hasNone
                    ? AppColors.success
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Custom Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customController,
                  decoration: const InputDecoration(
                    hintText: 'Add custom condition (e.g. Lupus)',
                    prefixIcon: Icon(Icons.add_circle_outline),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _addCustomCondition(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _addCustomCondition,
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Common Chronic Medical Conditions:',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: commonConditions.map((condition) {
              final isSelected = widget.selectedConditions.contains(condition);
              return FilterChip(
                label: Text(condition),
                selected: isSelected,
                selectedColor: AppColors.secondary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.secondary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColors.secondary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (_) => _toggleCondition(condition),
              );
            }).toList(),
          ),

          if (widget.selectedConditions.isNotEmpty && !hasNone) ...[
            const SizedBox(height: 24),
            Text(
              'Selected Conditions (${widget.selectedConditions.length}):',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.selectedConditions.map((condition) {
                return Chip(
                  label: Text(condition),
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                  labelStyle: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                  deleteIcon: const Icon(Icons.close_rounded, size: 16),
                  deleteIconColor: AppColors.secondary,
                  onDeleted: () => _toggleCondition(condition),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
