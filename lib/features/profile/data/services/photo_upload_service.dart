import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';

/// Service for handling photo uploads with compression and optimization
class PhotoUploadService {
  final FirebaseStorage _storage;
  final ImagePicker _imagePicker;
  final Uuid _uuid;

  PhotoUploadService({
    FirebaseStorage? storage,
    ImagePicker? imagePicker,
    Uuid? uuid,
  }) : _storage = storage ?? FirebaseStorage.instance,
        _imagePicker = imagePicker ?? ImagePicker(),
        _uuid = uuid ?? const Uuid();

  /// Pick image from camera or gallery
  Future<File?> pickImage({required ImageSource source}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Pick multiple images from gallery
  Future<List<File>> pickMultipleImages({int maxImages = 6}) async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      // Limit the number of images
      final limitedFiles = pickedFiles.take(maxImages).toList();
      return limitedFiles.map((file) => File(file.path)).toList();
    } catch (e) {
      throw Exception('Failed to pick multiple images: $e');
    }
  }

  /// Compress image to optimize for upload
  Future<File> compressImage(File imageFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final compressedFileName = '${_uuid.v4()}_compressed.jpg';
      final compressedPath = '${tempDir.path}/$compressedFileName';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        compressedPath,
        quality: 85,
        minWidth: 300,
        minHeight: 300,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        throw Exception('Failed to compress image');
      }

      return File(compressedFile.path);
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  /// Upload profile image to Firebase Storage
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      print('📸 PHOTO_SERVICE: Uploading profile image for user: $userId');
      
      // Compress the image first
      final compressedFile = await compressImage(imageFile);
      
      final fileName = 'profile_$userId.jpg';
      final ref = _storage.ref().child(AppConstants.profileImagesPath).child(fileName);
      
      // Upload the file
      final uploadTask = ref.putFile(compressedFile);
      
      // Monitor upload progress (optional)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('📸 PHOTO_SERVICE: Upload progress: ${progress.toStringAsFixed(2)}%');
      });
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Clean up temporary compressed file
      if (await compressedFile.exists()) {
        await compressedFile.delete();
      }
      
      print('📸 PHOTO_SERVICE: Profile image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('📸 PHOTO_SERVICE: Error uploading profile image: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Upload additional photo to Firebase Storage
  Future<String> uploadPhoto(String userId, File imageFile, String category) async {
    try {
      print('📸 PHOTO_SERVICE: Uploading photo for user: $userId, category: $category');
      
      // Compress the image first
      final compressedFile = await compressImage(imageFile);
      
      final fileName = '${category}_${userId}_${_uuid.v4()}.jpg';
      final ref = _storage.ref().child(AppConstants.additionalPhotosPath).child(fileName);
      
      // Upload the file
      final uploadTask = ref.putFile(compressedFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Clean up temporary compressed file
      if (await compressedFile.exists()) {
        await compressedFile.delete();
      }
      
      print('📸 PHOTO_SERVICE: Photo uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('📸 PHOTO_SERVICE: Error uploading photo: $e');
      throw Exception('Failed to upload photo: $e');
    }
  }

  /// Upload multiple photos at once
  Future<List<String>> uploadMultiplePhotos(
    String userId, 
    List<File> imageFiles, 
    String category
  ) async {
    try {
      print('📸 PHOTO_SERVICE: Uploading ${imageFiles.length} photos for user: $userId');
      
      final List<String> downloadUrls = [];
      
      // Upload each image
      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        final compressedFile = await compressImage(imageFile);
        
        final fileName = '${category}_${userId}_${i}_${_uuid.v4()}.jpg';
        final ref = _storage.ref().child(AppConstants.additionalPhotosPath).child(fileName);
        
        final uploadTask = ref.putFile(compressedFile);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        
        downloadUrls.add(downloadUrl);
        
        // Clean up temporary compressed file
        if (await compressedFile.exists()) {
          await compressedFile.delete();
        }
        
        print('📸 PHOTO_SERVICE: Uploaded photo ${i + 1}/${imageFiles.length}');
      }
      
      print('📸 PHOTO_SERVICE: All photos uploaded successfully');
      return downloadUrls;
    } catch (e) {
      print('📸 PHOTO_SERVICE: Error uploading multiple photos: $e');
      throw Exception('Failed to upload photos: $e');
    }
  }

  /// Delete image from Firebase Storage
  Future<void> deleteImage(String downloadUrl) async {
    try {
      print('📸 PHOTO_SERVICE: Deleting image: $downloadUrl');
      
      // Extract the file path from the download URL
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      
      print('📸 PHOTO_SERVICE: Image deleted successfully');
    } catch (e) {
      print('📸 PHOTO_SERVICE: Error deleting image: $e');
      throw Exception('Failed to delete image: $e');
    }
  }
}