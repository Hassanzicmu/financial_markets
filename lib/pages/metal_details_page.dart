import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:market_rates/widgets/design_system.dart';
import 'package:market_rates/theme.dart';

class MetalDetailsPage extends StatefulWidget {
  final String metalCode;
  final String metalName;
  final double currentPrice; // Price for 1 Troy Ounce
  final String baseCurrency;
  final Color color;
  final IconData icon;

  const MetalDetailsPage({
    super.key,
    required this.metalCode,
    required this.metalName,
    required this.currentPrice,
    required this.baseCurrency,
    required this.color,
    required this.icon,
  });

  @override
  State<MetalDetailsPage> createState() => _MetalDetailsPageState();
}

class _MetalDetailsPageState extends State<MetalDetailsPage> {
  List<FlSpot> _chartData = [];
  bool _isLoadingChart = true;
  String _chartError = '';
  String _selectedTimeframe = '7'; // Default to 7 days

  @override
  void initState() {
    super.initState();
    _fetchHistoricalData();
  }

  Future<void> _fetchHistoricalData() async {
    setState(() {
      _isLoadingChart = true;
      _chartError = '';
    });

    try {
      final List<FlSpot> spots = [];
      final int days = int.parse(_selectedTimeframe);
      final now = DateTime.now();

      for (int i = 0; i < 5; i++) {
        final date = now.subtract(Duration(days: (i * days ~/ 4)));
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        
        final url = 'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@$dateStr/v1/currencies/${widget.baseCurrency}.json';
        final response = await http.get(Uri.parse(url), headers: {'User-Agent': 'FinancialMarketsApp/1.0'});

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final rate = data[widget.baseCurrency][widget.metalCode.toLowerCase()];
          if (rate != null && rate is num && rate > 0) {
            final price = 1.0 / rate.toDouble();
            spots.add(FlSpot((4 - i).toDouble(), price));
          }
        }
      }

      setState(() {
        _chartData = spots.reversed.toList();
        _isLoadingChart = false;
      });
    } catch (e) {
      setState(() {
        _chartError = 'Failed to load historical data';
        _isLoadingChart = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TradingPlatformLayout(
      title: Text(widget.metalName, style: AppTypography.titleMd.copyWith(color: context.ink)),
      leading: const BackButton(),
      child: Column(
        children: [
          _buildHeader(),
          _buildChartSection(),
          _buildTimeframeSelector(),
          Expanded(child: SingleChildScrollView(
            child: Column(
              children: [
                _buildUnitConverter(),
                _buildTrendAnalysis(),
              ],
            )
          )),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        children: [
          Icon(widget.icon, color: widget.color, size: 48),
          const SizedBox(height: 16),
          Text(
            widget.metalName,
            style: AppTypography.titleLg.copyWith(color: context.ink),
          ),
          const SizedBox(height: 8),
          Text(
            '1 Troy Ounce = ${_formatPrice(widget.currentPrice, widget.baseCurrency)}',
            style: AppTypography.bodyMd.copyWith(color: context.inkMute),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitConverter() {
    final pricePerGram = widget.currentPrice / 31.1035;
    final pricePerKg = pricePerGram * 1000;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unit Conversions',
              style: AppTypography.titleSm.copyWith(color: context.ink),
            ),
            const SizedBox(height: 16),
            _buildUnitRow('1 Gram', pricePerGram),
            _buildUnitRow('1 Kilogram', pricePerKg),
            _buildUnitRow('1 Troy Ounce', widget.currentPrice),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitRow(String unit, double price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(unit, style: AppTypography.bodyMd.copyWith(color: context.inkMute)),
          Text(
            _formatPrice(price, widget.baseCurrency),
            style: AppTypography.numberMd.copyWith(fontWeight: FontWeight.bold, color: context.ink),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
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
                        color: widget.color,
                        barWidth: 4,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: widget.color.withValues(alpha: 0.1),
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
          _timeframeButton('7', '7d'),
          _timeframeButton('30', '1m'),
          _timeframeButton('90', '3m'),
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
            _fetchHistoricalData();
          }
        },
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Trend Analysis',
            style: AppTypography.titleSm.copyWith(color: context.ink),
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.metalName} prices are analyzed relative to the ${widget.baseCurrency.toUpperCase()}. The chart above shows the price movement per Troy Ounce over your selected timeframe.',
            style: AppTypography.bodyMd.copyWith(color: context.inkMute, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.info_outline, color: widget.color, size: 20),
              const SizedBox(width: 8),
              Text('Data refreshed with current financial markets rates.', style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic, color: context.inkMute)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price, String currency) {
    final formatter = NumberFormat("#,##0.00", "en_US");
    return '${currency.toUpperCase()} ${formatter.format(price)}';
  }
}
