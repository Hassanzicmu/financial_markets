import 'package:flutter/material.dart';
import 'package:financial_markets/widgets/design_system.dart';
import 'package:financial_markets/theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TradingPlatformLayout(
      title: Text('About', style: AppTypography.titleMd.copyWith(color: context.ink)),
      leading: const BackButton(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.query_stats_rounded,
                size: 64,
                color: context.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Financial Markets',
              style: AppTypography.titleLg.copyWith(color: context.ink),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.1',
              style: AppTypography.bodyMd.copyWith(color: context.inkMute),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Markets is a powerful and intuitive mobile application designed to keep you connected to the real value of money and precious assets. In a world where prices change every moment, Financial Markets provides a reliable and convenient way to monitor government currency exchange rates, cryptocurrency values, and precious metal prices such as gold and silver — all in one place.',
                    style: AppTypography.bodyMd.copyWith(color: context.ink, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Built for investors, traders, business owners, and everyday users, the app delivers accurate, real-time market data through a clean and easy-to-navigate interface. Whether you\'re tracking global currencies, checking crypto market movements, or staying updated on gold and silver prices, Financial Markets helps you make smarter financial decisions with confidence.',
                    style: AppTypography.bodyMd.copyWith(color: context.ink, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Key Features',
                    style: AppTypography.titleSm.copyWith(color: context.ink),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context: context,
                    icon: Icons.currency_exchange,
                    title: 'Live Currency Exchange Rates',
                    description: 'Access up-to-date official and market currency rates from around the world.',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context: context,
                    icon: Icons.currency_bitcoin,
                    title: 'Cryptocurrency Price Tracking',
                    description: 'Follow major digital currencies and stay informed about market fluctuations.',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context: context,
                    icon: Icons.diamond_outlined,
                    title: 'Precious Metals Page',
                    description: 'Monitor precious metal prices with reliable, real-time updates.',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context: context,
                    icon: Icons.speed,
                    title: 'Smart & Simple Interface',
                    description: 'Designed for speed, clarity, and effortless navigation.',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context: context,
                    icon: Icons.update,
                    title: 'Instant Updates',
                    description: 'Get the latest market movements as they happen.',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context: context,
                    icon: Icons.account_balance,
                    title: 'Live Local Bank Rates',
                    description: 'Track the exact buy and sell rates of currencies from local banks in real-time.',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context: context,
                    icon: Icons.show_chart,
                    title: 'Interactive Details & Charts',
                    description: 'Analyze any asset with dynamic charts, historical timeframes, and market statistics.',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context: context,
                    icon: Icons.calculate,
                    title: 'Savings & Balance Calculator',
                    description: 'Manage your personal portfolio and instantly calculate your total net worth across multiple assets.',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context: context,
                    icon: Icons.dashboard,
                    title: 'All Markets in One App',
                    description: 'No need for multiple apps — Financial Markets combines everything you need in a single platform.',
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Why Financial Markets?',
                    style: AppTypography.titleSm.copyWith(color: context.ink),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Financial markets move fast, and having the right information at the right time is essential. Financial Markets empowers users with transparent, reliable, and easy-to-understand pricing data — helping you stay ahead in a constantly changing market.',
                    style: AppTypography.bodyMd.copyWith(color: context.ink, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Whether you are investing, trading, or simply staying informed, Financial Markets is your trusted companion for tracking the value of currencies, cryptocurrencies, gold, and silver.',
                    style: AppTypography.bodyMd.copyWith(color: context.ink, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      'Financial Markets — Your Guide to Real Market Prices.',
                      style: AppTypography.titleSm.copyWith(color: context.primary, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              '© 2026 Financial Markets. All Rights Reserved.',
              style: AppTypography.caption.copyWith(color: context.inkMute),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: context.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleSm.copyWith(color: context.ink, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.bodyMd.copyWith(color: context.inkMute),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
