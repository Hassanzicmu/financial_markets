import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:market_rates/widgets/design_system.dart';
import 'package:market_rates/theme.dart';
import 'crypto_details_page.dart';

class CryptocurrenciesPage extends StatefulWidget {
  const CryptocurrenciesPage({super.key});

  @override
  State<CryptocurrenciesPage> createState() => _CryptocurrenciesPageState();
}

class _CryptocurrenciesPageState extends State<CryptocurrenciesPage> {
  String _baseCurrencyLower = 'usd';
  Map<String, String> _fiatCurrencies = {};
  double _conversionRateToSelected = 1.0;
  List<dynamic> _cryptoAssets = [];
  Set<String> _favorites = {};
  bool _isLoading = true;
  String _errorMessage = '';

  // Table state
  bool _isAscending = false;
  final TextEditingController _searchController = TextEditingController();
  String _tableSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _tableSearchQuery = _searchController.text.toLowerCase();
      });
    });
    _loadFavorites();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('favorite_cryptos')?.toSet() ?? {};
    });
  }



  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final fiatResponse = await http.get(
        Uri.parse('https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json'),
        headers: {'User-Agent': 'FinancialMarketsApp/1.0'},
      ).timeout(const Duration(seconds: 15));

      if (fiatResponse.statusCode == 200) {
        final decoded = json.decode(fiatResponse.body) as Map<String, dynamic>;
        _fiatCurrencies = decoded.map((k, v) => MapEntry(k.toLowerCase(), v.toString()));
      }

      final cryptoResponse = await http.get(
        Uri.parse('https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false'),
        headers: {'User-Agent': 'FinancialMarketsApp/1.0', 'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (cryptoResponse.statusCode == 200) {
        _cryptoAssets = json.decode(cryptoResponse.body);
      } else {
        throw Exception('Failed to load crypto assets (Status: ${cryptoResponse.statusCode})');
      }

      await _updateConversionRate(_baseCurrencyLower);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateConversionRate(String baseLower) async {
    if (baseLower == 'usd') {
      setState(() {
        _conversionRateToSelected = 1.0;
        _isLoading = false;
      });
      return;
    }

    try {
      final rateResponse = await http.get(
        Uri.parse('https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json'),
        headers: {'User-Agent': 'FinancialMarketsApp/1.0'},
      ).timeout(const Duration(seconds: 10));
      if (rateResponse.statusCode == 200) {
        final rates = json.decode(rateResponse.body)['usd'];
        setState(() {
          _conversionRateToSelected = (rates[baseLower] as num).toDouble();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Rate conversion failed: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onBaseCurrencyChanged(String newBaseLower) {
    setState(() {
       _baseCurrencyLower = newBaseLower;
       _isLoading = true;
    });
    _updateConversionRate(newBaseLower);
  }

  void _showSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return _FiatSearchModal(
          currencies: _fiatCurrencies,
          onSelected: (code) {
            _onBaseCurrencyChanged(code);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TradingPlatformLayout(
      title: Text('Cryptocurrencies', style: AppTypography.titleMd.copyWith(color: context.ink)),
      leading: const BackButton(),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _cryptoAssets.isEmpty) {
      return Center(child: CircularProgressIndicator(color: context.primary));
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: BinanceColors.tradingDown, size: 60),
            const SizedBox(height: 16),
            Text('Error: $_errorMessage', style: AppTypography.bodyMd.copyWith(color: context.ink)),
            const SizedBox(height: 16),
            ButtonSecondary(label: 'Retry', onPressed: _fetchInitialData),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildHeader(),
        _buildTableControls(),
        if (_isLoading)
          Padding(padding: const EdgeInsets.all(20), child: CircularProgressIndicator(color: context.primary))
        else
          Expanded(child: _buildCryptoTable()),
      ],
    );
  }

  Widget _buildHeader() {
    final baseName = _fiatCurrencies[_baseCurrencyLower] ?? 'US Dollar';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      color: context.surfaceElevated,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Display Prices In:',
            style: AppTypography.bodyMd.copyWith(color: context.inkMute),
          ),
          InkWell(
            onTap: _showSearchModal,
            child: Row(
              children: [
                Text(
                  '${_baseCurrencyLower.toUpperCase()} ($baseName)',
                  style: AppTypography.navLink.copyWith(color: context.primary),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, color: context.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextInputField(
              controller: _searchController,
              hintText: 'Search asset...',
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: context.surfaceCard,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: context.hairline),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                _isAscending ? Icons.south : Icons.north,
                color: context.ink,
                size: 20,
              ),
              tooltip: _isAscending ? 'Low to High' : 'High to Low',
              onPressed: () => setState(() => _isAscending = !_isAscending),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoTable() {
    final filtered = _cryptoAssets.where((asset) {
      final name = asset['name'].toString().toLowerCase();
      final symbol = asset['symbol'].toString().toLowerCase();
      return name.contains(_tableSearchQuery) || symbol.contains(_tableSearchQuery);
    }).toList();

    filtered.sort((a, b) {
      final idA = a['id'].toString();
      final idB = b['id'].toString();
      final isAFav = _favorites.contains(idA);
      final isBFav = _favorites.contains(idB);

      if (isAFav && !isBFav) return -1;
      if (!isAFav && isBFav) return 1;

      final priceA = (a['current_price'] as num).toDouble();
      final priceB = (b['current_price'] as num).toDouble();
      return _isAscending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });

    return Column(
      children: [
        MarketsTableHeader(
          isAscending: _isAscending,
          onSortPrice: () => setState(() => _isAscending = !_isAscending),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final asset = filtered[index];
              final symbol = asset['symbol'].toString();
              final name = asset['name'];
              final priceUsd = (asset['current_price'] as num).toDouble();
              final localPrice = priceUsd * _conversionRateToSelected;
              final change = (asset['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0;
              final iconUrl = asset['image'];
              final isPositive = change >= 0;
              
              return MarketsRow(
                icon: Image.network(
                  iconUrl,
                  errorBuilder: (c, e, s) => const Icon(Icons.currency_bitcoin),
                ),
                symbol: symbol.toUpperCase(),
                name: name,
                price: _formatPrice(localPrice),
                change: '${isPositive ? "+" : ""}${change.toStringAsFixed(2)}%',
                isUp: isPositive,
                isFavorite: _favorites.contains(symbol.toLowerCase()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CryptoDetailsPage(asset: asset, conversionRate: _conversionRateToSelected, baseCurrency: _baseCurrencyLower),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price == 0) return "0.00";
    final formatter = NumberFormat("#,##0.00####", "en_US");
    if (price < 0.0001) return price.toStringAsExponential(2);
    return formatter.format(price);
  }
}

class _FiatSearchModal extends StatefulWidget {
  final Map<String, String> currencies;
  final Function(String) onSelected;

  const _FiatSearchModal({required this.currencies, required this.onSelected});

  @override
  State<_FiatSearchModal> createState() => _FiatSearchModalState();
}

class _FiatSearchModalState extends State<_FiatSearchModal> {
  late List<String> _filtered;
  final TextEditingController _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.currencies.keys.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextInputField(
            controller: _ctrl,
            hintText: 'Search currency...',
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (c, i) {
                final code = _filtered[i];
                return ListTile(
                  title: Text('${code.toUpperCase()} - ${widget.currencies[code]}', style: AppTypography.bodyMd.copyWith(color: context.ink)),
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
