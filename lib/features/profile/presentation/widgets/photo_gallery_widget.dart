import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/photo_upload_service.dart';
import '../../../../core/di/service_locator.dart';

/// Widget for managing multiple profile photos in a gallery format
class PhotoGalleryWidget extends StatefulWidget {
  final String userId;
  final List<String> currentPhotos;
  final Function(List<String> photos) onPhotosUpdated;
  final int maxPhotos;

  const PhotoGalleryWidget({
    super.key,
    required this.userId,
    required this.currentPhotos,
    required this.onPhotosUpdated,
    this.maxPhotos = 6,
  });

  @override
  State<PhotoGalleryWidget> createState() => _PhotoGalleryWidgetState();
}

class _PhotoGalleryWidgetState extends State<PhotoGalleryWidget> {
  late final PhotoUploadService _photoUploadService;
  bool _isUploading = false;
  late List<String> _photos;

  @override
  void initState() {
    super.initState();
    _photoUploadService = ServiceLocator.instance<PhotoUploadService>();
    _photos = List.from(widget.currentPhotos);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Photos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_photos.length}/${widget.maxPhotos}',
              style: const TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Photo grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: widget.maxPhotos,
          itemBuilder: (context, index) {
            if (index < _photos.length) {
              return _buildPhotoItem(_photos[index], index);
            } else {
              return _buildAddPhotoItem();
            }
          },
        ),
        
        if (_isUploading) ...[
          const SizedBox(height: 12),
          const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Color(0xFF4CAF50),
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Uploading photos...',
                  style: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoItem(String photoUrl, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF333333),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              photoUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF1A1A1A),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Color(0xFF9E9E9E),
                      size: 32,
                    ),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: const Color(0xFF1A1A1A),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4CAF50),
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        // Remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removePhoto(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoItem() {
    final canAddMore = _photos.length < widget.maxPhotos && !_isUploading;
    
    return GestureDetector(
      onTap: canAddMore ? _showAddPhotoOptions : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: canAddMore ? const Color(0xFF4CAF50) : const Color(0xFF333333),
            width: 2,
            style: BorderStyle.solid,
          ),
          color: const Color(0xFF1A1A1A),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo,
                color: canAddMore ? const Color(0xFF4CAF50) : const Color(0xFF666666),
                size: 32,
              ),
              const SizedBox(height: 4),
              Text(
                'Add Photo',
                style: TextStyle(
                  color: canAddMore ? const Color(0xFF4CAF50) : const Color(0xFF666666),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPhotoOptions() {
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
            const Text(
              'Add Photos',
              style: TextStyle(
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
                _pickSingleImage(ImageSource.camera);
              },
            ),
            
            // Gallery single option
            ListTile(
              leading: const Icon(Icons.photo, color: Color(0xFF2196F3)),
              title: const Text('Choose Photo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickSingleImage(ImageSource.gallery);
              },
            ),
            
            // Gallery multiple option
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF9C27B0)),
              title: const Text('Choose Multiple Photos', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickMultipleImages();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSingleImage(ImageSource source) async {
    try {
      setState(() {
        _isUploading = true;
      });

      final File? imageFile = await _photoUploadService.pickImage(source: source);
      
      if (imageFile != null) {
        final downloadUrl = await _photoUploadService.uploadPhoto(
          widget.userId,
          imageFile,
          'gallery',
        );
        
        setState(() {
          _photos.add(downloadUrl);
        });
        
        widget.onPhotosUpdated(_photos);
        
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

  Future<void> _pickMultipleImages() async {
    try {
      setState(() {
        _isUploading = true;
      });

      final remainingSlots = widget.maxPhotos - _photos.length;
      final List<File> imageFiles = await _photoUploadService.pickMultipleImages(
        maxImages: remainingSlots,
      );
      
      if (imageFiles.isNotEmpty) {
        final downloadUrls = await _photoUploadService.uploadMultiplePhotos(
          widget.userId,
          imageFiles,
          'gallery',
        );
        
        setState(() {
          _photos.addAll(downloadUrls);
        });
        
        widget.onPhotosUpdated(_photos);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${downloadUrls.length} photos uploaded successfully!'),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photos: $e'),
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

  Future<void> _removePhoto(int index) async {
    try {
      final photoUrl = _photos[index];
      await _photoUploadService.deleteImage(photoUrl);
      
      setState(() {
        _photos.removeAt(index);
      });
      
      widget.onPhotosUpdated(_photos);
      
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