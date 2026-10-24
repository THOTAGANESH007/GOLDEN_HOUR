import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/profile_models.dart';
import '../domain/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _doctorPhoneController = TextEditingController();
  final TextEditingController _surgeryController = TextEditingController();
  final TextEditingController _implantController = TextEditingController();

  String? _gender;
  String? _bloodGroup;
  String? _photoUrl;
  bool _isUploadingPhoto = false;
  List<String> _allergies = [];
  List<String> _conditions = [];
  List<MedicationItem> _medications = [];
  List<String> _pastSurgeries = [];
  List<String> _implants = [];
  bool _isOrganDonor = false;
  bool _initialized = false;

  static const List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Unknown',
  ];

  static const List<String> genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _doctorNameController.dispose();
    _doctorPhoneController.dispose();
    _surgeryController.dispose();
    _implantController.dispose();
    super.dispose();
  }

  void _initFromProfile(PatientProfile profile) {
    if (_initialized) return;
    _fullNameController.text = profile.fullName ?? '';
    _ageController.text = (profile.age != null) ? profile.age.toString() : '';
    _gender = profile.gender;
    _bloodGroup = profile.bloodGroup;
    _photoUrl = profile.photoUrl;
    _allergies = List.from(profile.allergies);
    _conditions = List.from(profile.chronicConditions);
    _medications = List.from(profile.medications);
    _pastSurgeries = List.from(profile.pastSurgeries);
    _implants = List.from(profile.implants);
    _isOrganDonor = profile.isOrganDonor;
    _doctorNameController.text = profile.doctorName ?? '';
    _doctorPhoneController.text = profile.doctorPhone ?? '';
    _initialized = true;
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile == null) return;

      setState(() => _isUploadingPhoto = true);
      final success = await ref
          .read(profileNotifierProvider.notifier)
          .uploadPhoto(pickedFile.path);

      if (!mounted) return;
      setState(() {
        _isUploadingPhoto = false;
        if (success) {
          _photoUrl = ref.read(profileNotifierProvider).profile?.photoUrl;
        }
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        final err = ref.read(profileNotifierProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? 'Failed to upload photo'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Profile Photo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                  ),
                  title: const Text('Take a photo'),
                  subtitle: const Text('Use device camera'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndUploadPhoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.photo_library_rounded, color: AppColors.primary),
                  ),
                  title: const Text('Choose from gallery'),
                  subtitle: const Text('Select existing photo'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndUploadPhoto(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addSurgery() {
    final text = _surgeryController.text.trim();
    if (text.isNotEmpty && !_pastSurgeries.contains(text)) {
      setState(() {
        _pastSurgeries.add(text);
        _surgeryController.clear();
      });
    }
  }

  void _addImplant() {
    final text = _implantController.text.trim();
    if (text.isNotEmpty && !_implants.contains(text)) {
      setState(() {
        _implants.add(text);
        _implantController.clear();
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final ageVal = int.tryParse(_ageController.text.trim());
    final updateData = <String, dynamic>{
      'full_name': _fullNameController.text.trim(),
      if (ageVal != null) 'age': ageVal,
      'gender': _gender,
      'blood_group': _bloodGroup,
      'allergies': _allergies,
      'chronic_conditions': _conditions,
      'medications': _medications.map((m) => m.toJson()).toList(),
      'past_surgeries': _pastSurgeries,
      'implants': _implants,
      'is_organ_donor': _isOrganDonor,
      'doctor_name': _doctorNameController.text.trim(),
      'doctor_phone': _doctorPhoneController.text.trim(),
    };

    final success = await ref
        .read(profileNotifierProvider.notifier)
        .updateProfile(updateData);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      final err = ref.read(profileNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Failed to update profile'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = ref.watch(profileNotifierProvider);
    if (profileState.profile != null) {
      _initFromProfile(profileState.profile!);
    }
    final isSaving = profileState.isSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Patient Profile'),
        actions: [
          TextButton(
            onPressed: isSaving ? null : _saveProfile,
            child: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Photo Upload Avatar
                _buildPhotoAvatar(),
                const SizedBox(height: 20),

                // Personal Details Card
                _buildSectionHeader('Personal Information', Icons.person_rounded),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _fullNameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Legal Name',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Age (Years)',
                                  prefixIcon: Icon(Icons.cake_outlined),
                                  hintText: 'e.g. 28',
                                ),
                                validator: (val) {
                                  if (val != null && val.isNotEmpty) {
                                    final n = int.tryParse(val);
                                    if (n == null || n < 0 || n > 130) {
                                      return 'Valid age 0-130';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _gender,
                                decoration: const InputDecoration(
                                  labelText: 'Gender',
                                  prefixIcon: Icon(Icons.people_outline),
                                ),
                                items: genderOptions.map((g) {
                                  return DropdownMenuItem(
                                      value: g, child: Text(g));
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => _gender = val),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Critical Medical Data
                _buildSectionHeader(
                    'Emergency Medical Info', Icons.medical_services_rounded),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _bloodGroup,
                          decoration: const InputDecoration(
                            labelText: 'Blood Group',
                            prefixIcon: Icon(Icons.bloodtype_rounded,
                                color: AppColors.primary),
                          ),
                          items: bloodGroups.map((b) {
                            return DropdownMenuItem(value: b, child: Text(b));
                          }).toList(),
                          onChanged: (val) => setState(() => _bloodGroup = val),
                        ),
                        const SizedBox(height: 16),

                        // Organ Donor Toggle
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Registered Organ Donor',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: const Text(
                            'Displays verified donor status on emergency scan',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _isOrganDonor,
                          onChanged: (val) =>
                              setState(() => _isOrganDonor = val),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Surgeries & Implants
                _buildSectionHeader(
                    'Surgical History & Implants', Icons.healing_rounded),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Past Major Surgeries',
                            style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _surgeryController,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. Appendectomy, CABG Bypass',
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                ),
                                onSubmitted: (_) => _addSurgery(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: _addSurgery,
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                        if (_pastSurgeries.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: _pastSurgeries.map((s) {
                              return Chip(
                                label: Text(s),
                                onDeleted: () =>
                                    setState(() => _pastSurgeries.remove(s)),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text('Medical Implants / Devices',
                            style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _implantController,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. Titanium plate, Pacemaker',
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                ),
                                onSubmitted: (_) => _addImplant(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: _addImplant,
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                        if (_implants.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: _implants.map((i) {
                              return Chip(
                                label: Text(i),
                                onDeleted: () =>
                                    setState(() => _implants.remove(i)),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Primary Physician
                _buildSectionHeader(
                    'Primary Physician', Icons.local_hospital_rounded),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _doctorNameController,
                          decoration: const InputDecoration(
                            labelText: 'Doctor / Clinic Name',
                            prefixIcon: Icon(Icons.person_pin_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _doctorPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Doctor Contact Number',
                            prefixIcon: Icon(Icons.phone_outlined),
                            hintText: '+919876543210',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                FilledButton.icon(
                  onPressed: isSaving ? null : _saveProfile,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save All Changes'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoAvatar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 3,
                  ),
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                ),
                child: ClipOval(
                  child: _isUploadingPhoto
                      ? const Center(
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        )
                      : (_photoUrl != null && _photoUrl!.isNotEmpty)
                          ? Image.network(
                              _photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.person_rounded,
                                size: 56,
                                color: AppColors.textSecondary,
                              ),
                            )
                          : const Icon(
                              Icons.person_rounded,
                              size: 56,
                              color: AppColors.textSecondary,
                            ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _isUploadingPhoto ? null : _showPhotoOptions,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _isUploadingPhoto ? null : _showPhotoOptions,
            icon: const Icon(Icons.add_a_photo_outlined, size: 16),
            label: Text(
              _photoUrl != null && _photoUrl!.isNotEmpty
                  ? 'Change Profile Photo'
                  : 'Add Profile Photo',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
