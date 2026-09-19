import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:financial_markets/widgets/design_system.dart';
import 'package:financial_markets/theme.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController _amountController = TextEditingController(text: '1');
  String _fromCurrency = 'usd';
  String _toCurrency = 'eur';
  Map<String, String> _currencies = {};
  double _rate = 0.0;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    try {
      final response = await http.get(
        Uri.parse('https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json'),
        headers: {'User-Agent': 'FinancialMarketsApp/1.0'}
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _currencies = decoded.map(
              (key, value) => MapEntry(key.toLowerCase(), value.toString()),
            );
          });
          await _fetchRate();
        }
      } else {
        throw Exception('Failed to load currencies');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchRate() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await http.get(
        Uri.parse('https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/$_fromCurrency.json'),
        headers: {'User-Agent': 'FinancialMarketsApp/1.0'}
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final rateNum = decoded[_fromCurrency][_toCurrency];
        final rate = (rateNum is num) ? rateNum.toDouble() : 0.0;
        if (mounted) {
          setState(() {
            _rate = rate;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load rate');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _fetchRate();
  }

  @override
  Widget build(BuildContext context) {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    double result = amount * _rate;

    return TradingPlatformLayout(
      title: Text('Calculator', style: AppTypography.titleMd.copyWith(color: context.ink)),
      leading: const BackButton(),
      child: _isLoading && _currencies.isEmpty
          ? Center(child: CircularProgressIndicator(color: context.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(_errorMessage, style: TextStyle(color: BinanceColors.tradingDown)),
                    ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextInputField(
                          controller: _amountController,
                          hintText: 'Amount',
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: _buildCurrencyDropdown(true)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: IconButton(
                                icon: Icon(Icons.swap_horiz, size: 28, color: context.primary),
                                onPressed: _swapCurrencies,
                              ),
                            ),
                            Expanded(child: _buildCurrencyDropdown(false)),
                          ],
                        ),
                        const SizedBox(height: 48),
                        if (_isLoading)
                          Center(child: CircularProgressIndicator(color: context.primary))
                        else
                          Column(
                            children: [
                              Text(
                                '${amount.toStringAsFixed(2)} ${_fromCurrency.toUpperCase()} =',
                                style: AppTypography.bodyMd.copyWith(color: context.inkMute),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${result.toStringAsFixed(4)} ${_toCurrency.toUpperCase()}',
                                style: AppTypography.numberDisplay.copyWith(color: context.ink),
                                textAlign: TextAlign.center,
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

  Widget _buildCurrencyDropdown(bool isFrom) {
    String currentValue = isFrom ? _fromCurrency : _toCurrency;
    
    final popular = ['usd', 'eur', 'gbp', 'jpy', 'aud', 'cad', 'chf', 'cny', 'btc', 'eth'];
    final items = popular.contains(currentValue) ? popular : [...popular, currentValue];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.canvas,
        border: Border.all(color: context.hairline),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          isDense: true,
          value: items.contains(currentValue) ? currentValue : null,
          dropdownColor: context.surfaceCard,
          items: items.toSet().map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value.toUpperCase(),
                style: AppTypography.bodyMd.copyWith(color: context.ink, fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                if (isFrom) {
                  _fromCurrency = newValue;
                } else {
                  _toCurrency = newValue;
                }
              });
              _fetchRate();
            }
          },
        ),
      ),
    );
  }
}
