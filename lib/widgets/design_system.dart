import 'package:flutter/material.dart';
import '../theme.dart';

class TradingPlatformLayout extends StatelessWidget {
  final Widget child;
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const TradingPlatformLayout({
    super.key,
    required this.child,
    this.title,
    this.leading,
    this.actions,
    this.drawer,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.canvas,
      drawer: drawer,
      appBar: title != null 
          ? AppBar(
              backgroundColor: context.canvas,
              elevation: 0,
              centerTitle: false,
              title: title,
              leading: leading,
              actions: actions,
              iconTheme: IconThemeData(color: context.ink),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  height: 1,
                  color: context.hairline,
                ),
              ),
            )
          : null,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        child: child,
      ),
    );
  }
}

class ButtonPrimary extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  
  const ButtonPrimary({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.primary, context.primaryActive],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: context.primary.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.button.copyWith(color: context.onPrimary, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class ButtonSecondary extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  
  const ButtonSecondary({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: context.surfaceCard,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: context.hairline),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.button.copyWith(color: context.ink),
          ),
        ),
      ),
    );
  }
}

class ButtonTradingUp extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  
  const ButtonTradingUp({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: context.tradingUp.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.tradingUp.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.button.copyWith(color: context.tradingUp),
          ),
        ),
      ),
    );
  }
}

class ButtonTradingDown extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  
  const ButtonTradingDown({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: context.tradingDown.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.tradingDown.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.button.copyWith(color: context.tradingDown),
          ),
        ),
      ),
    );
  }
}

class MarketsTableCard extends StatelessWidget {
  final Widget child;
  const MarketsTableCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.hairline.withValues(alpha: 0.5)),
        boxShadow: context.isDark ? [
          BoxShadow(
            color: context.primary.withValues(alpha: 0.05),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          )
        ] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: child,
    );
  }
}

class MarketsTableHeader extends StatelessWidget {
  final bool isAscending;
  final VoidCallback onSortPrice;
  final String rightLabel;

  const MarketsTableHeader({
    super.key,
    required this.isAscending,
    required this.onSortPrice,
    this.rightLabel = 'Price / 24h Chg',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12, top: 4, left: 16, right: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.hairline)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 44),
          Expanded(
            child: Text('Asset / Name', style: AppTypography.caption.copyWith(color: context.inkMute)),
          ),
          InkWell(
            onTap: onSortPrice,
            child: Row(
              children: [
                Text(rightLabel, style: AppTypography.caption.copyWith(color: context.inkMute)),
                const SizedBox(width: 4),
                Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: context.inkMute),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final Widget child;
  const FeatureCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class StatCalloutCard extends StatelessWidget {
  final String value;
  final String label;

  const StatCalloutCard({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.numberDisplay.copyWith(color: context.primary),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodyMd.copyWith(color: context.inkMute),
        ),
      ],
    );
  }
}

class MarketsRow extends StatelessWidget {
  final Widget icon;
  final String symbol;
  final String name;
  final String price;
  final String change;
  final bool isUp;
  final VoidCallback? onTap;
  final bool? isFavorite;

  const MarketsRow({
    super.key,
    required this.icon,
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.isUp,
    this.onTap,
    this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.hairline)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: icon,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(symbol, style: AppTypography.titleSm.copyWith(color: context.ink)),
                      if (isFavorite != null) ...[
                        const SizedBox(width: 6),
                        Icon(
                          isFavorite! ? Icons.star : Icons.star_border,
                          color: isFavorite! ? BinanceColors.primary : context.inkMute,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  Text(name, style: AppTypography.caption.copyWith(color: context.inkMute)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: AppTypography.numberMd.copyWith(color: context.ink)),
                Row(
                  children: [
                    Icon(
                      isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: isUp ? context.tradingUp : context.tradingDown,
                      size: 16,
                    ),
                    Text(
                      change, 
                      style: AppTypography.numberSm.copyWith(
                        color: isUp ? context.tradingUp : context.tradingDown,
                      )
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TextInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  
  const TextInputField({super.key, required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: context.hairline),
      ),
      child: TextField(
        controller: controller,
        style: AppTypography.bodyMd.copyWith(color: context.ink),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: AppTypography.bodyMd.copyWith(color: context.inkMute),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          isDense: true,
        ),
      ),
    );
  }
}

class QRPromoCard extends StatelessWidget {
  const QRPromoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trade on the go. Anywhere, anytime.', style: AppTypography.titleMd.copyWith(color: context.ink)),
          const SizedBox(height: 16),
          Text('Scan to download the app.', style: AppTypography.bodyMd.copyWith(color: context.inkMute)),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                color: context.canvas,
                child: Center(
                  child: Icon(Icons.qr_code_2, size: 64, color: context.ink),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.hairline),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.apple, size: 16, color: context.ink),
                        const SizedBox(width: 8),
                        Text('App Store', style: AppTypography.caption.copyWith(color: context.ink)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.hairline),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.android, size: 16, color: context.ink),
                        const SizedBox(width: 8),
                        Text('Google Play', style: AppTypography.caption.copyWith(color: context.ink)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
