import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/profile_models.dart';
import '../../domain/profile_provider.dart';
import 'step1_blood_group.dart';
import 'step2_allergies.dart';
import 'step3_conditions.dart';
import 'step4_medications.dart';
import 'step5_contacts.dart';

class ProfileWizardScreen extends ConsumerStatefulWidget {
  const ProfileWizardScreen({super.key});

  @override
  ConsumerState<ProfileWizardScreen> createState() =>
      _ProfileWizardScreenState();
}

class _ProfileWizardScreenState extends ConsumerState<ProfileWizardScreen> {
  int _currentStep = 0;

  String? _bloodGroup;
  List<String> _allergies = [];
  List<String> _conditions = [];
  List<MedicationItem> _medications = [];
  List<EmergencyContact> _contacts = [];

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Prefill with existing profile data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(profileNotifierProvider);
      if (state.profile != null) {
        setState(() {
          _bloodGroup = state.profile!.bloodGroup;
          _allergies = List.from(state.profile!.allergies);
          _conditions = List.from(state.profile!.chronicConditions);
          _medications = List.from(state.profile!.medications);
          _contacts = List.from(state.contacts);
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (step < 0 || step > 4) return;
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitWizard() async {
    final currentProfile = ref.read(profileNotifierProvider).profile;
    final updatedProfile = (currentProfile ??
            const PatientProfile(id: '', userId: ''))
        .copyWith(
      bloodGroup: _bloodGroup,
      allergies: _allergies,
      chronicConditions: _conditions,
      medications: _medications,
      wizardCompleted: true,
    );

    final success =
        await ref.read(profileNotifierProvider.notifier).submitWizard(
              profileUpdates: updatedProfile,
              newContacts: _contacts,
            );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Emergency Profile saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/home');
    } else {
      final error = ref.read(profileNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to save profile. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  static const List<String> stepTitles = [
    'Blood Group',
    'Allergies',
    'Conditions',
    'Medications',
    'Emergency Contacts',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = ref.watch(profileNotifierProvider);
    final isSaving = profileState.isSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Profile Setup'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Indicator Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: theme.colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${_currentStep + 1} of 5: ${stepTitles[_currentStep]}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${((_currentStep + 1) / 5 * 100).toInt()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / 5,
                      minHeight: 6,
                      backgroundColor:
                          theme.colorScheme.outline.withValues(alpha: 0.15),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            // Step Content Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Step1BloodGroup(
                    selectedBloodGroup: _bloodGroup,
                    onSelected: (group) => setState(() => _bloodGroup = group),
                  ),
                  Step2Allergies(
                    selectedAllergies: _allergies,
                    onChanged: (list) => setState(() => _allergies = list),
                  ),
                  Step3Conditions(
                    selectedConditions: _conditions,
                    onChanged: (list) => setState(() => _conditions = list),
                  ),
                  Step4Medications(
                    medications: _medications,
                    onChanged: (list) => setState(() => _medications = list),
                  ),
                  Step5Contacts(
                    contacts: _contacts,
                    onChanged: (list) => setState(() => _contacts = list),
                  ),
                ],
              ),
            ),

            // Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    OutlinedButton.icon(
                      onPressed: isSaving ? null : () => _goToStep(_currentStep - 1),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Back'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    )
                  else
                    const SizedBox(width: 80),
                  const Spacer(),
                  if (_currentStep < 4)
                    FilledButton.icon(
                      onPressed: () => _goToStep(_currentStep + 1),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('Next Step'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    )
                  else
                    FilledButton.icon(
                      onPressed: isSaving ? null : _submitWizard,
                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded, size: 18),
                      label: Text(
                          isSaving ? 'Saving Profile...' : 'Complete & Save'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
