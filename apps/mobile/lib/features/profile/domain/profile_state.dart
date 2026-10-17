import '../data/profile_models.dart';

class ProfileState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final PatientProfile? profile;
  final ProfileCompletion? completion;
  final List<EmergencyContact> contacts;

  const ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.profile,
    this.completion,
    this.contacts = const [],
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    PatientProfile? profile,
    ProfileCompletion? completion,
    List<EmergencyContact>? contacts,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      profile: profile ?? this.profile,
      completion: completion ?? this.completion,
      contacts: contacts ?? this.contacts,
    );
  }
}
