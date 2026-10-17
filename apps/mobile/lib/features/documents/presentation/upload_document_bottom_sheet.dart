import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../data/document_models.dart';
import '../domain/document_provider.dart';

class UploadDocumentBottomSheet extends ConsumerStatefulWidget {
  const UploadDocumentBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const UploadDocumentBottomSheet(),
    );
  }

  @override
  ConsumerState<UploadDocumentBottomSheet> createState() =>
      _UploadDocumentBottomSheetState();
}

class _UploadDocumentBottomSheetState
    extends ConsumerState<UploadDocumentBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  DocumentType _selectedType = DocumentType.prescription;
  String? _pickedFilePath;
  int? _pickedFileSize;
  String? _pickedMimeType;
  bool _isPicking = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    setState(() => _isPicking = true);
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null) {
        final file = File(photo.path);
        final size = await file.length();
        setState(() {
          _pickedFilePath = photo.path;
          _pickedFileSize = size;
          _pickedMimeType = 'image/jpeg';
          if (_nameController.text.isEmpty) {
            _nameController.text =
                'Camera_${DateTime.now().millisecondsSinceEpoch}.jpg';
          }
        });
      }
    } catch (e) {
      debugPrint('Camera pick error: $e');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isPicking = true);
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (photo != null) {
        final file = File(photo.path);
        final size = await file.length();
        setState(() {
          _pickedFilePath = photo.path;
          _pickedFileSize = size;
          _pickedMimeType = photo.mimeType ?? 'image/jpeg';
          if (_nameController.text.isEmpty) {
            _nameController.text = photo.name;
          }
        });
      }
    } catch (e) {
      debugPrint('Gallery pick error: $e');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _pickFromFileManager() async {
    setState(() => _isPicking = true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );
      if (result != null && result.files.isNotEmpty) {
        final picked = result.files.first;
        setState(() {
          _pickedFilePath = picked.path;
          _pickedFileSize = picked.size;
          _pickedMimeType = picked.extension == 'pdf'
              ? 'application/pdf'
              : 'image/${picked.extension}';
          if (_nameController.text.isEmpty) {
            _nameController.text = picked.name;
          }
        });
      }
    } catch (e) {
      debugPrint('File picker error: $e');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _upload() async {
    if (_pickedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload')),
      );
      return;
    }

    if (_pickedFileSize != null && _pickedFileSize! > 10 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File too large — maximum limit is 10 MB'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final fileName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Medical_Document';

    final success =
        await ref.read(documentNotifierProvider.notifier).uploadDocument(
              fileName: fileName,
              fileType: _selectedType.key,
              mimeType: _pickedMimeType ?? 'application/octet-stream',
              filePath: _pickedFilePath,
            );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Document uploaded securely!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final err = ref.read(documentNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Failed to upload document'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUploading = ref.watch(documentNotifierProvider).isUploading;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upload Medical Document',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pick Sources Row
          Row(
            children: [
              _buildSourceButton(
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                color: AppColors.primary,
                onTap: _isPicking ? null : _pickFromCamera,
              ),
              const SizedBox(width: 12),
              _buildSourceButton(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                color: AppColors.info,
                onTap: _isPicking ? null : _pickFromGallery,
              ),
              const SizedBox(width: 12),
              _buildSourceButton(
                icon: Icons.picture_as_pdf_rounded,
                label: 'PDF / File',
                color: AppColors.secondary,
                onTap: _isPicking ? null : _pickFromFileManager,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // File Picked Indicator
          if (_pickedFilePath != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ready: ${_pickedFilePath!.split('/').last}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Document Category Selector
          Text(
            'Document Category',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: DocumentType.values.map((type) {
                final isSelected = _selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Icon(type.icon, size: 16, color: isSelected ? Colors.white : type.color),
                    label: Text(type.label),
                    selected: isSelected,
                    selectedColor: type.color,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (_) => setState(() => _selectedType = type),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // File Name Input
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Document Name',
              hintText: 'e.g. Cardiologist Prescription - Oct 2026',
              prefixIcon: Icon(Icons.drive_file_rename_outline),
            ),
          ),

          const SizedBox(height: 20),

          // Upload Action Button
          FilledButton.icon(
            onPressed: isUploading ? null : _upload,
            icon: isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.cloud_upload_rounded),
            label: Text(isUploading ? 'Uploading to Secure Cloud...' : 'Upload Document'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
