import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/translation_service.dart';
import '../providers/language_provider.dart';
import '../core/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final bool isLawyer;
  const ProfileScreen({super.key, required this.isLawyer});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _subDistrictController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await _authService.getUserData(user.uid);
        if (doc != null && doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _nameController.text = data['name'] ?? "";
            _emailController.text = data['email'] ?? "";
            _bioController.text = data['bio'] ?? "";
            _stateController.text = data['state'] ?? "";
            _districtController.text = data['district'] ?? "";
            _subDistrictController.text = data['subDistrict'] ?? "";
            _isLoading = false;
          });
        } else {
          setState(() {
            _emailController.text = user.email ?? "";
            _nameController.text = user.displayName ?? "";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _saveProfile(String lang) async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name cannot be empty")));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _authService.updateFullProfile(user.uid, {
          'name': _nameController.text.trim(),
          'bio': _bioController.text.trim(),
          'state': _stateController.text.trim(),
          'district': _districtController.text.trim(),
          'subDistrict': _subDistrictController.text.trim(),
          'role': widget.isLawyer ? 'lawyer' : 'client',
        });
        
        // Update local display name if possible
        try {
          await user.updateDisplayName(_nameController.text.trim());
        } catch (_) {}

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully")),
          );
          Navigator.pop(context, true); // Return true to trigger refresh
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final effectiveLang = langProvider.isHinglish ? 'hinglish' : langProvider.currentLocale.languageCode;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.obsidianBlack,
        body: Center(child: CircularProgressIndicator(color: AppTheme.goldenDawn)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.obsidianBlack,
      appBar: AppBar(
        title: Text(TranslationService.translate('edit_profile', effectiveLang), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isSaving)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.goldenDawn))))
          else
            TextButton(
              onPressed: () => _saveProfile(effectiveLang),
              child: Text(TranslationService.translate('save', effectiveLang).toUpperCase(), style: const TextStyle(color: AppTheme.goldenDawn, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.charcoalDeep,
              child: Icon(Icons.account_circle_rounded, size: 120, color: AppTheme.goldenDawn),
            ),
            const SizedBox(height: 32),
            _buildTextField(TranslationService.translate('full_name', effectiveLang), _nameController, Icons.person_outline),
            const SizedBox(height: 20),
            _buildTextField(TranslationService.translate('email', effectiveLang), _emailController, Icons.email_outlined, enabled: false),
            const SizedBox(height: 20),
            _buildTextField("State", _stateController, Icons.map_outlined),
            const SizedBox(height: 20),
            _buildTextField("District", _districtController, Icons.location_city_outlined),
            const SizedBox(height: 20),
            _buildTextField("Sub-District", _subDistrictController, Icons.location_on_outlined),
            const SizedBox(height: 20),
            _buildTextField(TranslationService.translate('bio', effectiveLang), _bioController, Icons.info_outline, maxLines: 4),
            const SizedBox(height: 40),
            if (widget.isLawyer) ...[
              Card(
                color: AppTheme.charcoalDeep,
                child: ListTile(
                  leading: const Icon(Icons.verified_user, color: AppTheme.goldenDawn),
                  title: Text(TranslationService.translate('open', effectiveLang), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(TranslationService.translate('verify_practice', effectiveLang), style: const TextStyle(color: Colors.white70)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.goldenDawn)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          enabled: enabled,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.goldenDawn.withOpacity(0.7)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            filled: true,
            fillColor: AppTheme.charcoalDeep,
          ),
        ),
      ],
    );
  }
}
