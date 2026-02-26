import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/custom_snackbar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _wardController;
  late TextEditingController _addressController;
  final _formKey = GlobalKey<FormState>();

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().profile ?? context.read<AuthProvider>().user;
    _firstNameController = TextEditingController(text: user?.firstName);
    _lastNameController = TextEditingController(text: user?.lastName);
    _phoneController = TextEditingController(text: user?.phone);
    _wardController = TextEditingController(text: user?.ward);
    _addressController = TextEditingController(text: user?.address);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    
    if (pickedFile != null) {
      final path = pickedFile.path.toLowerCase();
      if (!path.endsWith('.jpg') && !path.endsWith('.jpeg') && !path.endsWith('.png')) {
        if (mounted) {
          CustomSnackBar.show(context, 'Only JPG, JPEG, and PNG files are allowed.', isError: true);
        }
        return;
      }
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final updatedUser = await context.read<UserProvider>().updateProfile(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phone: _phoneController.text.trim(),
            ward: _wardController.text.trim(),
            address: _addressController.text.trim(),
            avatar: _imageFile,
          );

      if (updatedUser != null && mounted) {
        context.read<AuthProvider>().updateUser(updatedUser);
        CustomSnackBar.show(context, 'Profile updated successfully');
        Navigator.pop(context);
      } else if (mounted) {
        CustomSnackBar.show(context, context.read<UserProvider>().error ?? 'Update failed', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final user = provider.profile ?? context.read<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (user?.avatar != null ? NetworkImage(user!.avatar!) : null) as ImageProvider?,
                    child: _imageFile == null && user?.avatar == null
                        ? const Icon(Icons.person, size: 60, color: AppColors.primary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _firstNameController,
                label: 'First Name',
                validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _lastNameController,
                label: 'Last Name',
                validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _phoneController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _wardController,
                label: 'Ward',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _addressController,
                label: 'Address',
              ),
              const SizedBox(height: 48),
              AppButton(
                label: 'Save Changes',
                onPressed: _save,
                isLoading: provider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
