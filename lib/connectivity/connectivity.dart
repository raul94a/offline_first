import 'dart:io';
class Connectivity {
  static final instance = Connectivity._();


  Connectivity._();


  Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException{
      return false;
    }
  }
}