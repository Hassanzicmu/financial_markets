import 'package:flutter/material.dart';
import 'package:financial_markets/widgets/design_system.dart';
import '../theme.dart';
import 'package:financial_markets/theme.dart';
import 'package:financial_markets/l10n/app_localizations.dart';
import 'package:financial_markets/pages/currency_details_page.dart';
import '../main.dart'; // for countryNotifier
import '../models/bank_rate.dart';
import '../services/bank_rates_service.dart';

class BankRatesPage extends StatefulWidget {
  const BankRatesPage({super.key});

  @override
  State<BankRatesPage> createState() => _BankRatesPageState();
}

class _BankRatesPageState extends State<BankRatesPage> {
  final BankRatesService _service = BankRatesService();
  late Future<List<BankRate>> _ratesFuture;

  @override
  void initState() {
    super.initState();
    // Default fetch for current country
    _ratesFuture = _service.fetchBankRates(countryNotifier.country);
    
    // Add listener to refresh if country changes while page is open
    countryNotifier.addListener(_onCountryChanged);
  }

  @override
  void dispose() {
    countryNotifier.removeListener(_onCountryChanged);
    super.dispose();
  }

  void _onCountryChanged() {
    setState(() {
      _ratesFuture = _service.fetchBankRates(countryNotifier.country);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListenableBuilder(
      listenable: countryNotifier,
      builder: (context, _) {
        final country = countryNotifier.country;

        return TradingPlatformLayout(
          title: Text(l10n.bankRates, style: AppTypography.titleMd.copyWith(color: context.ink)),
          leading: const BackButton(),
          child: _buildBody(context, country, l10n),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, String country, AppLocalizations l10n) {
    if (country == 'eg') {
      return FutureBuilder<List<BankRate>>(
        future: _ratesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: context.tradingDown),
                    const SizedBox(height: 16),
                    Text(
                      "Error fetching rates",
                      style: AppTypography.titleMd.copyWith(color: context.ink),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMd.copyWith(color: context.inkMute),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _ratesFuture = _service.fetchBankRates(countryNotifier.country);
                        });
                      },
                      child: const Text('Retry'),
                    )
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No bank rates available.",
                style: AppTypography.bodyMd.copyWith(color: context.inkMute),
              ),
            );
          }

          final rates = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            children: [
              Text(
                "Egyptian Banks (EGP / USD)",
                style: AppTypography.titleLg.copyWith(color: context.ink),
              ),
              const SizedBox(height: 8),
              Text(
                "Live exchange rates for major local banks in Egypt.",
                style: AppTypography.bodyMd.copyWith(color: context.inkMute),
              ),
              const SizedBox(height: 24),
              MarketsTableCard(
                child: Column(
                  children: rates.map((rate) => _buildBankRow(context, rate)).toList(),
                ),
              ),
              const SizedBox(height: 32),
              const AstraTechFooter(),
            ],
          );
        },
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: context.inkMute),
            const SizedBox(height: 16),
            Text(
              "No local banks available",
              style: AppTypography.titleMd.copyWith(color: context.ink),
            ),
            const SizedBox(height: 8),
            Text(
              "We currently do not have bank rates for this country.",
              style: AppTypography.bodyMd.copyWith(color: context.inkMute),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBankRow(BuildContext context, BankRate rate) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => CurrencyDetailsPage(
          title: rate.name,
          subtitle: "EGP / USD",
          currentPrice: rate.buy, // Buy price
          priceChange: "+0.02%",  // Placeholder for bank rate change
          isUp: rate.isUp,
        )));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.account_balance, color: context.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rate.name,
                    style: AppTypography.bodyMd.copyWith(color: context.ink, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "EGP / USD",
                    style: AppTypography.bodySm.copyWith(color: context.inkMute),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rate.buy,
                  style: AppTypography.numberMd.copyWith(color: rate.isUp ? context.tradingUp : context.tradingDown),
                ),
                Text(
                  "Buy",
                  style: AppTypography.bodySm.copyWith(color: context.inkMute),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rate.sell,
                  style: AppTypography.numberMd.copyWith(color: rate.isUp ? context.tradingUp : context.tradingDown),
                ),
                Text(
                  "Sell",
                  style: AppTypography.bodySm.copyWith(color: context.inkMute),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
