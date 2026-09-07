import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:market_rates/widgets/design_system.dart';
import 'package:market_rates/theme.dart';
import '../models/saving_item.dart';

class TotalBalanceDetailsPage extends StatefulWidget {
  final List<SavingItem> savings;
  final Map<String, String> allSymbols;
  final Map<String, dynamic> usdRates;

  const TotalBalanceDetailsPage({
    super.key,
    required this.savings,
    required this.allSymbols,
    required this.usdRates,
  });

  @override
  State<TotalBalanceDetailsPage> createState() => _TotalBalanceDetailsPageState();
}

class _TotalBalanceDetailsPageState extends State<TotalBalanceDetailsPage> {
  String _selectedCurrency = 'usd';

  @override
  Widget build(BuildContext context) {
    // 1. Calculate USD totals
    double totalCurrentUsd = 0.0;
    double totalPurchaseUsd = 0.0;

    for (var item in widget.savings) {
      // Current USD Value
      final currentRate = widget.usdRates[item.symbol.toLowerCase()];
      if (currentRate != null && currentRate is num && currentRate > 0) {
        double amount = item.amount;
        if (item.assetClass == AssetClass.metal && item.unit == 'g') {
          amount = amount / 31.1035; // Convert Grams to Troy Ounces
        }
        totalCurrentUsd += (amount / currentRate.toDouble());
      }

      // Purchase USD Value
      final purchaseRate = widget.usdRates[item.purchaseCurrency.toLowerCase()];
      if (purchaseRate != null && purchaseRate is num && purchaseRate > 0) {
        totalPurchaseUsd += (item.purchaseAmount / purchaseRate.toDouble());
      }
    }

    // 2. Convert to selected currency
    final selectedRateDynamic = widget.usdRates[_selectedCurrency.toLowerCase()];
    final double selectedRate = (selectedRateDynamic is num) ? selectedRateDynamic.toDouble() : 1.0;

    final double totalCurrent = totalCurrentUsd * selectedRate;
    final double totalPurchase = totalPurchaseUsd * selectedRate;
    final double margin = totalCurrent - totalPurchase;
    final double marginPercent = totalPurchase > 0 ? (margin / totalPurchase) * 100 : 0.0;

    final isPositive = margin >= 0;
    final marginColor = isPositive ? BinanceColors.tradingUp : BinanceColors.tradingDown;
    final marginIcon = isPositive ? Icons.trending_up : Icons.trending_down;
    final marginPrefix = isPositive ? '+' : '';

    // Choose formatter based on currency symbol logic if desired, or just generic
    final formatter = NumberFormat.currency(
      symbol: _selectedCurrency.toUpperCase() == 'USD' ? r'$' : '${_selectedCurrency.toUpperCase()} ',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: context.surfaceSoft,
      appBar: AppBar(
        backgroundColor: context.surfaceSoft,
        elevation: 0,
        iconTheme: IconThemeData(color: context.ink),
        title: Text('Portfolio Details', style: AppTypography.titleMd.copyWith(color: context.ink)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: context.hairline,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Currency Selector
            Text('Display Currency', style: AppTypography.titleSm.copyWith(color: context.ink)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: context.surfaceCard,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  builder: (context) {
                    return _SearchModal(
                      title: 'Select Currency',
                      items: widget.allSymbols,
                      onSelected: (val) {
                        setState(() => _selectedCurrency = val);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedCurrency.toUpperCase()} - ${widget.allSymbols[_selectedCurrency] ?? ''}',
                      style: AppTypography.bodyMd.copyWith(color: context.ink)
                    ),
                    Icon(Icons.arrow_drop_down, color: context.inkMute),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Estimated Balance
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.surfaceCard,
                    context.surfaceCard.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.primary.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: context.primary.withValues(alpha: 0.08),
                    blurRadius: 24,
                    spreadRadius: -2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text('Total Estimated Balance', style: AppTypography.bodyMd.copyWith(color: context.inkMute)),
                  const SizedBox(height: 8),
                  Text(
                    formatter.format(totalCurrent),
                    style: AppTypography.numberDisplay.copyWith(color: context.ink),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Invested Amount
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.hairline),
              ),
              child: Column(
                children: [
                  Text('Total Actual Amount (Invested)', style: AppTypography.bodyMd.copyWith(color: context.inkMute)),
                  const SizedBox(height: 8),
                  Text(
                    formatter.format(totalPurchase),
                    style: AppTypography.titleLg.copyWith(color: context.ink),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Margin (Win/Loss)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: marginColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(marginIcon, color: marginColor, size: 20),
                      const SizedBox(width: 8),
                      Text('Total Return (Win/Loss)', style: AppTypography.bodyMd.copyWith(color: context.inkMute)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatter.format(margin),
                        style: AppTypography.titleLg.copyWith(color: marginColor),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($marginPrefix${marginPercent.toStringAsFixed(2)}%)',
                        style: AppTypography.bodyMd.copyWith(color: marginColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusing the Search Modal for convenience and isolation
class _SearchModal extends StatefulWidget {
  final Map<String, String> items;
  final Function(String) onSelected;
  final String title;

  const _SearchModal({required this.items, required this.onSelected, required this.title});

  @override
  State<_SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<_SearchModal> {
  late List<String> _filtered;
  final TextEditingController _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.items.keys.toList()..sort();
    _ctrl.addListener(() {
      final query = _ctrl.text.toLowerCase();
      setState(() {
        _filtered = widget.items.keys.where((k) {
          final code = k.toLowerCase();
          final name = widget.items[k]!.toLowerCase();
          return code.contains(query) || name.contains(query);
        }).toList()..sort();
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(widget.title, style: AppTypography.titleMd.copyWith(color: context.ink)),
          const SizedBox(height: 16),
          TextInputField(
            controller: _ctrl,
            hintText: 'Search...',
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (c, i) {
                final code = _filtered[i];
                return ListTile(
                  title: Text('${code.toUpperCase()} - ${widget.items[code]}', style: AppTypography.bodyMd.copyWith(color: context.ink)),
                  onTap: () => widget.onSelected(code),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
