import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:financial_markets/widgets/design_system.dart';
import 'package:financial_markets/theme.dart';

class AboutAstraTechPage extends StatelessWidget {
  const AboutAstraTechPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TradingPlatformLayout(
      title: Text('About ASTRA TECH', style: AppTypography.titleMd.copyWith(color: context.ink)),
      leading: const BackButton(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Image.asset(
              'assets/copyrights/astra-logo.png',
              height: 100,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.business,
                size: 80,
                color: context.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ASTRA TECH Company',
              style: AppTypography.titleLg.copyWith(color: context.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ASTRA TECH Company is a leading technology and innovation hub dedicated to building robust, modern software solutions. We specialize in financial applications, enterprise tools, and user-centric mobile experiences.',
                    style: AppTypography.bodyMd.copyWith(color: context.ink, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Our mission is to empower individuals and businesses with the data and tools they need to navigate the complexities of the modern digital economy.',
                    style: AppTypography.bodyMd.copyWith(color: context.ink, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ButtonPrimary(
              onPressed: () async {
                final Uri websiteUri = Uri.parse('https://www.astra-tech.net');
                if (await canLaunchUrl(websiteUri)) {
                  await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
                }
              },
              label: 'Visit Our Website',
            ),
            const SizedBox(height: 16),
            ButtonSecondary(
              onPressed: () async {
                final Uri emailUri = Uri.parse('mailto:support@astra-tech.net');
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                }
              },
              label: 'Email Support',
            ),
            const SizedBox(height: 16),
            ButtonSecondary(
              onPressed: () async {
                final Uri whatsappUri = Uri.parse('https://wa.me/201033978114');
                if (await canLaunchUrl(whatsappUri)) {
                  await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
                }
              },
              label: 'WhatsApp Support',
            ),
            const SizedBox(height: 48),
            Text(
              '© 2026 ASTRA TECH Company. All Rights Reserved.',
              style: AppTypography.caption.copyWith(color: context.inkMute),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
