import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/photo_upload_service.dart';
import '../../../../core/di/service_locator.dart';

/// Widget for uploading and managing profile photos
class PhotoUploadWidget extends StatefulWidget {
  final String userId;
  final String? currentPhotoUrl;
  final Function(String photoUrl) onPhotoUploaded;
  final VoidCallback? onPhotoRemoved;
  final double size;
  final bool isProfilePhoto;

  const PhotoUploadWidget({
    super.key,
    required this.userId,
    this.currentPhotoUrl,
    required this.onPhotoUploaded,
    this.onPhotoRemoved,
    this.size = 120,
    this.isProfilePhoto = true,
  });

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  late final PhotoUploadService _photoUploadService;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _photoUploadService = ServiceLocator.instance<PhotoUploadService>();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            // Photo container
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1A1A),
                border: Border.all(
                  color: const Color(0xFF4CAF50),
                  width: 2,
                ),
              ),
              child: _buildPhotoContent(),
            ),
            
            // Upload/Edit button
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _isUploading ? null : _showPhotoOptions,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0A0A0A),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    widget.currentPhotoUrl != null ? Icons.edit : Icons.add_a_photo,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        if (_isUploading) ...[
          const SizedBox(height: 8),
          const Text(
            'Uploading...',
            style: TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoContent() {
    if (_isUploading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4CAF50),
          strokeWidth: 2,
        ),
      );
    }

    if (widget.currentPhotoUrl != null) {
      return ClipOval(
        child: Image.network(
          widget.currentPhotoUrl!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF4CAF50),
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: widget.size * 0.4,
            color: const Color(0xFF9E9E9E),
          ),
          if (widget.size > 80) ...[
            const SizedBox(height: 4),
            Text(
              'Add Photo',
              style: TextStyle(
                color: const Color(0xFF9E9E9E),
                fontSize: widget.size * 0.08,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF9E9E9E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.isProfilePhoto ? 'Profile Photo' : 'Add Photo',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
            // Camera option
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
              title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            
            // Gallery option
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF2196F3)),
              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            
            // Remove option (if photo exists)
            if (widget.currentPhotoUrl != null && widget.onPhotoRemoved != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isUploading = true;
      });

      final File? imageFile = await _photoUploadService.pickImage(source: source);
      
      if (imageFile != null) {
        String downloadUrl;
        
        if (widget.isProfilePhoto) {
          downloadUrl = await _photoUploadService.uploadProfileImage(
            widget.userId,
            imageFile,
          );
        } else {
          downloadUrl = await _photoUploadService.uploadPhoto(
            widget.userId,
            imageFile,
            'additional',
          );
        }
        
        widget.onPhotoUploaded(downloadUrl);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo uploaded successfully!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _removePhoto() async {
    try {
      if (widget.currentPhotoUrl != null) {
        await _photoUploadService.deleteImage(widget.currentPhotoUrl!);
      }
      
      widget.onPhotoRemoved?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo removed successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}