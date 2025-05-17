import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:team_nlq_tdtu/core/constants/app_constants.dart';
import 'package:team_nlq_tdtu/core/routes/app_router.dart';
import 'package:team_nlq_tdtu/core/widgets/loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Simulate some initialization work
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Navigate to the home screen
      context.goNamed(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Icon(
                  Icons.computer,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // App name
            Text(
              AppConstants.appName,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // App tagline
            Text(
              'Cửa hàng máy tính và linh kiện',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            const LoadingIndicator(
              size: LoadingSize.small,
              color: Colors.white,
              message: 'Đang tải...',
            ),
          ],
        ),
      ),
    );
  }
}
