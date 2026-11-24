import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_models.dart';
import '../data/profile_repository.dart';
import 'profile_state.dart';

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repo);
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repo;

  ProfileNotifier(this._repo) : super(const ProfileState()) {
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repo.getProfile(),
        _repo.getCompletion(),
        _repo.getContacts(),
        _repo.getContactGroups().catchError((_) => <ContactGroup>[]),
      ]);

      state = state.copyWith(
        isLoading: false,
        profile: results[0] as PatientProfile,
        completion: results[1] as ProfileCompletion,
        contacts: results[2] as List<EmergencyContact>,
        contactGroups: results[3] as List<ContactGroup>,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final updatedProfile = await _repo.updateProfile(data);
      final updatedCompletion = await _repo.getCompletion();
      state = state.copyWith(
        isSaving: false,
        profile: updatedProfile,
        completion: updatedCompletion,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> uploadPhoto(String filePath) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final updatedProfile = await _repo.uploadPhoto(filePath);
      state = state.copyWith(
        isSaving: false,
        profile: updatedProfile,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updatePrivacy({
    bool? showName,
    bool? showDob,
    bool? showPhoto,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final updatedProfile = await _repo.updatePrivacy(
        showName: showName,
        showDob: showDob,
        showPhoto: showPhoto,
      );
      state = state.copyWith(
        isSaving: false,
        profile: updatedProfile,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> toggleQrActive(bool isActive) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final updatedProfile = await _repo.updateQrStatus(isActive);
      state = state.copyWith(
        isSaving: false,
        profile: updatedProfile,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> addEmergencyContact(EmergencyContact contact) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final newContact = await _repo.addContact(contact);
      final updatedContacts = [...state.contacts, newContact];
      final updatedCompletion = await _repo.getCompletion();
      state = state.copyWith(
        isSaving: false,
        contacts: updatedContacts,
        completion: updatedCompletion,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateEmergencyContact(
    String contactId,
    Map<String, dynamic> updates,
  ) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final updated = await _repo.updateContact(contactId, updates);
      final updatedContacts = state.contacts
          .map((c) => c.id == contactId ? updated : c)
          .toList();
      state = state.copyWith(
        isSaving: false,
        contacts: updatedContacts,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> deleteEmergencyContact(String contactId) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repo.deleteContact(contactId);
      final updatedContacts =
          state.contacts.where((c) => c.id != contactId).toList();
      final updatedCompletion = await _repo.getCompletion();
      state = state.copyWith(
        isSaving: false,
        contacts: updatedContacts,
        completion: updatedCompletion,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> submitWizard({
    required PatientProfile profileUpdates,
    required List<EmergencyContact> newContacts,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final payload = profileUpdates.toUpdateJson();
      payload['wizard_completed'] = true;
      final updatedProfile = await _repo.updateProfile(payload);

      // Delete any contacts that were removed during the wizard
      final remainingIds = newContacts
          .map((c) => c.id)
          .where((id) => id != null && id.isNotEmpty)
          .toSet();
      for (final existing in state.contacts) {
        if (existing.id != null && !remainingIds.contains(existing.id)) {
          try {
            await _repo.deleteContact(existing.id!);
          } catch (_) {}
        }
      }

      // Add contacts that don't have an ID yet
      for (final contact in newContacts) {
        if (contact.id == null || contact.id!.isEmpty) {
          await _repo.addContact(contact);
        }
      }

      final results = await Future.wait([
        _repo.getCompletion(),
        _repo.getContacts(),
      ]);

      state = state.copyWith(
        isSaving: false,
        profile: updatedProfile,
        completion: results[0] as ProfileCompletion,
        contacts: results[1] as List<EmergencyContact>,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // ── Contact Groups & Broadcast Actions ─────────────────────────────────────

  Future<void> fetchContactGroups() async {
    try {
      final groups = await _repo.getContactGroups();
      state = state.copyWith(contactGroups: groups);
    } catch (e) {
      // Non-fatal, retain existing groups
    }
  }

  Future<bool> createContactGroup(String name, {String? description}) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final newGroup = await _repo.createContactGroup(name, description: description);
      state = state.copyWith(
        isSaving: false,
        contactGroups: [...state.contactGroups, newGroup],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateContactGroup(
    String groupId, {
    String? name,
    String? description,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final updated = await _repo.updateContactGroup(groupId, name: name, description: description);
      state = state.copyWith(
        isSaving: false,
        contactGroups: state.contactGroups.map((g) => g.id == groupId ? updated : g).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> deleteContactGroup(String groupId) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repo.deleteContactGroup(groupId);
      state = state.copyWith(
        isSaving: false,
        contactGroups: state.contactGroups.where((g) => g.id != groupId).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> addContactToGroup(String groupId, String contactId) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final updatedGroup = await _repo.addContactToGroup(groupId, contactId);
      final updatedGroups = state.contactGroups.map((g) => g.id == groupId ? updatedGroup : g).toList();
      final updatedContacts = state.contacts.map((c) {
        if (c.id == contactId) {
          return c.copyWith(groupId: groupId, groupName: updatedGroup.name);
        }
        return c;
      }).toList();

      state = state.copyWith(
        isSaving: false,
        contactGroups: updatedGroups,
        contacts: updatedContacts,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> removeContactFromGroup(String groupId, String contactId) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final updatedGroup = await _repo.removeContactFromGroup(groupId, contactId);
      final updatedGroups = state.contactGroups.map((g) => g.id == groupId ? updatedGroup : g).toList();
      final updatedContacts = state.contacts.map((c) {
        if (c.id == contactId) {
          return c.copyWith(groupId: null, groupName: null);
        }
        return c;
      }).toList();

      state = state.copyWith(
        isSaving: false,
        contactGroups: updatedGroups,
        contacts: updatedContacts,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<BroadcastResult?> broadcastEmergencyAlert({
    String? groupId,
    String? message,
    double? lat,
    double? lng,
    String? address,
  }) async {
    state = state.copyWith(isBroadcasting: true, clearError: true);
    try {
      final result = await _repo.broadcastEmergencyAlert(
        groupId: groupId,
        message: message,
        lat: lat,
        lng: lng,
        address: address,
      );
      state = state.copyWith(
        isBroadcasting: false,
        lastBroadcastResult: result,
      );
      return result;
    } catch (e) {
      state = state.copyWith(
        isBroadcasting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }
}
