import 'package:shared_preferences/shared_preferences.dart';
import '../models/saving_item.dart';

class SavingsService {
  static const String _key = 'user_savings_portfolio';

  static Future<List<SavingItem>> getSavings() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? data = prefs.getStringList(_key);
    if (data == null) return [];
    
    return data.map((jsonStr) => SavingItem.fromJson(jsonStr)).toList();
  }

  static Future<void> saveSavings(List<SavingItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> data = items.map((item) => item.toJson()).toList();
    await prefs.setStringList(_key, data);
  }

  static Future<void> addSaving(SavingItem item) async {
    final items = await getSavings();
    // Update if exists (based on ID)
    final index = items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      items[index] = item;
    } else {
      items.add(item);
    }
    await saveSavings(items);
  }

  static Future<void> removeSaving(String id) async {
    final items = await getSavings();
    items.removeWhere((item) => item.id == id);
    await saveSavings(items);
  }
}
