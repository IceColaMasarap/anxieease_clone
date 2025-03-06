import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/theme_provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          // Account Settings
          _buildSection(
            context,
            'Account Settings',
            [
              _buildSettingTile(
                context,
                title: 'Profile Information',
                subtitle: 'Update your personal and professional details',
                icon: Icons.person_outline,
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                title: 'Change Password',
                subtitle: 'Update your account password',
                icon: Icons.lock_outline,
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                title: 'Email Notifications',
                subtitle: 'Configure email notification preferences',
                icon: Icons.notifications_outlined,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Appearance Settings
          _buildSection(
            context,
            'Appearance',
            [
              _buildSettingTile(
                context,
                title: 'Dark Mode',
                subtitle: 'Toggle between light and dark theme',
                icon: Icons.dark_mode_outlined,
                trailing: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) => themeProvider.toggleTheme(),
                    );
                  },
                ),
              ),
              _buildSettingTile(
                context,
                title: 'Language',
                subtitle: 'Change application language',
                icon: Icons.language,
                trailing: DropdownButton<String>(
                  value: 'English',
                  items: const [
                    DropdownMenuItem(
                      value: 'English',
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: 'Spanish',
                      child: Text('Spanish'),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Privacy & Security
          _buildSection(
            context,
            'Privacy & Security',
            [
              _buildSettingTile(
                context,
                title: 'Two-Factor Authentication',
                subtitle: 'Add an extra layer of security',
                icon: Icons.security,
                trailing: Switch(
                  value: false,
                  onChanged: (value) {},
                ),
              ),
              _buildSettingTile(
                context,
                title: 'Data Privacy',
                subtitle: 'Manage your data and privacy settings',
                icon: Icons.privacy_tip_outlined,
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                title: 'Session Management',
                subtitle: 'View and manage active sessions',
                icon: Icons.devices,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Support & About
          _buildSection(
            context,
            'Support & About',
            [
              _buildSettingTile(
                context,
                title: 'Help Center',
                subtitle: 'Get help and support',
                icon: Icons.help_outline,
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                title: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                icon: Icons.description_outlined,
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                icon: Icons.policy_outlined,
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                title: 'About',
                subtitle: 'Version 1.0.0',
                icon: Icons.info_outline,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
    );
  }
} 