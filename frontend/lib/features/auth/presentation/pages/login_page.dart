import 'package:flutter/material.dart';
import 'package:basketvibe/core/app/demo_mode.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:basketvibe/core/constants/route_constants.dart';
import 'package:basketvibe/core/l10n/app_localizations.dart';
import 'package:basketvibe/core/styles/app_colors.dart';
import 'package:basketvibe/core/styles/app_spacing.dart';
import 'package:basketvibe/core/utils/snackbars/app_snackbar.dart';
import 'package:basketvibe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:basketvibe/features/auth/presentation/cubit/auth_state.dart';

class LoginPage extends StatelessWidget with SnackbarMixin {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(
              state.isNewUser ? RouteConstants.onboarding : RouteConstants.home,
            );
          } else if (state is AuthError) {
            showErrorSnackbar(context, state.message);
          }
        },
        builder: (context, state) => SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.cardPaddingLG,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.sports_soccer,
                      size: 100,
                      color: AppColors.primary,
                    ),
                    AppSpacing.gapXL,
                    Text(
                      'Football Day',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    AppSpacing.gapSM,
                    Text(
                      l.fdLoginTagline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    AppSpacing.gapXXL,
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () => context.read<AuthCubit>().googleSignIn(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (state is AuthLoading)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                SvgPicture.asset(
                                  'assets/icons/google_icon.svg',
                                  width: 20,
                                  height: 20,
                                ),
                              AppSpacing.rowGapMD,
                              Flexible(
                                child: Text(
                                  demoMode ? l.fdDemoSignIn : l.fdSignIn,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.gapXL,
                    Text(
                      demoMode ? l.fdDemoNotice : l.fdLoginNotice,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    AppSpacing.gapLG,
                    TextButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () => context.go(RouteConstants.home),
                      child: Text(l.fdBrowse, textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
