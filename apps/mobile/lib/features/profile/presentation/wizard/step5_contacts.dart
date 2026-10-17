import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/profile_models.dart';

class Step5Contacts extends StatefulWidget {
  final List<EmergencyContact> contacts;
  final ValueChanged<List<EmergencyContact>> onChanged;

  const Step5Contacts({
    super.key,
    required this.contacts,
    required this.onChanged,
  });

  @override
  State<Step5Contacts> createState() => _Step5ContactsState();
}

class _Step5ContactsState extends State<Step5Contacts> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedRelation = 'Spouse';
  bool _whatsappEnabled = true;
  bool _notifyOnScan = true;

  static const List<String> relationOptions = [
    'Spouse',
    'Parent',
    'Child',
    'Sibling',
    'Friend',
    'Doctor',
    'Guardian',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _addContact() {
    if (widget.contacts.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 emergency contacts allowed'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    var phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter contact name and phone number')),
      );
      return;
    }

    // Auto-prefix +91 if 10-digit number entered without country code
    if (!phone.startsWith('+')) {
      final digits = phone.replaceAll(RegExp(r'\D'), '');
      if (digits.length == 10) {
        phone = '+91$digits';
      } else {
        phone = '+$digits';
      }
    }

    final newContact = EmergencyContact(
      name: name,
      relation: _selectedRelation,
      phone: phone,
      whatsappEnabled: _whatsappEnabled,
      notifyOnScan: _notifyOnScan,
      sortOrder: widget.contacts.length,
    );

    widget.onChanged([...widget.contacts, newContact]);

    _nameController.clear();
    _phoneController.clear();
  }

  void _removeContact(int index) {
    final updated = List<EmergencyContact>.from(widget.contacts)..removeAt(index);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canAddMore = widget.contacts.length < 5;

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
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.contact_emergency_rounded,
                  color: AppColors.success,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Contacts',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Notified immediately with GPS when your QR code is scanned',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Add contact card
          if (canAddMore)
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
                      'Add Emergency Contact (${widget.contacts.length}/5)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedRelation,
                            decoration: const InputDecoration(
                              labelText: 'Relationship',
                              prefixIcon: Icon(Icons.people_outline),
                            ),
                            items: relationOptions.map((r) {
                              return DropdownMenuItem(value: r, child: Text(r));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedRelation = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              hintText: '+919876543210',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Toggles
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('WhatsApp Notifications',
                          style: TextStyle(fontSize: 14)),
                      subtitle: const Text(
                        'Send location & hospital alerts via WhatsApp',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _whatsappEnabled,
                      onChanged: (val) => setState(() => _whatsappEnabled = val),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Notify Immediately on Scan',
                          style: TextStyle(fontSize: 14)),
                      subtitle: const Text(
                        'Trigger SMS and WhatsApp alert when responder scans QR',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _notifyOnScan,
                      onChanged: (val) => setState(() => _notifyOnScan = val),
                    ),
                    const SizedBox(height: 12),

                    FilledButton.icon(
                      onPressed: _addContact,
                      icon: const Icon(Icons.person_add_rounded),
                      label: const Text('Add Contact to Profile'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Maximum limit reached (5 contacts). You can remove an existing contact to add a new one.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          if (widget.contacts.isNotEmpty) ...[
            Text(
              'Added Contacts (${widget.contacts.length}):',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.contacts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final c = widget.contacts[index];
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      child: Text(
                        c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          c.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            c.relation,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(c.phone),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (c.whatsappEnabled)
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.chat_bubble_outline,
                                        size: 14, color: AppColors.success),
                                    SizedBox(width: 2),
                                    Text('WhatsApp',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.success)),
                                  ],
                                ),
                              ),
                            if (c.notifyOnScan)
                              const Row(
                                children: [
                                  Icon(Icons.notifications_active_outlined,
                                      size: 14, color: AppColors.primary),
                                  SizedBox(width: 2),
                                  Text('Scan Alerts',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.primary)),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.error),
                      onPressed: () => _removeContact(index),
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
