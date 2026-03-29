import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _zipCodeController;
  late TextEditingController _countryController;
  String? _avatarUrl;
  File? _localAvatarFile;
  bool _isEditing = true; // Start in edit mode by default
  final ImagePicker _picker = ImagePicker();

  // Sample avatar URLs for selection (cartoon characters)
  static const List<String> sampleAvatars = [
    'https://api.dicebear.com/7.x/avataaars/png?seed=Felix',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Aneka',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Bailey',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Charlie',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Dana',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Elliot',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Frankie',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Grace',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Harper',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Indigo',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Jamie',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Kai',
  ];

  // Default avatar when none selected
  static const String defaultAvatarUrl = 'https://api.dicebear.com/7.x/avataaars/png?seed=Felix';

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final user = authState.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _zipCodeController = TextEditingController(text: user?.zipCode ?? '');
    _countryController = TextEditingController(text: user?.country ?? 'United States');
    // Set default avatar if user doesn't have one
    _avatarUrl = (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) 
        ? user.avatarUrl 
        : defaultAvatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState.user == null) return;

    // For local demo, we'll use the local file path as avatar URL
    // In production, you would upload the image to a server and get a URL
    String? finalAvatarUrl = _avatarUrl;
    if (_localAvatarFile != null) {
      // Store the local file path as a placeholder URL
      // In production, this would be an uploaded image URL
      finalAvatarUrl = _localAvatarFile!.path;
    }

    final updatedUser = authState.user!.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
      zipCode: _zipCodeController.text.trim().isNotEmpty ? _zipCodeController.text.trim() : null,
      country: _countryController.text.trim().isNotEmpty ? _countryController.text.trim() : null,
      avatarUrl: finalAvatarUrl,
    );

    context.read<AuthBloc>().add(AuthUserUpdated(updatedUser));
    
    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _localAvatarFile = File(pickedFile.path);
          _avatarUrl = null; // Clear URL when using local file
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.face),
              title: const Text('Choose Sample Avatar'),
              onTap: () {
                Navigator.pop(context);
                _showSampleAvatars(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Enter Image URL'),
              onTap: () {
                Navigator.pop(context);
                _showImageUrlDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Use Default Avatar'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _avatarUrl = defaultAvatarUrl;
                  _localAvatarFile = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSampleAvatars(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose an Avatar'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: sampleAvatars.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _avatarUrl = sampleAvatars[index];
                    _localAvatarFile = null;
                  });
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(sampleAvatars[index]),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showImageUrlDialog(BuildContext context) {
    final urlController = TextEditingController(text: _avatarUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Image URL'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: 'https://example.com/avatar.jpg',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _avatarUrl = urlController.text.trim();
                _localAvatarFile = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('Save'),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState.user == null) {
            return const Center(child: Text('Please log in to view your profile'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar Section - Round shape with Logo background
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          // Priority: Local file > URL > Default initial
                          backgroundImage: _localAvatarFile != null
                              ? FileImage(_localAvatarFile!)
                              : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                                  ? NetworkImage(_avatarUrl!)
                                  : null),
                          child: (_localAvatarFile == null && 
                                  (_avatarUrl == null || _avatarUrl!.isEmpty))
                              ? Text(
                                  authState.user!.name.isNotEmpty 
                                      ? authState.user!.name[0].toUpperCase() 
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                onPressed: () => _showAvatarOptions(context),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authState.user!.email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Profile Form
                  TextFormField(
                    controller: _nameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    enabled: false, // Email cannot be changed
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _addressController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.home_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          enabled: _isEditing,
                          decoration: const InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _zipCodeController,
                          enabled: _isEditing,
                          decoration: const InputDecoration(
                            labelText: 'ZIP Code',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _countryController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      prefixIcon: Icon(Icons.public_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Save Profile'),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
