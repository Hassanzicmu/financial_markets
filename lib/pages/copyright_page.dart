import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:market_rates/widgets/design_system.dart';
import 'package:market_rates/theme.dart';

class CopyrightPage extends StatelessWidget {
  const CopyrightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TradingPlatformLayout(
      title: Text('Copyright', style: AppTypography.titleMd.copyWith(color: context.ink)),
      leading: const BackButton(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.copyright,
              size: 64,
              color: BinanceColors.tradingUp,
            ),
            const SizedBox(height: 24),
            Text(
              '© 2026 WE ALIENS AGENCY. All rights reserved.',
              style: AppTypography.titleMd.copyWith(color: context.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.hairline),
              ),
              child: Text(
                'The Financial Markets mobile application, including its design, interface, graphics, text, data presentation, and software, is the intellectual property of WE ALIENS AGENCY. Unauthorized reproduction, distribution, modification, or use of any part of this app without express written permission from WE ALIENS AGENCY is strictly prohibited.',
                style: AppTypography.bodyMd.copyWith(color: context.inkMute, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.hairline),
              ),
              child: Text(
                'All market data displayed in the app — including government currency exchange rates, cryptocurrency values, and precious metal prices — are provided for informational purposes only. While we strive to provide accurate and timely information, WE ALIENS AGENCY does not guarantee the completeness, accuracy, or reliability of the data and will not be responsible for any financial decisions made based on the app’s content.',
                style: AppTypography.bodyMd.copyWith(color: context.inkMute, height: 1.5),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'For permission requests, licensing inquiries, or other copyright-related matters, please contact:',
              style: AppTypography.bodyMd.copyWith(color: context.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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
                } else {
                  await launchUrl(whatsappUri);
                }
              },
              label: 'WhatsApp Support',
            ),
            const SizedBox(height: 48),
            Text(
              'Financial Markets and its content are protected under international copyright and intellectual property laws.',
              style: AppTypography.caption.copyWith(color: context.inkMute, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
