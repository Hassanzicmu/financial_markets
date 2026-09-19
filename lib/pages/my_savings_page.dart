import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:financial_markets/widgets/design_system.dart';
import 'package:financial_markets/theme.dart';
import '../models/saving_item.dart';
import '../services/savings_service.dart';
import 'saving_item_details_page.dart';
import 'total_balance_details_page.dart';

class MySavingsPage extends StatefulWidget {
  const MySavingsPage({super.key});

  @override
  State<MySavingsPage> createState() => _MySavingsPageState();
}

class _MySavingsPageState extends State<MySavingsPage> {
  List<SavingItem> _savings = [];
  Map<String, String> _allSymbols = {};
  Map<String, dynamic> _usdRates = {};
  bool _isLoading = true;
  String _errorMessage = '';

  static const Map<String, String> _popularCrypto = {
    'btc': 'Bitcoin', 'eth': 'Ethereum', 'bnb': 'Binance Coin', 'sol': 'Solana',
    'xrp': 'XRP', 'ada': 'Cardano', 'doge': 'Dogecoin', 'dot': 'Polkadot'
  };

  static const Map<String, String> _popularMetals = {
    'xau': 'Gold', 'xag': 'Silver', 'xpt': 'Platinum', 'xpd': 'Palladium'
  };

