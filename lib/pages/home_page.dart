import 'package:flutter/material.dart';
import 'package:market_rates/l10n/app_localizations.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:market_rates/widgets/design_system.dart';
import 'package:market_rates/theme.dart';

import 'global_currencies_page.dart';
import 'cryptocurrencies_page.dart';
import 'precious_metals_page.dart';
import 'my_savings_page.dart';
import 'calculator_page.dart';
import 'about_page.dart';
import 'copyright_page.dart';
import 'faq_page.dart';
import 'support_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> _snapshot = {};
  bool _isLoadingSnapshot = true;

  @override
  void initState() {
    super.initState();
    _fetchSnapshot();
  }

  Future<void> _fetchSnapshot() async {
    setState(() => _isLoadingSnapshot = true);
    try {
      final res = await http.get(Uri.parse('https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body)['usd'];
        if (mounted) {
          setState(() {
            _snapshot = data;
            _isLoadingSnapshot = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSnapshot = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return TradingPlatformLayout(
      title: Row(
        children: [
          Icon(Icons.trending_up, color: context.primary),
          const SizedBox(width: 8),
          Text(
            l10n.marketRates,
            style: AppTypography.titleLg.copyWith(color: context.ink),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.calculate, color: context.ink),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CalculatorPage()));
          },
        ),
      ],
      drawer: Drawer(
        backgroundColor: context.surfaceCard,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: context.surfaceCard,
                border: Border(bottom: BorderSide(color: context.hairline)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.trending_up, color: context.primary, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    l10n.marketRates,
                    style: AppTypography.titleLg.copyWith(color: context.ink),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, l10n.home, () => Navigator.pop(context)),
            _buildDrawerItem(Icons.info, l10n.aboutApp, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
            }),
            _buildDrawerItem(Icons.copyright, l10n.copyright, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CopyrightPage()));
            }),
            Divider(color: context.hairline),
            _buildDrawerItem(Icons.settings, l10n.settings, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
            }),
            _buildDrawerItem(Icons.question_answer, l10n.faq, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FAQPage()));
            }),
            _buildDrawerItem(Icons.help, l10n.support, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportPage()));
            }),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 24, bottom: 64, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Funds Are Safu style hero band
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                color: context.canvas,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "REAL-TIME MARKETS",
                    style: AppTypography.displayLg.copyWith(color: context.primary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      StatCalloutCard(
                        value: _isLoadingSnapshot || _snapshot['btc'] == null ? '...' : '\$${(1 / _snapshot['btc']).toStringAsFixed(0)}',
                        label: 'BTC/USD',
                      ),
                      StatCalloutCard(
                        value: _isLoadingSnapshot || _snapshot['eur'] == null ? '...' : '\$${(1 / _snapshot['eur']).toStringAsFixed(4)}',
                        label: 'EUR/USD',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text("Markets Overview", style: AppTypography.titleLg.copyWith(color: context.ink)),
            const SizedBox(height: 16),
            
            MarketsTableCard(
              child: Column(
                children: [
                  MarketsRow(
                    icon: Icon(Icons.public, color: context.primary),
                    symbol: "Global",
                    name: "Fiat Currencies",
                    price: "150+",
                    change: "Pairs",
                    isUp: true,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GlobalCurrenciesPage())),
                  ),
                  MarketsRow(
                    icon: Icon(Icons.currency_bitcoin, color: context.primary),
                    symbol: "Crypto",
                    name: "Digital Assets",
                    price: "10K+",
                    change: "Coins",
                    isUp: true,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CryptocurrenciesPage())),
                  ),
                  MarketsRow(
                    icon: Icon(Icons.diamond_outlined, color: context.primary),
                    symbol: "Metals",
                    name: "Commodities",
                    price: "XAU, XAG",
                    change: "Live",
                    isUp: true,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PreciousMetalsPage())),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            MarketsTableCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Savings Portfolio', style: AppTypography.titleMd.copyWith(color: context.ink)),
                  const SizedBox(height: 8),
                  Text('Track your personal assets securely.', style: AppTypography.bodyMd.copyWith(color: context.inkMute)),
                  const SizedBox(height: 24),
                  ButtonPrimary(
                    label: "View Portfolio",
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MySavingsPage()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: context.inkMute),
      title: Text(title, style: AppTypography.navLink.copyWith(color: context.ink)),
      onTap: onTap,
    );
  }
}
