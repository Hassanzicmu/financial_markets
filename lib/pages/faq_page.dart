import 'package:flutter/material.dart';
import 'package:financial_markets/widgets/design_system.dart';
import 'package:financial_markets/theme.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TradingPlatformLayout(
      title: Text('FAQ', style: AppTypography.titleMd.copyWith(color: context.ink)),
      leading: const BackButton(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFaqItem(
              context: context,
              question: 'How often are rates updated?',
              answer: 'Currency and crypto rates are updated in real-time or at frequent intervals depending on the asset class.',
            ),
            const SizedBox(height: 12),
            _buildFaqItem(
              context: context,
              question: 'Is the data accurate?',
              answer: 'We source our data from reliable financial providers to ensure maximum accuracy.',
            ),
            const SizedBox(height: 12),
            _buildFaqItem(
              context: context,
              question: 'How do I check local Egyptian bank rates?',
              answer: 'Navigate to the "Bank Rates" page from the main menu or home screen. It displays live buy and sell rates directly from Egyptian banks.',
            ),
            const SizedBox(height: 12),
            _buildFaqItem(
              context: context,
              question: 'How do I add a currency to my favorites?',
              answer: 'Simply tap the star icon next to any currency in the global list or inside the details page. Your favorites will be saved for quick access.',
            ),
            const SizedBox(height: 12),
            _buildFaqItem(
              context: context,
              question: 'Can I track cryptocurrency and precious metal prices?',
              answer: 'Yes! Financial Markets supports thousands of digital assets and precious metals like Gold (XAU) and Silver (XAG). Access them directly from the home dashboard.',
            ),
            const SizedBox(height: 12),
            _buildFaqItem(
              context: context,
              question: 'How does the My Savings calculator work?',
              answer: 'The My Savings page allows you to input your current holdings across various assets (fiat, crypto, metals). The app automatically calculates your total net worth in your preferred base currency using live rates.',
            ),
            const SizedBox(height: 12),
            _buildFaqItem(
              context: context,
              question: 'Why am I seeing random data in the charts?',
              answer: 'Currently, historical chart data is randomly generated around the real-time live price for demonstration purposes until the full historical data API is connected.',
            ),
            const SizedBox(height: 12),
            _buildFaqItem(
              context: context,
              question: 'Who owns Financial Markets?',
              answer: 'Financial Markets is proudly built and owned by ASTRA TECH Company.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({required BuildContext context, required String question, required String answer}) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.hairline),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: context.primary,
          collapsedIconColor: context.inkMute,
          title: Text(question, style: AppTypography.titleSm.copyWith(color: context.ink)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Text(
                answer,
                style: AppTypography.bodyMd.copyWith(color: context.inkMute, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
