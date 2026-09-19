import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:financial_markets/widgets/design_system.dart';
import 'package:financial_markets/theme.dart';

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
            Image.asset(
              'assets/copyrights/astra-logo.png',
              height: 80,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.copyright,
                size: 64,
                color: BinanceColors.tradingUp,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '© 2026 ASTRA TECH Company. All rights reserved.',
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
                'The Financial Markets mobile application, including its design, interface, graphics, text, data presentation, and software, is the intellectual property of ASTRA TECH Company. Unauthorized reproduction, distribution, modification, or use of any part of this app without express written permission from ASTRA TECH Company is strictly prohibited.',
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
                'All market data displayed in the app — including government currency exchange rates, cryptocurrency values, and precious metal prices — are provided for informational purposes only. While we strive to provide accurate and timely information, ASTRA TECH Company does not guarantee the completeness, accuracy, or reliability of the data and will not be responsible for any financial decisions made based on the app’s content.',
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
