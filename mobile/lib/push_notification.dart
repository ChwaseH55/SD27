// import 'package:flutter/cupertino.dart';
// import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
// import 'package:provider/provider.dart';


// class PushNotification {
//   static Future<String> getAccessToken() async {
//     final serviceAccountJson = {
//       "type": "service_account",
//       "project_id": "flutter-ucf-golf-club",
//       "private_key_id": "47f7407211fded542baf0d06c35b9b049b0c260f",
//       "private_key":
//           "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDLbzDwM9qvQygt\nl0rGTTQfnt669qcrJ93gPiEbpKjVwxKVYBefBV1XMU69TbcQJD52+E+XiCBxE13t\npUQW0kWo9h3bmGqoOKJtHJxK4TMgXowJiwROmM7sRmBSxYiSZZ8jFWlHaJsbk7mf\nbAZ8J+THlK3KaIcO62aeSEh5NFqOsW1LoTYgkgRuUShlkPfmvfXDvln/ba04TURk\n8L+8gHPAWstWh6HtuEWrffCa99PIyKDjeUXzX7kz4hnQyAEnY5GwzGxf7DiyD64v\nWI1BQn1IJGD8/rMRKpGHa2SJL58uGpzCPUF3OZZffX3CCDBC5ZC2zaQc2zs7Gxhv\n6sYmz3tJAgMBAAECggEALlr0Xk+ajaQyZA0c60nNTkU/wH+SwQkxDDdsCOYA2NC+\nC86dI02wIr2oEQfD5ogzuZ1EWaWZqtp8ZTnq5X5dhC4syIyXBST+kflafc+J/F6+\n7y+/t/8m63zv1vyO7bj9RZvL5QsniOWk/vg5FBJtFbNB1KTz3YjzVa7n4MJ2vhu0\nc0uoEcqUmGYsjBUocze4ofxgQQzlphiU54LSyx3iWVXUQxiOcM8SoBMSe74Nkfxv\nT9mKztcTkW+t5+ovXUA6I7LHvGwY07jz7vTB54rHAlwx+RZerOHGM9LElJDhNH4r\nrpWTMM/7ir3p8uJVutJAieEwbskxYigIVbz3P6CXdwKBgQD6rdkUAot9sozgK2CR\np/PBm0m+dB/2e9WgdFjHEUGtT+kY0JcrOAdgL4qCE474FdCRY0xbHB+ggCksjxA+\n6ZqP0MrzzxomlgHkbEoQ29Oefw56qkjX6G5p/sVgMuvcBh+wvXzRFTEUftzGB4Jx\nUogympa2UD5PVr7nVrVqOm8quwKBgQDPwJ9WBrNIkOE2GDNAymn3pkG9vrqeJSmH\norx/Ri+n6beEjEA8idTNiInvTs3MJDaeGwt4JCm1scFa6H0Zr+tjib7HTpwiuVMP\nGNXQjZHMLL2thkucI2vvEp8ri4t3KAZwVqNIfm+HV5TebE3eDNj6KoztpTm9Wi7g\nE90Duza7ywKBgF3ZqGPtb/vnVQa4NrdRgdkCImHDaBQH2Lrx1CrzMvuH52T68x2j\nJF/GbLy2RdhrkmJcIsIZjV2xnbio9xQWsV8WdGVDLC82Cg9S24fkRR4Zw3n5Nrxe\nsLfOQmb5qYP+Zu7sgkZlALMDq/QX66Yxl/waFEK9WBasC1zhAZp7thLxAoGAWzhQ\nvg0jG3HB8Wae2owGC19M7muYtWfL3GpwKdI/ipLsqZ6LdglvDvAs4I7RfhlIghON\n7aqzRbxPEgOTKnw79vC8e/bgR77n4XEeMPx4UBY1EsQs3toOwmKC0TPsgN1qNllU\nSLh7cAncq+0SI7Wwb+fPCWnK+IFoo6sVGFZTqhECgYA0dEfXp0oRTWXJ5Cn8WmRL\nl84DvxZFkUDL09694YxJQbnInfJoI5TT4pMMA4tNO4UnzKWqmrC+VP9CYpd3Fzxl\nWmG51npnNWeMYsDbsoBYs0yNfgidV7DHip6QRSLh00YVkjfZ5NWKpg1+ygB8Y7jq\nIXv0FGSBHCoeLNvzTKBJwQ==\n-----END PRIVATE KEY-----\n",
//       "client_email":
//           "flutter-ucf-golf-club@flutter-ucf-golf-club.iam.gserviceaccount.com",
//       "client_id": "110143933776246905777",
//       "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//       "token_uri": "https://oauth2.googleapis.com/token",
//       "auth_provider_x509_cert_url":
//           "https://www.googleapis.com/oauth2/v1/certs",
//       "client_x509_cert_url":
//           "https://www.googleapis.com/robot/v1/metadata/x509/flutter-ucf-golf-club%40flutter-ucf-golf-club.iam.gserviceaccount.com",
//       "universe_domain": "googleapis.com"
//     };

//     List<String> scopes = [
//       "https://www.googleapis.com/auth/firebase.messaging",
//       "https://www.googleapis.com/auth/firebase.database",
//       "https://www.googleapis.com/auth/userinfo.email"
//     ];

//     http.Client client = await auth.clientViaServiceAccount(
//         auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

//     //get the access token
//     auth.AccessCredentials credentials =
//         await auth.obtainAccessCredentialsViaServiceAccount(
//             auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
//             scopes,
//             client);

//             client.close();

//             return credentials.accessToken.data;
//   }

//   static sendNotificationToSelectedDriver(String deviceToken, BuildContext context, String tripID) async {
//     String dropOffDestinationAddress = Provider.of<AppInfo>(context, listen: false).dropOffLocation!.placeName.toString();
//     String pickUpAddress = Provider.of<AppInfo>(context, listen: false).pickUpLocation!.placeName.toString();

//     final String serverKey = await getAccessToken();
//     String endpointFirebaseCloundMessaging = 'https://fcm.googleapis.com/v1/projects/flutter-ucf-golf-club/messages:send';

//     final Map<String, dynamic> message = 
//     {
//       'message':
//       {
//         'token': deviceToken,
//         'notification':
//         {
//           'title': "",
//           'body': ""
//         }
//       }
//     };
//   }
// }
