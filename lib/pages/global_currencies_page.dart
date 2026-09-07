import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:market_rates/widgets/design_system.dart';
import 'package:market_rates/theme.dart';

class GlobalCurrenciesPage extends StatefulWidget {
  const GlobalCurrenciesPage({super.key});

  @override
  State<GlobalCurrenciesPage> createState() => _GlobalCurrenciesPageState();
}

class _GlobalCurrenciesPageState extends State<GlobalCurrenciesPage> {
  String _baseCurrencyLower = 'usd';
  Map<String, String> _currencies = {};
  Map<String, dynamic> _rates = {};
  Map<String, dynamic> _yesterdayRates = {};
  Set<String> _favorites = {};
  bool _isLoading = true;
  String _errorMessage = '';

  bool _isAscending = false;
  final TextEditingController _searchController = TextEditingController();
  String _tableSearchQuery = '';
  bool _sortByPopular = false;

  static const Set<String> _popularCurrencies = {
    'usd', 'eur', 'gbp', 'jpy', 'aud', 'cad', 'chf', 'cny', 'inr', 'brl', 'zar', 'sar', 'aed'
  };

  static const Map<String, String> _currencyToCountry = {
    'usd': 'us', 'eur': 'eu', 'gbp': 'gb', 'jpy': 'jp', 'aud': 'au',
    'cad': 'ca', 'chf': 'ch', 'cny': 'cn', 'inr': 'in', 'rub': 'ru',
    'krw': 'kr', 'brl': 'br', 'zar': 'za', 'try': 'tr', 'nzd': 'nz',
    'mxn': 'mx', 'sgd': 'sg', 'hkd': 'hk', 'nok': 'no', 'sek': 'se',
    'dkk': 'dk', 'pln': 'pl', 'thb': 'th', 'idr': 'id', 'huf': 'hu',
    'czk': 'cz', 'ils': 'il', 'clp': 'cl', 'php': 'ph', 'aed': 'ae',
    'sar': 'sa', 'myr': 'my', 'twd': 'tw', 'btc': 'bt',
  };

