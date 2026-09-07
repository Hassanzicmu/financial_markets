import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:market_rates/widgets/design_system.dart';
import 'package:market_rates/theme.dart';

enum AssetType { fiat, crypto, metal }

class AssetItem {
  final String symbol;
  final String name;
  final AssetType type;
  double price;
  double change24h;

  AssetItem({
    required this.symbol,
    required this.name,
    required this.type,
    this.price = 0.0,
    this.change24h = 0.0,
  });
}

class ComparisonPage extends StatefulWidget {
  const ComparisonPage({super.key});

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  final List<AssetItem> _selectedAssets = [];
  bool _isLoading = false;
  final String _baseCurrencyLower = 'usd';
  Map<String, String> _allCurrencies = {};
  
  final List<AssetItem> _defaults = [
    AssetItem(symbol: 'eur', name: 'Euro', type: AssetType.fiat),
    AssetItem(symbol: 'btc', name: 'Bitcoin', type: AssetType.crypto),
    AssetItem(symbol: 'xau', name: 'Gold', type: AssetType.metal),
  ];

  @override
  void initState() {
    super.initState();
    _selectedAssets.addAll(_defaults);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final namesRes = await http.get(
        Uri.parse('https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json'),
        headers: {'User-Agent': 'FinancialMarketsApp/1.0'}
      );
      if (namesRes.statusCode == 200) {
        final decoded = json.decode(namesRes.body) as Map<String, dynamic>;
        _allCurrencies = decoded.map((k, v) => MapEntry(k.toLowerCase(), v.toString()));
      }
      await _refreshPrices();
    } catch (e) {
      debugPrint('Error fetching metadata: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshPrices() async {
    final fiats = _selectedAssets.where((a) => a.type == AssetType.fiat || a.type == AssetType.metal).toList();
    final cryptos = _selectedAssets.where((a) => a.type == AssetType.crypto).toList();

    if (fiats.isNotEmpty) {
      try {
        final res = await http.get(
          Uri.parse('https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/$_baseCurrencyLower.json'),
          headers: {'User-Agent': 'FinancialMarketsApp/1.0'}
        );
        if (res.statusCode == 200) {
          final rates = json.decode(res.body)[_baseCurrencyLower];
          for (var asset in fiats) {
            final rate = rates[asset.symbol];
            if (rate != null) {
              asset.price = 1 / (rate as num).toDouble();
            }
          }
        }
      } catch (e) {
        debugPrint('Fiat fetch error: $e');
      }
    }

    if (cryptos.isNotEmpty) {
      try {
        final symbols = cryptos.map((a) => a.symbol).join(',');
        final res = await http.get(
          Uri.parse('https://api.coingecko.com/api/v3/coins/markets?vs_currency=$_baseCurrencyLower&symbols=$symbols'),
          headers: {'Accept': 'application/json', 'User-Agent': 'FinancialMarketsApp/1.0'},
        );
        if (res.statusCode == 200) {
          final data = json.decode(res.body) as List;
          for (var crypto in cryptos) {
            final match = data.firstWhere((item) => item['symbol'] == crypto.symbol, orElse: () => null);
            if (match != null) {
              crypto.price = (match['current_price'] as num).toDouble();
              crypto.change24h = (match['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0;
            }
          }
        }
      } catch (e) {
        debugPrint('Crypto fetch error: $e');
      }
    }
    setState(() {});
  }

  void _addAsset(AssetItem asset) {
    if (!_selectedAssets.any((a) => a.symbol == asset.symbol)) {
      setState(() {
        _selectedAssets.add(asset);
      });
      _refreshPrices();
    }
  }

  void _removeAsset(int index) {
    setState(() {
      _selectedAssets.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TradingPlatformLayout(
      title: Text('Comparison', style: AppTypography.titleMd.copyWith(color: context.ink)),
      leading: const BackButton(),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: context.ink),
          onPressed: _refreshPrices,
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssetDialog,
        backgroundColor: context.primary,
        child: Icon(Icons.add, color: context.onPrimary),
      ),
      child: _isLoading && _selectedAssets.isEmpty
          ? Center(child: CircularProgressIndicator(color: context.primary))
          : Column(
              children: [
                _buildTopControls(),
                Expanded(child: _buildComparisonGrid()),
              ],
            ),
    );
  }

  Widget _buildTopControls() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      color: context.surfaceElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compare Side-by-Side',
            style: AppTypography.titleMd.copyWith(color: context.ink),
          ),
          const SizedBox(height: 4),
          Text(
            'Prices in ${_baseCurrencyLower.toUpperCase()}',
            style: AppTypography.bodySm.copyWith(color: context.inkMute),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonGrid() {
    if (_selectedAssets.isEmpty) {
      return Center(child: Text('Add assets to compare', style: AppTypography.bodyMd.copyWith(color: context.inkMute)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _selectedAssets.length,
      itemBuilder: (context, index) {
        final asset = _selectedAssets[index];
        final isPositive = asset.change24h >= 0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: context.surfaceCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.hairline),
          ),
          child: Row(
            children: [
              _buildAssetIcon(asset),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.symbol.toUpperCase(),
                      style: AppTypography.titleSm.copyWith(color: context.ink),
                    ),
                    Text(
                      asset.name,
                      style: AppTypography.caption.copyWith(color: context.inkMute),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatPrice(asset.price),
                    style: AppTypography.numberMd.copyWith(color: context.ink),
                  ),
                  if (asset.type == AssetType.crypto)
                    Text(
                      '${isPositive ? "+" : ""}${asset.change24h.toStringAsFixed(2)}%',
                      style: AppTypography.caption.copyWith(
                        color: isPositive ? BinanceColors.tradingUp : BinanceColors.tradingDown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.close, size: 20, color: context.inkMute),
                onPressed: () => _removeAsset(index),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssetIcon(AssetItem asset) {
    IconData icon;
    if (asset.type == AssetType.metal) {
      icon = asset.symbol == 'xau' ? Icons.brightness_high : Icons.brightness_low;
    } else if (asset.type == AssetType.crypto) {
      icon = Icons.currency_bitcoin;
    } else {
      icon = Icons.account_balance;
    }
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon, color: context.primary, size: 16),
      ),
    );
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat("#,##0.00####", "en_US");
    if (price == 0) return "---";
    if (price < 0.0001) return price.toStringAsExponential(2);
    return formatter.format(price);
  }

  void _showAddAssetDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  labelColor: context.primary,
                  unselectedLabelColor: context.inkMute,
                  indicatorColor: context.primary,
                  tabs: const [
                    Tab(text: 'Fiat'),
                    Tab(text: 'Crypto'),
                    Tab(text: 'Metals'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildAssetList(AssetType.fiat),
                      _buildAssetList(AssetType.crypto),
                      _buildAssetList(AssetType.metal),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssetList(AssetType type) {
    List<AssetItem> items = [];
    if (type == AssetType.fiat) {
      _allCurrencies.forEach((sym, name) {
        if (!['xau', 'xag', 'xpt', 'xpd'].contains(sym)) {
          items.add(AssetItem(symbol: sym, name: name, type: AssetType.fiat));
        }
      });
    } else if (type == AssetType.metal) {
      items = [
        AssetItem(symbol: 'xau', name: 'Gold', type: AssetType.metal),
        AssetItem(symbol: 'xag', name: 'Silver', type: AssetType.metal),
        AssetItem(symbol: 'xpt', name: 'Platinum', type: AssetType.metal),
        AssetItem(symbol: 'xpd', name: 'Palladium', type: AssetType.metal),
      ];
    } else {
      final popular = ['btc', 'eth', 'usdt', 'bnb', 'sol', 'xrp', 'ada', 'doge', 'trx', 'dot'];
      items = popular.map((s) => AssetItem(symbol: s, name: s.toUpperCase(), type: AssetType.crypto)).toList();
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.name, style: AppTypography.bodyMd.copyWith(color: context.ink)),
          subtitle: Text(item.symbol.toUpperCase(), style: AppTypography.caption.copyWith(color: context.inkMute)),
          onTap: () {
            _addAsset(item);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
