import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final currencyProvider =
    StateNotifierProvider<CurrencyNotifier, String>((ref) => CurrencyNotifier());

class CurrencyNotifier extends StateNotifier<String> {
  CurrencyNotifier() : super('USD') {
    loadCurrency();
  }

  Future<void> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('selectedCurrency') ?? 'USD';
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    state = currency;
    await prefs.setString('selectedCurrency', currency);
  }
}
