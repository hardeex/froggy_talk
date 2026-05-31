import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/country.dart';
import '../../../data/models/requests.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/state_widgets.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  Country? _selectedCountry;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCountry == null) {
      _showSnack('Please select your country.');
      return;
    }
    if (!_agreedToTerms) {
      _showSnack('Please agree to the terms to continue.');
      return;
    }

    final success = await ref.read(authStateProvider.notifier).register(
      RegisterRequest(
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        countryCode: _selectedCountry!.code,
      ),
    );

    if (success && mounted) {
      // Load wallet immediately after registration
      context.go('/wallet');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final countriesAsync = ref.watch(countriesProvider);

    // Handle auth errors
    ref.listen(authStateProvider, (_, next) {
      if (next.error != null) {
        _showSnack(next.error!.message);
        ref.read(authStateProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(24),
                _buildHeader(),
                const Gap(40),
                _buildNameField(),
                const Gap(16),
                _buildEmailField(),
                const Gap(16),
                _buildPhoneField(),
                const Gap(16),
                _buildCountrySelector(countriesAsync),
                const Gap(24),
                _buildTermsCheckbox(),
                const Gap(32),
                AppButton(
                  label: 'Create Account',
                  onPressed: _submit,
                  isLoading: authState.isLoading,
                ),
                const Gap(24),
                _buildSignInPrompt(),
                const Gap(16),
              ]
                  .animate(interval: 60.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.15, end: 0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo mark
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Text('🐸', style: TextStyle(fontSize: 26)),
          ),
        ),
        const Gap(20),
        Text(
          'Join FroggyTalk',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontSize: 30,
            color: AppColors.textPrimary,
          ),
        ),
        const Gap(6),
        Text(
          'Stay connected with your community,\nwherever you are.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameCtrl,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Full Name',
        prefixIcon: Icon(Icons.person_outline_rounded),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Full name is required.';
        if (v.trim().split(' ').length < 2) return 'Please enter first and last name.';
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      decoration: const InputDecoration(
        labelText: 'Email Address',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Email is required.';
        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v.trim())) {
          return 'Please enter a valid email address.';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneCtrl,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        prefixIcon: const Icon(Icons.phone_outlined),
        prefixText: _selectedCountry != null
            ? '${_selectedCountry!.phonePrefix} '
            : null,
        prefixStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Phone number is required.';
        if (v.trim().length < 7) return 'Please enter a valid phone number.';
        return null;
      },
    );
  }

  Widget _buildCountrySelector(AsyncValue<List<Country>> countriesAsync) {
    return countriesAsync.when(
      loading: () => Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (e, _) => ErrorStateWidget(
        message: 'Could not load countries.',
        onRetry: () => ref.refresh(countriesProvider),
      ),
      data: (countries) => _CountryDropdown(
        countries: countries,
        selected: _selectedCountry,
        onChanged: (c) => setState(() {
          _selectedCountry = c;
        }),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const Gap(10),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: 'I agree to the ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: Text.rich(
        TextSpan(
          text: 'Already have an account? ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {},
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Country Dropdown Widget ────────────────────────────────────────────────────

class _CountryDropdown extends StatelessWidget {
  const _CountryDropdown({
    required this.countries,
    required this.selected,
    required this.onChanged,
  });

  final List<Country> countries;
  final Country? selected;
  final ValueChanged<Country?> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected != null
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.surfaceBorder,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.public_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
            const Gap(10),
            Expanded(
              child: selected == null
                  ? const Text(
                      'Select your country',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                    )
                  : Row(
                      children: [
                        Text(
                          selected!.flag,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const Gap(10),
                        Expanded(
                          child: Text(
                            selected!.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            selected!.currencyCode,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollCtrl) => Column(
          children: [
            const Gap(12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select Country',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Gap(8),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: countries.length,
                itemBuilder: (_, i) {
                  final c = countries[i];
                  final isSelected = c.code == selected?.code;
                  return ListTile(
                    leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
                    title: Text(
                      c.name,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: Text(
                      c.currencyCode,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      onChanged(c);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
