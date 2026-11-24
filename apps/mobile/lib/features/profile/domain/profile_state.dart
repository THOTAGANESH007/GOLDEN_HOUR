import '../data/profile_models.dart';

class ProfileState {
  final bool isLoading;
  final bool isSaving;
  final bool isBroadcasting;
  final String? errorMessage;
  final PatientProfile? profile;
  final ProfileCompletion? completion;
  final List<EmergencyContact> contacts;
  final List<ContactGroup> contactGroups;
  final BroadcastResult? lastBroadcastResult;

  const ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.isBroadcasting = false,
    this.errorMessage,
    this.profile,
    this.completion,
    this.contacts = const [],
    this.contactGroups = const [],
    this.lastBroadcastResult,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isBroadcasting,
    String? errorMessage,
    bool clearError = false,
    PatientProfile? profile,
    ProfileCompletion? completion,
    List<EmergencyContact>? contacts,
    List<ContactGroup>? contactGroups,
    BroadcastResult? lastBroadcastResult,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isBroadcasting: isBroadcasting ?? this.isBroadcasting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      profile: profile ?? this.profile,
      completion: completion ?? this.completion,
      contacts: contacts ?? this.contacts,
      contactGroups: contactGroups ?? this.contactGroups,
      lastBroadcastResult: lastBroadcastResult ?? this.lastBroadcastResult,
    );
  }
}
