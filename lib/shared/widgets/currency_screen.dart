import 'package:flutter/material.dart';
import '../api/currency_service.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final service = CurrencyService.create();

  Map<String, dynamic>? rates;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRates();
  }

  Future<void> loadRates() async {
    final response = await service.getRates();

    setState(() {
      rates = response.body['rates'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Rates'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                buildRateCard('KZT'),
                buildRateCard('EUR'),
                buildRateCard('RUB'),
                buildRateCard('GBP'),
              ],
            ),
    );
  }

  Widget buildRateCard(String currency) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        title: Text(currency),
        subtitle: Text(
          rates![currency].toString(),
        ),
      ),
    );
  }
}