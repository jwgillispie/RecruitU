import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/usecases/create_profile_from_form_usecase.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../widgets/photo_upload_widget.dart';
import '../widgets/photo_gallery_widget.dart';

/// Profile completion onboarding page
class ProfileCompletionPage extends StatefulWidget {
  final UserType userType;
  final String userId;
  final String displayName;

  const ProfileCompletionPage({
    super.key,
    required this.userType,
    required this.userId,
    required this.displayName,
  });

  @override
  State<ProfileCompletionPage> createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends State<ProfileCompletionPage>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Form data storage
  final Map<String, dynamic> _formData = {};
  
  // Completion tracking
  double _completionPercentage = 0.0;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
    
    // Initialize completion percentage
    _updateCompletionPercentage();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<ProfileStep> get _steps {
    if (widget.userType == UserType.player) {
      return [
        ProfileStep(
          title: 'Welcome!',
          subtitle: 'Let\'s build your player profile',
          icon: Icons.sports_soccer,
        ),
        ProfileStep(
          title: 'Basic Info',
          subtitle: 'Tell us about yourself',
          icon: Icons.person,
        ),
        ProfileStep(
          title: 'Playing Position',
          subtitle: 'What position do you play?',
          icon: Icons.location_on,
        ),
        ProfileStep(
          title: 'Profile Photo',
          subtitle: 'Add your profile picture',
          icon: Icons.photo_camera,
        ),
        ProfileStep(
          title: 'Academic Info',
          subtitle: 'Your academic details',
          icon: Icons.school,
        ),
        ProfileStep(
          title: 'All Set!',
          subtitle: 'Your profile is ready',
          icon: Icons.check_circle,
        ),
      ];
    } else {
      return [
        ProfileStep(
          title: 'Welcome Coach!',
          subtitle: 'Let\'s set up your program profile',
          icon: Icons.sports,
        ),
        ProfileStep(
          title: 'Program Info',
          subtitle: 'Tell us about your program',
          icon: Icons.business,
        ),
        ProfileStep(
          title: 'Recruiting Needs',
          subtitle: 'What positions are you recruiting?',
          icon: Icons.search,
        ),
        ProfileStep(
          title: 'Profile Photo',
          subtitle: 'Add your profile picture',
          icon: Icons.photo_camera,
        ),
        ProfileStep(
          title: 'Contact Details',
          subtitle: 'How can players reach you?',
          icon: Icons.contact_mail,
        ),
        ProfileStep(
          title: 'Ready to Recruit!',
          subtitle: 'Your profile is complete',
          icon: Icons.check_circle,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF1A1A1A).withValues(alpha: 0.8),
                  border: Border.all(
                    color: const Color(0xFF333333),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                  onPressed: _goToPreviousStep,
                ),
              )
            : null,
        actions: [
          if (_currentStep < _steps.length - 1)
            TextButton(
              onPressed: _skipToEnd,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A1A),
              Color(0xFF0F1419),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Progress indicator
                _buildProgressIndicator(),
                
                // Content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentStep = index;
                      });
                    },
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      return _buildStepContent(_steps[index], index);
                    },
                  ),
                ),
                
                // Navigation buttons
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: List.generate(_steps.length, (index) {
              final isActive = index <= _currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(
                    right: index < _steps.length - 1 ? 8 : 0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: isActive
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF333333),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of ${_steps.length}',
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 14,
                ),
              ),
              if (_completionPercentage > 0)
                Text(
                  '${_completionPercentage.toInt()}% Complete',
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(ProfileStep step, int index) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              step.icon,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            step.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            step.subtitle,
            style: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 60),
          
          // Step-specific content
          _buildStepSpecificContent(index),
        ],
        ),
      ),
    );
  }

  Widget _buildStepSpecificContent(int stepIndex) {
    switch (stepIndex) {
      case 0:
        return _buildWelcomeContent();
      case 1:
        return _buildBasicInfoContent();
      case 2:
        return widget.userType == UserType.player
            ? _buildPositionSelectionContent()
            : _buildRecruitingNeedsContent();
      case 3:
        return _buildPhotoUploadContent();
      case 4:
        return widget.userType == UserType.player
            ? _buildAcademicInfoContent()
            : _buildContactDetailsContent();
      case 5:
        return _buildCompletionContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWelcomeContent() {
    return Column(
      children: [
        Text(
          widget.userType == UserType.player
              ? 'Ready to showcase your soccer skills and connect with college coaches?'
              : 'Ready to discover talented players for your program?',
          style: const TextStyle(
            color: Color(0xFFBBBBBB),
            fontSize: 16,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF333333)),
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.5),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
              const SizedBox(height: 12),
              Text(
                'This setup will only take a few minutes and you can always update your profile later.',
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoContent() {
    return Column(
      children: [
        _buildGlassField(
          label: 'Phone Number',
          hint: 'Enter your phone number',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            _formData['phoneNumber'] = value;
            setState(() {
              _updateCompletionPercentage();
            });
          },
        ),
        const SizedBox(height: 20),
        _buildGlassField(
          label: 'Location',
          hint: 'City, State',
          icon: Icons.location_on,
          onChanged: (value) {
            _formData['location'] = value;
            setState(() {
              _updateCompletionPercentage();
            });
          },
        ),
        const SizedBox(height: 20),
        _buildGlassField(
          label: 'Bio',
          hint: 'Tell us about yourself...',
          icon: Icons.person,
          maxLines: 3,
          onChanged: (value) {
            _formData['bio'] = value;
            setState(() {
              _updateCompletionPercentage();
            });
          },
        ),
      ],
    );
  }

  Widget _buildPositionSelectionContent() {
    return Column(
      children: [
        Text(
          'What position do you play?',
          style: const TextStyle(
            color: Color(0xFFBBBBBB),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildPositionGrid(),
      ],
    );
  }

  Widget _buildRecruitingNeedsContent() {
    return Column(
      children: [
        _buildGlassField(
          label: 'School/Program Name',
          hint: 'University of Example',
          icon: Icons.school,
          onChanged: (value) {
            _formData['schoolName'] = value;
            setState(() {
              _updateCompletionPercentage();
            });
          },
        ),
        const SizedBox(height: 20),
        _buildGlassField(
          label: 'Your Title',
          hint: 'Head Coach, Assistant Coach, etc.',
          icon: Icons.work,
          onChanged: (value) {
            _formData['coachingTitle'] = value;
            setState(() {
              _updateCompletionPercentage();
            });
          },
        ),
        const SizedBox(height: 20),
        _buildGlassField(
          label: 'Conference/League',
          hint: 'Big Ten, ACC, etc.',
          icon: Icons.sports,
          onChanged: (value) {
            _formData['conference'] = value;
            setState(() {
              _updateCompletionPercentage();
            });
          },
        ),
      ],
    );
  }

  Widget _buildPhotoUploadContent() {
    return Column(
      children: [
        // Profile Photo Upload
        PhotoUploadWidget(
          userId: widget.userId,
          currentPhotoUrl: _formData['profilePhotoUrl'] as String?,
          onPhotoUploaded: (photoUrl) {
            setState(() {
              _formData['profilePhotoUrl'] = photoUrl;
              _updateCompletionPercentage();
            });
          },
          onPhotoRemoved: () {
            setState(() {
              _formData['profilePhotoUrl'] = null;
              _updateCompletionPercentage();
            });
          },
          size: 120,
          isProfilePhoto: true,
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Profile Photo',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'This will be the first photo people see when they discover your profile.',
          style: const TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),

        if (widget.userType == UserType.player) ...[
          const SizedBox(height: 40),
          
          // Additional Photos Gallery
          PhotoGalleryWidget(
            userId: widget.userId,
            currentPhotos: _formData['additionalPhotos'] as List<String>? ?? [],
            onPhotosUpdated: (photos) {
              setState(() {
                _formData['additionalPhotos'] = photos;
                _updateCompletionPercentage();
              });
            },
            maxPhotos: 4,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Add more photos to showcase your skills and personality. These photos help coaches get to know you better.',
            style: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildAcademicInfoContent() {
    return Column(
      children: [
        _buildGlassField(
          label: 'Current School',
          hint: 'Your high school or current college',
          icon: Icons.school,
          onChanged: (value) {
            _formData['currentSchool'] = value;
            setState(() {
              _updateCompletionPercentage();
            });
          },
        ),
        const SizedBox(height: 20),
        _buildGlassField(
          label: 'GPA',
          hint: '3.5',
          icon: Icons.grade,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _formData['gpa'] = value;
            setState(() {
              _updateCompletionPercentage();
            });
          },
        ),
        const SizedBox(height: 20),
        _buildGlassField(
          label: 'Graduation Year',
          hint: '2025',
          icon: Icons.calendar_today,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _formData['graduationYear'] = value;
            setState(() {
              _updateCompletionPercentage();
            });
          },
        ),
      ],
    );
  }

  Widget _buildContactDetailsContent() {
    return Column(
      children: [
        _buildGlassField(
          label: 'Official Email',
          hint: 'coach@university.edu',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => _formData['officialEmail'] = value,
        ),
        const SizedBox(height: 20),
        _buildGlassField(
          label: 'Phone Number',
          hint: 'Your contact number',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            _formData['phoneNumber'] = value;
            setState(() {
              _updateCompletionPercentage();
            });
          },
        ),
        const SizedBox(height: 20),
        _buildGlassField(
          label: 'Years Coaching',
          hint: '5',
          icon: Icons.history,
          keyboardType: TextInputType.number,
          onChanged: (value) => _formData['yearsCoaching'] = value,
        ),
      ],
    );
  }

  Widget _buildCompletionContent() {
    return Column(
      children: [
        const Text(
          '🎉',
          style: TextStyle(fontSize: 40),
        ),
        const SizedBox(height: 20),
        Text(
          widget.userType == UserType.player
              ? 'You\'re all set! Your profile is now live and coaches can discover you.'
              : 'Perfect! Your program profile is ready and players can now find you.',
          style: const TextStyle(
            color: Color(0xFFBBBBBB),
            fontSize: 16,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0 && _currentStep < _steps.length - 1)
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF333333)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          
          if (_currentStep > 0 && _currentStep < _steps.length - 1)
            const SizedBox(width: 16),
          
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                ),
              ),
              child: ElevatedButton(
                onPressed: _isCompleting ? null : () {
                  print('🔥 BUTTON_PRESSED: Current step: $_currentStep, Steps length: ${_steps.length}');
                  if (_currentStep < _steps.length - 1) {
                    print('🔥 BUTTON_PRESSED: Calling _goToNextStep');
                    _goToNextStep();
                  } else {
                    print('🔥 BUTTON_PRESSED: Calling _completeOnboarding');
                    _completeOnboarding();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCompleting && _currentStep == _steps.length - 1
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Completing...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _currentStep < _steps.length - 1
                            ? (_currentStep == 0 ? 'Get Started' : 'Continue')
                            : 'Go to Home',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToNextStep() {
    if (_currentStep < _steps.length - 1) {
      // Validate current step before proceeding
      if (_validateCurrentStep()) {
        HapticFeedback.lightImpact();
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _showValidationError();
      }
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Welcome step
        return true;
      case 1: // Basic info
        return _validateBasicInfo();
      case 2: // Position selection (for players) or Program info (for coaches)
        if (widget.userType == UserType.player) {
          return _formData['primaryPosition'] != null;
        } else {
          return _validateProgramInfo();
        }
      case 3: // Photo upload
        // Profile photo is optional but recommended
        return true;
      case 4: // Academic/Contact info
        if (widget.userType == UserType.player) {
          return _validateAcademicInfo();
        } else {
          return _validateContactInfo();
        }
      default:
        return true;
    }
  }

  bool _validateBasicInfo() {
    final phoneNumber = _formData['phoneNumber'] as String?;
    final location = _formData['location'] as String?;
    final bio = _formData['bio'] as String?;
    
    return phoneNumber != null && phoneNumber.trim().isNotEmpty &&
           location != null && location.trim().isNotEmpty &&
           bio != null && bio.trim().isNotEmpty;
  }

  bool _validateProgramInfo() {
    final schoolName = _formData['schoolName'] as String?;
    final coachingTitle = _formData['coachingTitle'] as String?;
    
    return schoolName != null && schoolName.trim().isNotEmpty &&
           coachingTitle != null && coachingTitle.trim().isNotEmpty;
  }

  bool _validateAcademicInfo() {
    final currentSchool = _formData['currentSchool'] as String?;
    final graduationYear = _formData['graduationYear'] as String?;
    final gpa = _formData['gpa'] as String?;
    
    bool isValid = currentSchool != null && currentSchool.trim().isNotEmpty &&
                   graduationYear != null && graduationYear.trim().isNotEmpty;
    
    // Validate GPA if provided
    if (gpa != null && gpa.trim().isNotEmpty) {
      final gpaValue = double.tryParse(gpa);
      if (gpaValue == null || gpaValue < 0.0 || gpaValue > 4.0) {
        return false;
      }
    }
    
    // Validate graduation year
    if (graduationYear != null && graduationYear.trim().isNotEmpty) {
      final year = int.tryParse(graduationYear);
      final currentYear = DateTime.now().year;
      if (year == null || year < currentYear || year > currentYear + 10) {
        return false;
      }
    }
    
    return isValid;
  }

  bool _validateContactInfo() {
    final officialEmail = _formData['officialEmail'] as String?;
    final phoneNumber = _formData['phoneNumber'] as String?;
    
    bool isValid = phoneNumber != null && phoneNumber.trim().isNotEmpty;
    
    // Validate email if provided
    if (officialEmail != null && officialEmail.trim().isNotEmpty) {
      final emailRegex = RegExp(AppConstants.emailPattern);
      if (!emailRegex.hasMatch(officialEmail)) {
        return false;
      }
    }
    
    return isValid;
  }

  String _getValidationErrorMessage() {
    switch (_currentStep) {
      case 1:
        return _getBasicInfoValidationError();
      case 2:
        if (widget.userType == UserType.player) {
          return 'Please select your primary playing position';
        } else {
          return _getProgramInfoValidationError();
        }
      case 4:
        if (widget.userType == UserType.player) {
          return _getAcademicInfoValidationError();
        } else {
          return _getContactInfoValidationError();
        }
      default:
        return 'Please complete all required fields';
    }
  }

  String _getBasicInfoValidationError() {
    final phoneNumber = _formData['phoneNumber'] as String?;
    final location = _formData['location'] as String?;
    final bio = _formData['bio'] as String?;
    
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    if (location == null || location.trim().isEmpty) {
      return 'Please enter your location';
    }
    if (bio == null || bio.trim().isEmpty) {
      return 'Please write a short bio about yourself';
    }
    return 'Please fill in all basic information fields';
  }

  String _getProgramInfoValidationError() {
    final schoolName = _formData['schoolName'] as String?;
    final coachingTitle = _formData['coachingTitle'] as String?;
    
    if (schoolName == null || schoolName.trim().isEmpty) {
      return 'Please enter your school/program name';
    }
    if (coachingTitle == null || coachingTitle.trim().isEmpty) {
      return 'Please enter your coaching title';
    }
    return 'Please provide your program information';
  }

  String _getAcademicInfoValidationError() {
    final currentSchool = _formData['currentSchool'] as String?;
    final graduationYear = _formData['graduationYear'] as String?;
    final gpa = _formData['gpa'] as String?;
    
    if (currentSchool == null || currentSchool.trim().isEmpty) {
      return 'Please enter your current school';
    }
    if (graduationYear == null || graduationYear.trim().isEmpty) {
      return 'Please enter your graduation year';
    }
    
    // Validate graduation year format
    if (graduationYear.trim().isNotEmpty) {
      final year = int.tryParse(graduationYear);
      final currentYear = DateTime.now().year;
      if (year == null) {
        return 'Please enter a valid graduation year';
      }
      if (year < currentYear || year > currentYear + 10) {
        return 'Graduation year must be between $currentYear and ${currentYear + 10}';
      }
    }
    
    // Validate GPA format
    if (gpa != null && gpa.trim().isNotEmpty) {
      final gpaValue = double.tryParse(gpa);
      if (gpaValue == null) {
        return 'Please enter a valid GPA (e.g., 3.5)';
      }
      if (gpaValue < 0.0 || gpaValue > 4.0) {
        return 'GPA must be between 0.0 and 4.0';
      }
    }
    
    return 'Please provide your academic information';
  }

  String _getContactInfoValidationError() {
    final officialEmail = _formData['officialEmail'] as String?;
    final phoneNumber = _formData['phoneNumber'] as String?;
    
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    
    if (officialEmail != null && officialEmail.trim().isNotEmpty) {
      final emailRegex = RegExp(AppConstants.emailPattern);
      if (!emailRegex.hasMatch(officialEmail)) {
        return 'Please enter a valid email address';
      }
    }
    
    return 'Please provide your contact information';
  }

  void _showValidationError() {
    HapticFeedback.heavyImpact();
    
    String message = _getValidationErrorMessage();
    
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFE53E3E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToEnd() {
    HapticFeedback.lightImpact();
    _pageController.animateToPage(
      _steps.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _updateCompletionPercentage() {
    if (widget.userType == UserType.player) {
      _completionPercentage = _calculatePlayerCompletionPercentage();
    } else {
      _completionPercentage = _calculateCoachCompletionPercentage();
    }
  }

  double _calculatePlayerCompletionPercentage() {
    int totalFields = 10; // Key fields for initial profile completion
    int filledFields = 0;
    
    // Basic info
    if (_formData['phoneNumber'] != null && (_formData['phoneNumber'] as String).trim().isNotEmpty) filledFields++;
    if (_formData['location'] != null && (_formData['location'] as String).trim().isNotEmpty) filledFields++;
    if (_formData['bio'] != null && (_formData['bio'] as String).trim().isNotEmpty) filledFields++;
    
    // Position
    if (_formData['primaryPosition'] != null) filledFields++;
    
    // Photo
    if (_formData['profilePhotoUrl'] != null) filledFields++;
    if (_formData['additionalPhotos'] != null && (_formData['additionalPhotos'] as List<String>).isNotEmpty) filledFields++;
    
    // Academic info
    if (_formData['currentSchool'] != null && (_formData['currentSchool'] as String).trim().isNotEmpty) filledFields++;
    if (_formData['graduationYear'] != null && (_formData['graduationYear'] as String).trim().isNotEmpty) filledFields++;
    if (_formData['gpa'] != null && (_formData['gpa'] as String).trim().isNotEmpty) filledFields++;
    
    // Always count display name as filled
    filledFields++; // Display name
    
    return (filledFields / totalFields) * 100;
  }

  double _calculateCoachCompletionPercentage() {
    int totalFields = 8; // Key fields for initial profile completion
    int filledFields = 0;
    
    // Basic info
    if (_formData['phoneNumber'] != null && (_formData['phoneNumber'] as String).trim().isNotEmpty) filledFields++;
    if (_formData['location'] != null && (_formData['location'] as String).trim().isNotEmpty) filledFields++;
    if (_formData['bio'] != null && (_formData['bio'] as String).trim().isNotEmpty) filledFields++;
    
    // Program info
    if (_formData['schoolName'] != null && (_formData['schoolName'] as String).trim().isNotEmpty) filledFields++;
    if (_formData['coachingTitle'] != null && (_formData['coachingTitle'] as String).trim().isNotEmpty) filledFields++;
    if (_formData['conference'] != null && (_formData['conference'] as String).trim().isNotEmpty) filledFields++;
    
    // Photo
    if (_formData['profilePhotoUrl'] != null) filledFields++;
    
    // Always count display name as filled
    filledFields++; // Display name
    
    return (filledFields / totalFields) * 100;
  }

  void _completeOnboarding() async {
    print('🏠 PROFILE_COMPLETION: _completeOnboarding called, current step: $_currentStep');
    HapticFeedback.mediumImpact();
    
    try {
      // Show loading indicator
      setState(() {
        _isCompleting = true;
      });
      
      // Update profile completion status FIRST to prevent redirect loop
      final authRepository = ServiceLocator.instance<AuthRepository>();
      await authRepository.updateProfileCompletionStatus(widget.userId, true);
      print('🏠 PROFILE_COMPLETION: Profile completion status updated');
      
      // Force auth state refresh to ensure router knows about completion
      final authBloc = ServiceLocator.instance<AuthBloc>();
      authBloc.add(AuthRefreshRequested());
      
      // Wait a moment for auth state to propagate
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Navigate with error handling
      if (mounted) {
        print('🏠 PROFILE_COMPLETION: Attempting navigation to home...');
        await _navigateToHome();
      }
      
      // Create profile in background (don't await)
      _createProfileInBackground();
      
    } catch (e) {
      print('🏠 PROFILE_COMPLETION: Error in completion: $e');
      
      // Fallback navigation methods
      if (mounted) {
        await _navigateToHome();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  Future<void> _navigateToHome() async {
    final List<Future<void> Function()> navigationMethods = [
      // Method 1: GoRouter
      () async {
        context.go('/home');
        await Future.delayed(const Duration(milliseconds: 300));
      },
      
      // Method 2: Navigator pushReplacement
      () async {
        Navigator.of(context).pushReplacementNamed('/home');
        await Future.delayed(const Duration(milliseconds: 300));
      },
      
      // Method 3: Navigator pushAndRemoveUntil
      () async {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        await Future.delayed(const Duration(milliseconds: 300));
      },
    ];
    
    // Try each method until one succeeds
    for (int i = 0; i < navigationMethods.length; i++) {
      try {
        print('🚀 NAVIGATION: Trying method ${i + 1}');
        await navigationMethods[i]();
        
        // Check if navigation was successful by waiting a bit
        await Future.delayed(const Duration(milliseconds: 500));
        print('🚀 NAVIGATION: Method ${i + 1} completed');
        return; // Exit on first successful attempt
      } catch (e) {
        print('🚀 NAVIGATION: Method ${i + 1} failed: $e');
        continue;
      }
    }
    
    print('🚀 NAVIGATION: All methods attempted, showing error dialog');
    _showNavigationErrorDialog();
  }

  void _showNavigationErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Navigation Issue',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Having trouble navigating to the home screen. Would you like to try again?',
          style: TextStyle(color: Color(0xFF9E9E9E)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
            child: const Text(
              'Retry',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
            },
            child: const Text(
              'Force Navigate',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  void _createProfileInBackground() async {
    try {
      // Check if profile already exists before creating
      final profileRepository = ServiceLocator.instance<ProfileRepository>();
      
      bool profileExists = false;
      if (widget.userType == UserType.player) {
        profileExists = await profileRepository.playerProfileExists(widget.userId);
      } else {
        profileExists = await profileRepository.coachProfileExists(widget.userId);
      }
      
      if (profileExists) {
        print('🏠 PROFILE_COMPLETION: Profile already exists for user ${widget.userId}, skipping creation');
        return;
      }
      
      // Save profile data to Firestore
      final createProfileUseCase = ServiceLocator.instance<CreateProfileFromFormUseCase>();
      
      await createProfileUseCase.createProfile(
        userId: widget.userId,
        displayName: widget.displayName,
        userType: widget.userType,
        formData: _formData,
      );
      
      print('🏠 PROFILE_COMPLETION: Profile created successfully in background');
    } catch (e) {
      print('🏠 PROFILE_COMPLETION: Failed to create profile in background: $e');
    }
  }

  Widget _buildGlassField({
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E1E1E).withValues(alpha: 0.8),
            const Color(0xFF2A2A2A).withValues(alpha: 0.6),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF4CAF50),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPositionGrid() {
    final positions = [
      {'name': 'GK', 'full': 'Goalkeeper', 'value': SoccerPosition.gk},
      {'name': 'CB', 'full': 'Center Back', 'value': SoccerPosition.cb},
      {'name': 'LB', 'full': 'Left Back', 'value': SoccerPosition.lb},
      {'name': 'RB', 'full': 'Right Back', 'value': SoccerPosition.rb},
      {'name': 'CDM', 'full': 'Defensive Mid', 'value': SoccerPosition.cdm},
      {'name': 'CM', 'full': 'Central Mid', 'value': SoccerPosition.cm},
      {'name': 'CAM', 'full': 'Attacking Mid', 'value': SoccerPosition.cam},
      {'name': 'LW', 'full': 'Left Winger', 'value': SoccerPosition.lw},
      {'name': 'RW', 'full': 'Right Winger', 'value': SoccerPosition.rw},
      {'name': 'ST', 'full': 'Striker', 'value': SoccerPosition.st},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: positions.length,
      itemBuilder: (context, index) {
        final position = positions[index];
        final isSelected = _formData['primaryPosition'] == position['value'];
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _formData['primaryPosition'] = position['value'];
              _updateCompletionPercentage();
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                    )
                  : null,
              color: isSelected ? null : const Color(0xFF333333),
              border: Border.all(
                color: isSelected ? Colors.transparent : const Color(0xFF444444),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  position['name'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFFBBBBBB),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  position['full'] as String,
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white.withValues(alpha: 0.9)
                        : const Color(0xFF888888),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Data class for profile completion steps
class ProfileStep {
  final String title;
  final String subtitle;
  final IconData icon;

  const ProfileStep({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}