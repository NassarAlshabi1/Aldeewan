import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/presentation/providers/account_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/utils/error_handler.dart';

class LinkAccountScreen extends ConsumerStatefulWidget {
  const LinkAccountScreen({super.key});

  @override
  ConsumerState<LinkAccountScreen> createState() => _LinkAccountScreenState();
}

class _LinkAccountScreenState extends ConsumerState<LinkAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedProvider = 'MOCK_BANK';
  bool _isLoading = false;

  final List<Map<String, String>> _providers = [
    {'id': 'MOCK_BANK', 'name': 'Mock Bank (Demo)'},
    {'id': 'MBOK', 'name': 'Bank of Khartoum (Mbok)'},
    {'id': 'SYBER', 'name': 'Syber Pay'},
  ];

  Future<void> _linkAccount() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isLoading = true);

    bool success = false;
    try {
      await ref.read(accountProvider.notifier).linkAccount(
            _selectedProvider,
            _usernameController.text,
            _passwordController.text,
          );
      success = true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorOccurred(ErrorHandler.getUserFriendlyErrorMessage(e, l10n)))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.accountLinkedSuccess)),
          );
          context.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.linkBankAccountTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(LucideIcons.landmark, size: 64, color: Colors.grey),
              const SizedBox(height: 24),
              Text(
                'Connect your bank or wallet to automatically track transactions.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              DropdownButtonFormField<String>(
                initialValue: _selectedProvider,
                decoration: const InputDecoration(
                  labelText: 'Select Provider',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(LucideIcons.building),
                ),
                items: _providers.map((provider) {
                  return DropdownMenuItem(
                    value: provider['id'],
                    child: Text(provider['name']!),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedProvider = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username / Phone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(LucideIcons.user),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password / PIN',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(LucideIcons.lock),
                ),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isLoading ? null : _linkAccount,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.connectAccount),
              ),
              if (_selectedProvider == 'MOCK_BANK') ...[
                const SizedBox(height: 16),
                Text(
                  'Demo Credentials:\nUser: ${dotenv.env['MOCK_USER'] ?? 'user'}\nPass: ${dotenv.env['MOCK_PASSWORD'] ?? 'password'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
