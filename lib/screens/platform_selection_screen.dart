import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notiflex/screens/auth/login_screen.dart';
import 'package:notiflex/screens/notification_settings_screen.dart';
import 'package:notiflex/services/icon_service.dart';
import 'package:notiflex/utils/platform_helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlatformSelectionScreen extends StatefulWidget {
  const PlatformSelectionScreen({super.key});

  @override
  State<PlatformSelectionScreen> createState() =>
      _PlatformSelectionScreenState();
}

class _PlatformSelectionScreenState extends State<PlatformSelectionScreen>
    with SingleTickerProviderStateMixin {
  AppIcon? currentIcon;
  AppIcon? selectedPlatform;
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCurrentIcon();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animationController.forward();
  }

  void _loadCurrentIcon() {
    IconService.getCurrentAppIcon().then((icon) {
      if (mounted) {
        setState(() => currentIcon = icon);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPlatformTap(AppIcon platform) {
    if (selectedPlatform != platform) {
      HapticFeedback.selectionClick();
      setState(() {
        selectedPlatform = platform;
      });
    }
  }

  void navigateToSettingsScreen() {
    if (selectedPlatform != null) {
      HapticFeedback.mediumImpact();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationSettingsScreen(
            selectedPlatform: selectedPlatform!,
          ),
        ),
      );
    }
  }

  void _handleLogout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              }
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformCard(AppIcon platform, bool isDark) {
    final isSelected = selectedPlatform == platform;
    final isComingSoon = platform == AppIcon.shopify ||
        platform == AppIcon.gmail ||
        platform == AppIcon.linkedin ||
        platform == AppIcon.openai ||
        platform == AppIcon.uber ||
        platform == AppIcon.binance ||
        platform == AppIcon.spotify ||
        platform == AppIcon.telegram ||
        platform == AppIcon.reddit ||
        platform == AppIcon.mcdonalds;

    return Stack(
      children: [
        GestureDetector(
          onTap: isComingSoon ? null : () => _onPlatformTap(platform),
          child: Opacity(
            opacity: isComingSoon ? 0.5 : 1.0,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          getPlatformAssetPath(platform),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      getPlatformName(platform),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : isDark
                                    ? Colors.white
                                    : Colors.black87,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isComingSoon)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Soon',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 35, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Platform',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.account_circle,
                          color: isDark ? Colors.white : Colors.black87,
                          size: 28,
                        ),
                        onPressed: _handleLogout,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose your preferred notification source',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 16,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 12,
                ),
                itemCount: AppIcon.values.length - 1,
                itemBuilder: (context, index) => _buildPlatformCard(
                  AppIcon.values[index + 1],
                  isDark,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                  24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
              ),
              child: ElevatedButton(
                onPressed:
                    selectedPlatform != null ? navigateToSettingsScreen : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPlatform != null
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  foregroundColor: selectedPlatform != null
                      ? Colors.white
                      : (isDark ? Colors.grey[700] : Colors.grey[500]),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: selectedPlatform != null
                          ? Theme.of(context).primaryColor
                          : (isDark ? Colors.grey[700] : Colors.grey[400])!,
                      width: 1.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        color: selectedPlatform != null
                            ? Colors.white
                            : (isDark ? Colors.grey[700] : Colors.grey[500]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
