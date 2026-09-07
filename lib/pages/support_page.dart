import 'package:flutter/material.dart';
import 'package:market_rates/widgets/design_system.dart';
import 'package:market_rates/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TradingPlatformLayout(
      title: Text('Support', style: AppTypography.titleMd.copyWith(color: context.ink)),
      leading: const BackButton(),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.help_outline, size: 80, color: context.primary),
              const SizedBox(height: 24),
              Text(
                'Need Help?',
                style: AppTypography.titleLg.copyWith(color: context.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Our team is here to assist you with any questions or issues you may have.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd.copyWith(color: context.inkMute),
              ),
              const SizedBox(height: 48),
              ButtonPrimary(
                onPressed: () async {
                  final Uri emailUri = Uri.parse('mailto:support@wealiens.com');
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  }
                },
                label: 'Email Support',
              ),
              const SizedBox(height: 16),
              ButtonSecondary(
                onPressed: () async {
                  final Uri whatsappUri = Uri.parse('https://wa.me/0021113212911');
                  if (await canLaunchUrl(whatsappUri)) {
                    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
                  }
                },
                label: 'WhatsApp Support',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
