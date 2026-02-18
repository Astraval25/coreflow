import 'dart:io';
import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class ItemImageUploader extends StatelessWidget {
  final File? selectedImage;
  final String? existingImageUrl;
  final VoidCallback onPickImage;
  final double height;

  const ItemImageUploader({
    super.key,
    required this.selectedImage,
    this.existingImageUrl,
    required this.onPickImage,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImage,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: LoginColors.fieldFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: LoginColors.primary.withOpacity(0.2),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (selectedImage != null) {
      return _buildImageWrapper(Image.file(selectedImage!, fit: BoxFit.cover));
    }
    
    if (existingImageUrl != null) {
      return _buildImageWrapper(
        Image.network(
          existingImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildImageWrapper(Widget image) {
    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: LoginColors.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            color: LoginColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tap to upload image',
          style: TextStyle(
            color: LoginColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
