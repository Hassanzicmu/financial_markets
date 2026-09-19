import 'package:flutter/material.dart';
import 'package:financial_markets/widgets/design_system.dart';
import 'package:financial_markets/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, String>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final currencies = prefs.getStringList('favorite_currencies') ?? [];
    final cryptos = prefs.getStringList('favorite_cryptos') ?? [];

    setState(() {
      _favorites = [
        ...currencies.map((c) => {'code': c, 'type': 'Currency'}),
        ...cryptos.map((c) => {'code': c, 'type': 'Crypto'}),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TradingPlatformLayout(
      title: Text('Favorites', style: AppTypography.titleMd.copyWith(color: context.ink)),
      leading: const BackButton(),
      child: _isLoading
          ? Center(child: CircularProgressIndicator(color: context.primary))
          : _favorites.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(child: _buildFavoritesList()),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border, size: 64, color: context.inkMute),
          const SizedBox(height: 16),
          Text(
            'No favorites yet.',
            style: AppTypography.titleMd.copyWith(color: context.ink),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Star your top currencies and cryptos to track them here.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd.copyWith(color: context.inkMute),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final item = _favorites[index];
        final code = item['code']!.toUpperCase();
        final type = item['type']!;
        final isCrypto = type == 'Crypto';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: context.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.hairline),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCrypto ? Icons.currency_bitcoin : Icons.payments,
                color: context.primary,
              ),
            ),
            title: Text(code, style: AppTypography.titleSm.copyWith(color: context.ink)),
            subtitle: Text(type, style: AppTypography.bodySm.copyWith(color: context.inkMute)),
            trailing: const Icon(Icons.star, color: BinanceColors.tradingUp),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Details for $code coming soon!')),
              );
            },
          ),
        );
      },
    );
  }
}
