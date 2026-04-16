import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final String currentDomain;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentEmail,
    required this.currentDomain,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _otherDomainController;
  
  String? _selectedDomain;
  bool _isOtherSelected = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<String> _domains = [
    "Frontend Development",
    "Backend Development",
    "Full Stack Development",
    "Mobile App Development",
    "Artificial Intelligence & Machine Learning",
    "Data Science",
    "Cybersecurity",
    "Cloud Computing",
    "DevOps",
    "Blockchain Development",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _passwordController = TextEditingController();
    _otherDomainController = TextEditingController();

    if (_domains.contains(widget.currentDomain)) {
      _selectedDomain = widget.currentDomain;
    } else if (widget.currentDomain != "Not Set") {
      _selectedDomain = "Other";
      _isOtherSelected = true;
      _otherDomainController.text = widget.currentDomain;
    } else {
      _selectedDomain = _domains[0];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _otherDomainController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final finalDomain = _isOtherSelected ? _otherDomainController.text.trim() : _selectedDomain;

    try {
      final result = await ApiService.updateProfile(
        name: _nameController.text.trim(),
        domain: finalDomain,
        newPassword: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result["error"] != true) {
        // Update local storage
        await AuthService.updateUserLocalData(
          name: _nameController.text.trim(),
          domain: finalDomain,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully"), backgroundColor: AppColors.success),
        );
        Navigator.pop(context, true); // Return true to indicate update happened
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Update failed"), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred"), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email (Read-only)
              _buildLabel("Email Address (Cannot be changed)"),
              TextFormField(
                initialValue: widget.currentEmail,
                enabled: false,
                decoration: InputDecoration(
                  fillColor: AppColors.surface.withOpacity(0.5),
                  filled: true,
                ),
              ),
              const SizedBox(height: 24),

              // Name
              _buildLabel("Full Name"),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: "Enter your name"),
                validator: (val) => val == null || val.isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 24),

              // Domain Dropdown
              _buildLabel("Domain Currently Studying"),
              DropdownButtonFormField<String>(
                value: _selectedDomain,
                isExpanded: true,
                items: _domains.map((d) => DropdownMenuItem(
                  value: d, 
                  child: Text(
                    d,
                    overflow: TextOverflow.ellipsis,
                  )
                )).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedDomain = val;
                    _isOtherSelected = val == "Other";
                  });
                },
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              ),
              
              if (_isOtherSelected) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _otherDomainController,
                  decoration: const InputDecoration(hintText: "Enter your domain manually"),
                  validator: (val) => _isOtherSelected && (val == null || val.isEmpty) ? "Please specify your domain" : null,
                ),
              ],
              const SizedBox(height: 24),

              // Password Change
              _buildLabel("New Password (Leave blank to keep current)"),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: "••••••••",
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return null;
                  if (val.length < 6) return 'Minimum 6 characters';
                  if (!RegExp(r'[A-Z]').hasMatch(val)) return 'Missing uppercase letter';
                  if (!RegExp(r'[a-z]').hasMatch(val)) return 'Missing lowercase letter';
                  if (!RegExp(r'[0-9]').hasMatch(val)) return 'Missing a number';
                  if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(val)) return 'Missing special character';
                  return null;
                },
              ),

              const SizedBox(height: 48),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
    );
  }
}
