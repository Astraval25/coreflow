import 'dart:io';

import 'package:coreflow/core/theme/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FileSourceBottomSheet extends StatelessWidget {
  const FileSourceBottomSheet({super.key});

  static Future<File?> show(BuildContext context) {
    return showModalBottomSheet<File>(
      context: context,
      backgroundColor: LoginColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const FileSourceBottomSheet(),
    );
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (picked != null && context.mounted) {
        Navigator.pop(context, File(picked.path));
      }
    } catch (_) {
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (picked != null && context.mounted) {
        Navigator.pop(context, File(picked.path));
      }
    } catch (_) {
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _pickDocument(BuildContext context) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null &&
          result.files.single.path != null &&
          context.mounted) {
        Navigator.pop(context, File(result.files.single.path!));
      }
    } catch (_) {
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: LoginColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select Source',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _SourceTile(
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            subtitle: 'Take a photo',
            onTap: () => _pickFromCamera(context),
          ),
          const SizedBox(height: 8),
          _SourceTile(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            subtitle: 'Pick an image',
            onTap: () => _pickFromGallery(context),
          ),
          const SizedBox(height: 8),
          _SourceTile(
            icon: Icons.description_rounded,
            label: 'Documents',
            subtitle: 'Pick a PDF or image file',
            onTap: () => _pickDocument(context),
          ),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: LoginColors.fieldFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LoginColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, color: LoginColors.primary, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: LoginColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: LoginColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: LoginColors.textTertiary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
