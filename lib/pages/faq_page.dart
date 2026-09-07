import 'package:flutter/material.dart';
import 'package:market_rates/widgets/design_system.dart';
import 'package:market_rates/theme.dart';

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
            Container(
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
                  title: Text('How often are rates updated?', style: AppTypography.titleSm.copyWith(color: context.ink)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                      child: Text(
                        'Currency and crypto rates are updated in real-time or at frequent intervals depending on the asset class.',
                        style: AppTypography.bodyMd.copyWith(color: context.inkMute),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
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
                  title: Text('Is the data accurate?', style: AppTypography.titleSm.copyWith(color: context.ink)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                      child: Text(
                        'We source our data from reliable financial providers to ensure maximum accuracy.',
                        style: AppTypography.bodyMd.copyWith(color: context.inkMute),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
