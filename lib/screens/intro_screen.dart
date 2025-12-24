import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/aurora_background.dart';

/// Intro/Welcome screen with aurora effects
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: () => _navigateToDashboard(context),
                    child: Text(
                      'Skip',
                      style: AppTheme.labelLarge.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hero illustration
                      Expanded(flex: 5, child: _buildHeroSection()),
                      // Headline & Body
                      Text(
                        'Magic in Every Page',
                        style: AppTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Design unique diary covers with generative art and write your thoughts in our beautiful Aurora-themed editor.',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.textSecondary.withValues(
                              alpha: 0.8,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIndicator(isActive: true),
                        const SizedBox(width: 8),
                        _buildIndicator(isActive: false),
                        const SizedBox(width: 8),
                        _buildIndicator(isActive: false),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _navigateToDashboard(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 8,
                          shadowColor: AppTheme.primary.withValues(alpha: 0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Start Writing',
                              style: AppTheme.titleMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
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
      ),
    );
  }

  Widget _buildHeroSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Angled backdrop
        Positioned.fill(
          child: Transform.rotate(
            angle: -0.05,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(48),
              ),
            ),
          ),
        ),
        // Main image card
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(48),
            border: Border.all(color: Colors.white, width: 6),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(42),
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBuFrb1h8w3vnN-9HMEqEAzSJwMK2wG7kP7L9nSh42gHzM5pkPMu_GtPdYquA95Z98LQ6CUoPzeL2fodi2JYcpIOAZfsfRgRf_8OGhFTkb4KivpkNU_Qmklq4kzbrtneQP9rL6E3n3pJ4W7dJruN9B42_mmWTUi2Iwl_ZZDJwGDtpj2DxPI8TVFvoG-lNaQVLqLgSaHjfcUwVdVzQFAexO3845w2nCkE_WrEMIICLtWugd38GbIEaXIIquVIKjji1T-AXp8xwF9l2hS',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppTheme.primaryLight,
                  child: const Center(
                    child: Icon(
                      Icons.auto_stories,
                      size: 64,
                      color: AppTheme.primary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Floating badge
        Positioned(
          bottom: 0,
          right: 24,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.surfaceLight, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppTheme.primary,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primary
            : AppTheme.textMuted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _navigateToDashboard(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }
}
