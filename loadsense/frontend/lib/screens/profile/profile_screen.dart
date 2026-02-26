import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/screen_header.dart';
import '../../providers/navigation_provider.dart';

import '../../widgets/custom_snackbar.dart';

class ProfileScreen extends StatefulWidget {
  final bool showBackButton;
  const ProfileScreen({super.key, this.showBackButton = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchProfile();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Slightly compress to stay under 2MB
    );
    
    if (pickedFile != null) {
      final path = pickedFile.path.toLowerCase();
      if (!path.endsWith('.jpg') && !path.endsWith('.jpeg') && !path.endsWith('.png')) {
        if (mounted) {
          CustomSnackBar.show(context, 'Only JPG, JPEG, and PNG files are allowed.', isError: true);
        }
        return;
      }

      if (!mounted) return;
      
      final auth = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();
      final user = userProvider.profile ?? auth.user;
      
      if (user != null) {
        final updatedUser = await userProvider.updateProfile(
          firstName: user.firstName,
          lastName: user.lastName,
          phone: user.phone ?? '',
          ward: user.ward ?? '',
          address: user.address ?? '',
          avatar: File(pickedFile.path),
        );
        
        if (updatedUser != null && mounted) {
          auth.updateUser(updatedUser);
          CustomSnackBar.show(context, 'Profile image updated successfully');
        } else if (mounted) {
          CustomSnackBar.show(context, userProvider.error ?? 'Failed to update profile image', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.profile ?? auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(userProvider.error!, style: const TextStyle(color: AppColors.error)),
                      TextButton(onPressed: () => userProvider.fetchProfile(), child: const Text('Retry')),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      ScreenHeader(
                        title: user?.fullName ?? 'User Name',
                        subtitle: user?.email ?? 'email@example.com',
                        showNotification: false,
                        showBackButton: widget.showBackButton,
                        action: IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.white),
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                        ),
                        child: Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 46,
                                  backgroundColor: AppColors.primaryLight,
                                  backgroundImage: (user?.avatar != null && user!.avatar!.isNotEmpty) ? NetworkImage(user!.avatar!) : null,
                                  child: (user?.avatar == null || user!.avatar!.isEmpty)
                                      ? Text(
                                          user?.firstName.isNotEmpty == true ? user!.firstName[0] : 'U',
                                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary),
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                  
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildProfileItem(Icons.person_outline, 'Role', user?.role ?? 'Student'),
                            _buildProfileItem(Icons.phone_outlined, 'Phone', user?.phone ?? 'Not set'),
                            _buildProfileItem(Icons.location_on_outlined, 'Address', user?.address ?? 'Not set'),
                            _buildProfileItem(Icons.map_outlined, 'Ward', user?.ward ?? 'Not set'),
                            const SizedBox(height: 24),
                            _buildSectionHeader('General'),
                            _buildMenuTile(Icons.notifications_none, 'Notifications', () => Navigator.pushNamed(context, AppRoutes.reminders)),
                            _buildMenuTile(Icons.feedback_outlined, 'Send Feedback', () => Navigator.pushNamed(context, AppRoutes.feedback)),
                            _buildMenuTile(Icons.info_outline, 'About LoadSense', () => Navigator.pushNamed(context, AppRoutes.about)),
                            const SizedBox(height: 24),
                            _buildMenuTile(
                              Icons.logout,
                              'Logout',
                              () => _showLogoutDialog(context),
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? AppColors.textPrimary),
      title: Text(title, style: TextStyle(color: color ?? AppColors.textPrimary, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textDisabled),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<NavigationProvider>().setIndex(0);
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
