import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/profile_models.dart';

class Step4Medications extends StatefulWidget {
  final List<MedicationItem> medications;
  final ValueChanged<List<MedicationItem>> onChanged;

  const Step4Medications({
    super.key,
    required this.medications,
    required this.onChanged,
  });

  @override
  State<Step4Medications> createState() => _Step4MedicationsState();
}

class _Step4MedicationsState extends State<Step4Medications> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  String _selectedFrequency = 'Once daily';

  static const List<String> frequencyOptions = [
    'Once daily',
    'Twice daily',
    'Thrice daily',
    'Morning only',
    'Night only',
    'As needed (PRN)',
    'Weekly',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  void _addMedication() {
    final name = _nameController.text.trim();
    final dosage = _dosageController.text.trim();

    if (name.isEmpty) return;

    final updated = List<MedicationItem>.from(widget.medications)
      ..add(
        MedicationItem(
          name: name,
          dosage: dosage.isNotEmpty ? dosage : 'Standard',
          frequency: _selectedFrequency,
        ),
      );

    widget.onChanged(updated);
    _nameController.clear();
    _dosageController.clear();
  }

  void _removeMedication(int index) {
    final updated = List<MedicationItem>.from(widget.medications)..removeAt(index);
    widget.onChanged(updated);
  }

  void _setNoMedications() {
    widget.onChanged([]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  color: AppColors.infoLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medication_rounded,
                  color: AppColors.info,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Medications',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Critical to prevent drug-drug interactions (e.g. Blood Thinners, Insulin)',
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

          // Quick button
          OutlinedButton.icon(
            onPressed: _setNoMedications,
            icon: Icon(
              widget.medications.isEmpty
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: widget.medications.isEmpty ? AppColors.success : null,
            ),
            label: const Text('Not Taking Any Regular Medications'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              backgroundColor: widget.medications.isEmpty
                  ? AppColors.successLight
                  : null,
              side: BorderSide(
                color: widget.medications.isEmpty
                    ? AppColors.success
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Add Medication Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Medication',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Medication Name',
                      hintText: 'e.g. Metformin, Warfarin, Aspirin',
                      prefixIcon: Icon(Icons.medication_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _dosageController,
                          decoration: const InputDecoration(
                            labelText: 'Dosage',
                            hintText: 'e.g. 500mg, 10ml',
                            prefixIcon: Icon(Icons.scale_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedFrequency,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Frequency',
                            prefixIcon: Icon(Icons.schedule_rounded),
                          ),
                          items: frequencyOptions.map((f) {
                            return DropdownMenuItem(
                              value: f,
                              child: Text(f, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedFrequency = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _addMedication,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Medication to List'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          if (widget.medications.isNotEmpty) ...[
            Text(
              'Active Medications (${widget.medications.length}):',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.medications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final med = widget.medications[index];
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.infoLight,
                      child: Icon(Icons.medication_rounded, color: AppColors.info),
                    ),
                    title: Text(
                      med.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${med.dosage} • ${med.frequency}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.error),
                      onPressed: () => _removeMedication(index),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