  static const List<String> _popularFiats = [
    'usd', 'eur', 'gbp', 'jpy', 'aud', 'cad', 'chf', 'cny', 'inr', 'sar', 'aed', 'try'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final savings = await SavingsService.getSavings();

      final namesResponse = await http.get(
        Uri.parse('https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json'),
        headers: {'User-Agent': 'FinancialMarketsApp/1.0'}
      );
      if (namesResponse.statusCode == 200) {
        final decoded = json.decode(namesResponse.body) as Map<String, dynamic>;
        _allSymbols = decoded.map((k, v) => MapEntry(k.toLowerCase(), v.toString()));
      }

      final ratesResponse = await http.get(
        Uri.parse('https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json'),
        headers: {'User-Agent': 'FinancialMarketsApp/1.0'}
      );
      if (ratesResponse.statusCode == 200) {
        final decodedRates = json.decode(ratesResponse.body);
        _usdRates = decodedRates['usd'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load live rates');
      }

      setState(() {
        _savings = savings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  double _calculateTotalPortfolioValue() {
    double totalUsd = 0.0;
    for (var item in _savings) {
      totalUsd += _calculateItemValue(item);
    }
    return totalUsd;
  }

  double _calculateItemValue(SavingItem item) {
    final rate = _usdRates[item.symbol.toLowerCase()];
    if (rate != null && rate is num && rate > 0) {
      double amount = item.amount;
      if (item.assetClass == AssetClass.metal && item.unit == 'g') {
        amount = amount / 31.1035; // Convert Grams to Troy Ounces
      }
      return amount / rate.toDouble();
    }
    return 0.0;
  }

  void _showAddHoldingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHoldingSheet(allSymbols: _allSymbols),
    ).then((result) {
      if (result == true || result is SavingItem) {
        _loadData();
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final totalValue = _calculateTotalPortfolioValue();
    final formatter = NumberFormat.currency(symbol: r'$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: context.surfaceSoft,
      appBar: AppBar(
        backgroundColor: context.surfaceSoft,
        elevation: 0,
        title: Text('My Savings', style: AppTypography.titleMd.copyWith(color: context.ink)),
        iconTheme: IconThemeData(color: context.ink),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: context.hairline,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: context.primary))
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: AppTypography.bodyMd.copyWith(color: BinanceColors.tradingDown)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TotalBalanceDetailsPage(
                                savings: _savings,
                                allSymbols: _allSymbols,
                                usdRates: _usdRates,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Estimated Balance', style: AppTypography.bodyMd.copyWith(color: context.inkMute)),
                                  Icon(Icons.chevron_right, color: context.inkMute),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formatter.format(totalValue),
                                style: AppTypography.numberDisplay.copyWith(color: context.ink),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('My Assets', style: AppTypography.titleMd.copyWith(color: context.ink)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_savings.isEmpty)
                        _buildEmptyState()
                      else
                        _buildHoldingsList(formatter),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddHoldingSheet,
        backgroundColor: context.primary,
        icon: Icon(Icons.add, color: context.onPrimary),
        label: Text('Deposit', style: AppTypography.button.copyWith(color: context.onPrimary)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.hairline),
      ),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet, size: 48, color: context.inkMute),
          const SizedBox(height: 16),
          Text('No assets saved yet.', style: AppTypography.titleSm.copyWith(color: context.ink)),
          const SizedBox(height: 8),
          Text(
            'Start building your portfolio by adding your fiat, crypto, or metal holdings.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd.copyWith(color: context.inkMute),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsList(NumberFormat formatter) {
    return MarketsTableCard(
      child: Column(
        children: _savings.map((item) {
          final itemValue = _calculateItemValue(item);
          final name = _allSymbols[item.symbol] ?? item.symbol.toUpperCase();
          IconData iconData;
          Color iconColor = context.primary;

          switch (item.assetClass) {
            case AssetClass.crypto:
              iconData = Icons.currency_bitcoin;
              break;
            case AssetClass.metal:
              iconData = Icons.diamond_outlined;
              break;
            default:
              iconData = Icons.payments_outlined;
          }

          final unitString = item.unit != null ? item.unit!.toUpperCase() : item.symbol.toUpperCase();

          return MarketsRow(
            icon: Container(
              color: iconColor.withValues(alpha: 0.1),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            symbol: name,
            name: '${item.amount.toStringAsFixed(4)} $unitString',
            price: formatter.format(itemValue),
            change: '', // omit change
            isUp: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavingItemDetailsPage(
                    item: item,
                    usdRates: _usdRates,
                    allSymbols: _allSymbols,
                  ),
                ),
              ).then((_) => _loadData());
            },
          );
        }).toList(),
      ),
    );
  }
}

class AddHoldingSheet extends StatefulWidget {
  final Map<String, String> allSymbols;
  final SavingItem? existingItem;

  const AddHoldingSheet({super.key, required this.allSymbols, this.existingItem});

  @override
  State<AddHoldingSheet> createState() => _AddHoldingSheetState();
}

class _AddHoldingSheetState extends State<AddHoldingSheet> {
  AssetClass _selectedClass = AssetClass.fiat;
  String? _selectedSymbol;
  String _metalUnit = 'g';
  final _amountController = TextEditingController();
  final _purchaseAmountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _actionDate = DateTime.now();
  String _selectedPurchaseCurrency = 'usd';

  Map<String, String> _allSymbols = {};

  @override
  void initState() {
    super.initState();
    _allSymbols = widget.allSymbols;
    if (widget.existingItem != null) {
      final item = widget.existingItem!;
      _selectedClass = item.assetClass;
      _selectedSymbol = item.symbol;
      _metalUnit = item.unit ?? 'g';
      _amountController.text = item.amount.toString();
      _purchaseAmountController.text = item.purchaseAmount > 0 ? item.purchaseAmount.toString() : '';
      _selectedPurchaseCurrency = item.purchaseCurrency;
      _notesController.text = item.notes ?? '';
      _actionDate = item.actionDate;
    } else if (_allSymbols.isEmpty) {
      _fetchSymbols();
    }
  }

  Future<void> _fetchSymbols() async {
    try {
      final namesResponse = await http.get(
        Uri.parse('https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json'),
        headers: {'User-Agent': 'FinancialMarketsApp/1.0'}
      );
      if (namesResponse.statusCode == 200) {
        final decoded = json.decode(namesResponse.body) as Map<String, dynamic>;
        setState(() {
          _allSymbols = decoded.map((k, v) => MapEntry(k.toLowerCase(), v.toString()));
          _selectedSymbol = 'usd';
        });
      }
    } catch (_) {}
  }

  List<String> _getSymbolsForClass() {
    switch (_selectedClass) {
      case AssetClass.metal:
        return _MySavingsPageState._popularMetals.keys.toList();
      case AssetClass.crypto:
        return _MySavingsPageState._popularCrypto.keys.toList();
      case AssetClass.fiat:
        final list = List<String>.from(_MySavingsPageState._popularFiats);
        list.addAll(_allSymbols.keys.where((k) => !list.contains(k)));
        return list;
    }
  }

  String _getSymbolName(String symbol) {
    if (_selectedClass == AssetClass.metal) {
      return _MySavingsPageState._popularMetals[symbol] ?? symbol.toUpperCase();
    }
    if (_selectedClass == AssetClass.crypto) {
      return _MySavingsPageState._popularCrypto[symbol] ?? symbol.toUpperCase();
    }
    return _allSymbols[symbol] ?? symbol.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final availableSymbols = _getSymbolsForClass();
    if (availableSymbols.isNotEmpty && (_selectedSymbol == null || !availableSymbols.contains(_selectedSymbol))) {
      _selectedSymbol = availableSymbols.first;
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.existingItem != null ? 'Edit Asset' : 'Add Asset', style: AppTypography.titleLg.copyWith(color: context.ink)),
              const SizedBox(height: 24),
              
              // Segmented Control
              SegmentedButton<AssetClass>(
                segments: const [
                  ButtonSegment(value: AssetClass.fiat, label: Text('Fiat')),
                  ButtonSegment(value: AssetClass.crypto, label: Text('Crypto')),
                  ButtonSegment(value: AssetClass.metal, label: Text('Metal')),
                ],
                selected: {_selectedClass},
                onSelectionChanged: (Set<AssetClass> newSelection) {
                  setState(() {
                    _selectedClass = newSelection.first;
                    _selectedSymbol = null;
                  });
                },
              ),
              const SizedBox(height: 24),

              if (availableSymbols.isNotEmpty)
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
                        final items = { for (var e in availableSymbols) e : _getSymbolName(e) };
                        return _SearchModal(
                          title: 'Select Asset',
                          items: items,
                          onSelected: (val) {
                            setState(() => _selectedSymbol = val);
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Select Asset',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedSymbol != null ? '${_selectedSymbol!.toUpperCase()} - ${_getSymbolName(_selectedSymbol!)}' : 'Select Asset',
                            style: AppTypography.bodyMd.copyWith(color: context.ink),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: context.inkMute),
                      ],
                    ),
                  ),
                )
              else
                Center(child: CircularProgressIndicator(color: context.primary)),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: AppTypography.bodyMd.copyWith(color: context.ink),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  if (_selectedClass == AssetClass.metal) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _metalUnit,
                            isExpanded: true,
                            isDense: true,
                            items: [
                              DropdownMenuItem(value: 'g', child: Text('Grams', style: AppTypography.bodyMd.copyWith(color: context.ink))),
                              DropdownMenuItem(value: 'oz', child: Text('Ounces', style: AppTypography.bodyMd.copyWith(color: context.ink))),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _metalUnit = val);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _purchaseAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: AppTypography.bodyMd.copyWith(color: context.ink),
                      decoration: const InputDecoration(
                        labelText: 'Purchase Amount (Total)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: InkWell(
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
                              items: _allSymbols,
                              onSelected: (val) {
                                setState(() => _selectedPurchaseCurrency = val);
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedPurchaseCurrency.toUpperCase(),
                              style: AppTypography.bodyMd.copyWith(color: context.ink)
                            ),
                            Icon(Icons.arrow_drop_down, color: context.inkMute),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _actionDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _actionDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: _selectedClass == AssetClass.metal ? 'Purchase Date' : 'Income Date',
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(DateFormat.yMMMd().format(_actionDate), style: AppTypography.bodyMd.copyWith(color: context.ink)),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: AppTypography.bodyMd.copyWith(color: context.ink),
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              ButtonPrimary(
                onPressed: () async {
                  final amount = double.tryParse(_amountController.text) ?? 0.0;
                  if (amount <= 0 || _selectedSymbol == null) return;
                  
                  final purchaseAmount = double.tryParse(_purchaseAmountController.text) ?? 0.0;

                  final newItem = SavingItem(
                    id: widget.existingItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    assetClass: _selectedClass,
                    symbol: _selectedSymbol!,
                    amount: amount,
                    unit: _selectedClass == AssetClass.metal ? _metalUnit : null,
                    createdAt: widget.existingItem?.createdAt ?? DateTime.now(),
                    actionDate: _actionDate,
                    purchaseAmount: purchaseAmount,
                    purchaseCurrency: _selectedPurchaseCurrency,
                    notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
                  );
                  await SavingsService.addSaving(newItem);
                  if (!context.mounted) return;
                  Navigator.pop(context, newItem);
                },
                label: widget.existingItem != null ? 'Update Asset' : 'Confirm',
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

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
