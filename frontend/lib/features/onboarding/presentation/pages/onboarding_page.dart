import 'package:flutter/material.dart';
import 'package:basketvibe/core/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:basketvibe/core/constants/route_constants.dart';
import 'package:basketvibe/core/styles/app_border_radius.dart';
import 'package:basketvibe/core/styles/app_colors.dart';
import 'package:basketvibe/core/styles/app_spacing.dart';
import 'package:basketvibe/core/styles/app_text_styles.dart';
import 'package:basketvibe/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:basketvibe/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:basketvibe/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:basketvibe/features/onboarding/presentation/models/onboarding_content_data.dart';
import 'package:basketvibe/features/onboarding/presentation/widgets/utils/onboarding_content.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingContentData> get _pages {
    final l = AppLocalizations.of(context);
    return [
      OnboardingContentData(
        title: l.fdOnboardTitle1,
        description: l.fdOnboardBody1,
        icon: Icons.calendar_month,
      ),
      OnboardingContentData(
        title: l.fdOnboardTitle2,
        description: l.fdOnboardBody2,
        icon: Icons.groups,
      ),
      OnboardingContentData(
        title: l.fdOnboardTitle3,
        description: l.fdOnboardBody3,
        icon: Icons.sports_soccer,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onComplete();
    }
  }

  void _onComplete() {
    context.read<OnboardingBloc>().add(const CompleteOnboarding());
  }

  void _onSkip() {
    _onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          context.go(RouteConstants.home);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        body: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: AppSpacing.pagePadding,
                  child: TextButton(
                    onPressed: _onSkip,
                    child: Text(
                      AppLocalizations.of(context).fdSkip,
                      style: AppTextStyles.labelLG.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ),
              ),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return OnboardingContent(data: _pages[index]);
                  },
                ),
              ),

              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted),
                      borderRadius: AppRadius.brPill,
                    ),
                  ),
                ),
              ),

              AppSpacing.gapXL,

              // Next/Get Started button
              Padding(
                padding: AppSpacing.pagePadding,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onNext,
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? AppLocalizations.of(context).fdStart
                          : AppLocalizations.of(context).fdNext,
                      style: AppTextStyles.buttonLG,
                    ),
                  ),
                ),
              ),

              AppSpacing.gapXL,
            ],
          ),
        ),
      ),
    );
  }
}
