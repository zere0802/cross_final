// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'currency_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$CurrencyService extends CurrencyService {
  _$CurrencyService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = CurrencyService;

  @override
  Future<Response<dynamic>> getRates() {
    final Uri $url = Uri.parse('/v4/latest/USD');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}
