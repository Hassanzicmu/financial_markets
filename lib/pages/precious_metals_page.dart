import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:financial_markets/widgets/design_system.dart';
import 'package:financial_markets/theme.dart';
import 'metal_details_page.dart';

class PreciousMetalsPage extends StatefulWidget {
  const PreciousMetalsPage({super.key});

  @override
  State<PreciousMetalsPage> createState() => _PreciousMetalsPageState();
}

class _PreciousMetalsPageState extends State<PreciousMetalsPage> {
  String _baseCurrencyLower = 'usd';
  Map<String, String> _allCurrencies = {};
  Map<String, dynamic> _rates = {};
  bool _isLoading = true;
  String _errorMessage = '';

  bool _isAscending = false;
  final TextEditingController _searchController = TextEditingController();
  String _tableSearchQuery = '';

  final List<Map<String, dynamic>> _metalAssets = [
    {'symbol': 'xau', 'name': 'Gold', 'icon': Icons.brightness_high},
    {'symbol': 'xag', 'name': 'Silver', 'icon': Icons.brightness_low},
    {'symbol': 'xpt', 'name': 'Platinum', 'icon': Icons.auto_awesome},
    {'symbol': 'xpd', 'name': 'Palladium', 'icon': Icons.diamond},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _tableSearchQuery = _searchController.text.toLowerCase();
      });
    });
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final namesResponse = await http.get(
        Uri.parse('https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json'),
        headers: {'User-Agent': 'FinancialMarketsApp/1.0'}
      );

      if (namesResponse.statusCode == 200) {
        final decoded = json.decode(namesResponse.body) as Map<String, dynamic>;
        _allCurrencies = decoded.map((k, v) => MapEntry(k.toLowerCase(), v.toString()));
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

      if (ratesResponse.statusCode == 200) {
        final decodedData = json.decode(ratesResponse.body);
        setState(() {
          _rates = decodedData[baseLower] as Map<String, dynamic>;
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
    setState(() {
      _baseCurrencyLower = newBaseLower;
      _isLoading = true;
    });
    _fetchRates(newBaseLower);
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
        return _BaseCurrencySearchModal(
          currencies: _allCurrencies,
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
      title: Text('Precious Metals', style: AppTypography.titleMd.copyWith(color: context.ink)),
      leading: const BackButton(),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _allCurrencies.isEmpty) {
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
          Expanded(child: _buildMetalTable()),
      ],
    );
  }

  Widget _buildHeader() {
    final baseName = _allCurrencies[_baseCurrencyLower] ?? 'US Dollar';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      color: context.surfaceElevated,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Metal Prices In:',
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Price per Troy Ounce', style: AppTypography.bodySm.copyWith(color: context.inkMute)),
          Expanded(
            child: TextInputField(
              controller: _searchController,
              hintText: 'Search metal...',
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
              icon: Icon(_isAscending ? Icons.south : Icons.north, color: context.ink, size: 20),
              onPressed: () => setState(() => _isAscending = !_isAscending),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetalTable() {
    final List<Map<String, dynamic>> displayItems = _metalAssets.map((metal) {
      final symbol = metal['symbol'] as String;
      final rateValue = _rates[symbol];
      double localizedPrice = 0.0;
      if (rateValue != null && rateValue is num && rateValue > 0) {
        localizedPrice = 1.0 / rateValue.toDouble();
      }
      return {
        ...metal,
        'price': localizedPrice,
      };
    }).toList();

    displayItems.sort((a, b) {
      final priceA = a['price'] as double;
      final priceB = b['price'] as double;
      return _isAscending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });

    final filteredItems = displayItems.where((metal) {
      final name = metal['name'].toString().toLowerCase();
      final symbol = metal['symbol'].toString().toLowerCase();
      return name.contains(_tableSearchQuery) || symbol.contains(_tableSearchQuery);
    }).toList();

    return Column(
      children: [
        MarketsTableHeader(
          isAscending: _isAscending,
          onSortPrice: () => setState(() => _isAscending = !_isAscending),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredItems.length + 1,
            itemBuilder: (context, index) {
              if (index == filteredItems.length) {
                return const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: AstraTechFooter(),
                );
              }
              final item = filteredItems[index];
              final price = item['price'] as double;

              return MarketsRow(
                icon: Container(
                  color: context.primary.withValues(alpha: 0.1),
                  child: Icon(item['icon'] as IconData, color: context.primary, size: 20),
                ),
                symbol: (item['symbol'] as String).toUpperCase(),
                name: item['name'],
                price: price == 0 ? '--' : _formatPrice(price),
                change: _baseCurrencyLower.toUpperCase(), // repurpose change for base currency
                isUp: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MetalDetailsPage(
                        metalCode: item['symbol'],
                        metalName: item['name'],
                        currentPrice: price,
                        baseCurrency: _baseCurrencyLower,
                        color: context.primary,
                        icon: item['icon'],
                      ),
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

class _BaseCurrencySearchModal extends StatefulWidget {
  final Map<String, String> currencies;
  final Function(String) onSelected;

  const _BaseCurrencySearchModal({required this.currencies, required this.onSelected});

  @override
  State<_BaseCurrencySearchModal> createState() => _BaseCurrencySearchModalState();
}

class _BaseCurrencySearchModalState extends State<_BaseCurrencySearchModal> {
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
      height: MediaQuery.of(context).size.height * 0.75,
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
