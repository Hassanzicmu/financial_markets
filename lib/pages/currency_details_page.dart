import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:financial_markets/widgets/design_system.dart';
import 'package:financial_markets/theme.dart';

class CurrencyDetailsPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final String currentPrice;
  final String priceChange;
  final bool isUp;

  const CurrencyDetailsPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.currentPrice,
    required this.priceChange,
    required this.isUp,
  });

  @override
  State<CurrencyDetailsPage> createState() => _CurrencyDetailsPageState();
}

class _CurrencyDetailsPageState extends State<CurrencyDetailsPage> {
  String _selectedFilter = '1D';
  final List<String> _filters = ['1D', '1W', '1M', '1Y', 'ALL'];
  List<FlSpot> _chartData = [];
  double _minY = 0;
  double _maxY = 0;

  @override
  void initState() {
    super.initState();
    _generateChartData();
  }

  void _generateChartData() {
    final random = Random();
    final double basePrice = double.tryParse(widget.currentPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 1.0;
    
    // Generate 20 points
    List<FlSpot> spots = [];
    double currentVal = basePrice * 0.95; // start a bit lower
    
    double minVal = currentVal;
    double maxVal = currentVal;

    for (int i = 0; i < 20; i++) {
      // randomly move price up or down slightly
      double change = (random.nextDouble() - 0.45) * (basePrice * 0.02);
      if (widget.isUp) {
        change = (random.nextDouble() - 0.35) * (basePrice * 0.02); // bias upwards
      } else {
        change = (random.nextDouble() - 0.65) * (basePrice * 0.02); // bias downwards
      }
      
      currentVal += change;
      spots.add(FlSpot(i.toDouble(), currentVal));

      if (currentVal < minVal) minVal = currentVal;
      if (currentVal > maxVal) maxVal = currentVal;
    }

    // End exactly at current price
    spots[19] = FlSpot(19, basePrice);
    if (basePrice < minVal) minVal = basePrice;
    if (basePrice > maxVal) maxVal = basePrice;

    setState(() {
      _chartData = spots;
      _minY = minVal * 0.98;
      _maxY = maxVal * 1.02;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TradingPlatformLayout(
      title: Text(widget.title.toUpperCase(), style: AppTypography.titleMd.copyWith(color: context.ink)),
      leading: const BackButton(),
      actions: [
        IconButton(
          icon: Icon(Icons.star_border, color: context.ink),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Added ${widget.title} to favorites')),
            );
          },
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildFilters(context),
          const SizedBox(height: 24),
          _buildChart(context),
          const SizedBox(height: 32),
          _buildDetailsGrid(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.subtitle, style: AppTypography.bodyMd.copyWith(color: context.inkMute)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.currentPrice,
                  style: AppTypography.heroDisplay.copyWith(color: context.ink, fontSize: 40),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text(
                widget.priceChange,
                style: AppTypography.titleSm.copyWith(
                  color: widget.isUp ? context.tradingUp : context.tradingDown,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _filters.map((filter) {
        final isSelected = filter == _selectedFilter;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedFilter = filter;
              _generateChartData(); // Simulate fetching new data
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? context.surfaceElevated : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              filter,
              style: AppTypography.button.copyWith(
                color: isSelected ? context.ink : context.inkMute,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChart(BuildContext context) {
    final lineColor = widget.isUp ? context.tradingUp : context.tradingDown;

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 19,
          minY: _minY,
          maxY: _maxY,
          lineBarsData: [
            LineChartBarData(
              spots: _chartData,
              isCurved: true,
              color: lineColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    lineColor.withValues(alpha: 0.3),
                    lineColor.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsGrid(BuildContext context) {
    final basePrice = double.tryParse(widget.currentPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Market Stats", style: AppTypography.titleSm.copyWith(color: context.ink)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatItem(context, "24h High", (basePrice * 1.02).toStringAsFixed(2))),
            Expanded(child: _buildStatItem(context, "24h Low", (basePrice * 0.98).toStringAsFixed(2))),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildStatItem(context, "24h Vol", "1.2M")),
            Expanded(child: _buildStatItem(context, "Market Cap", "8.4B")),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySm.copyWith(color: context.inkMute)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.numberMd.copyWith(color: context.ink)),
      ],
    );
  }
}
