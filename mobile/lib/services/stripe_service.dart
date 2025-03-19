import 'package:coffee_card/constants.dart';
import 'package:dio/dio.dart';

class StripeService
{
  StripeService._();


  static final StripeService instance = StripeService._();

  Future<void> makePayment() async
  {
    try {

      String? result = await _createPaymentIntent(10, "usd");
    } catch (e) 
    {
      print(e);
    }
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async //Needs to be created on servcr-side this is not secure! Only used this to test
  {
    try 
    { 
      final Dio dio = Dio();
      Map<String, dynamic> data = { 
        "amount": _calculateAmount(amount), //in cents
        "currency": currency,
      };
      
      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType, headers: {
            "Authorization" : "Bearer $stripeSecretKey",
            "Content-Type": 'application/x-www-form-urlencoded'
            },
          )
          );
          if(response.data != null) {
            print(response.data);
            return "";
          }
          return null;
          
    } catch(e) {
      print(e); };

      return null;
  }

  String _calculateAmount(int amount) {
    final calculatedAmount = amount * 100;
    return calculatedAmount.toString();
  }
}