import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authStateProvider.notifier)
        .login(_emailCtrl.text.trim(), _passwordCtrl.text);

    if (success && mounted) {
      context.go('/wallet');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.error!.message,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        ref.read(authStateProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  [
                        const Gap(16),
                        _buildHeader(),
                        const Gap(40),
                        _buildEmailField(),
                        const Gap(16),
                        _buildPasswordField(),
                        const Gap(32),
                        AppButton(
                          label: 'Sign In',
                          onPressed: _submit,
                          isLoading: authState.isLoading,
                        ),
                        const Gap(24),
                        _buildSignUpPrompt(),
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
        // Container(
        //   width: 52,
        //   height: 52,
        //   decoration: BoxDecoration(
        //     gradient: AppColors.cardGradient,
        //     borderRadius: BorderRadius.circular(14),
        //   ),
        //   child: const Center(
        //     child: Text('🐸', style: TextStyle(fontSize: 26)),
        //   ),
        // ),
        const Gap(20),
        Text(
          'Welcome back',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontSize: 30,
            color: AppColors.textPrimary,
          ),
        ),
        const Gap(6),
        Text(
          'Sign in to continue to your wallet.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
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

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password is required.';
        return null;
      },
    );
  }

  Widget _buildSignUpPrompt() {
    return Center(
      child: Text.rich(
        TextSpan(
          text: "Don't have an account? ",
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: const Text(
                  'Sign Up',
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
