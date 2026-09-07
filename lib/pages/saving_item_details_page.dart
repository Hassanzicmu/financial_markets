import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:market_rates/widgets/design_system.dart';
import 'package:market_rates/theme.dart';
import '../models/saving_item.dart';
import '../services/savings_service.dart';
import 'my_savings_page.dart'; // To reuse _AddHoldingSheet for editing

class SavingItemDetailsPage extends StatefulWidget {
  final SavingItem item;
  final Map<String, dynamic> usdRates;
  final Map<String, String> allSymbols;

  const SavingItemDetailsPage({
    super.key,
    required this.item,
    required this.usdRates,
    required this.allSymbols,
  });

  @override
  State<SavingItemDetailsPage> createState() => _SavingItemDetailsPageState();
}

class _SavingItemDetailsPageState extends State<SavingItemDetailsPage> {
  late SavingItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  double _calculateItemValue(SavingItem item) {
    final rate = widget.usdRates[item.symbol.toLowerCase()];
    if (rate != null && rate is num && rate > 0) {
      double amount = item.amount;
      if (item.assetClass == AssetClass.metal && item.unit == 'g') {
        amount = amount / 31.1035;
      }
      return amount / rate.toDouble();
    }
    return 0.0;
  }

  void _deleteHolding() async {
    await SavingsService.removeSaving(_item.id);
    if (mounted) Navigator.pop(context, true); // Pop and signal changes
  }

  void _editHolding() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHoldingSheet(
        allSymbols: widget.allSymbols,
        existingItem: _item,
      ),
    ).then((updatedItem) {
      if (updatedItem != null && updatedItem is SavingItem) {
        setState(() {
          _item = updatedItem;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
    final dateFormatter = DateFormat.yMMMd();
    
    final itemValue = _calculateItemValue(_item);
    final name = widget.allSymbols[_item.symbol] ?? _item.symbol.toUpperCase();
    final unitString = _item.unit != null ? _item.unit!.toUpperCase() : _item.symbol.toUpperCase();
    
    IconData iconData;
    Color iconColor = context.primary;
    switch (_item.assetClass) {
      case AssetClass.crypto:
        iconData = Icons.currency_bitcoin;
        break;
      case AssetClass.metal:
        iconData = Icons.diamond_outlined;
        break;
      default:
        iconData = Icons.payments_outlined;
    }

    return Scaffold(
      backgroundColor: context.surfaceSoft,
      appBar: AppBar(
        backgroundColor: context.surfaceSoft,
        elevation: 0,
        title: Text('Asset Details', style: AppTypography.titleMd.copyWith(color: context.ink)),
        iconTheme: IconThemeData(color: context.ink),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: context.hairline,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              color: context.surfaceSoft,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: iconColor.withValues(alpha: 0.1),
                    child: Icon(iconData, color: iconColor, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(name, style: AppTypography.titleLg.copyWith(color: context.ink)),
                  const SizedBox(height: 8),
                  Text(
                    formatter.format(itemValue),
                    style: AppTypography.numberDisplay.copyWith(color: context.ink),
                  ),
                  const SizedBox(height: 8),
                  Text('${_item.amount.toStringAsFixed(4)} $unitString', style: AppTypography.bodyMd.copyWith(color: context.inkMute)),
                  if (_item.purchaseAmount > 0) ...[
                    const SizedBox(height: 24),
                    Builder(
                      builder: (context) {
                        final purchaseRate = widget.usdRates[_item.purchaseCurrency.toLowerCase()];
                        if (purchaseRate == null || purchaseRate == 0) return const SizedBox.shrink();
                        
                        final currentValueInPurchaseCurr = itemValue * purchaseRate;
                        final pnl = currentValueInPurchaseCurr - _item.purchaseAmount;
                        final isPositive = pnl >= 0;
                        final pnlPercent = (_item.purchaseAmount > 0) ? (pnl / _item.purchaseAmount) * 100 : 0.0;
                        
                        final pnlFormatter = NumberFormat.currency(symbol: '', decimalDigits: 2);

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isPositive ? context.tradingUp.withValues(alpha: 0.1) : context.tradingDown.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isPositive ? context.tradingUp.withValues(alpha: 0.3) : context.tradingDown.withValues(alpha: 0.3)
                            ),
                          ),
                          child: Column(
                            children: [
                              Text('Total Return (${_item.purchaseCurrency.toUpperCase()})', style: AppTypography.caption.copyWith(color: context.inkMute)),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                                    color: isPositive ? context.tradingUp : context.tradingDown,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${pnlFormatter.format(pnl.abs())} (${pnlPercent.toStringAsFixed(2)}%)',
                                    style: AppTypography.titleSm.copyWith(
                                      color: isPositive ? context.tradingUp : context.tradingDown,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Information', style: AppTypography.titleSm.copyWith(color: context.ink)),
                    const SizedBox(height: 16),
                    _buildDetailRow('Asset Class', _item.assetClass.name.toUpperCase(), context),
                    if (_item.purchaseAmount > 0) ...[
                      Divider(height: 32, color: context.hairline),
                      _buildDetailRow('Purchase Value', '${_item.purchaseAmount.toStringAsFixed(2)} ${_item.purchaseCurrency.toUpperCase()}', context),
                    ],
                    Divider(height: 32, color: context.hairline),
                    _buildDetailRow(_item.assetClass == AssetClass.metal ? 'Purchase Date' : 'Income Date', dateFormatter.format(_item.actionDate), context),
                    Divider(height: 32, color: context.hairline),
                    _buildDetailRow('Created At', dateFormatter.format(_item.createdAt), context),
                    if (_item.notes != null && _item.notes!.isNotEmpty) ...[
                      Divider(height: 32, color: context.hairline),
                      Text('Notes', style: AppTypography.bodySm.copyWith(color: context.inkMute)),
                      const SizedBox(height: 4),
                      Text(_item.notes!, style: AppTypography.bodyMd.copyWith(color: context.ink)),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ButtonSecondary(
                      label: 'Delete',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: context.surfaceCard,
                            title: Text('Delete Asset', style: AppTypography.titleMd.copyWith(color: context.ink)),
                            content: Text('Are you sure you want to delete this asset?', style: AppTypography.bodyMd.copyWith(color: context.ink)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: context.ink))),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteHolding();
                                },
                                child: Text('Delete', style: TextStyle(color: BinanceColors.tradingDown)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ButtonPrimary(
                      label: 'Edit',
                      onPressed: _editHolding,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.bodyMd.copyWith(color: context.inkMute)),
        Text(value, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold, color: context.ink)),
      ],
    );
  }
}