  String _getCountryCode(String currencyCode) {
    final code = currencyCode.toLowerCase();
    if (_currencyToCountry.containsKey(code)) {
      return _currencyToCountry[code]!;
    }
    if (code.length >= 2) {
      return code.substring(0, 2);
    }
    return 'un';
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _tableSearchQuery = _searchController.text.toLowerCase();
      });
    });
    _loadFavorites();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('favorite_currencies')?.toSet() ?? {};
    });
  }

  Future<void> _toggleFavorite(String code) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(code)) {
        _favorites.remove(code);
      } else {
        _favorites.add(code);
      }
      prefs.setStringList('favorite_currencies', _favorites.toList());
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final currenciesResponse = await http.get(
        Uri.parse('https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json'),
        headers: {'User-Agent': 'FinancialMarketsApp/1.0'}
      );

      if (currenciesResponse.statusCode == 200) {
        final decodedCurrencies = json.decode(currenciesResponse.body) as Map<String, dynamic>;
        _currencies = decodedCurrencies.map(
          (key, value) => MapEntry(key.toLowerCase(), value.toString()),
        );
      } else {
        throw Exception('Failed to load world currencies');
      }

      await _fetchRates(_baseCurrencyLower);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRates(String baseLower) async {
    try {
      final ratesResponse = await http.get(
        Uri.parse('https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/$baseLower.json'),
        headers: {'User-Agent': 'FinancialMarketsApp/1.0'}
      );

      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dateStr = DateFormat('yyyy-MM-dd').format(yesterday);
      final yesterdayResponse = await http.get(
        Uri.parse('https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@$dateStr/v1/currencies/$baseLower.json'),
        headers: {'User-Agent': 'FinancialMarketsApp/1.0'}
      );

      if (ratesResponse.statusCode == 200) {
        final decodedData = json.decode(ratesResponse.body);
        final decodedYesterday = yesterdayResponse.statusCode == 200 
            ? json.decode(yesterdayResponse.body)[baseLower] as Map<String, dynamic>
            : <String, dynamic>{};
            
        setState(() {
          _rates = decodedData[baseLower] as Map<String, dynamic>;
          _yesterdayRates = decodedYesterday;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load rates for $baseLower');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onBaseCurrencyChanged(String newBaseLower) {
    if (newBaseLower != _baseCurrencyLower) {
      setState(() {
        _baseCurrencyLower = newBaseLower;
        _isLoading = true;
      });
      _fetchRates(newBaseLower);
    }
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
        return _CurrencySearchModal(
          currencies: _currencies,
          onSelected: (code) {
            _onBaseCurrencyChanged(code);
            Navigator.pop(context);
          },
          getCountryCode: _getCountryCode,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TradingPlatformLayout(
      title: Text('Fiat Currencies', style: AppTypography.titleMd.copyWith(color: context.ink)),
      leading: const BackButton(),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _currencies.isEmpty) {
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
            ButtonSecondary(label: 'Retry', onPressed: _fetchData),
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
          Expanded(child: _buildRatesTable()),
      ],
    );
  }

  Widget _buildHeader() {
    final baseName = _currencies[_baseCurrencyLower] ?? '';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      color: context.surfaceElevated,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Base World Currency:',
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
              hintText: 'Search currency...',
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: _sortByPopular ? context.primary.withValues(alpha: 0.1) : context.surfaceCard,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: context.hairline),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                _sortByPopular ? Icons.star : Icons.star_border,
                color: _sortByPopular ? context.primary : context.ink,
                size: 20,
              ),
              tooltip: 'Popular only',
              onPressed: () => setState(() => _sortByPopular = !_sortByPopular),
            ),
          ),
          const SizedBox(width: 8),
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

  Widget _buildRatesTable() {
    final filteredEntries = _rates.entries.where((entry) {
      final code = entry.key.toLowerCase();
      final name = (_currencies[entry.key] ?? '').toLowerCase();
      if (_sortByPopular && !_popularCurrencies.contains(code)) return false;
      return code.contains(_tableSearchQuery) || name.contains(_tableSearchQuery);
    }).toList();

    filteredEntries.sort((a, b) {
        final valA = (a.value is num) ? (a.value as num).toDouble() : 0.0;
        final valB = (b.value is num) ? (b.value as num).toDouble() : 0.0;
        final isAFav = _favorites.contains(a.key.toLowerCase());
        final isBFav = _favorites.contains(b.key.toLowerCase());

        if (isAFav && !isBFav) return -1;
        if (!isAFav && isBFav) return 1;

        return _isAscending ? valA.compareTo(valB) : valB.compareTo(valA);
    });

    return Column(
      children: [
        MarketsTableHeader(
          isAscending: _isAscending,
          onSortPrice: () => setState(() => _isAscending = !_isAscending),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredEntries.length,
            itemBuilder: (context, index) {
              final entry = filteredEntries[index];
              final codeLower = entry.key.toLowerCase();
              final code = entry.key.toUpperCase();
              final rawRate = (entry.value is num) ? (entry.value as num).toDouble() : 0.0;
              
              final formatter = NumberFormat("#,##0.00####", "en_US");
              String rateStr;
              if (rawRate < 0.0001 && rawRate > 0) {
                rateStr = rawRate.toStringAsExponential(2);
              } else {
                rateStr = formatter.format(rawRate);
              }

              final name = _currencies[entry.key] ?? 'Unknown';
              final countryCode = _getCountryCode(entry.key);
              double changePercent = 0.0;
              if (_yesterdayRates.containsKey(codeLower)) {
                final yesterdayRate = (_yesterdayRates[codeLower] is num) 
                    ? (_yesterdayRates[codeLower] as num).toDouble() 
                    : rawRate;
                if (yesterdayRate > 0) {
                  final currentValue = 1 / rawRate;
                  final yesterdayValue = 1 / yesterdayRate;
                  changePercent = ((currentValue - yesterdayValue) / yesterdayValue) * 100;
                }
              }
              final isPositive = changePercent >= 0;

              return MarketsRow(
                icon: Image.network(
                  'https://flagcdn.com/w40/$countryCode.png',
                  errorBuilder: (c, e, s) => const Icon(Icons.flag),
                ),
                symbol: code,
                name: name,
                price: rateStr,
                change: '${isPositive ? "+" : ""}${changePercent.toStringAsFixed(2)}%',
                isUp: isPositive,
                isFavorite: _favorites.contains(codeLower),
                onTap: () => _toggleFavorite(codeLower),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CurrencySearchModal extends StatefulWidget {
  final Map<String, String> currencies;
  final Function(String) onSelected;
  final String Function(String) getCountryCode;

  const _CurrencySearchModal({
    required this.currencies,
    required this.onSelected,
    required this.getCountryCode,
  });

  @override
  State<_CurrencySearchModal> createState() => _CurrencySearchModalState();
}

class _CurrencySearchModalState extends State<_CurrencySearchModal> {
  late List<String> _filteredCodes;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCodes = widget.currencies.keys.toList()..sort();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextInputField(
            controller: _searchController,
            hintText: 'Search currency or country...',
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCodes.length,
              itemBuilder: (context, index) {
                final code = _filteredCodes[index];
                final name = widget.currencies[code]!;
                final flag = widget.getCountryCode(code);

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      'https://flagcdn.com/w40/$flag.png',
                      width: 32,
                      errorBuilder: (ctx, err, stack) => const Icon(Icons.flag),
                    ),
                  ),
                  title: Text('${code.toUpperCase()} - $name', style: AppTypography.bodyMd.copyWith(color: context.ink)),
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
