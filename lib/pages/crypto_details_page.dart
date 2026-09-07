import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:market_rates/widgets/design_system.dart';
import 'package:market_rates/theme.dart';

class CryptoDetailsPage extends StatefulWidget {
  final Map<String, dynamic> asset;
  final double conversionRate;
  final String baseCurrency;

  const CryptoDetailsPage({
    super.key,
    required this.asset,
    required this.conversionRate,
    required this.baseCurrency,
  });

  @override
  State<CryptoDetailsPage> createState() => _CryptoDetailsPageState();
}

class _CryptoDetailsPageState extends State<CryptoDetailsPage> {
  List<FlSpot> _chartData = [];
  bool _isLoadingChart = true;
  String _chartError = '';
  String _selectedTimeframe = '1';

  @override
  void initState() {
    super.initState();
    _fetchChartData();
  }

  Future<void> _fetchChartData() async {
    setState(() {
      _isLoadingChart = true;
      _chartError = '';
    });

    final id = widget.asset['id'];
    final url = 'https://api.coingecko.com/api/v3/coins/$id/market_chart?vs_currency=usd&days=$_selectedTimeframe';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'FinancialMarketsApp/1.0', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> prices = data['prices'];
        
        setState(() {
          _chartData = prices.map((p) {
            return FlSpot(
              (p[0] as num).toDouble(),
              (p[1] as num).toDouble() * widget.conversionRate,
            );
          }).toList();
          _isLoadingChart = false;
        });
      } else {
        throw Exception('Failed to load chart (Status: ${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        _chartError = e.toString();
        _isLoadingChart = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final symbol = widget.asset['symbol'].toString().toUpperCase();
    final name = widget.asset['name'].toString();
    final price = (widget.asset['current_price'] as num).toDouble() * widget.conversionRate;
    final change = (widget.asset['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0;
    final isPositive = change >= 0;

    return TradingPlatformLayout(
      title: Text('$name ($symbol)', style: AppTypography.titleMd.copyWith(color: context.ink)),
      leading: const BackButton(),
      child: Column(
        children: [
          _buildPriceHeader(price, change, isPositive),
          _buildChartSection(),
          _buildTimeframeSelector(),
          Expanded(child: SingleChildScrollView(child: _buildAssetStats())),
        ],
      ),
    );
  }

  Widget _buildPriceHeader(double price, double change, bool isPositive) {
    final currencyFormat = NumberFormat.currency(symbol: '', decimalDigits: price < 1 ? 4 : 2);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(widget.asset['image'], width: 32, height: 32),
              const SizedBox(width: 12),
              Text(
                '${widget.baseCurrency.toUpperCase()} ${currencyFormat.format(price)}',
                style: AppTypography.numberDisplay.copyWith(color: context.ink),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isPositive ? BinanceColors.tradingUp.withValues(alpha: 0.1) : BinanceColors.tradingDown.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${isPositive ? "+" : ""}${change.toStringAsFixed(2)}% (24h)',
              style: AppTypography.caption.copyWith(
                color: isPositive ? BinanceColors.tradingUp : BinanceColors.tradingDown,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _isLoadingChart
          ? Center(child: CircularProgressIndicator(color: context.primary))
          : _chartError.isNotEmpty
              ? Center(child: Text(_chartError, style: TextStyle(color: BinanceColors.tradingDown)))
              : LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _chartData,
                        isCurved: true,
                        color: BinanceColors.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: BinanceColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _timeframeButton('1', '24h'),
          _timeframeButton('7', '7d'),
          _timeframeButton('30', '1m'),
          _timeframeButton('365', '1y'),
        ],
      ),
    );
  }

  Widget _timeframeButton(String value, String label) {
    bool isSelected = _selectedTimeframe == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ChoiceChip(
        label: Text(label, style: AppTypography.bodySm.copyWith(color: isSelected ? context.onPrimary : context.ink)),
        selected: isSelected,
        selectedColor: context.primary,
        backgroundColor: context.surfaceCard,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedTimeframe = value);
            _fetchChartData();
          }
        },
      ),
    );
  }

  Widget _buildAssetStats() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.hairline),
        ),
        child: Column(
          children: [
            _statRow('Market Cap Rank', '#${widget.asset['market_cap_rank']}'),
            Divider(color: context.hairline),
            _statRow('Market Cap', _formatCompact(widget.asset['market_cap'])),
            Divider(color: context.hairline),
            _statRow('Total Volume', _formatCompact(widget.asset['total_volume'])),
            Divider(color: context.hairline),
            _statRow('24h High', _formatPrice(widget.asset['high_24h'])),
            Divider(color: context.hairline),
            _statRow('24h Low', _formatPrice(widget.asset['low_24h'])),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMd.copyWith(color: context.inkMute)),
          Text(value, style: AppTypography.numberMd.copyWith(fontWeight: FontWeight.bold, color: context.ink)),
        ],
      ),
    );
  }

  String _formatCompact(dynamic value) {
    if (value == null) return '---';
    final numValue = (value as num).toDouble() * widget.conversionRate;
    return NumberFormat.compactCurrency(symbol: '${widget.baseCurrency.toUpperCase()} ').format(numValue);
  }

  String _formatPrice(dynamic value) {
    if (value == null) return '---';
    final price = (value as num).toDouble() * widget.conversionRate;
    final formatter = NumberFormat.currency(symbol: widget.baseCurrency.toUpperCase(), decimalDigits: price < 1 ? 4 : 2);
    return formatter.format(price);
  }
}
