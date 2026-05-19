import 'package:chopper/chopper.dart';

part 'currency_service.chopper.dart';

@ChopperApi()
abstract class CurrencyService extends ChopperService {
  static CurrencyService create() {
    final client = ChopperClient(
      baseUrl: Uri.parse('https://api.exchangerate-api.com'),
      services: [
        _$CurrencyService(),
      ],
      converter: const JsonConverter(),
    );

    return _$CurrencyService(client);
  }

  @GET(path: '/v4/latest/USD')
  Future<Response> getRates();
}