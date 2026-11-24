import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String tag;

  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.tag,
  });
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Universal Emergency Safety QR',
      description:
          'Generate an encrypted emergency safety QR code for your helmet, vehicle, backpack, or phone lock screen in seconds.',
      icon: Icons.qr_code_2_rounded,
      accentColor: AppColors.primary,
      tag: 'INSTANT IDENTIFICATION',
    ),
    OnboardingSlide(
      title: 'Automated Family Alerts',
      description:
          'When scanned by bystanders or first responders, your emergency contacts instantly receive real-time notifications with scene map location.',
      icon: Icons.notifications_active_rounded,
      accentColor: AppColors.secondary,
      tag: 'ZERO-DELAY NOTIFICATIONS',
    ),
    OnboardingSlide(
      title: 'Offline Emergency Safety Guides',
      description:
          'Access life-saving step-by-step emergency response instructions, CPR workflows, and first responder checklists anywhere without internet.',
      icon: Icons.menu_book_rounded,
      accentColor: AppColors.info,
      tag: 'OFFLINE READINESS',
    ),
    OnboardingSlide(
      title: 'Privacy-First & DPDPA 2023 Compliant',
      description:
          'You control which details are publicly visible during scans. Data is secured with AES-256 and subject to instant Right to Erasure.',
      icon: Icons.shield_rounded,
      accentColor: AppColors.success,
      tag: 'LEGAL & ENCRYPTED',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.setOnboardingCompleted(true);
    if (mounted) {
      context.go('/login');
    }
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeSlide = _slides[_currentPage];
    final isLastSlide = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar with Tag & Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.emergency_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'GOLDEN HOUR',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  // Skip Button
                  if (!isLastSlide)
                    Semantics(
                      label: 'Skip onboarding',
                      button: true,
                      child: TextButton(
                        onPressed: _completeOnboarding,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(60, 48),
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 48, width: 60),
                ],
              ),
            ),

            // PageView Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Hero Visual Card
                          Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              color: slide.accentColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: slide.accentColor.withValues(alpha: 0.25),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: slide.accentColor.withValues(alpha: 0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  slide.icon,
                                  size: 64,
                                  color: slide.accentColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Slide Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: slide.accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              slide.tag,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: slide.accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Title
                          Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Description
                          Text(
                            slide.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  // Progress Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) {
                        final isSelected = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isSelected ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? activeSlide.accentColor
                                : theme.colorScheme.outline
                                    .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      key: const ValueKey('onboarding_action_button'),
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeSlide.accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLastSlide ? 'Get Started' : 'Continue',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isLastSlide
                                ? Icons.arrow_forward_rounded
                                : Icons.chevron_right_rounded,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

